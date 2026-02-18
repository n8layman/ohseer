#' Extract Page Content from Claude OCR Results
#'
#' Transforms Claude OCR output to match Tensorlake's page format.
#' Returns a list structure compatible with ecoextract and other downstream tools.
#'
#' @author Nathan C. Layman
#'
#' @param result List. The parsed response from claude_ocr().
#' @param pages Integer vector. Page numbers to extract. If NULL (default), extracts all pages.
#' @param exclude_types Character vector. Fragment types to exclude. Default is
#'   character(0) (no exclusions).
#'
#' @return List with one element per page, each containing:
#'   \describe{
#'     \item{page_number}{Integer page number}
#'     \item{page_header}{Character vector of page_header contents}
#'     \item{section_header}{Character vector of section_header contents}
#'     \item{text}{Character string with all text in markdown format}
#'     \item{tables}{List of tables, each with markdown, html, content, and summary fields}
#'     \item{other}{List of other elements with type and content}
#'   }
#'
#' @examples
#' \dontrun{
#' # Process document with Claude
#' result <- claude_ocr("document.pdf")
#'
#' # Extract pages in Tensorlake-compatible format
#' pages <- claude_extract_pages(result)
#'
#' # Extract specific pages
#' first_two <- claude_extract_pages(result, pages = c(1, 2))
#'
#' # Use with ecoextract
#' library(ecoextract)
#' json_content <- jsonlite::toJSON(pages, auto_unbox = TRUE)
#' }
#'
#' @export
claude_extract_pages <- function(result,
                                  pages = NULL,
                                  exclude_types = character(0)) {

  # Check if structured output is available
  if (!is.null(result$structured_output) && !is.null(result$structured_output$pages)) {
    all_pages <- result$structured_output$pages
  } else {
    stop("No structured output found in Claude result. The response may not have been parsed correctly.",
         call. = FALSE)
  }

  # Default to all pages if not specified
  if (is.null(pages)) {
    pages <- seq_along(all_pages)
  }

  output <- list()

  # Process each requested page
  for (page_num in pages) {
    if (page_num > length(all_pages)) {
      warning("Page ", page_num, " not found in result. Skipping.", call. = FALSE)
      next
    }

    page <- all_pages[[page_num]]

    # Ensure all required fields exist with defaults
    page_data <- list(
      page_number = page$page_number %||% page_num,
      page_header = page$page_header %||% character(0),
      section_header = page$section_header %||% character(0),
      text = page$text %||% "",
      tables = page$tables %||% list(),
      other = page$other %||% list()
    )

    # Ensure tables have all required fields
    if (length(page_data$tables) > 0) {
      page_data$tables <- lapply(page_data$tables, function(tbl) {
        list(
          content = tbl$content %||% "",
          markdown = tbl$markdown %||% "",
          html = tbl$html %||% "",
          summary = tbl$summary %||% ""
        )
      })
    }

    # Ensure other elements have required fields
    if (length(page_data$other) > 0) {
      page_data$other <- lapply(page_data$other, function(elem) {
        list(
          type = elem$type %||% "unknown",
          content = elem$content %||% ""
        )
      })
    }

    output[[length(output) + 1]] <- page_data
  }

  return(output)
}
