# Parse Document with Tensorlake API

This function submits a document to Tensorlake for parsing using a file
ID from tensorlake_upload_file(). Tensorlake offers high-accuracy
document parsing (91.7% accuracy) with support for tables, forms, and
structured data extraction.

## Usage

``` r
tensorlake_parse_document(
  file_id,
  tensorlake_api_key,
  pages = NULL,
  base_url = "https://api.tensorlake.ai"
)
```

## Arguments

- file_id:

  Character string. Tensorlake file ID from tensorlake_upload_file().

- tensorlake_api_key:

  Character string. Tensorlake API key.

- pages:

  Character string. Optional page range to parse (e.g., "1-5" or
  "1,3,5").

- base_url:

  Character string. Base URL for Tensorlake API. Default is
  "https://api.tensorlake.ai".

## Value

List containing the parse job details including:

- parse_id:

  Unique ID for the parse job

- status:

  Job status (processing, completed, failed)

- result:

  Parsed document content (when completed)

## Author

Nathan C. Layman
