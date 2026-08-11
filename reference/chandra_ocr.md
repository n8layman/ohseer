# Process Document with Chandra OCR (Datalab)

Runs a document through Chandra, Datalab's document OCR model, via their
hosted conversion API. Chandra is oriented toward complex and academic
documents: it handles intricate tables, equations, forms, and
handwriting, preserves reading order, and extracts embedded
figures/images as files.

## Usage

``` r
chandra_ocr(
  file_path,
  api_key = Sys.getenv("DATALAB_API_KEY"),
  output_format = "markdown",
  mode = "balanced",
  use_llm = FALSE,
  langs = NULL,
  max_pages = NULL,
  output_file = NULL,
  timeout = 300
)
```

## Arguments

- file_path:

  Character string. Path to a local PDF, PNG, JPEG, or other supported
  document.

- api_key:

  Character string. Datalab API key, sent in the `X-Api-Key` header.
  Default retrieves from environment variable "DATALAB_API_KEY".

- output_format:

  Character string. One of "markdown" (default), "html", "json", or
  "chunks".

- mode:

  Character string. Quality/speed tradeoff: "fast", "balanced"
  (default), or "accurate".

- use_llm:

  Logical. If TRUE, adds an LLM pass to improve accuracy on tables,
  forms, and inline math (higher cost). Default is FALSE.

- langs:

  Character string. Optional comma-separated OCR language hints (e.g.
  "English"). Default is NULL (auto).

- max_pages:

  Integer. Optional cap on pages processed. Default is NULL.

- output_file:

  Character string. Optional path to save the JSON response. Default is
  NULL (no file output).

- timeout:

  Numeric. Maximum seconds to wait for the async job. Default is 300.

## Value

List with `structured_output` containing the paginated `markdown`,
`output_format`, `page_count`, `images` (named list of base64 strings),
and `metadata`. Pass to
[`chandra_extract_pages`](https://n8layman.github.io/ohseer/reference/chandra_extract_pages.md)
for a normalized page list.

## Details

The Datalab API is asynchronous; this function submits the file and
polls until the result is ready. See
[`chandra_extract_pages`](https://n8layman.github.io/ohseer/reference/chandra_extract_pages.md)
to normalize the output into the per-page format shared across
providers.

## See also

[`chandra_extract_pages`](https://n8layman.github.io/ohseer/reference/chandra_extract_pages.md),
[`ohseer_ocr`](https://n8layman.github.io/ohseer/reference/ohseer_ocr.md)

## Author

Nathan C. Layman

## Examples

``` r
if (FALSE) { # \dontrun{
# Key in DATALAB_API_KEY
result <- chandra_ocr("paper.pdf")
pages <- chandra_extract_pages(result)

# Higher accuracy with the LLM table pass
result <- chandra_ocr("paper.pdf", mode = "accurate", use_llm = TRUE)

# Access extracted figures (base64, keyed by filename)
figures <- result$structured_output$images
} # }
```
