# Extract Page Content from olmOCR Results

Transforms olmOCR output into the Tensorlake-compatible page format used
by the other providers. olmOCR returns natural-reading-order markdown
per page with a YAML front matter header (primary_language,
is_rotation_valid, rotation_correction, is_table, is_diagram). This
function strips the front matter into a `metadata` field and returns the
body as `text`.

## Usage

``` r
olmocr_extract_pages(result, pages = NULL)
```

## Arguments

- result:

  List. The parsed response from
  [`olmocr_ocr()`](https://n8layman.github.io/ohseer/reference/olmocr_ocr.md).

- pages:

  Integer vector. Page numbers to extract. If NULL (default), extracts
  all pages.

## Value

List with one element per page, each containing:

- page_number:

  Integer page number

- page_header:

  Empty character vector (olmOCR removes headers/footers)

- section_header:

  Empty character vector

- text:

  Character string with page content in markdown

- tables:

  Empty list (tables are inline in `text`)

- other:

  Empty list

- metadata:

  Named list parsed from the olmOCR YAML front matter

## Details

Tables and equations are emitted inline in the markdown `text` by
olmOCR, so the `tables` and `other` fields are returned empty for
compatibility.

## Author

Nathan C. Layman

## Examples

``` r
if (FALSE) { # \dontrun{
result <- olmocr_ocr("document.pdf")
pages <- olmocr_extract_pages(result)
pages[[1]]$text
} # }
```
