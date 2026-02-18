# Extract Page Content from Mistral OCR Results

Returns Mistral's native page output. Each page includes markdown text,
tables, images, headers, footers, and dimensional information.

## Usage

``` r
mistral_extract_pages(result, pages = NULL)
```

## Arguments

- result:

  List. The parsed response from mistral_ocr().

- pages:

  Integer vector. Page numbers to extract. If NULL (default), extracts
  all pages.

## Value

List with one element per page. Each page contains Mistral's native
format:

- index:

  Integer page index (0-based)

- markdown:

  Character string with page content in markdown format

- header:

  Character string with page header (if extract_header=TRUE)

- footer:

  Character string with page footer (if extract_footer=TRUE)

- tables:

  List of tables with id, content, and format fields

- images:

  List of images extracted from page

- hyperlinks:

  List of hyperlinks detected

- dimensions:

  Page dimensions (width, height)

## Author

Nathan C. Layman

## Examples

``` r
if (FALSE) { # \dontrun{
# Process document with Mistral OCR 3
result <- mistral_ocr(
  "document.pdf",
  extract_header = TRUE,
  extract_footer = TRUE,
  table_format = "markdown"
)

# Extract all pages
pages <- mistral_extract_pages(result)

# Extract specific pages
first_two <- mistral_extract_pages(result, pages = c(1, 2))

# Access page content
page1_text <- pages[[1]]$markdown
page1_tables <- pages[[1]]$tables
} # }
```
