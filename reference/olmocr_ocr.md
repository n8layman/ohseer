# Process Document with olmOCR

Runs a document through olmOCR, an open-weights 7B vision-language OCR
model from the Allen Institute for AI (AI2). olmOCR converts PDFs and
images into clean, natural-reading-order markdown, removing headers and
footers and handling equations, tables, handwriting, and multi-column
layouts.

## Usage

``` r
olmocr_ocr(
  file_path,
  api_key = Sys.getenv("OLMOCR_API_KEY"),
  server = Sys.getenv("OLMOCR_SERVER", "https://api.deepinfra.com/v1/openai"),
  model = "allenai/olmOCR-2-7B-1025",
  pages = NULL,
  max_tokens = 8000,
  target_longest_image_dim = 1288,
  extraction_prompt = NULL,
  output_file = NULL,
  timeout = 120
)
```

## Arguments

- file_path:

  Character string. Path to a local PDF, PNG, or JPEG file.

- api_key:

  Character string. Provider API key (Bearer token). Default retrieves
  from environment variable "OLMOCR_API_KEY". May be empty for an
  unauthenticated local vLLM server.

- server:

  Character string. Base URL of the OpenAI-compatible endpoint. Default
  retrieves from environment variable "OLMOCR_SERVER", falling back to
  DeepInfra ("https://api.deepinfra.com/v1/openai").

- model:

  Character string. Model identifier as registered with the provider.
  Default is "allenai/olmOCR-2-7B-1025". Note that model names differ
  between providers (e.g. Cirrascale uses "olmOCR-2-7B-1025").

- pages:

  Integer vector. 1-based page numbers to process. If NULL (default),
  processes all pages.

- max_tokens:

  Integer. Maximum tokens per page response. Default is 8000.

- target_longest_image_dim:

  Integer. Longest-side pixel target used when rendering PDF pages.
  Default is 1288.

- extraction_prompt:

  Character string. Custom prompt. If NULL, uses the default olmOCR
  no-anchoring prompt.

- output_file:

  Character string. Optional path to save the JSON response. Default is
  NULL (no file output).

- timeout:

  Numeric. Per-request timeout in seconds. Default is 120.

## Value

List with `structured_output$pages` containing one entry per page
(`page_number`, raw `text`), plus the `model` and `server` used. Pass to
[`olmocr_extract_pages`](https://n8layman.github.io/ohseer/reference/olmocr_extract_pages.md)
for a normalized page list.

## Details

Because olmOCR is a GPU model, this function calls an existing
OpenAI-compatible endpoint rather than running the model locally. Point
it at a hosted provider (DeepInfra, Parasail, Cirrascale) or your own
vLLM server via the `server` argument. See the package README for
provider setup.

## See also

[`olmocr_extract_pages`](https://n8layman.github.io/ohseer/reference/olmocr_extract_pages.md),
[`ohseer_ocr`](https://n8layman.github.io/ohseer/reference/ohseer_ocr.md)

## Author

Nathan C. Layman

## Examples

``` r
if (FALSE) { # \dontrun{
# Using DeepInfra (default endpoint), key in OLMOCR_API_KEY
result <- olmocr_ocr("document.pdf")
pages <- olmocr_extract_pages(result)

# Using Parasail
result <- olmocr_ocr(
  "document.pdf",
  server = "https://api.parasail.io/v1",
  model = "allenai/olmOCR-2-7B-1025"
)

# Using a local vLLM server (no key needed)
result <- olmocr_ocr(
  "document.pdf",
  server = "http://localhost:8000/v1",
  api_key = "",
  model = "olmocr"
)
} # }
```
