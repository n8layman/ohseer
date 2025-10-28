#' Preview Mistral OCR Page as HTML with Embedded Images
#'
#' This function creates a complete HTML preview of a Mistral OCR page with
#' embedded images. Unlike mistral_preview_page(), this function embeds images
#' directly in the HTML using base64 data URIs, eliminating the need for the
#' magick package.
#'
#' @param mistral_obj A Mistral OCR object containing pages with markdown content and images.
#' @param page_num Integer. The page number to preview (default: 1).
#'
#' @return A browsable HTML widget displaying the rendered page content with embedded images.
#'
#' @details
#' This function combines markdown rendering with image embedding to create a
#' complete, self-contained HTML preview. Images are embedded as base64 data URIs,
#' so no external files or image processing libraries are required.
#'
#' @examples
#' \dontrun{
#' # Preview the first page of an OCR result
#' result <- mistral_ocr("document.pdf")
#' mistral_preview_html(result, page_num = 1)
#'
#' # Use in Shiny
#' output$ocr_preview <- renderUI({
#'   mistral_preview_html(ocr_result())
#' })
#' }
#'
#' @seealso \code{\link{mistral_embed_images}} for the underlying image embedding function
#'
#' @author Nathan C. Layman
#'
#' @importFrom htmltools browsable HTML
#' @importFrom markdown mark_html
#'
#' @export
mistral_preview_html <- function(mistral_obj, page_num = 1) {

  # Extract the markdown content from the page
  markdown_content <- mistral_obj$pages[[page_num]][["markdown"]]

  # Embed images in the markdown
  processed_markdown <- mistral_embed_images(markdown_content, mistral_obj, page_num)

  # Convert markdown to HTML
  html_content <- markdown::mark_html(processed_markdown)

  # Wrap in a styled div for better presentation
  styled_html <- sprintf(
    '<div style="font-family: sans-serif; max-width: 900px; margin: 20px auto; padding: 20px; line-height: 1.6;">
      <style>
        img { max-width: 100%%; height: auto; display: block; margin: 20px 0; }
        pre { background: #f5f5f5; padding: 10px; border-radius: 4px; overflow-x: auto; }
        code { background: #f5f5f5; padding: 2px 4px; border-radius: 2px; }
        table { border-collapse: collapse; width: 100%%; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f5f5f5; }
      </style>
      %s
    </div>',
    html_content
  )

  # Return as browsable HTML
  htmltools::browsable(htmltools::HTML(styled_html))
}
