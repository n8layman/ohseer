# Process Document with Mistral AI OCR

This function processes a document with Mistral AI OCR service and
returns the recognized text and metadata. It automatically detects
whether the input is a URL, local file path, or file ID.

## Usage

``` r
mistral_ocr(
  input,
  input_type = "auto",
  api_key = Sys.getenv("MISTRAL_API_KEY"),
  model = "mistral-ocr-2512",
  include_image_base64 = TRUE,
  document_annotation_format = NULL,
  document_annotation_prompt = NULL,
  table_format = "markdown",
  extract_header = TRUE,
  extract_footer = TRUE,
  output_file = NULL,
  timeout = 60,
  ...
)
```

## Arguments

- input:

  Either a character string with a URL, a path to a local file, or a
  file ID from a previous upload.

- input_type:

  Character string. Type of input: "auto", "url", "file", or "file_id".
  Default is "auto".

- api_key:

  Character string. The Mistral AI API key. Default is to retrieve from
  environment variable "MISTRAL_API_KEY".

- model:

  Character string. The model to use for OCR processing. Default is
  "mistral-ocr-2512".

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

- extract_footer:

  Logical. Whether to extract page footers separately. Default is TRUE.

- output_file:

  Character string. Optional path to save the JSON response to a file.
  Default is NULL (no file output).

- timeout:

  Numeric. Timeout in seconds for file upload operations. Default is 60.

## Value

List. The parsed response from the Mistral AI OCR API containing
recognized text and metadata.

## Author

Nathan C. Layman

## Examples

``` r
if (FALSE) { # \dontrun{
# Process a document with auto-detection of input type
result <- mistral_ocr("https://arxiv.org/pdf/2201.04234")
result <- mistral_ocr("path/to/local/document.pdf")
result <- mistral_ocr("00edaf84-95b0-45db-8f83-f71138491f23")

# Explicitly specify input type
result <- mistral_ocr("https://arxiv.org/pdf/2201.04234", input_type = "url")
} # }
```
