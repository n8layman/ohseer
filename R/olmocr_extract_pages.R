#' Extract Page Content from olmOCR Results
#'
#' Transforms olmOCR output into the Tensorlake-compatible page format used by
#' the other providers. olmOCR returns natural-reading-order markdown per page
#' with a YAML front matter header (primary_language, is_rotation_valid,
#' rotation_correction, is_table, is_diagram). This function strips the front
#' matter into a \code{metadata} field and returns the body as \code{text}.
#'
#' Tables and equations are emitted inline in the markdown \code{text} by
#' olmOCR, so the \code{tables} and \code{other} fields are returned empty for
#' compatibility.
#'
#' @author Nathan C. Layman
#'
#' @param result List. The parsed response from \code{olmocr_ocr()}.
#' @param pages Integer vector. Page numbers to extract. If NULL (default),
#'   extracts all pages.
#'
#' @return List with one element per page, each containing:
#'   \describe{
#'     \item{page_number}{Integer page number}
#'     \item{page_header}{Empty character vector (olmOCR removes headers/footers)}
#'     \item{section_header}{Empty character vector}
#'     \item{text}{Character string with page content in markdown}
#'     \item{tables}{Empty list (tables are inline in \code{text})}
#'     \item{other}{Empty list}
#'     \item{metadata}{Named list parsed from the olmOCR YAML front matter}
#'   }
#'
#' @examples
#' \dontrun{
#' result <- olmocr_ocr("document.pdf")
#' pages <- olmocr_extract_pages(result)
#' pages[[1]]$text
#' }
#'
#' @export
olmocr_extract_pages <- function(result, pages = NULL) {

  if (is.null(result$structured_output) || is.null(result$structured_output$pages)) {
    stop("No pages found in olmOCR result.", call. = FALSE)
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
    parsed <- olmocr_parse_front_matter(page$text %||% "")

    output[[length(output) + 1]] <- list(
      page_number = page$page_number %||% page_num,
      page_header = character(0),
      section_header = character(0),
      text = parsed$body,
      tables = list(),
      other = list(),
      metadata = parsed$metadata
    )
  }

  output
}


#' Split olmOCR YAML front matter from the markdown body
#'
#' @param text Character string. Raw per-page olmOCR output.
#'
#' @return List with \code{metadata} (named list of front matter values) and
#'   \code{body} (the markdown text after the front matter).
#'
#' @keywords internal
olmocr_parse_front_matter <- function(text) {

  lines <- strsplit(text, "\n", fixed = TRUE)[[1]]

  # Front matter is delimited by a leading '---' and a closing '---'
  is_fence <- function(x) grepl("^---\\s*$", x)

  if (length(lines) >= 2 && is_fence(lines[1])) {
    close_idx <- which(vapply(lines[-1], is_fence, logical(1)))[1]
    if (!is.na(close_idx)) {
      close_idx <- close_idx + 1  # offset for dropped first line
      fm_lines <- lines[2:(close_idx - 1)]
      body <- paste(lines[-(1:close_idx)], collapse = "\n")

      metadata <- list()
      for (fm in fm_lines) {
        kv <- regmatches(fm, regexec("^\\s*([^:]+):\\s*(.*)$", fm))[[1]]
        if (length(kv) == 3) {
          key <- stringr::str_squish(kv[2])
          val <- stringr::str_squish(kv[3])
          metadata[[key]] <- olmocr_coerce_scalar(val)
        }
      }

      # Trim surrounding whitespace only; preserve internal markdown newlines
      return(list(metadata = metadata, body = trimws(body)))
    }
  }

  # No recognizable front matter: return everything as body
  list(metadata = list(), body = text)
}


#' Coerce a YAML scalar string to logical/numeric where obvious
#' @keywords internal
olmocr_coerce_scalar <- function(val) {
  low <- tolower(val)
  if (low %in% c("true", "false")) return(low == "true")
  if (grepl("^-?[0-9]+(\\.[0-9]+)?$", val)) return(as.numeric(val))
  val
}
