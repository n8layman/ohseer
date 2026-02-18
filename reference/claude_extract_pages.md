# Extract Page Content from Claude OCR Results

Transforms Claude OCR output to match Tensorlake's page format. Returns
a list structure compatible with ecoextract and other downstream tools.

## Usage

``` r
claude_extract_pages(result, pages = NULL, exclude_types = character(0))
```

## Arguments

- result:

  List. The parsed response from claude_ocr().

- pages:

  Integer vector. Page numbers to extract. If NULL (default), extracts
  all pages.

- exclude_types:

  Character vector. Fragment types to exclude. Default is character(0)
  (no exclusions).

## Value

List with one element per page, each containing:

- page_number:

  Integer page number

- page_header:

  Character vector of page_header contents

- section_header:

  Character vector of section_header contents

- text:

  Character string with all text in markdown format

- tables:

  List of tables, each with markdown, html, content, and summary fields

- other:

  List of other elements with type and content

## Author

Nathan C. Layman

## Examples

``` r
if (FALSE) { # \dontrun{
# Process document with Claude
result <- claude_ocr("document.pdf")

# Extract pages in Tensorlake-compatible format
pages <- claude_extract_pages(result)

# Extract specific pages
first_two <- claude_extract_pages(result, pages = c(1, 2))

# Use with ecoextract
library(ecoextract)
json_content <- jsonlite::toJSON(pages, auto_unbox = TRUE)
} # }
```
