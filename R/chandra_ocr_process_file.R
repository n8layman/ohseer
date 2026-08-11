#' Process Document with Chandra OCR (Datalab)
#'
#' Submits a document to Datalab's document conversion API, which is powered by
#' the Chandra OCR model, and polls until the result is ready. Chandra is
#' academic-document oriented: it handles complex tables, equations, forms and
#' handwriting, and extracts figures/images as files. Output is returned as
#' paginated markdown plus a dictionary of extracted images.
#'
#' The Datalab API is asynchronous: this function POSTs the file, then polls the
#' returned check URL until \code{status == "complete"}. Results are deleted from
#' Datalab's servers one hour after completion.
#'
#' @author Nathan C. Layman
#'
#' @param file_path Character string. Path to a local PDF, PNG, JPEG, or other
#'   supported document.
#' @param api_key Character string. Datalab API key, sent in the \code{X-Api-Key}
#'   header. Default retrieves from environment variable "DATALAB_API_KEY".
#' @param output_format Character string. One of "markdown" (default), "html",
#'   "json", or "chunks".
#' @param mode Character string. Quality/speed tradeoff: "fast", "balanced"
#'   (default), or "accurate".
#' @param use_llm Logical. If TRUE, use an LLM pass to improve accuracy on tables,
#'   forms, and inline math (higher cost). Default is FALSE.
#' @param langs Character string. Optional comma-separated OCR language hints
#'   (e.g. "English"). Default is NULL (auto).
#' @param max_pages Integer. Optional cap on pages processed. Default is NULL.
#' @param endpoint Character string. Datalab convert endpoint. Default is
#'   "https://www.datalab.to/api/v1/convert".
#' @param timeout Numeric. Maximum seconds to wait for the async job. Default is 300.
#' @param poll_interval Numeric. Seconds between status polls. Default is 2.
#'
#' @return A list mirroring the other providers, containing
#'   \code{structured_output} with the raw \code{markdown} (paginated),
#'   \code{output_format}, \code{page_count}, \code{images} (named list of
#'   base64 strings), and \code{metadata}.
#'
#' @keywords internal
#'
#' @importFrom httr2 request req_headers req_body_multipart req_perform resp_body_json
#' @importFrom curl form_file
chandra_ocr_process_file <- function(file_path,
                                     api_key = Sys.getenv("DATALAB_API_KEY"),
                                     output_format = "markdown",
                                     mode = "balanced",
                                     use_llm = FALSE,
                                     langs = NULL,
                                     max_pages = NULL,
                                     endpoint = "https://www.datalab.to/api/v1/convert",
                                     timeout = 300,
                                     poll_interval = 2) {

  if (is.null(api_key) || api_key == "") {
    stop("API key not found. Please set the DATALAB_API_KEY environment variable ",
         "or provide it as a parameter.", call. = FALSE)
  }

  if (is.null(file_path) || !file.exists(file_path)) {
    stop("File not found: ", file_path, call. = FALSE)
  }

  api_key <- stringr::str_squish(api_key)

  # Build multipart body (Datalab expects form fields, booleans as strings)
  body <- list(
    file = curl::form_file(file_path),
    output_format = output_format,
    mode = mode,
    use_llm = tolower(as.character(isTRUE(use_llm)))
  )
  if (!is.null(langs)) body$langs <- langs
  if (!is.null(max_pages)) body$max_pages <- as.character(max_pages)

  message("Submitting document to Chandra (Datalab)...")
  submit <- tryCatch({
    httr2::request(endpoint) |>
      httr2::req_headers("X-Api-Key" = api_key) |>
      httr2::req_body_multipart(!!!body) |>
      httr2::req_perform() |>
      httr2::resp_body_json()
  }, error = function(e) {
    stop("Chandra submission failed: ", conditionMessage(e), call. = FALSE)
  })

  if (!isTRUE(submit$success)) {
    stop("Chandra submission was rejected: ",
         submit$error %||% "unknown error", call. = FALSE)
  }

  check_url <- submit$request_check_url
  if (is.null(check_url) || check_url == "") {
    stop("Chandra did not return a request_check_url.", call. = FALSE)
  }

  # Poll until the job completes or we exceed the timeout
  message("Waiting for Chandra to finish (request ", submit$request_id %||% "?", ")...")
  deadline <- Sys.time() + timeout
  result <- NULL

  repeat {
    result <- tryCatch({
      httr2::request(check_url) |>
        httr2::req_headers("X-Api-Key" = api_key) |>
        httr2::req_perform() |>
        httr2::resp_body_json()
    }, error = function(e) {
      stop("Chandra status poll failed: ", conditionMessage(e), call. = FALSE)
    })

    status <- result$status %||% "unknown"

    if (identical(status, "complete")) break

    if (!is.null(result$error) && nzchar(result$error)) {
      stop("Chandra processing failed: ", result$error, call. = FALSE)
    }

    if (Sys.time() > deadline) {
      stop("Chandra timed out after ", timeout, " seconds (last status: ",
           status, ").", call. = FALSE)
    }

    Sys.sleep(poll_interval)
  }

  if (!isTRUE(result$success)) {
    stop("Chandra completed but reported failure: ",
         result$error %||% "unknown error", call. = FALSE)
  }

  message("Chandra processing complete.")

  # The converted content lives in a field named after the output format
  content <- result[[output_format]] %||% result$markdown %||% ""

  list(
    request_id = submit$request_id,
    structured_output = list(
      markdown = content,
      output_format = output_format,
      page_count = result$page_count %||% NA_integer_,
      images = result$images %||% list(),
      metadata = result$metadata %||% list()
    )
  )
}
