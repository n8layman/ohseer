# Parse a dots.mocr layout JSON array into Tensorlake-compatible fields

Parse a dots.mocr layout JSON array into Tensorlake-compatible fields

## Usage

``` r
dotsmocr_parse_layout(text)
```

## Arguments

- text:

  Character string. Raw per-page dots.mocr output.

## Value

List with `page_header`, `section_header`, `text`, `tables`, and
`other`.
