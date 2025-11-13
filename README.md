# ohseer

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of ohseer is to provide R interfaces to OCR (Optical Character
Recognition) APIs. This package supports Mistral AI OCR, AWS Textract, and
Tensorlake, allowing you to easily extract text and structured data from
documents directly from your R environment.

## Part of the EcoExtract Suite

`OhSeeR` is the foundational first step in the **EcoExtract Suite**, a
collection of R packages designed for extracting and structuring
ecological data from academic literature. This suite facilitates a
modular workflow from raw documents to validated, analysis-ready data.

**Workflow**: Source PDF Documents → **OhSeeR** (OCR) → sanitizeR (text cleaning) → whispeR (prompts) → LLM API → structuR (structured data) → auditR (validation) → Structured Dataset

## Features

### Tensorlake (Recommended)

- **Highest accuracy**: 91.7% for structured data extraction
- Extract tables, forms, and key-value pairs from documents
- No file size limit for synchronous processing
- Support for PDF, DOCX, PPTX, images, and more
- Simple API key authentication
- Competitive pricing: $0.01 per page

### Mistral AI OCR

- Upload files to Mistral AI
- Process documents via URL or uploaded files
- Extract text and images from PDFs
- Preview OCR results as HTML with embedded images
- Embed base64 images in markdown for Shiny apps

### AWS Textract OCR

- Extract structured data from documents (forms, tables, key-value pairs)
- Supports tables, forms, layout, and signature detection
- Process local PDF, PNG, JPEG, or TIFF files
- **Note**: 5 MB file size limit (synchronous API)

### General

- Simple, consistent interface across OCR providers
- No heavy image processing dependencies (no magick required)
- Lightweight: uses httr2 for all API calls

## Installation

