# Preview Mistral OCR Page as HTML

This function converts the markdown content from a Mistral OCR object
page to HTML and displays it in a browsable format.

## Usage

``` r
mistral_preview_page(mistral_obj, page_num = 1)
```

## Arguments

- mistral_obj:

  A Mistral OCR object containing pages with markdown content.

- page_num:

  The page number to preview (default: 1).

## Value

A browsable HTML widget displaying the rendered page content.

## Author

Nathan C. Layman

## Examples

``` r
if (FALSE) { # \dontrun{
# Assuming test_mistral is a Mistral OCR object
mistral_preview_page(test_mistral, 1)
} # }
```
