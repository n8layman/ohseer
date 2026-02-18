# Unified OCR Interface for Multiple Providers with Automatic Fallback

## Usage

``` r
ohseer_ocr(
  file_path,
  provider = c("tensorlake", "mistral", "claude"),
  pages = NULL,
  timeout = 60,
  extract_pages = TRUE,
  ...
)
```

## Arguments

- file_path:

  Character string. Path to the PDF file to process.

- provider:

  Character vector. OCR provider(s) to use. Can be a single provider or
  multiple providers for automatic fallback. Valid values:

  "tensorlake"

  :   Tensorlake OCR API (default) - Highest accuracy (91.7\\
      "mistral"Mistral OCR 3 - Lower cost, native markdown format
      "claude"Claude Opus/Sonnet - Structured outputs with JSON schema

  pagesInteger vector. Specific page numbers to process. If NULL
  (default), processes all pages. Page numbers are 1-based.

  timeoutNumeric. Maximum wait time in seconds for OCR processing.
  Default is 60 seconds. Not used for Claude provider.

  extract_pagesLogical. If TRUE (default), automatically extracts and
  returns page data using provider-specific extraction functions. If
  FALSE, returns raw API response.

  ...Additional provider-specific arguments passed to the underlying OCR
  function:

  Tensorlake

  :   `model`, `use_cache`, etc.

  Mistral

  :   `extract_header`, `extract_footer`, `table_format`, etc.

  Claude

  :   `model`, `max_tokens`, `dpi`, `schema`, etc.

If `extract_pages = TRUE` (default), returns a list with:

- provider:

  Character string naming the provider that succeeded

- pages:

  List of extracted page data (structure varies by provider)

- raw:

  Raw API response (for advanced use)

- error_log:

  Character string (JSON) of failed attempts, or NA if first provider
  succeeded

If `extract_pages = FALSE`, returns the raw provider API response. A
unified wrapper function that provides a consistent interface across
different OCR providers (Tensorlake, Mistral, Claude). This function
normalizes parameter names and return structures, making it easier to
switch between providers or implement provider fallback logic.
Provider-Specific Output FormatsEach provider returns pages in a
different native format:**Tensorlake** - Structured fragments:

- `page_number`: Integer (1-based)

- `page_fragments`: List of content fragments with type, content,
  reading_order

**Mistral** - Native markdown format:

- `index`: Integer (0-based)

- `markdown`: Full page content

- `tables`: Array of table objects

- `header`, `footer`: Separate header/footer fields

**Claude** - Structured output (Tensorlake-compatible by default):

- `page_number`: Integer (1-based)

- `page_fragments`: List of content fragments

- Custom schema can be provided via `schema` argument

Provider FallbackWhen multiple providers are specified, they are tried
sequentially until one succeeds:

    # Try Mistral first (lower cost), fall back to Tensorlake (higher quality)
    result <- ohseer_ocr("document.pdf", provider = c("mistral", "tensorlake"))# Try Tensorlake first (higher quality), fall back to Mistral (lower cost)
    result <- ohseer_ocr("document.pdf", provider = c("tensorlake", "mistral"))# Check which provider succeeded
    message("Used provider: ", result$provider)# Check error log if any providers failed
    if (!is.na(result$error_log)) {
      errors <- jsonlite::fromJSON(result$error_log)
      print(errors)
    }

Provider-specific functions:

- [`tensorlake_ocr`](https://n8layman.github.io/ohseer/reference/tensorlake_ocr.md),
  [`tensorlake_extract_pages`](https://n8layman.github.io/ohseer/reference/tensorlake_extract_pages.md)

- [`mistral_ocr`](https://n8layman.github.io/ohseer/reference/mistral_ocr.md),
  [`mistral_extract_pages`](https://n8layman.github.io/ohseer/reference/mistral_extract_pages.md)

- [`claude_ocr_process_file`](https://n8layman.github.io/ohseer/reference/claude_ocr_process_file.md),
  [`claude_extract_pages`](https://n8layman.github.io/ohseer/reference/claude_extract_pages.md)

Nathan C. Layman
