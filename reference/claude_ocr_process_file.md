# Process Document with Claude OCR (via ellmer)

Processes a local PDF or image with Claude's document understanding
using ellmer for structured output, returning Tensorlake-compatible page
data. The output schema is enforced with an `ellmer` type specification,
so the model reliably returns pages, tables, and other elements.

## Usage

``` r
claude_ocr_process_file(
  file_path,
  api_key = Sys.getenv("ANTHROPIC_API_KEY"),
  model = "claude-opus-4-6",
  max_tokens = 16000,
  extraction_prompt = NULL,
  pages = NULL
)
```

## Arguments

- file_path:

  Character string. Path to a local PDF, PNG, JPEG, GIF, or WEBP file.

- api_key:

  Character string. The Anthropic API key. Default retrieves from
  environment variable "ANTHROPIC_API_KEY".

- model:

  Character string. The Claude model to use. Default is
  "claude-opus-4-6".

- max_tokens:

  Integer. Maximum tokens in the response. Default is 16000.

- extraction_prompt:

  Character string. Custom task prompt. If NULL, uses a default prompt
  (the output structure itself is enforced by the type schema).

- pages:

  Integer vector. Accepted for interface parity; Claude reads the whole
  document, so page selection is applied later in
  [`claude_extract_pages`](https://n8layman.github.io/ohseer/reference/claude_extract_pages.md).
  Default NULL.

## Value

A list with `structured_output$pages`: a list with one entry per page
(`page_number`, `page_header`, `section_header`, `text`, `tables`,
`other`).

## Author

Nathan C. Layman
