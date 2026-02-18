# Process Document with Claude Opus 4.5 OCR

This function processes a document with Claude Opus 4.5 (#1 on OCR Arena
leaderboard) and returns structured OCR results in Tensorlake-compatible
format. Claude provides exceptional accuracy for complex documents,
handwriting, tables, and multi-page PDFs.

## Usage

``` r
claude_ocr(
  file_path,
  api_key = Sys.getenv("ANTHROPIC_API_KEY"),
  model = "claude-opus-4-6",
  max_tokens = 16000,
  extraction_prompt = NULL,
  output_file = NULL
)
```

## Arguments

- file_path:

  Character string. Path to a local PDF, PNG, JPEG, or image file.

- api_key:

  Character string. Anthropic API key. Default retrieves from
  environment variable "ANTHROPIC_API_KEY".

- model:

  Character string. Claude model to use. Default is "claude-opus-4-6".
  Alternative: "claude-sonnet-4-5" for faster/cheaper processing.

- max_tokens:

  Integer. Maximum tokens in response. Default is 16000.

- extraction_prompt:

  Character string. Custom extraction prompt. If NULL, uses default
  prompt that generates Tensorlake-compatible JSON structure.

- output_file:

  Character string. Optional path to save the JSON response to a file.
  Default is NULL (no file output).

## Value

List. The parsed response from Claude containing:

- structured_output:

  Parsed JSON with pages, tables, and structured data

- content:

  Raw response content from Claude

- usage:

  Token usage information

## Note

Claude Opus 4.5 ranks \#1 on OCR Arena (ELO: 1696, 71.2% win rate) as of
Feb 2026. It excels at:

- Complex tables and forms

- Handwritten text

- Multi-page PDFs

- Low-quality scans

- Scientific/technical documents

Pricing varies by model and region. Check Anthropic pricing for current
rates.

## Author

Nathan C. Layman

## Examples

``` r
if (FALSE) { # \dontrun{
# Process a PDF with Claude Opus 4.5
result <- claude_ocr("document.pdf")

# Extract pages in Tensorlake format
pages <- claude_extract_pages(result)

# Use faster/cheaper Sonnet model
result <- claude_ocr("document.pdf", model = "claude-sonnet-4.5-20250929")

# Save output to file
result <- claude_ocr("document.pdf", output_file = "ocr_result.json")

# Use with ecoextract
library(ecoextract)
pages <- claude_extract_pages(result)
json_content <- jsonlite::toJSON(pages, auto_unbox = TRUE)
} # }
```
