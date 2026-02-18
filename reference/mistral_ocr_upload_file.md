# Upload File to Mistral AI API for OCR Processing

This function uploads a local file to the Mistral AI API for OCR
processing. It sends the file as a multipart form upload with an
authorization header. You can enable verbose mode to get detailed HTTP
request and response info for debugging.

## Usage

``` r
mistral_ocr_upload_file(
  file_path,
  purpose = "ocr",
  api_key = Sys.getenv("MISTRAL_API_KEY"),
  endpoint = "https://api.mistral.ai/v1/files",
  verbose = FALSE,
  timeout = 60
)
```

## Arguments

- file_path:

  Character string. Path to the local file to upload.

- purpose:

  Character string. The purpose for which the file is being uploaded.
  Default is "ocr".

- api_key:

  Character string. The Mistral AI API key. Default is to retrieve from
  environment variable "MISTRAL_API_KEY".

- endpoint:

  Character string. The Mistral AI API endpoint URL. Default is
  "https://api.mistral.ai/v1/files".

- verbose:

  Logical. If TRUE, enables verbose HTTP request/response logging for
  debugging. Default is FALSE.

- timeout:

  Numeric. Timeout in seconds for the upload request. Default is 60.

## Value

List. Parsed JSON response from the Mistral AI API containing file
metadata including file ID.

## Author

Nathan C. Layman

## Examples

``` r
if (FALSE) { # \dontrun{
# Upload a local PDF file
result <- mistral_ocr_upload_file("path/to/document.pdf")

# Use the returned file ID for OCR processing
file_id <- result$id

# Enable verbose mode to debug upload issues
result <- mistral_ocr_upload_file("path/to/document.pdf", verbose = TRUE)

# Specify a custom endpoint
result <- mistral_ocr_upload_file("path/to/document.pdf", 
                                 endpoint = "https://api.custom-mistral.ai/v1/files")
} # }
```
