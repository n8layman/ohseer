# Perform OCR on an Image using Mistral AI

This function sends an image to Mistral AI for Optical Character
Recognition (OCR) and returns the extracted text and layout information.

## Usage

``` r
mistral_ocr_process_image(
  image_url,
  model = "mistral-ocr-latest",
  include_image_base64 = TRUE,
  api_key = Sys.getenv("MISTRAL_API_KEY"),
  endpoint = "https://api.mistral.ai/v1/ocr"
)
```

## Arguments

- image_url:

  Character string. The URL to the image to process with OCR.

- model:

  Character string. The OCR model to use. Default is
  "mistral-ocr-latest".

- include_image_base64:

  Logical. Whether to include base64-encoded images in the response.
  Default is TRUE.

- api_key:

  Character string. The Mistral AI API key. Default is to retrieve from
  environment variable "MISTRAL_API_KEY".

- endpoint:

  Character string. The OCR API endpoint. Default is
  "https://api.mistral.ai/v1/ocr".

## Value

A list containing the OCR results, including extracted text and layout
information.

## Author

Nathan C. Layman

## Examples

``` r
if (FALSE) { # \dontrun{
# Perform OCR on an image from a URL
ocr_results <- mistral_ocr_process_image("https://example.com/receipt.png")
} # }
```
