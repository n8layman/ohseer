# Process Document with a Local dots.mocr Model

Runs a document through `dots.mocr` (rednote-hilab), a multilingual
document layout-parsing VLM, served locally by vLLM. Because dots.mocr
is a GPU model, this function calls an existing vLLM server through its
OpenAI-compatible API rather than running the model in-process; point it
at your server with the `server` argument.

## Usage

``` r
dotsmocr_ocr(
  file_path,
  server = Sys.getenv("DOTSMOCR_SERVER", "http://localhost:8000/v1"),
  api_key = Sys.getenv("DOTSMOCR_API_KEY"),
  model = "rednote-hilab/dots.mocr",
  pages = NULL,
  prompt = NULL,
  max_tokens = 16000,
  target_longest_image_dim = 1600,
  output_file = NULL,
  timeout = 120
)
```

## Arguments

- file_path:

  Character string. Path to a local PDF, PNG, or JPEG file.

- server:

  Character string. Base URL of the OpenAI-compatible endpoint. Default
  retrieves from environment variable "DOTSMOCR_SERVER", falling back to
  "http://localhost:8000/v1".

- api_key:

  Character string. Bearer token, usually empty for a local server.
  Default retrieves from environment variable "DOTSMOCR_API_KEY".

- model:

  Character string. Served model name. Default is
  "rednote-hilab/dots.mocr".

- pages:

  Integer vector. 1-based page numbers to process. If NULL (default),
  processes all pages.

- prompt:

  Character string. Custom parsing prompt. If NULL, uses the default
  full-layout prompt.

- max_tokens:

  Integer. Maximum tokens per page response. Default is 16000.

- target_longest_image_dim:

  Integer. Longest-side pixel target when rendering PDF pages. Default
  is 1600.

- output_file:

  Character string. Optional path to save the JSON response. Default is
  NULL (no file output).

- timeout:

  Numeric. Accepted for interface parity; ellmer manages retries and
  timeouts. Default is 120.

## Value

List with `structured_output$pages` (one entry per page with
`page_number` and raw `text`). Pass to
[`dotsmocr_extract_pages`](https://n8layman.github.io/ohseer/reference/dotsmocr_extract_pages.md)
for a normalized page list.

## See also

[`dotsmocr_extract_pages`](https://n8layman.github.io/ohseer/reference/dotsmocr_extract_pages.md),
[`ohseer_ocr`](https://n8layman.github.io/ohseer/reference/ohseer_ocr.md)

## Author

Nathan C. Layman

## Examples

``` r
if (FALSE) { # \dontrun{
# Against a local vLLM server (default http://localhost:8000/v1)
result <- dotsmocr_ocr("paper.pdf")
pages <- dotsmocr_extract_pages(result)

# Custom server / served model name
result <- dotsmocr_ocr(
  "paper.pdf",
  server = "http://gpu-box:8000/v1",
  model = "model"
)
} # }
```
