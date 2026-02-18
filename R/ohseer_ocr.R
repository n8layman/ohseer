#' Unified OCR Interface for Multiple Providers with Automatic Fallback
#'
#' A unified wrapper function that provides a consistent interface across different
#' OCR providers (Tensorlake, Mistral, Claude). This function normalizes parameter
#' names and return structures, making it easier to switch between providers or
#' implement provider fallback logic.
#'
#' @author Nathan C. Layman
#'
#' @param file_path Character string. Path to the PDF file to process.
#' @param provider Character vector. OCR provider(s) to use. Can be a single provider
#'   or multiple providers for automatic fallback. Valid values:
#'   \describe{
#'     \item{"tensorlake"}{Tensorlake OCR API (default) - Highest accuracy (91.7\%)}
#'     \item{"mistral"}{Mistral OCR 3 - Lower cost, native markdown format}
#'     \item{"claude"}{Claude Opus/Sonnet - Structured outputs with JSON schema}
#'   }
#'   When multiple providers are specified, they will be tried sequentially until
#'   one succeeds. Default is \code{c("tensorlake")}.
#' @param pages Integer vector. Specific page numbers to process. If NULL (default),
#'   processes all pages. Page numbers are 1-based.
#' @param timeout Numeric. Maximum wait time in seconds for OCR processing.
#'   Default is 60 seconds. Not used for Claude provider.
#' @param extract_pages Logical. If TRUE (default), automatically extracts and
#'   returns page data using provider-specific extraction functions. If FALSE,
#'   returns raw API response.
#' @param ... Additional provider-specific arguments passed to the underlying
#'   OCR function:
#'   \describe{
#'     \item{Tensorlake}{\code{model}, \code{use_cache}, etc.}
#'     \item{Mistral}{\code{extract_header}, \code{extract_footer}, \code{table_format}, etc.}
#'     \item{Claude}{\code{model}, \code{max_tokens}, \code{dpi}, \code{schema}, etc.}
#'   }
#'
#' @return If \code{extract_pages = TRUE} (default), returns a list with:
#'   \describe{
#'     \item{provider}{Character string naming the provider that succeeded}
#'     \item{pages}{List of extracted page data (structure varies by provider)}
#'     \item{raw}{Raw API response (for advanced use)}
#'     \item{error_log}{Character string (JSON) of failed attempts, or NA if first provider succeeded}
#'   }
#'
#'   If \code{extract_pages = FALSE}, returns the raw provider API response.
#'
#' @section Provider-Specific Output Formats:
#'
#' Each provider returns pages in a different native format:
#'
#' \strong{Tensorlake} - Structured fragments:
#' \itemize{
#'   \item \code{page_number}: Integer (1-based)
#'   \item \code{page_fragments}: List of content fragments with type, content, reading_order
#' }
#'
#' \strong{Mistral} - Native markdown format:
#' \itemize{
#'   \item \code{index}: Integer (0-based)
#'   \item \code{markdown}: Full page content
#'   \item \code{tables}: Array of table objects
#'   \item \code{header}, \code{footer}: Separate header/footer fields
#' }
#'
#' \strong{Claude} - Structured output (Tensorlake-compatible by default):
#' \itemize{
#'   \item \code{page_number}: Integer (1-based)
#'   \item \code{page_fragments}: List of content fragments
#'   \item Custom schema can be provided via \code{schema} argument
#' }
#'
#' @section Provider Fallback:
#'
#' When multiple providers are specified, they are tried sequentially until one succeeds:
#'
#' \preformatted{
#' # Try Mistral first (lower cost), fall back to Tensorlake (higher quality)
#' result <- ohseer_ocr("document.pdf", provider = c("mistral", "tensorlake"))
#'
#' # Try Tensorlake first (higher quality), fall back to Mistral (lower cost)
#' result <- ohseer_ocr("document.pdf", provider = c("tensorlake", "mistral"))
#'
#' # Check which provider succeeded
#' message("Used provider: ", result$provider)
#'
#' # Check error log if any providers failed
#' if (!is.na(result$error_log)) {
#'   errors <- jsonlite::fromJSON(result$error_log)
#'   print(errors)
#' }
#' }
#'
#' @examples
#' \dontrun{
#' # Basic usage with default provider (Tensorlake)
#' result <- ohseer_ocr("document.pdf")
#'
#' # Use Mistral OCR with header/footer extraction
#' result <- ohseer_ocr(
#'   "document.pdf",
#'   provider = "mistral",
#'   extract_header = TRUE,
#'   extract_footer = TRUE
#' )
#'
#' # Use Claude with custom model and page selection
#' result <- ohseer_ocr(
#'   "document.pdf",
#'   provider = "claude",
#'   pages = c(1, 2),
#'   model = "claude-sonnet-4-5"
#' )
#'
#' # Provider fallback: try Mistral first, fall back to Tensorlake
#' result <- ohseer_ocr("document.pdf", provider = c("mistral", "tensorlake"))
#'
#' # Quality-first: try Tensorlake first, fall back to Mistral
#' result <- ohseer_ocr("document.pdf", provider = c("tensorlake", "mistral"))
#'
#' # Full fallback chain
#' result <- ohseer_ocr(
#'   "document.pdf",
#'   provider = c("tensorlake", "mistral", "claude")
#' )
#'
#' # Access results
#' pages <- result$pages
#' provider_used <- result$provider
#' }
#'
#' @seealso
#' Provider-specific functions:
#' \itemize{
#'   \item \code{\link{tensorlake_ocr}}, \code{\link{tensorlake_extract_pages}}
#'   \item \code{\link{mistral_ocr}}, \code{\link{mistral_extract_pages}}
#'   \item \code{\link{claude_ocr_process_file}}, \code{\link{claude_extract_pages}}
#' }
#'
#' @export
ohseer_ocr <- function(file_path,
                      provider = c("tensorlake", "mistral", "claude"),
                      pages = NULL,
                      timeout = 60,
                      extract_pages = TRUE,
                      ...) {

  # Validate inputs
  if (!file.exists(file_path)) {
    stop("File not found: ", file_path, call. = FALSE)
  }

  # Ensure provider is a character vector
  if (!is.character(provider) || length(provider) == 0) {
    stop("provider must be a non-empty character vector", call. = FALSE)
  }

  # Validate all providers
  valid_providers <- c("tensorlake", "mistral", "claude")
  invalid <- provider[!provider %in% valid_providers]
  if (length(invalid) > 0) {
    stop("Invalid provider(s): ", paste(invalid, collapse = ", "),
         "\nValid providers: ", paste(valid_providers, collapse = ", "),
         call. = FALSE)
  }

  # Filter to providers with API keys available, warn about skipped ones
  providers_to_try <- check_api_keys_for_providers(provider)

  if (length(providers_to_try) == 0) {
    stop("No providers with valid API keys. Set environment variables:\n",
         "  - TENSORLAKE_API_KEY\n",
         "  - MISTRAL_API_KEY\n",
         "  - ANTHROPIC_API_KEY",
         call. = FALSE)
  }

  # Track errors for fallback
  errors <- list()

  # Try each provider with available API key sequentially
  for (prov in providers_to_try) {
    result <- tryCatch({
      # Get provider-specific result
      # Note: Provider functions read API keys from environment variables
      raw_result <- switch(
        prov,

        "tensorlake" = {
          tensorlake_ocr(
            file_path = file_path,
            pages = pages,
            max_wait_seconds = timeout,
            ...
          )
        },

        "mistral" = {
          mistral_ocr(
            input = file_path,
            timeout = timeout,
            ...
          )
        },

        "claude" = {
          claude_ocr_process_file(
            file_path = file_path,
            pages = pages,
            ...
          )
        },

        stop("Unknown provider: ", prov, call. = FALSE)
      )

      # Extract pages if requested
      if (extract_pages) {
        extracted_pages <- switch(
          prov,
          "tensorlake" = tensorlake_extract_pages(raw_result, pages = pages),
          "mistral" = mistral_extract_pages(raw_result, pages = pages),
          "claude" = claude_extract_pages(raw_result, pages = pages),
          stop("Unknown provider: ", prov, call. = FALSE)
        )

        # Success - return with error log
        message("OCR completed successfully using ", prov)

        # Convert error log to JSON (NA if no errors)
        error_log_json <- if (length(errors) > 0) {
          jsonlite::toJSON(errors, auto_unbox = TRUE)
        } else {
          NA_character_
        }

        return(list(
          provider = prov,
          pages = extracted_pages,
          raw = raw_result,
          error_log = error_log_json
        ))
      } else {
        # Return raw response without error tracking
        return(raw_result)
      }

    }, error = function(e) {
      # Store error for audit log
      message("OCR failed with ", prov, ": ", conditionMessage(e))

      errors[[prov]] <<- list(
        error = conditionMessage(e),
        timestamp = Sys.time()
      )

      NULL  # Return NULL to trigger next provider
    })

    # If we got a result, it was already returned above
    # If NULL, continue to next provider
  }

  # If we get here, all providers failed
  error_msg <- paste0(
    "All OCR providers failed for: ", basename(file_path), "\n",
    "Providers attempted: ", paste(provider, collapse = ", ")
  )

  # Add error details
  if (length(errors) > 0) {
    error_msg <- paste0(
      error_msg, "\n\nErrors:\n",
      paste(sapply(names(errors), function(p) {
        sprintf("  - %s: %s", p, errors[[p]]$error)
      }), collapse = "\n")
    )
  }

  stop(error_msg, call. = FALSE)
}


#' Check API Keys for Providers
#'
#' Internal function to filter providers to only those with API keys available.
#' Warns about skipped providers but allows cascade to continue.
#'
#' @param providers Character vector of provider names
#' @return Character vector of providers that have API keys
#' @keywords internal
check_api_keys_for_providers <- function(providers) {
  available <- character()
  skipped <- character()

  for (prov in providers) {
    env_var <- switch(
      prov,
      "tensorlake" = "TENSORLAKE_API_KEY",
      "mistral" = "MISTRAL_API_KEY",
      "claude" = "ANTHROPIC_API_KEY",
      stop("Unknown provider: ", prov)
    )

    if (Sys.getenv(env_var) != "") {
      available <- c(available, prov)
    } else {
      skipped <- c(skipped, paste0(prov, " (", env_var, " not set)"))
    }
  }

  # Warn about skipped providers
  if (length(skipped) > 0) {
    warning(
      "Skipping providers without API keys: ", paste(skipped, collapse = ", "), "\n",
      "Set environment variables to enable these providers.",
      call. = FALSE,
      immediate. = TRUE
    )
  }

  return(available)
}
