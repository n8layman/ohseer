#' Extract Page Content from Mistral OCR Results
#'
#' Returns Mistral's native page output. Each page includes markdown text, tables,
#' images, headers, footers, and dimensional information.
#'
#' @author Nathan C. Layman
#'
#' @param result List. The parsed response from mistral_ocr().
#' @param pages Integer vector. Page numbers to extract. If NULL (default), extracts all pages.
#'
#' @return List with one element per page. Each page contains Mistral's native format:
#'   \describe{
#'     \item{index}{Integer page index (0-based)}
#'     \item{markdown}{Character string with page content in markdown format}
#'     \item{header}{Character string with page header (if extract_header=TRUE)}
#'     \item{footer}{Character string with page footer (if extract_footer=TRUE)}
#'     \item{tables}{List of tables with id, content, and format fields}
#'     \item{images}{List of images extracted from page}
#'     \item{hyperlinks}{List of hyperlinks detected}
#'     \item{dimensions}{Page dimensions (width, height)}
#'   }
#'
#' @examples
#' \dontrun{
#' # Process document with Mistral OCR 3
#' result <- mistral_ocr(
#'   "document.pdf",
#'   extract_header = TRUE,
#'   extract_footer = TRUE,
#'   table_format = "markdown"
#' )
#'
#' # Extract all pages
#' pages <- mistral_extract_pages(result)
#'
#' # Extract specific pages
#' first_two <- mistral_extract_pages(result, pages = c(1, 2))
#'
#' # Access page content
#' page1_text <- pages[[1]]$markdown
#' page1_tables <- pages[[1]]$tables
#' }
#'
#' @export
mistral_extract_pages <- function(result,
                                   pages = NULL) {

  # Extract pages from result
  if (!is.null(result$pages)) {
    all_pages <- result$pages
  } else {
    stop("Invalid result structure: no pages found.", call. = FALSE)
  }

  # Filter to requested pages if specified
  if (!is.null(pages)) {
    # Validate page numbers
    invalid_pages <- pages[pages < 1 | pages > length(all_pages)]
    if (length(invalid_pages) > 0) {
      warning("Page(s) ", paste(invalid_pages, collapse = ", "),
              " not found in result. Skipping.", call. = FALSE)
    }

    # Filter to valid requested pages
    valid_pages <- pages[pages >= 1 & pages <= length(all_pages)]
    all_pages <- all_pages[valid_pages]
  }

  return(all_pages)
}
