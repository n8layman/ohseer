# Embed Base64 Images in Markdown Content

This function processes markdown content and replaces image references
with embedded base64 data URIs from a Mistral OCR response object. This
allows images to be displayed inline in HTML without external files.

## Usage

``` r
mistral_embed_images(markdown_text, mistral_response, page_num = 1)
```

## Arguments

- markdown_text:

  Character string. The markdown content to process.

- mistral_response:

  A Mistral OCR response object containing pages with image data.

- page_num:

  Integer. The page number to extract images from (default: 1).

## Value

Character string. The processed markdown with embedded image data URIs.

## Details

The function looks for image references in the markdown and replaces
them with HTML img tags containing base64-encoded image data. This is
useful for rendering OCR results in Shiny applications or R Markdown
documents.

Supported image reference patterns:

- `![img-0.jpeg](img-0.jpeg)`, `![img-1.jpeg](img-1.jpeg)`, etc.
  (Mistral's default format)

- `![image1]`, `![image2]`, etc.

- `![1]`, `![2]`, etc.

- Generic `![](...)` patterns

## Author

Nathan C. Layman

## Examples

``` r
if (FALSE) { # \dontrun{
# Process markdown with embedded images
markdown_with_images <- mistral_embed_images(
  markdown_text = ocr_result$pages[[1]]$markdown,
  mistral_response = ocr_result,
  page_num = 1
)
} # }
```
