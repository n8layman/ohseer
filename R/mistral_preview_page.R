#' Preview Mistral OCR Page as HTML
#'
#' This function converts the markdown content from a Mistral OCR object page
#' to HTML and displays it in a browsable format.
#'
#' @param mistral_obj A Mistral OCR object containing pages with markdown content.
#' @param page_num The page number to preview (default: 1).
#'
#' @return A browsable HTML widget displaying the rendered page content.
#'
#' @examples
#' \dontrun{
#' # Assuming test_mistral is a Mistral OCR object
#' mistral_preview_page(test_mistral, 1)
#' }
#'
#' @author Nathan C. Layman
#'
#' @importFrom htmltools browsable HTML
#' @importFrom markdown mark_html
#'
#' @export
mistral_preview_page <- function(mistral_obj, page_num = 1) {
  # Convert markdown to HTML and make it browsable
  markdown_content <- mistral_obj$pages[[page_num]][["markdown"]]
  html_content <- markdown::mark_html(markdown_content)
  htmltools::browsable(htmltools::HTML(html_content))
}
