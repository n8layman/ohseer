# Process Document with AWS Textract OCR (Synchronous)

This function processes a document with AWS Textract service
(synchronous API) and returns the OCR results. It's an alternative to
mistral_ocr() that provides better structured output for forms and
tables. Note: This uses synchronous processing with a 5 MB file size
limit. For larger PDFs, the function automatically converts the first 2
pages to PNG format.

## Usage

``` r
textract_ocr(
  file_path,
  features = c("TABLES", "FORMS"),
  aws_access_key_id = Sys.getenv("AWS_ACCESS_KEY_ID"),
  aws_secret_access_key = Sys.getenv("AWS_SECRET_ACCESS_KEY"),
  aws_region = Sys.getenv("AWS_REGION", unset = "us-east-1"),
  max_pages = 2,
  output_file = NULL
)
```

## Arguments

- file_path:

  Character string. Path to a local PDF, PNG, JPEG, or TIFF file.

- features:

  Character vector. Features to extract. Options: "TABLES", "FORMS",
  "LAYOUT", "SIGNATURES". Default is c("TABLES", "FORMS") for structured
  extraction. Set to NULL for simple text extraction.

- aws_access_key_id:

  Character string. AWS access key ID. Default retrieves from
  environment variable "AWS_ACCESS_KEY_ID".

- aws_secret_access_key:

  Character string. AWS secret access key. Default retrieves from
  environment variable "AWS_SECRET_ACCESS_KEY".

- aws_region:

  Character string. AWS region. Default retrieves from environment
  variable "AWS_REGION" or "us-east-1" if not set.

- max_pages:

  Integer. Maximum number of pages to process for large PDFs. Default
  is 2. Set to NULL to process all pages (will chunk automatically).

- output_file:

  Character string. Optional path to save the JSON response to a file.
  Default is NULL (no file output).

## Value

List. The parsed response from AWS Textract containing:

- Blocks:

  List of detected blocks (text, tables, forms, etc.)

- DocumentMetadata:

  Metadata about the document

## Warning

This function uses the synchronous Textract API which has a **5 MB file
size limit**. For PDFs larger than 5 MB, only the first 2 pages will be
automatically extracted and converted to PNG format. For full document
processing of large files, consider using the asynchronous S3-based
Textract workflow or an alternative service like Google Document AI (20
MB limit) or Azure Document Intelligence (500 MB limit).

## Author

Nathan C. Layman

## Examples

``` r
if (FALSE) { # \dontrun{
# Process a PDF with structured extraction (tables and forms)
result <- textract_ocr("document.pdf")

# Just extract text (faster, no structured data)
result <- textract_ocr("document.pdf", features = NULL)

# Extract citation metadata from the result
metadata <- textract_extract_metadata(result)

# Save output to JSON file
result <- textract_ocr("document.pdf", output_file = "result.json")
} # }
```
