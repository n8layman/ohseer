# Extract Page Content by Fragment Type

Extracts content from Tensorlake OCR results organized by fragment type.
Returns a simple list structure with fragments grouped by their
Tensorlake-assigned types (page_header, section_header, text, table,
etc.).

## Usage

``` r
tensorlake_extract_pages(result, pages = NULL, exclude_types = character(0))
```

## Arguments

- result:

  List. The parsed response from tensorlake_ocr().

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

  Character vector of page_header fragment contents

- section_header:

  Character vector of section_header fragment contents

- text:

  Character string with all text fragments in markdown format

- tables:

  List of tables, each with markdown, html, and content fields

- other:

  List of other fragment types with type and content

## Author

Nathan C. Layman

## Examples

``` r
if (FALSE) { # \dontrun{
result <- tensorlake_ocr("article.pdf")

# Extract all pages
all_pages <- tensorlake_extract_pages(result)

# Extract specific pages
first_two <- tensorlake_extract_pages(result, pages = c(1, 2))

# Access first page data
page1 <- all_pages[[1]]
page1$page_header     # Journal citation
page1$section_header  # Article title
page1$text           # Body text in markdown
page1$tables         # List of tables
} # }
```
