#' Extract Page Content by Fragment Type
#'
#' Extracts content from Tensorlake OCR results organized by fragment type.
#' Returns a simple list structure with fragments grouped by their Tensorlake-assigned
#' types (page_header, section_header, text, table, etc.).
#'
#' @author Nathan C. Layman
#'
#' @param result List. The parsed response from tensorlake_ocr().
#' @param pages Integer vector. Page numbers to extract (default is c(1, 2)).
#' @param exclude_types Character vector. Fragment types to exclude. Default is
#'   c("page_number", "page_footer").
#'
#' @return List with one element per page, each containing:
#'   \describe{
#'     \item{page_number}{Integer page number}
#'     \item{page_header}{Character vector of page_header fragment contents}
#'     \item{section_header}{Character vector of section_header fragment contents}
#'     \item{text}{Character string with all text fragments in markdown format}
#'     \item{tables}{List of tables, each with markdown, html, and content fields}
#'     \item{other}{List of other fragment types with type and content}
#'   }
#'
#' @examples
#' \dontrun{
#' result <- tensorlake_ocr("article.pdf")
#' pages <- tensorlake_extract_pages(result, pages = c(1, 2))
#'
#' # Access first page data
#' page1 <- pages[[1]]
#' page1$page_header     # Journal citation
#' page1$section_header  # Article title
#' page1$text           # Body text in markdown
#' page1$tables         # List of tables
#' }
#'
#' @export
tensorlake_extract_pages <- function(result,
                                     pages = c(1, 2),
                                     exclude_types = c("page_number", "page_footer")) {

  # Validate result structure
  if (is.null(result$pages)) {
    stop("Invalid result structure: no pages found.", call. = FALSE)
  }

  output <- list()

  # Process each requested page
  for (page_num in pages) {
    if (page_num > length(result$pages)) {
      warning("Page ", page_num, " not found in result. Skipping.", call. = FALSE)
      next
    }

    page <- result$pages[[page_num]]

    if (is.null(page$page_fragments)) {
      warning("No fragments found on page ", page_num, ". Skipping.", call. = FALSE)
      next
    }

    # Initialize page data structure
    page_data <- list(
      page_number = page_num,
      page_header = character(0),
      section_header = character(0),
      text = character(0),
      tables = list(),
      other = list()
    )

    # Collect fragments by type
    for (frag in page$page_fragments) {
      # Skip excluded types
      if (!is.null(frag$fragment_type) && frag$fragment_type %in% exclude_types) {
        next
      }

      frag_type <- frag$fragment_type %||% "unknown"
      content <- frag$content$content %||% ""

      if (frag_type == "page_header") {
        page_data$page_header <- c(page_data$page_header, content)
      } else if (frag_type == "section_header") {
        page_data$section_header <- c(page_data$section_header, content)
      } else if (frag_type == "text") {
        page_data$text <- c(page_data$text, content)
      } else if (frag_type == "table") {
        # Add table with all available formats
        table_data <- list(
          content = content,
          markdown = frag$content$markdown %||% "",
          html = frag$content$html %||% "",
          summary = frag$content$summary %||% ""
        )
        page_data$tables[[length(page_data$tables) + 1]] <- table_data
      } else {
        # Other fragment types
        page_data$other[[length(page_data$other) + 1]] <- list(
          type = frag_type,
          content = content
        )
      }
    }

    # Convert text array to markdown format (paragraphs separated by blank lines)
    if (length(page_data$text) > 0) {
      page_data$text <- paste(page_data$text, collapse = "\n\n")
    } else {
      page_data$text <- ""
    }

    output[[length(output) + 1]] <- page_data
  }

  return(output)
}
