# Tensorlake Setup Guide

This guide will help you get started with Tensorlake, the recommended
OCR provider for `ohseer`.

## Why Tensorlake?

Tensorlake offers the best accuracy for document parsing: - **91.7%
accuracy** for structured data extraction - **86.8% accuracy** for table
structure preservation - No 5 MB file size limit (unlike AWS Textract
synchronous API) - Simple API key authentication (no IAM setup
required) - Competitive pricing at **\$0.01 per page**

### Accuracy Comparison

| Service        | Accuracy | File Limit  | Auth     | Pricing           |
|----------------|----------|-------------|----------|-------------------|
| **Tensorlake** | 91.7%    | None        | API Key  | \$0.01/page       |
| AWS Textract   | 88.4%    | 5 MB (sync) | IAM Keys | \$1.50/1000 pages |
| Google Doc AI  | ~89%     | 20 MB       | OAuth2   | \$1.50/1000 pages |

## Getting Started

### 1. Sign Up

Visit <https://cloud.tensorlake.ai> and create an account.

### 2. Get Your API Key

1.  Log into your Tensorlake dashboard
2.  Navigate to API Keys section
3.  Click “Create New API Key”
4.  Copy your API key

### 3. Set Environment Variable

**Option 1: In R Session**

``` r
Sys.setenv(TENSORLAKE_API_KEY = "your-api-key-here")
```

**Option 2: In .env File (Recommended)**

Create a `.env` file in your project directory:

``` bash
TENSORLAKE_API_KEY=your-api-key-here
```

**⚠️ Security:** Never commit `.env` files to version control! Add
`.env` to your `.gitignore`.

### 4. Test Your Setup

``` r
library(ohseer)

# Process a document
result <- tensorlake_ocr("path/to/document.pdf")

# Check the result
str(result, max.level = 2)
```

## Usage Examples

### Basic Document Parsing

``` r
# Parse entire document
result <- tensorlake_ocr("document.pdf")

# Parse specific pages
result <- tensorlake_ocr("document.pdf", pages = "1-5")

# Save output to file
result <- tensorlake_ocr("document.pdf", output_file = "result.json")
```

### Working with Results

``` r
# Access parsed content
text <- result$result$content

# Access metadata
metadata <- result$metadata

# Check parse status
status <- result$status  # Should be "completed"
```

## Advanced Options

### Custom Wait Time

By default,
[`tensorlake_ocr()`](https://n8layman.github.io/ohseer/reference/tensorlake_ocr.md)
waits up to 60 seconds for parsing to complete:

``` r
# Wait up to 120 seconds
result <- tensorlake_ocr("large-document.pdf", max_wait_seconds = 120)
```

### Poll Interval

Adjust how frequently to check parse status:

``` r
# Check every 5 seconds instead of default 2
result <- tensorlake_ocr("document.pdf", poll_interval = 5)
```

### Low-Level API Access

For more control, use the low-level functions:

``` r
# Submit parse job
parse_response <- tensorlake_parse_document(
  file_path = "document.pdf",
  tensorlake_api_key = Sys.getenv("TENSORLAKE_API_KEY"),
  pages = "1-10"
)

parse_id <- parse_response$parse_id

# Wait a bit...
Sys.sleep(5)

# Get results
result <- tensorlake_get_parse_result(
  parse_id = parse_id,
  tensorlake_api_key = Sys.getenv("TENSORLAKE_API_KEY")
)
```

## Supported File Formats

Tensorlake supports: - PDF - Microsoft Word (DOCX, DOC) - Microsoft
PowerPoint (PPTX, PPT) - Microsoft Excel (XLSX, XLS) - Images (PNG,
JPEG, TIFF) - HTML - Plain text (TXT) - CSV

## Pricing

- **Document Parsing**: \$0.01 per page
- **No additional fees** for storage or bandwidth
- Pay only for what you process

For enterprise or on-premises deployments, contact Tensorlake support.

## Troubleshooting

### API Key Not Found

**Error**: `Tensorlake API key not found`

**Solution**: Set the `TENSORLAKE_API_KEY` environment variable:

``` r
Sys.setenv(TENSORLAKE_API_KEY = "your-key")
```

### Timeout Errors

**Error**: `Parse job timed out after 60 seconds`

**Solution**: Increase `max_wait_seconds`:

``` r
result <- tensorlake_ocr("document.pdf", max_wait_seconds = 120)
```

### Parse Job Failed

**Error**: `Parse job failed`

**Solution**: Check the error details in the result:

``` r
result$error
```

Common causes: - Unsupported file format - Corrupted document - Invalid
API key

## Support

- **Documentation**: <https://docs.tensorlake.ai>
- **GitHub**: <https://github.com/tensorlakeai/tensorlake>
- **Community Slack**: Join via website
- **Email**: <support@tensorlake.ai>
