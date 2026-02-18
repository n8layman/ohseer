# Get Parse Result from Tensorlake

This function retrieves the result of a Tensorlake parse job using the
parse ID. Tensorlake parsing is typically fast, but large documents may
take a few seconds.

## Usage

``` r
tensorlake_get_parse_result(
  parse_id,
  tensorlake_api_key,
  base_url = "https://api.tensorlake.ai"
)
```

## Arguments

- parse_id:

  Character string. The parse job ID returned from
  tensorlake_parse_document().

- tensorlake_api_key:

  Character string. Tensorlake API key.

- base_url:

  Character string. Base URL for Tensorlake API. Default is
  "https://api.tensorlake.ai".

## Value

List containing the parsed document data including:

- status:

  Job status (processing, completed, failed)

- result:

  Parsed document content with text, tables, and structured data

- metadata:

  Document metadata

## Author

Nathan C. Layman
