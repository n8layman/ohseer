# Process Document with Tensorlake OCR

This function processes a document with Tensorlake's high-accuracy
parsing service (91.7% accuracy) and returns the OCR results. The
function uploads the file, submits a parse job, polls for completion,
and returns the final result.

## Usage

``` r
tensorlake_ocr(
  file_path,
  pages = NULL,
  tensorlake_api_key = Sys.getenv("TENSORLAKE_API_KEY"),
  max_wait_seconds = 60,
  poll_interval = 2,
  output_file = NULL
)
```

## Arguments

- file_path:

  Character string. Path to a local PDF, DOCX, PPTX, image, or text
  file.

- pages:

  Integer vector or character string. Optional page range to parse. Can
  be a vector like c(1, 2) or 1:5, or a string like "1-5" or "1,3,5". If
  NULL (default), parses entire document.

- tensorlake_api_key:

  Character string. Tensorlake API key. Default retrieves from
  environment variable "TENSORLAKE_API_KEY".

- max_wait_seconds:

  Numeric. Maximum seconds to wait for parsing to complete. Default is
  60.

- poll_interval:

  Numeric. Seconds between status checks. Default is 2.

- output_file:

  Character string. Optional path to save the JSON response to a file.
  Default is NULL (no file output).

## Value

List. The parsed response from Tensorlake containing:

- status:

  Parse job status

- result:

  Parsed document content with text, tables, and structured data

- metadata:

  Document metadata

## Note

Tensorlake offers superior accuracy (91.7%) compared to AWS Textract
(88.4%) and does not have the 5 MB file size limit of Textract's
synchronous API. Pricing is competitive at \$0.01 per page.

## Author

Nathan C. Layman

## Examples

``` r
if (FALSE) { # \dontrun{
# Process entire PDF with Tensorlake
result <- tensorlake_ocr("document.pdf")

# Process only first 2 pages (faster, cheaper)
result <- tensorlake_ocr("document.pdf", pages = c(1, 2))

# Save output to JSON file
result <- tensorlake_ocr("document.pdf", output_file = "result.json")

# Extract structured data
pages <- tensorlake_extract_pages(result, pages = c(1, 2))
} # }
```
