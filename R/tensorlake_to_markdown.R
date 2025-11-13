#' Convert Tensorlake Result to Markdown
#'
#' Convert a Tensorlake parsing result to well-formatted Markdown, preserving
#' document structure including headers, text, tables, and figures.
#'
#' @param result List. The result object from tensorlake_ocr() or tensorlake_get_parse_result().
#' @param pages Integer vector. Optional page numbers to convert. Default is NULL (all pages).
#' @param include_page_breaks Logical. Include page break markers in output. Default is TRUE.
#' @param include_headers Logical. Include page headers in output. Default is FALSE.
#' @param include_footers Logical. Include page footers/numbers in output. Default is FALSE.
#'
#' @return Character string containing the Markdown-formatted document.
#'
#' @examples
#' \dontrun{
#' result <- tensorlake_ocr("document.pdf")
#'
#' # Convert to markdown
#' markdown <- tensorlake_to_markdown(result)
#' cat(markdown)
#'
#' # Save to file
#' writeLines(markdown, "document.md")
#'
#' # Convert only first 5 pages without page breaks
#' markdown <- tensorlake_to_markdown(result, pages = 1:5, include_page_breaks = FALSE)
#' }
#'
#' @export
tensorlake_to_markdown <- function(result,
                                    pages = NULL,
                                    include_page_breaks = TRUE,
                                    include_headers = FALSE,
                                    include_footers = FALSE) {

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

  # Process each page
  markdown_parts <- list()

  for (i in seq_along(all_pages)) {
    page <- all_pages[[i]]
    page_num <- page_numbers[i]

    if (is.null(page$page_fragments)) {
      next
    }

    # Add page break if requested
    if (include_page_breaks && i > 1) {
      markdown_parts[[length(markdown_parts) + 1]] <- "\n\n---\n\n"
      markdown_parts[[length(markdown_parts) + 1]] <- paste0("**Page ", page_num, "**\n\n")
    }

    # Sort fragments by reading order
    sorted_fragments <- page$page_fragments[order(sapply(page$page_fragments,
                                                         function(f) f$reading_order %||% 0))]

    # Process each fragment
    for (frag in sorted_fragments) {
      frag_type <- frag$fragment_type %||% "unknown"
      content <- frag$content$content %||% ""

      # Skip empty content
      if (content == "") {
        next
      }

      # Skip headers/footers if not requested
      if (!include_headers && frag_type == "page_header") {
        next
      }
      if (!include_footers && frag_type %in% c("page_number", "page_footer")) {
        next
      }

      # Format based on fragment type
      formatted <- switch(frag_type,
        "section_header" = paste0("## ", content, "\n\n"),
        "page_header" = if (include_headers) paste0("*", content, "*\n\n") else "",
        "page_number" = if (include_footers) paste0("*", content, "*\n\n") else "",
        "page_footer" = if (include_footers) paste0("*", content, "*\n\n") else "",
        "table_caption" = paste0("**", content, "**\n\n"),
        "figure_caption" = paste0("*Figure: ", content, "*\n\n"),
        "table" = {
          # Use HTML table if available, otherwise format as code block
          if (!is.null(frag$content$html)) {
            paste0(frag$content$html, "\n\n")
          } else {
            paste0("```\n", content, "\n```\n\n")
          }
        },
        "figure" = paste0("*[Figure]*\n\n"),
        # Default: regular text
        paste0(content, "\n\n")
      )

      markdown_parts[[length(markdown_parts) + 1]] <- formatted
    }
  }

  # Combine all parts
  markdown <- paste(unlist(markdown_parts), collapse = "")

  # Clean up excessive newlines
  markdown <- gsub("\n{3,}", "\n\n", markdown)

  return(markdown)
}
