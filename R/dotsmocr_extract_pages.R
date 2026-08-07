#' Extract Page Content from dots.mocr Results
#'
#' Parses each page's dots.mocr layout output (a JSON array of elements with
#' \code{bbox}, \code{category}, and \code{text}) into the Tensorlake-compatible
#' page format used by the other providers. Elements are mapped by category:
#' titles/section headers to \code{section_header}, page headers to
#' \code{page_header}, tables to \code{tables} (HTML), captions/footnotes to
#' \code{other}, and everything with text is concatenated (in reading order) into
#' \code{text}.
#'
#' If a page's output is not valid JSON, the raw text is returned as \code{text}
#' with the other fields empty.
#'
#' @author Nathan C. Layman
#'
#' @param result List. The parsed response from \code{dotsmocr_ocr()}.
#' @param pages Integer vector. Page numbers to extract. If NULL (default),
#'   extracts all pages.
#'
#' @return List with one element per page, each containing \code{page_number},
#'   \code{page_header}, \code{section_header}, \code{text}, \code{tables}, and
#'   \code{other}.
#'
#' @examples
#' \dontrun{
#' result <- dotsmocr_ocr("paper.pdf")
#' pages <- dotsmocr_extract_pages(result)
#' pages[[1]]$text
#' }
#'
#' @export
#'
#' @importFrom jsonlite fromJSON
dotsmocr_extract_pages <- function(result, pages = NULL) {

  if (is.null(result$structured_output) || is.null(result$structured_output$pages)) {
    stop("No pages found in dots.mocr result.", call. = FALSE)
  }

  all_pages <- result$structured_output$pages

  if (is.null(pages)) {
    pages <- seq_along(all_pages)
  }

  output <- list()

  for (page_num in pages) {
    if (page_num > length(all_pages)) {
      warning("Page ", page_num, " not found in result. Skipping.", call. = FALSE)
      next
    }

    page <- all_pages[[page_num]]
    parsed <- dotsmocr_parse_layout(page$text %||% "")

    output[[length(output) + 1]] <- list(
      page_number = page$page_number %||% page_num,
      page_header = parsed$page_header,
      section_header = parsed$section_header,
      text = parsed$text,
      tables = parsed$tables,
      other = parsed$other
    )
  }

  output
}


#' Parse a dots.mocr layout JSON array into Tensorlake-compatible fields
#'
#' @param text Character string. Raw per-page dots.mocr output.
#'
#' @return List with \code{page_header}, \code{section_header}, \code{text},
#'   \code{tables}, and \code{other}.
#'
#' @keywords internal
dotsmocr_parse_layout <- function(text) {

  empty <- list(
    page_header = character(0),
    section_header = character(0),
    text = "",
    tables = list(),
    other = list()
  )

  if (is.null(text) || !nzchar(text)) {
    return(empty)
  }

  # Strip ```json ... ``` fences the model sometimes adds
  cleaned <- sub("^```[a-zA-Z]*\\s*", "", trimws(text))
  cleaned <- sub("\\s*```$", "", cleaned)

  elements <- tryCatch(
    jsonlite::fromJSON(cleaned, simplifyVector = FALSE),
    error = function(e) NULL
  )

  # Not valid JSON (e.g. plain-text prompt was used): return raw text as body
  if (is.null(elements) || !is.list(elements) || length(elements) == 0) {
    out <- empty
    out$text <- trimws(text)
    return(out)
  }

  page_header <- character(0)
  section_header <- character(0)
  body <- character(0)
  tables <- list()
  other <- list()

  for (el in elements) {
    category <- el$category %||% "Text"
    content <- el$text %||% ""
    if (!nzchar(content) && !identical(category, "Table")) next

    switch(
      category,
      "Page-header" = { page_header <- c(page_header, content) },
      "Title" = ,
      "Section-header" = { section_header <- c(section_header, content); body <- c(body, content) },
      "Table" = {
        tables[[length(tables) + 1]] <- list(
          content = "", markdown = "", html = content, summary = ""
        )
        body <- c(body, content)
      },
      "Caption" = ,
      "Footnote" = ,
      "Page-footer" = {
        other[[length(other) + 1]] <- list(
          type = tolower(gsub("-", "_", category)), content = content
        )
      },
      "Picture" = { }, # images carry no text
      # Text, List-item, Formula, and anything else -> body
      { body <- c(body, content) }
    )
  }

  list(
    page_header = page_header,
    section_header = section_header,
    text = paste(body, collapse = "\n\n"),
    tables = tables,
    other = other
  )
}
