# Process Document with olmOCR (via ellmer)

Renders each page of a PDF (or a single image) to a PNG and sends it to
an olmOCR model served behind any OpenAI-compatible endpoint, using
ellmer (`chat_openai_compatible`). Works with hosted providers that
serve olmOCR (DeepInfra, Parasail, Cirrascale) and with a local or
remote vLLM server started via
`vllm serve allenai/olmOCR-2-7B-1025-FP8`.

## Usage

``` r
olmocr_ocr_process_file(
  file_path,
  api_key = Sys.getenv("OLMOCR_API_KEY"),
  server = Sys.getenv("OLMOCR_SERVER", "https://api.deepinfra.com/v1/openai"),
  model = "allenai/olmOCR-2-7B-1025",
  pages = NULL,
  max_tokens = 8000,
  temperature = 0.1,
  target_longest_image_dim = 1288,
  extraction_prompt = NULL,
  timeout = 120
)
```

## Arguments

- file_path:

  Character string. Path to a local PDF, PNG, or JPEG file.

- api_key:

  Character string. API key for the serving provider. Default retrieves
  from environment variable "OLMOCR_API_KEY". May be empty for an
  unauthenticated local vLLM server.

- server:

  Character string. Base URL of the OpenAI-compatible endpoint, e.g.
  "https://api.deepinfra.com/v1/openai" or "http://localhost:8000/v1".
  Default retrieves from environment variable "OLMOCR_SERVER", falling
  back to DeepInfra.

- model:

  Character string. Model identifier as registered with the provider.
  Default is "allenai/olmOCR-2-7B-1025".

- pages:

  Integer vector. 1-based page numbers to process. If NULL (default),
  processes all pages. Ignored for single-image inputs.

- max_tokens:

  Integer. Maximum tokens in each per-page response. Default is 8000.

- temperature:

  Numeric. Sampling temperature. Default is 0.1.

- target_longest_image_dim:

  Integer. Pixel dimension of the longest side used when rendering PDF
  pages. Default is 1288 (olmOCR's default).

- extraction_prompt:

  Character string. Custom prompt. If NULL, uses the default olmOCR
  no-anchoring prompt.

- timeout:

  Numeric. Accepted for interface parity; request retries and timeouts
  are managed by ellmer. Default is 120.

## Value

A list with `structured_output$pages`; each page has `page_number` and
the raw model `text` (markdown with a YAML front matter header).

## Details

olmOCR is a 7B vision-language model served on a GPU; this package only
calls an existing endpoint, it does not run the model locally.

## Author

Nathan C. Layman
