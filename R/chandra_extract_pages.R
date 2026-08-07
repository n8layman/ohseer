#' Extract Page Content from Chandra (Datalab) OCR Results
#'
#' Splits Chandra's paginated markdown into per-page entries in the
#' Tensorlake-compatible format used by the other providers. Datalab separates
#' pages with a delimiter of the form \code{\\n\\n\{PAGE_NUMBER\}} followed by a
#' run of dashes; this function splits on that marker.
#'
#' Tables and equations are emitted inline in the markdown \code{text}, so the
#' \code{tables} and \code{other} fields are returned empty for compatibility.
#' Extracted figures/images are available on the raw result
#' (\code{result$structured_output$images}) as a named list of base64 strings.
#'
#' @author Nathan C. Layman
#'
#' @param result List. The parsed response from \code{chandra_ocr()}.
#' @param pages Integer vector. Page numbers to extract. If NULL (default),
#'   extracts all pages.
#'
#' @return List with one element per page, each containing \code{page_number},
#'   \code{page_header}, \code{section_header}, \code{text}, \code{tables}, and
#'   \code{other}.
#'
#' @examples
#' \dontrun{
#' result <- chandra_ocr("paper.pdf")
#' pages <- chandra_extract_pages(result)
#' pages[[1]]$text
#' }
#'
#' @export
chandra_extract_pages <- function(result, pages = NULL) {

  if (is.null(result$structured_output) || is.null(result$structured_output$markdown)) {
    stop("No markdown content found in Chandra result.", call. = FALSE)
  }

  markdown <- result$structured_output$markdown

  page_texts <- chandra_split_pages(markdown)

  # Build normalized page entries (1-based page numbers)
  all_pages <- lapply(seq_along(page_texts), function(i) {
    list(
      page_number = i,
      page_header = character(0),
      section_header = character(0),
      text = page_texts[[i]],
      tables = list(),
      other = list()
    )
  })

  if (is.null(pages)) {
    return(all_pages)
  }

  invalid <- pages[pages < 1 | pages > length(all_pages)]
  if (length(invalid) > 0) {
    warning("Page(s) ", paste(invalid, collapse = ", "),
            " not found in result. Skipping.", call. = FALSE)
  }
  valid <- pages[pages >= 1 & pages <= length(all_pages)]
  all_pages[valid]
}


#' Split Datalab paginated markdown into per-page strings
#'
#' Datalab's paginate marker is \code{\\n\\n\{PAGE_NUMBER\}} followed by ~48
#' dashes and \code{\\n\\n}. If no marker is present (paginate off, or a
#' single-page document), the whole document is returned as one page.
#'
#' @param markdown Character string. The full paginated markdown.
#'
#' @return Character vector, one element per page, in reading order.
#'
#' @keywords internal
chandra_split_pages <- function(markdown) {

  if (is.null(markdown) || !nzchar(markdown)) {
    return(character(0))
  }

  # Marker: two newlines, {N}, a run of dashes, two newlines
  delimiter <- "\n\n\\{[0-9]+\\}-{10,}\n\n"

  parts <- strsplit(markdown, delimiter, perl = TRUE)[[1]]
  parts <- trimws(parts)
  parts <- parts[nzchar(parts)]

  if (length(parts) == 0) {
    return(trimws(markdown))
  }

  parts
}
