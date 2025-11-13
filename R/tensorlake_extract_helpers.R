#' Extract Headers from Tensorlake Result
#'
#' Extract page headers and section headers from a Tensorlake parsing result.
#'
#' @param result List. The result object from tensorlake_ocr() or tensorlake_get_parse_result().
#' @param pages Integer vector. Optional page numbers to extract from. Default is NULL (all pages).
#' @param type Character. Type of headers to extract: "page" for page headers,
#'   "section" for section headers, or "all" for both. Default is "all".
#'
#' @return Data frame with columns:
#'   \describe{
#'     \item{page_number}{Page where header was found}
#'     \item{type}{Header type ("page_header" or "section_header")}
#'     \item{text}{Header text content}
#'     \item{reading_order}{Position in reading sequence}
#'   }
#'
#' @examples
#' \dontrun{
#' result <- tensorlake_ocr("document.pdf")
#'
#' # Get all headers
#' headers <- tensorlake_extract_headers(result)
#'
#' # Get only section headers
#' sections <- tensorlake_extract_headers(result, type = "section")
#'
#' # Get headers from first 5 pages
#' page_headers <- tensorlake_extract_headers(result, pages = 1:5)
#' }
#'
#' @export
tensorlake_extract_headers <- function(result, pages = NULL, type = "all") {

  if (is.null(result$pages)) {
    stop("Result does not contain 'pages' field", call. = FALSE)
  }

  # Determine which fragment types to extract
  fragment_types <- switch(type,
    "page" = "page_header",
    "section" = "section_header",
    "all" = c("page_header", "section_header"),
    stop("type must be 'page', 'section', or 'all'", call. = FALSE)
  )

  # Filter pages if specified
  all_pages <- result$pages
  page_numbers <- seq_along(all_pages)

  if (!is.null(pages)) {
    all_pages <- all_pages[pages]
    page_numbers <- pages
  }

  # Extract headers
  headers_list <- list()

  for (i in seq_along(all_pages)) {
    page <- all_pages[[i]]
    page_num <- page_numbers[i]

    if (is.null(page$page_fragments)) {
      next
    }

    # Find header fragments
    for (frag in page$page_fragments) {
      if (!is.null(frag$fragment_type) && frag$fragment_type %in% fragment_types) {
        headers_list[[length(headers_list) + 1]] <- data.frame(
          page_number = page_num,
          type = frag$fragment_type,
          text = frag$content$content %||% "",
          reading_order = frag$reading_order %||% NA,
          stringsAsFactors = FALSE
        )
      }
    }
  }

  if (length(headers_list) == 0) {
    return(data.frame(
      page_number = integer(),
      type = character(),
      text = character(),
      reading_order = integer(),
      stringsAsFactors = FALSE
    ))
  }

  do.call(rbind, headers_list)
}


#' Extract Footers from Tensorlake Result
#'
#' Extract page footers (typically page numbers and footer text) from a Tensorlake parsing result.
#'
#' @param result List. The result object from tensorlake_ocr() or tensorlake_get_parse_result().
#' @param pages Integer vector. Optional page numbers to extract from. Default is NULL (all pages).
#'
#' @return Data frame with columns:
#'   \describe{
#'     \item{page_number}{Page where footer was found}
#'     \item{type}{Footer type ("page_number" or other footer types)}
#'     \item{text}{Footer text content}
#'     \item{reading_order}{Position in reading sequence}
#'   }
#'
#' @examples
#' \dontrun{
#' result <- tensorlake_ocr("document.pdf")
#'
#' # Get all footers
#' footers <- tensorlake_extract_footers(result)
#'
#' # Get footers from specific pages
#' page_footers <- tensorlake_extract_footers(result, pages = 1:10)
#' }
#'
#' @export
tensorlake_extract_footers <- function(result, pages = NULL) {

  if (is.null(result$pages)) {
    stop("Result does not contain 'pages' field", call. = FALSE)
  }

  # Footer fragment types
  footer_types <- c("page_number", "page_footer")

  # Filter pages if specified
  all_pages <- result$pages
  page_numbers <- seq_along(all_pages)

  if (!is.null(pages)) {
    all_pages <- all_pages[pages]
    page_numbers <- pages
  }

  # Extract footers
  footers_list <- list()

  for (i in seq_along(all_pages)) {
    page <- all_pages[[i]]
    page_num <- page_numbers[i]

    if (is.null(page$page_fragments)) {
      next
    }

    # Find footer fragments
    for (frag in page$page_fragments) {
      if (!is.null(frag$fragment_type) && frag$fragment_type %in% footer_types) {
        footers_list[[length(footers_list) + 1]] <- data.frame(
          page_number = page_num,
          type = frag$fragment_type,
          text = frag$content$content %||% "",
          reading_order = frag$reading_order %||% NA,
          stringsAsFactors = FALSE
        )
      }
    }
  }

  if (length(footers_list) == 0) {
    return(data.frame(
      page_number = integer(),
      type = character(),
      text = character(),
      reading_order = integer(),
      stringsAsFactors = FALSE
    ))
  }

  do.call(rbind, footers_list)
}


