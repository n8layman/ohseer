# Process Document with a Local dots.mocr Model (via ellmer)

Renders each page of a PDF (or a single image) to a PNG and sends it to
a `dots.mocr` model served locally by vLLM, using ellmer (`chat_vllm`).
dots.mocr (rednote-hilab) is a multilingual document layout-parsing VLM
that returns layout elements (bbox, category, text) with tables as HTML
and formulas as LaTeX.

## Usage

``` r
dotsmocr_ocr_process_file(
  file_path,
  server = Sys.getenv("DOTSMOCR_SERVER", "http://localhost:8000/v1"),
  api_key = Sys.getenv("DOTSMOCR_API_KEY"),
  model = "rednote-hilab/dots.mocr",
  pages = NULL,
  prompt = NULL,
  max_tokens = 16000,
  temperature = 0.1,
  target_longest_image_dim = 1600,
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
  "rednote-hilab/dots.mocr" (use "model" if you launched vLLM with
  `--served-model-name model`).

- pages:

  Integer vector. 1-based page numbers to process. If NULL (default),
  processes all pages.

- prompt:

  Character string. The parsing prompt. If NULL, uses the default
  full-layout prompt that returns bbox + category + text per element.

- max_tokens:

  Integer. Maximum tokens per page response. Default is 16000.

- temperature:

  Numeric. Sampling temperature. Default is 0.1.

- target_longest_image_dim:

  Integer. Longest-side pixel target when rendering PDF pages. Default
  is 1600.

- timeout:

  Numeric. Accepted for interface parity; retries and timeouts are
  managed by ellmer. Default is 120.

## Value

A list with `structured_output$pages`; each page has `page_number` and
the raw model `text`.

## Details

This targets a model you host yourself. Launch a server with, e.g.:


    vllm serve rednote-hilab/dots.mocr --tensor-parallel-size 1 \
      --chat-template-content-format string --trust-remote-code

then point `server` at it (default `http://localhost:8000/v1`).

## Author

Nathan C. Layman
