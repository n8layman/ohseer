# Split Datalab paginated markdown into per-page strings

Datalab's paginate marker is `\n\n{PAGE_NUMBER}` followed by ~48 dashes
and `\n\n`. If no marker is present (paginate off, or a single-page
document), the whole document is returned as one page.

## Usage

``` r
chandra_split_pages(markdown)
```

## Arguments

- markdown:

  Character string. The full paginated markdown.

## Value

Character vector, one element per page, in reading order.