#' Extract References from Tensorlake Result
#'
#' Extract reference/bibliography sections from a Tensorlake parsing result.
#' This function looks for sections commonly labeled as references, bibliography,
#' works cited, etc.
#'
#' @param result List. The result object from tensorlake_ocr() or tensorlake_get_parse_result().
#' @param pages Integer vector. Optional page numbers to search. Default is NULL (all pages).
#' @param keywords Character vector. Keywords to identify reference sections.
#'   Default is c("references", "bibliography", "works cited", "literature cited").
#'
#' @return List with:
#'   \describe{
#'     \item{start_page}{Page where references section starts}
#'     \item{end_page}{Page where references section ends (or document ends)}
#'     \item{header_text}{Text of the references section header}
#'     \item{content}{Full text content of the references section}
#'   }
#'   Returns NULL if no references section is found.
#'
#' @examples
#' \dontrun{
#' result <- tensorlake_ocr("paper.pdf")
#'
#' # Extract references section
#' refs <- tensorlake_extract_references(result)
#'
#' if (!is.null(refs)) {
#'   cat("References found on pages", refs$start_page, "to", refs$end_page, "\n")
#'   cat(refs$content)
#' }
#' }
#'
#' @export
tensorlake_extract_references <- function(result,
                                          pages = NULL,
                                          keywords = c("references", "bibliography",
                                                      "works cited", "literature cited")) {

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

  # Search for references section header
  ref_start_page <- NULL
  ref_header <- NULL

  for (i in seq_along(all_pages)) {
    page <- all_pages[[i]]
    page_num <- page_numbers[i]

    if (is.null(page$page_fragments)) {
      next
    }

    # Look for section headers that match reference keywords
    for (frag in page$page_fragments) {
      if (!is.null(frag$fragment_type) && frag$fragment_type == "section_header") {
        header_text <- tolower(frag$content$content %||% "")

        # Check if header matches any keyword
        if (any(sapply(keywords, function(kw) grepl(kw, header_text, ignore.case = TRUE)))) {
          ref_start_page <- page_num
          ref_header <- frag$content$content
          break
        }
      }
    }

    if (!is.null(ref_start_page)) {
      break
    }
  }

  # If no references section found, return NULL
  if (is.null(ref_start_page)) {
    return(NULL)
  }

  # Extract all text from references section to end of document
  # (or until next major section if detectable)
  ref_end_page <- page_numbers[length(page_numbers)]

  # Get text from references section
  ref_pages_idx <- which(page_numbers >= ref_start_page)
  ref_text <- tensorlake_extract_text(result, pages = page_numbers[ref_pages_idx])

  list(
    start_page = ref_start_page,
    end_page = ref_end_page,
    header_text = ref_header,
    content = paste(ref_text, collapse = "\n\n")
  )
}


#' Get All Fragment Types in Result
#'
#' Get a summary of all fragment types present in a Tensorlake result.
#' Useful for exploring what content types were detected.
#'
#' @param result List. The result object from tensorlake_ocr() or tensorlake_get_parse_result().
#' @param pages Integer vector. Optional page numbers to analyze. Default is NULL (all pages).
#'
#' @return Named integer vector with counts of each fragment type.
#'
#' @examples
#' \dontrun{
#' result <- tensorlake_ocr("document.pdf")
#'
#' # See what types of content were found
#' fragment_types <- tensorlake_get_fragment_types(result)
#' print(fragment_types)
#' }
#'
#' @export
tensorlake_get_fragment_types <- function(result, pages = NULL) {

  if (is.null(result$pages)) {
    stop("Result does not contain 'pages' field", call. = FALSE)
  }

  # Filter pages if specified
  all_pages <- result$pages

  if (!is.null(pages)) {
    all_pages <- all_pages[pages]
  }

  # Collect all fragment types
  all_types <- unlist(lapply(all_pages, function(page) {
    if (is.null(page$page_fragments)) {
      return(character(0))
    }
    sapply(page$page_fragments, function(frag) frag$fragment_type %||% "unknown")
  }))

  table(all_types)
}
