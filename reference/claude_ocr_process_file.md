# Process Document with Claude OCR

This function processes a local PDF or image file using Claude's
document understanding capabilities and returns structured OCR results.

## Usage

``` r
claude_ocr_process_file(
  file_path,
  api_key = Sys.getenv("ANTHROPIC_API_KEY"),
  model = "claude-opus-4-6",
  max_tokens = 16000,
  extraction_prompt = NULL,
  endpoint = "https://api.anthropic.com/v1/messages"
)
```

## Arguments

- file_path:

  Character string. Path to a local PDF, PNG, JPEG, or other supported
  image file.

- api_key:

  Character string. The Anthropic API key. Default is to retrieve from
  environment variable "ANTHROPIC_API_KEY".

- model:

  Character string. The Claude model to use. Default is
  "claude-opus-4.5-20250514".

- max_tokens:

  Integer. Maximum tokens in response. Default is 16000.

- extraction_prompt:

  Character string. Custom prompt for extraction. If NULL, uses default
  Tensorlake-compatible prompt.

- endpoint:

  Character string. The Claude Messages API endpoint. Default is
  "https://api.anthropic.com/v1/messages".

## Value

A list containing the Claude API response with structured OCR data.

## Author

Nathan C. Layman