You can install the development version of ohseer from
[GitHub](https://github.com/) with:

``` r
# Option 1: Using pak (recommended)
# install.packages("pak")
pak::pak("n8layman/ohseer")

# Option 2: Using devtools
# install.packages("devtools")
devtools::install_github("n8layman/ohseer")

# Option 3: Using remotes
# install.packages("remotes")
remotes::install_github("n8layman/ohseer")
```

## Authentication

### Mistral AI

To use Mistral OCR, you’ll need a Mistral AI API key:

1.  Visit [mistral.ai](https://mistral.ai/)
2.  Click ‘Try the API’ from the top menu bar
3.  Sign in using Google, Apple, or Microsoft accounts or register
4.  Create and name a workspace or organization
5.  Click ‘Subscription’ and then ‘Compare plans’ from the left task bar
6.  Choose ‘Experiment for Free’ to try out the service and subscribe
7.  Click on ‘API keys’ and ‘Create New Key’
8.  Copy down your API key and set it as an environment variable in R

``` r
Sys.setenv(MISTRAL_API_KEY = "your-api-key-here")
```

### Tensorlake (Recommended)

To use Tensorlake's high-accuracy parsing API (91.7% accuracy):

1.  Sign up for a [Tensorlake account](https://cloud.tensorlake.ai/)
2.  Get your API key from the dashboard
3.  Set environment variable in R:

``` r
Sys.setenv(TENSORLAKE_API_KEY = "your-api-key-here")
```

**Why Tensorlake?**
- Highest accuracy: 91.7% (vs AWS Textract 88.4%)
- No file size limit for synchronous processing
- Simple API key authentication
- Competitive pricing: $0.01 per page

### AWS Textract

To use AWS Textract, you'll need AWS credentials:

1.  Sign up for an [AWS account](https://aws.amazon.com/)
2.  Create an IAM user with Textract permissions:
    - Navigate to IAM > Users > Create user
    - Choose a username (e.g., `textract-user`)
    - On the permissions page, click "Attach policies directly"
    - Search for and attach `AmazonTextractFullAccess` policy
    - Complete user creation
3.  Create access keys:
    - Select the created user
    - Go to "Security credentials" tab
    - Click "Create access key"
    - Choose "Application running outside AWS"
    - Copy the Access Key ID and Secret Access Key
4.  Set environment variables in R:

``` r
Sys.setenv(
  AWS_ACCESS_KEY_ID = "your-access-key-id",
  AWS_SECRET_ACCESS_KEY = "your-secret-access-key"
)
```

**Note:** AWS Textract synchronous API has a 5 MB file size limit. Large PDFs are automatically reduced to first 2 pages.

### Persistent Authentication

Create a `.env` file in your project directory:

``` bash
# .env
MISTRAL_API_KEY=your-api-key-here
TENSORLAKE_API_KEY=your-tensorlake-key-here
AWS_ACCESS_KEY_ID=your-access-key-id
AWS_SECRET_ACCESS_KEY=your-secret-access-key
```

⚠️ **Security Warning**: Never commit `.env` files containing API keys
to version control. Add `.env` to your `.gitignore` file.

## Examples

### Tensorlake OCR (Recommended)

#### High-Accuracy Document Parsing

Tensorlake offers the highest accuracy (91.7%) for structured data extraction:

``` r
library(ohseer)
library(jsonlite)

# Process entire PDF with high-accuracy parsing
result <- tensorlake_ocr("paper.pdf")

# Extract all pages
all_pages <- tensorlake_extract_pages(result)

# Or extract just first 2 pages for citation metadata
result <- tensorlake_ocr("paper.pdf", pages = c(1, 2))
pages <- tensorlake_extract_pages(result)

# Access citation info from first page
page1 <- pages[[1]]
citation <- page1$page_header      # Journal citation
title <- page1$section_header      # Article title
text <- page1$text                 # Body text (markdown format)
tables <- page1$tables             # Tables with markdown/html/content

# Convert to JSON for LLM processing
json_data <- toJSON(pages, auto_unbox = TRUE, pretty = TRUE)
```

**Benefits over AWS Textract:**
- Higher accuracy: 91.7% vs 88.4%
- No 5 MB file size limit
- Simpler authentication (just API key)
- Competitive pricing: $0.01 per page

See the [Tensorlake Output Structure vignette](vignettes/tensorlake-output-structure.Rmd) for detailed information on working with results.

### Mistral AI OCR

#### Basic OCR Processing

The simplest way to process a document is to provide a URL:

``` r
library(ohseer)

# OCR processing of a PDF from a URL
result <- mistral_ocr("https://arxiv.org/pdf/2201.04234.pdf")
```

#### Processing Local Files

You can also process local documents:

``` r
# Process a local PDF file
result <- mistral_ocr("path/to/document.pdf")

# Save the OCR results to a file
result <- mistral_ocr("path/to/document.pdf", output_file = "ocr_result.json")
```

### AWS Textract OCR

#### Extract Structured Data from PDFs

Perfect for extracting citation metadata and structured information:

``` r
library(ohseer)

# Process a PDF with structured extraction (forms and tables)
result <- textract_ocr("paper.pdf")

# Extract citation metadata and other structured data
metadata <- textract_extract_metadata(result)

# Access key-value pairs (e.g., Title, Authors, DOI, Journal)
metadata$key_value_pairs
#>        key                          value confidence
#> 1   Title:  Machine Learning for OCR         95.2
#> 2  Author:  Smith, J.; Jones, A.            98.1
#> 3     DOI:  10.1038/nmeth.1234              99.5

# Access extracted tables
metadata$tables[[1]]

# Full document text
cat(metadata$text)
```

#### Simple Text Extraction

For faster text-only extraction without structured data:

``` r
# Extract just text (no forms/tables)
result <- textract_ocr("document.pdf", features = NULL)
```

### Working with File IDs

If you already have a file ID from a previous upload:

``` r
# Retrieve a file using its ID
file_content <- mistral_ocr("00edaf84-95b0-45db-8f83-f71138491f23")
```

### Previewing OCR Results

You can preview OCR results with embedded images:

``` r
# Process a document
result <- mistral_ocr("path/to/document.pdf")

# Preview a page as HTML with embedded images
mistral_preview_html(result, page_num = 1)

# For Shiny apps: embed images in markdown
processed_markdown <- mistral_embed_images(
  markdown_text = result$pages[[1]]$markdown,
  mistral_response = result,
  page_num = 1
)

# Then render with your preferred markdown renderer
html_output <- commonmark::markdown_html(processed_markdown)
```

### Direct API Access

For more control, you can use the lower-level functions:

``` r
# Upload a file
upload_result <- mistral_ocr_upload_file("path/to/document.pdf")
file_id <- upload_result$id

# Process a URL directly
url_result <- mistral_ocr_url("https://arxiv.org/pdf/2201.04234.pdf")

# Retrieve a file by ID
file_content <- mistral_ocr_retrieve_file(file_id, output_path = "retrieved_document.pdf")
```

## API Functions

### Tensorlake OCR Functions

- `tensorlake_ocr()`: Main function for high-accuracy document parsing (recommended)
- `tensorlake_extract_pages()`: Extract structured page data organized by fragment type

### Mistral AI OCR Functions

- `mistral_ocr()`: Main function that auto-detects input type (URL,
  file, or file ID)
- `mistral_ocr_url()`: Process a document at a URL
- `mistral_ocr_upload_file()`: Upload a file to Mistral AI
- `mistral_ocr_retrieve_file()`: Retrieve a file from Mistral AI using
  its ID

### Mistral Preview and Display Functions

- `mistral_preview_html()`: Generate a complete HTML preview with
  embedded images
- `mistral_embed_images()`: Embed base64 images into markdown text (for
  Shiny apps)
- `mistral_preview_page()`: Simple markdown-to-HTML preview (without
  images)

### AWS Textract OCR Functions

- `textract_ocr()`: Main function for AWS Textract OCR with structured
  data extraction
- `textract_extract_metadata()`: Parse Textract output to extract
  key-value pairs and tables
- `textract_analyze_document()`: Low-level function for AnalyzeDocument
  API
- `textract_detect_document_text()`: Low-level function for
  DetectDocumentText API

## Notes

- This package is experimental and the API may change
- Large files may take some time to process
- **Mistral OCR**: Check [Mistral AI
  documentation](https://docs.mistral.ai/) for the latest API
  information
- **AWS Textract**:
  - Supports synchronous processing for documents up to 5 MB
  - Check [AWS Textract
    pricing](https://aws.amazon.com/textract/pricing/) for cost
    information
  - See [AWS Textract
    documentation](https://docs.aws.amazon.com/textract/) for more
    details

## License

This package is licensed under the MIT License.
