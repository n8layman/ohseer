
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ohseer

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of ohseer is to provide an R interface to the Mistral AI OCR
(Optical Character Recognition) API. This package allows you to easily
extract text from documents using Mistral’s powerful OCR capabilities
directly from your R environment.

## Features

- Upload files to Mistral AI
- Process documents via URL or uploaded files
- Retrieve OCR processed files
- Simple, consistent interface
- Customizable API endpoints

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

To use this package, you’ll need a Mistral AI API key. Set your API key
as an environment variable:

``` r
Sys.setenv(MISTRAL_API_KEY = "your-api-key-here")
```

For persistent authentication, add this to your `.Renviron` file:

    MISTRAL_API_KEY=your-api-key-here

⚠️ **Security Warning**: Never commit `.env` or `.Renviron` files
containing API keys to version control. Consider using encrypted
environment files or a secure credential management system for
production environments.

## Examples

### Basic OCR Processing

The simplest way to process a document is to provide a URL:

``` r
library(ohseer)

# OCR processing of a PDF from a URL
result <- mistral_ocr("https://arxiv.org/pdf/2201.04234.pdf")
```

### Processing Local Files

You can also process local documents:

``` r
# Process a local PDF file
result <- mistral_ocr("path/to/document.pdf")

# Save the OCR results to a file
result <- mistral_ocr("path/to/document.pdf", output_file = "ocr_result.json")
```

### Working with File IDs

If you already have a file ID from a previous upload:

``` r
# Retrieve a file using its ID
file_content <- mistral_ocr("00edaf84-95b0-45db-8f83-f71138491f23")
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

The package provides three main functions:

- `mistral_ocr()`: Main function that auto-detects input type (URL,
  file, or file ID)
- `mistral_ocr_url()`: Process a document at a URL
- `mistral_ocr_upload_file()`: Upload a file to Mistral AI
- `mistral_ocr_retrieve_file()`: Retrieve a file from Mistral AI using
  its ID

## Notes

- This package is experimental and the API may change
- Large files may take some time to process
- Check Mistral AI documentation for the latest API information

## License

This package is licensed under the MIT License.
