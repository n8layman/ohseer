# Perform OCR on a Document using Mistral AI

This function sends a document to Mistral AI for Optical Character
Recognition (OCR) and returns the extracted text and layout information.

## Usage

``` r
mistral_ocr_process_url(
  document_url,
  model = "mistral-ocr-2512",
  include_image_base64 = TRUE,
  document_annotation_format = NULL,
  document_annotation_prompt = NULL,
  table_format = "markdown",
  extract_header = TRUE,
  extract_footer = TRUE,
  api_key = Sys.getenv("MISTRAL_API_KEY"),
  endpoint = "https://api.mistral.ai/v1/ocr"
)
```

## Arguments

- document_url:

  Character string. The URL to the document to process with OCR.

- model:

  Character string. The OCR model to use. Default is "mistral-ocr-2512".

- include_image_base64:

  Logical. Whether to include base64-encoded images in the response.
  Default is TRUE.

- document_annotation_format:

  List. Optional structured output format specification. Use list(type =
  "json_schema", json_schema = schema) for structured extraction.

- document_annotation_prompt:

  Character string. Optional prompt to guide structured extraction.

- table_format:

  Character string. Format for tables: "markdown" or "html". Default is
  "markdown".

- extract_header:

  Logical. Whether to extract page headers separately. Default is TRUE.
  Only available in OCR 2512 (OCR 3) or newer.

- extract_footer:

  Logical. Whether to extract page footers separately. Default is TRUE.
  Only available in OCR 2512 (OCR 3) or newer.

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
