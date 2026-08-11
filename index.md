# ohseer

A unified R interface to multiple OCR (Optical Character Recognition)
APIs. Process documents with Claude (Opus 4.6/Sonnet 4.5), Mistral OCR
3, Tensorlake, or AWS Textract using a single, consistent function.

## Documentation

📚 **Full documentation**: <https://n8layman.github.io/ohseer/>

- [Getting Started
  Guide](https://n8layman.github.io/ohseer/articles/unified-interface.html)
- [Provider-Specific
  Documentation](https://n8layman.github.io/ohseer/reference/index.html)

## Part of the EcoExtract Suite

`OhSeeR` is the foundational first step in the **EcoExtract Suite**, a
collection of R packages designed for extracting and structuring
ecological data from academic literature.

**Workflow**: Source PDF Documents → **OhSeeR** (OCR) → sanitizeR (text
cleaning) → whispeR (prompts) → LLM API → structuR (structured data) →
auditR (validation) → Structured Dataset

## Features

- **Unified interface**: Use
  [`ohseer_ocr()`](https://n8layman.github.io/ohseer/reference/ohseer_ocr.md)
  with any provider
- **Provider fallback**: Automatic failover if one provider fails
- **Multiple OCR providers**:
  - **Claude Opus 4.6**: \#1 on OCR Arena leaderboards, structured
    outputs with JSON schemas
  - **Tensorlake**: Highest accuracy (91.7%), best for tables and forms
  - **Mistral OCR 3**: Native markdown output, cost-effective
  - **olmOCR (AI2)**: Open-weights VLM, markdown output, runs on your
    own GPU or a hosted provider (DeepInfra, Parasail, Cirrascale)
  - **Chandra (Datalab)**: Academic-document OCR via Datalab’s hosted
    API; strong tables/equations and extracts figures as images
  - **AWS Textract**: Reliable option for structured data extraction
- **Consistent output**: Same interface across all providers
- **Standing on solid ground**: Chat-based providers (Claude, olmOCR,
  dots.mocr) use [ellmer](https://ellmer.tidyverse.org) for LLM
  plumbing; bespoke OCR APIs (Mistral, Tensorlake, Chandra, Textract)
  use httr2 directly

## Installation

``` r

# Using pak (recommended)
pak::pak("n8layman/ohseer")

# Using devtools
devtools::install_github("n8layman/ohseer")

# Using remotes
remotes::install_github("n8layman/ohseer")
```

## Authentication

Set up API keys as environment variables:

``` r

# Set for the current session
Sys.setenv(
  ANTHROPIC_API_KEY = "your-claude-key",        # For Claude
  TENSORLAKE_API_KEY = "your-tensorlake-key",   # For Tensorlake
  MISTRAL_API_KEY = "your-mistral-key",         # For Mistral
  OLMOCR_API_KEY = "your-provider-key",         # For olmOCR (DeepInfra/Parasail/etc.)
  OLMOCR_SERVER = "https://api.parasail.io/v1", # olmOCR endpoint (optional; defaults to DeepInfra)
  DATALAB_API_KEY = "your-datalab-key",         # For Chandra (Datalab)
  AWS_ACCESS_KEY_ID = "your-aws-key",           # For AWS Textract
  AWS_SECRET_ACCESS_KEY = "your-aws-secret"     # For AWS Textract
)
```

Or create a `.env` file in your project directory:

``` bash
# .env
ANTHROPIC_API_KEY=your-claude-key
TENSORLAKE_API_KEY=your-tensorlake-key
MISTRAL_API_KEY=your-mistral-key
AWS_ACCESS_KEY_ID=your-aws-key
AWS_SECRET_ACCESS_KEY=your-aws-secret
```

⚠️ **Security**: Never commit `.env` files to version control. Add
`.env` to your `.gitignore`.

### Getting API Keys

- **Claude**: [console.anthropic.com](https://console.anthropic.com/) →
  API Keys
- **Tensorlake**: [cloud.tensorlake.ai](https://cloud.tensorlake.ai/) →
  Dashboard → API Key
- **Mistral**: [mistral.ai](https://mistral.ai/) → Try the API → API
  keys
- **olmOCR**: Any provider serving `allenai/olmOCR-2-7B-1025` over an
  OpenAI-compatible API — e.g. [Parasail](https://parasail.io/),
  [DeepInfra](https://deepinfra.com/),
  [Cirrascale](https://cirrascale.com/), or your own `vllm serve`. Set
  `OLMOCR_API_KEY` and `OLMOCR_SERVER`.
- **Chandra (Datalab)**: [datalab.to](https://www.datalab.to/) → sign up
  → API key. Set `DATALAB_API_KEY`.
- **AWS Textract**: [aws.amazon.com](https://aws.amazon.com/) → IAM →
  Create access key with `AmazonTextractFullAccess`

## Quick Start

### Basic Usage

``` r

library(ohseer)

# Process with default provider (Tensorlake)
result <- ohseer_ocr("document.pdf")

# Access extracted pages
pages <- result$pages
provider_used <- result$provider
```

### Choose a Specific Provider

``` r

# Use Claude for highest accuracy
result <- ohseer_ocr("document.pdf", provider = "claude")

# Use Mistral for cost-effectiveness
result <- ohseer_ocr("document.pdf", provider = "mistral")

# Use Tensorlake for best table extraction
result <- ohseer_ocr("document.pdf", provider = "tensorlake")
```

### Provider Fallback

Automatically try multiple providers in order until one succeeds:

``` r

# Try Tensorlake first (highest quality), fall back to Mistral (lower cost)
result <- ohseer_ocr(
  "document.pdf",
  provider = c("tensorlake", "mistral", "claude")
)

# Check which provider succeeded
message("Used provider: ", result$provider)

# Check if any providers failed
if (!is.na(result$error_log)) {
  errors <- jsonlite::fromJSON(result$error_log)
  print(errors)
}
```

### Select Specific Pages

``` r

# Process only first 2 pages
result <- ohseer_ocr("document.pdf", pages = c(1, 2))

# Process specific pages
result <- ohseer_ocr("document.pdf", pages = c(1, 5, 10))
```

### Provider-Specific Options

Each provider accepts its own custom parameters via `...`:

``` r

# Mistral: extract headers and footers separately
result <- ohseer_ocr(
  "document.pdf",
  provider = "mistral",
  extract_header = TRUE,
  extract_footer = TRUE
)

# Claude: use Sonnet instead of Opus, custom schema
result <- ohseer_ocr(
  "document.pdf",
  provider = "claude",
  model = "claude-sonnet-4-5",
  schema = my_custom_schema
)

# Tensorlake: use different model
result <- ohseer_ocr(
  "document.pdf",
  provider = "tensorlake",
  model = "high-quality-v1"
)
```

## Output Format

All providers return a consistent structure when using
[`ohseer_ocr()`](https://n8layman.github.io/ohseer/reference/ohseer_ocr.md):

``` r

result <- ohseer_ocr("document.pdf")

# Result structure:
# $provider  - Character: which provider was used
# $pages     - List: extracted page data (format varies by provider)
# $raw       - List: raw API response
# $error_log - Character (JSON): errors from failed providers, or NA
```

**Note**: Each provider returns pages in its own native format. See
provider-specific vignettes for details:

- [Tensorlake Output
  Structure](https://n8layman.github.io/ohseer/articles/tensorlake-output-structure.html)
- [Mistral Output
  Structure](https://n8layman.github.io/ohseer/articles/mistral-output-structure.html)
- [Claude Structured
  Output](https://n8layman.github.io/ohseer/articles/claude-structured-output.html)

## Provider Comparison

| Provider | Accuracy | Speed | Cost | Best For |
|----|----|----|----|----|
| **Claude Opus 4.6** | ⭐⭐⭐⭐⭐ (#1 OCR Arena) | Medium | High | Structured outputs, custom schemas |
| **Tensorlake** | ⭐⭐⭐⭐⭐ (91.7%) | Fast | \$0.01/page | Tables, forms, batch processing |
| **Mistral OCR 3** | ⭐⭐⭐ | Very Fast | Low | Markdown output, cost-sensitive |
| **AWS Textract** | ⭐⭐⭐⭐ (88.4%) | Fast | Medium | AWS ecosystem, reliability |

## Advanced Usage

For provider-specific functions and advanced features, see:

- [Complete Function
  Reference](https://n8layman.github.io/ohseer/reference/index.html)
- [Unified Interface
  Guide](https://n8layman.github.io/ohseer/articles/unified-interface.html)
- Provider guides:
  [Tensorlake](https://n8layman.github.io/ohseer/articles/tensorlake-output-structure.html)
  \|
  [Mistral](https://n8layman.github.io/ohseer/articles/mistral-output-structure.html)
  \|
  [Claude](https://n8layman.github.io/ohseer/articles/claude-structured-output.html)

## Notes

- This package is experimental and the API may change
- Large files may take time to process depending on provider
- Check provider documentation for pricing and rate limits:
  - [Claude API Pricing](https://www.anthropic.com/pricing)
  - [Tensorlake Pricing](https://docs.tensorlake.ai/pricing)
  - [Mistral AI Pricing](https://mistral.ai/technology/#pricing)
  - [AWS Textract Pricing](https://aws.amazon.com/textract/pricing/)

## License

MIT License
