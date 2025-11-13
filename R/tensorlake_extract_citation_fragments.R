#' Extract Citation Fragments from Tensorlake OCR Result
#'
#' Extracts the top-of-page citation metadata fragments (page headers, section headers,
#' and initial text fragments) from a Tensorlake OCR result. These fragments typically
#' contain journal information, article title, authors, and affiliations.
#'
#' @author Nathan C. Layman
#'
#' @param result List. The parsed response from tensorlake_ocr().
#' @param page_number Integer. Page number to extract from (default is 1).
#' @param max_fragments Integer. Maximum number of fragments to extract (default is 10).
#'   This captures the citation area without including the full article text.
#' @param format Character. Output format: "text" (plain text), "json" (structured JSON),
#'   or "markdown" (markdown formatted). Default is "text".
#' @param include_types Character vector. Fragment types to include. Default is
#'   c("page_header", "section_header", "text") which captures citation metadata.
#'
#' @return Depending on format parameter:
#'   \describe{
#'     \item{text}{Character string with concatenated fragment content}
#'     \item{json}{List with structured fragment data}
#'     \item{markdown}{Character string with markdown-formatted content}
#'   }
#'
#' @examples
#' \dontrun{
#' result <- tensorlake_ocr("article.pdf", pages = "1")
#'
#' # Get plain text for Claude
#' citation_text <- tensorlake_extract_citation_fragments(result)
#'
#' # Get structured JSON
#' citation_json <- tensorlake_extract_citation_fragments(result, format = "json")
#'
#' # Get markdown formatted
#' citation_md <- tensorlake_extract_citation_fragments(result, format = "markdown")
#' }
#'
#' @export
tensorlake_extract_citation_fragments <- function(result,
                                                   page_number = 1,
                                                   max_fragments = 10,
                                                   format = c("text", "json", "markdown"),
                                                   include_types = c("page_header", "section_header", "text")) {

  format <- match.arg(format)

  # Validate result structure
  if (is.null(result$pages) || length(result$pages) < page_number) {
    stop("Invalid result structure or page number out of range.", call. = FALSE)
  }

  page <- result$pages[[page_number]]

  if (is.null(page$page_fragments)) {
    stop("No page fragments found.", call. = FALSE)
  }

  # Extract first N fragments of specified types
  fragments <- list()
  for (i in seq_along(page$page_fragments)) {
    if (length(fragments) >= max_fragments) break

    frag <- page$page_fragments[[i]]

    # Check if fragment type matches
    if (!is.null(frag$fragment_type) && frag$fragment_type %in% include_types) {
      fragments[[length(fragments) + 1]] <- list(
        type = frag$fragment_type,
        reading_order = frag$reading_order,
        content = frag$content$content %||% "",
        html = frag$content$html %||% ""
      )
    }
  }

  if (length(fragments) == 0) {
    warning("No matching fragments found.", call. = FALSE)
    return(if (format == "json") list() else "")
  }

  # Format output
  if (format == "json") {
    return(fragments)
  } else if (format == "text") {
    # Concatenate all content with double newlines
    text_parts <- sapply(fragments, function(f) f$content)
    return(paste(text_parts, collapse = "\n\n"))
  } else if (format == "markdown") {
    # Format as markdown with type labels
    md_parts <- sapply(fragments, function(f) {
      prefix <- switch(f$type,
                      "page_header" = "**Journal Info:**",
                      "section_header" = "**Title:**",
                      "text" = "",
                      "")
      if (prefix != "") {
        paste0(prefix, "\n", f$content)
      } else {
        f$content
      }
    })
    return(paste(md_parts, collapse = "\n\n"))
  }
}
