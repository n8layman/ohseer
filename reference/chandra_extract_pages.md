# Extract Page Content from Chandra (Datalab) OCR Results

Splits Chandra's paginated markdown into per-page entries in the
Tensorlake-compatible format used by the other providers. Datalab
separates pages with a delimiter of the form `\n\n{PAGE_NUMBER}`
followed by a run of dashes; this function splits on that marker.

## Usage

``` r
chandra_extract_pages(result, pages = NULL)
```

## Arguments

- result:

  List. The parsed response from
  [`chandra_ocr()`](https://n8layman.github.io/ohseer/reference/chandra_ocr.md).

- pages:

  Integer vector. Page numbers to extract. If NULL (default), extracts
  all pages.

## Value

List with one element per page, each containing `page_number`,
`page_header`, `section_header`, `text`, `tables`, and `other`.

## Details

Tables and equations are emitted inline in the markdown `text`, so the
`tables` and `other` fields are returned empty for compatibility.
Extracted figures/images are available on the raw result
(`result$structured_output$images`) as a named list of base64 strings.

## Author

Nathan C. Layman

## Examples

``` r
if (FALSE) { # \dontrun{
result <- chandra_ocr("paper.pdf")
pages <- chandra_extract_pages(result)
pages[[1]]$text
} # }
```
