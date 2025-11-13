#' Extract Text from Tensorlake Result
#'
#' Extract all text content from a Tensorlake parsing result, organized by page.
#'
#' @param result List. The result object from tensorlake_ocr() or tensorlake_get_parse_result().
#' @param pages Integer vector. Optional page numbers to extract. Default is NULL (all pages).
#' @param collapse Character string. String to use when collapsing text fragments. Default is " ".
#'
#' @return Character vector with one element per page, or a single collapsed string if collapse is not NULL.
#'
#' @examples
#' \dontrun{
#' result <- tensorlake_ocr("document.pdf")
#'
#' # Get all text as character vector (one element per page)
#' text_by_page <- tensorlake_extract_text(result)
#'
#' # Get text from specific pages
#' first_two_pages <- tensorlake_extract_text(result, pages = 1:2)
#'
#' # Get all text as single string
#' full_text <- tensorlake_extract_text(result, collapse = "\n\n")
#' }
#'
#' @export
tensorlake_extract_text <- function(result, pages = NULL, collapse = " ") {

  if (is.null(result$pages)) {
    stop("Result does not contain 'pages' field", call. = FALSE)
  }

  # Filter pages if specified
  all_pages <- result$pages
  if (!is.null(pages)) {
    all_pages <- all_pages[pages]
  }

  # Extract text from each page
  page_texts <- sapply(all_pages, function(page) {
    if (is.null(page$page_fragments)) {
      return("")
    }

    # Get text from all fragments
    fragments <- sapply(page$page_fragments, function(frag) {
      if (!is.null(frag$content$content)) {
        return(frag$content$content)
      }
      return("")
    })

    # Collapse fragments for this page
    paste(fragments, collapse = collapse)
  }, USE.NAMES = FALSE)

  return(page_texts)
}


#' Extract Tables from Tensorlake Result
#'
#' Extract all table data from a Tensorlake parsing result.
#'
#' @param result List. The result object from tensorlake_ocr() or tensorlake_get_parse_result().
#' @param pages Integer vector. Optional page numbers to extract tables from. Default is NULL (all pages).
#'
#' @return List of lists, where each element contains:
#'   \describe{
#'     \item{page_number}{Page number where table was found}
#'     \item{reading_order}{Reading order position on page}
#'     \item{content}{Plain text representation of table}
#'     \item{html}{HTML representation of table}
#'     \item{markdown}{Markdown representation of table}
#'     \item{summary}{AI-generated summary of table content}
#'     \item{cells}{Structured cell data}
#'     \item{bbox}{Bounding box coordinates}
#'   }
#'
#' @examples
#' \dontrun{
#' result <- tensorlake_ocr("document.pdf")
#'
#' # Get all tables
#' tables <- tensorlake_extract_tables(result)
#'
#' # Get tables from specific pages
#' page1_tables <- tensorlake_extract_tables(result, pages = 1)
#' }
#'
#' @export
tensorlake_extract_tables <- function(result, pages = NULL) {

  if (is.null(result$pages)) {
    stop("Result does not contain 'pages' field", call. = FALSE)
  }

  # Filter pages if specified
  all_pages <- result$pages
  page_numbers <- seq_along(all_pages)

  if (!is.null(pages)) {
    all_pages <- all_pages[pages]
    page_numbers <- pages
  }

  # Extract tables from each page
  tables <- list()

  for (i in seq_along(all_pages)) {
    page <- all_pages[[i]]
    page_num <- page_numbers[i]

    if (is.null(page$page_fragments)) {
      next
    }

    # Find table fragments
    for (frag in page$page_fragments) {
      if (!is.null(frag$fragment_type) && frag$fragment_type == "table") {
        tables[[length(tables) + 1]] <- list(
          page_number = page_num,
          reading_order = frag$reading_order,
          content = frag$content$content,
          html = frag$content$html,
          markdown = frag$content$markdown,
          summary = frag$content$summary,
          cells = frag$content$cells,
          bbox = frag$bbox
        )
      }
    }
  }

  return(tables)
}


#' Extract Metadata from Tensorlake Result
#'
#' Extract document metadata and statistics from a Tensorlake parsing result.
#'
#' @param result List. The result object from tensorlake_ocr() or tensorlake_get_parse_result().
#'
#' @return List containing:
#'   \describe{
#'     \item{parse_id}{Unique parse job identifier}
#'     \item{status}{Parse job status}
#'     \item{total_pages}{Total number of pages in document}
#'     \item{parsed_pages_count}{Number of pages successfully parsed}
#'     \item{created_at}{Timestamp when parse job was created}
#'     \item{finished_at}{Timestamp when parse job completed}
#'     \item{processing_time}{Time taken to process (in seconds)}
#'     \item{usage}{API usage statistics}
#'   }
#'
#' @examples
#' \dontrun{
#' result <- tensorlake_ocr("document.pdf")
#' metadata <- tensorlake_extract_metadata(result)
#'
#' cat("Processed", metadata$total_pages, "pages in",
#'     metadata$processing_time, "seconds\n")
#' }
#'
#' @export
tensorlake_extract_metadata <- function(result) {

  # Calculate processing time if timestamps available
  processing_time <- NULL
  if (!is.null(result$created_at) && !is.null(result$finished_at)) {
    created <- as.POSIXct(result$created_at, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
    finished <- as.POSIXct(result$finished_at, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
    processing_time <- as.numeric(difftime(finished, created, units = "secs"))
  }

  list(
    parse_id = result$parse_id,
    status = result$status,
    total_pages = result$total_pages,
    parsed_pages_count = result$parsed_pages_count,
    created_at = result$created_at,
    finished_at = result$finished_at,
    processing_time = processing_time,
    usage = result$usage
  )
}
