# Split olmOCR YAML front matter from the markdown body

Split olmOCR YAML front matter from the markdown body

## Usage

``` r
olmocr_parse_front_matter(text)
```

## Arguments

- text:

  Character string. Raw per-page olmOCR output.

## Value

List with `metadata` (named list of front matter values) and `body` (the
markdown text after the front matter).
