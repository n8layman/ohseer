# Preview Mistral OCR Page as HTML with Embedded Images

This function creates a complete HTML preview of a Mistral OCR page with
embedded images. Unlike mistral_preview_page(), this function embeds
images directly in the HTML using base64 data URIs, eliminating the need
for the magick package.

## Usage

``` r
mistral_preview_html(mistral_obj, page_num = 1)
```

## Arguments

- mistral_obj:

  A Mistral OCR object containing pages with markdown content and
  images.

- page_num:

  Integer. The page number to preview (default: 1).

## Value

A browsable HTML widget displaying the rendered page content with
embedded images.

## Details

This function combines markdown rendering with image embedding to create
a complete, self-contained HTML preview. Images are embedded as base64
data URIs, so no external files or image processing libraries are
required.

## See also

[`mistral_embed_images`](https://n8layman.github.io/ohseer/reference/mistral_embed_images.md)
for the underlying image embedding function

## Author

Nathan C. Layman

## Examples

``` r
if (FALSE) { # \dontrun{
# Preview the first page of an OCR result
result <- mistral_ocr("document.pdf")
mistral_preview_html(result, page_num = 1)

# Use in Shiny
output$ocr_preview <- renderUI({
  mistral_preview_html(ocr_result())
})
} # }
```
