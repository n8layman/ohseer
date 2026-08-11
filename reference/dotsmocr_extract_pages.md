# Extract Page Content from dots.mocr Results

Parses each page's dots.mocr layout output (a JSON array of elements
with `bbox`, `category`, and `text`) into the Tensorlake-compatible page
format used by the other providers. Elements are mapped by category:
titles/section headers to `section_header`, page headers to
`page_header`, tables to `tables` (HTML), captions/footnotes to `other`,
and everything with text is concatenated (in reading order) into `text`.

## Usage

``` r
dotsmocr_extract_pages(result, pages = NULL)
```

## Arguments

- result:

  List. The parsed response from
  [`dotsmocr_ocr()`](https://n8layman.github.io/ohseer/reference/dotsmocr_ocr.md).

- pages:

  Integer vector. Page numbers to extract. If NULL (default), extracts
  all pages.

## Value

List with one element per page, each containing `page_number`,
`page_header`, `section_header`, `text`, `tables`, and `other`.

## Details

If a page's output is not valid JSON, the raw text is returned as `text`
with the other fields empty.

## Author

Nathan C. Layman

## Examples

``` r
if (FALSE) { # \dontrun{
result <- dotsmocr_ocr("paper.pdf")
pages <- dotsmocr_extract_pages(result)
pages[[1]]$text
} # }
```
