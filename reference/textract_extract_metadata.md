# Extract Metadata from AWS Textract Response

This convenience function parses AWS Textract output to extract citation
metadata and other structured information from document headers. Useful
for extracting titles, authors, DOIs, journal names, dates, etc. from
academic papers.

## Usage

``` r
textract_extract_metadata(textract_response)
```

## Arguments

- textract_response:

  List. Response from textract_ocr().

## Value

List with the following structure:

- text:

  Character string. Full document text with line breaks.

- key_value_pairs:

  Data frame with columns: key, value, confidence. Contains extracted
  metadata like "Title:", "Author:", etc.

- tables:

  List of data frames, one per table.

- pages:

  Integer. Number of pages processed.

## Author

Nathan C. Layman

## Examples

``` r
if (FALSE) { # \dontrun{
# Process document with Textract
result <- textract_ocr("paper.pdf")

# Extract citation metadata
metadata <- textract_extract_metadata(result)

# Access extracted key-value pairs (e.g., Title, Authors, DOI)
metadata$key_value_pairs
} # }
```
