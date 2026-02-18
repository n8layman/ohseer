# Retrieve File Metadata from Mistral AI API

This function retrieves file metadata from the Mistral AI API using its
file ID.

## Usage

``` r
mistral_ocr_get_file_metadata(
  file_id,
  api_key = Sys.getenv("MISTRAL_API_KEY"),
  endpoint_base = "https://api.mistral.ai/v1"
)
```

## Arguments

- file_id:

  Character string. The ID of the file to retrieve.

- api_key:

  Character string. The Mistral AI API key. Default is to retrieve from
  environment variable "MISTRAL_API_KEY".

- endpoint_base:

  Character string. Base URL for the Mistral AI API. Default is
  "https://api.mistral.ai/v1".

## Value

A list containing the file metadata from the API response.

## Author

Nathan C. Layman

## Examples

``` r
if (FALSE) { # \dontrun{
# Retrieve file metadata
file_metadata <- mistral_ocr_get_file_metadata("00edaf84-95b0-45db-8f83-f71138491f23")

# Use a custom API endpoint
file_metadata <- mistral_ocr_get_file_metadata("00edaf84-95b0-45db-8f83-f71138491f23", 
                                        endpoint_base = "https://api.custom-mistral.ai/v1")
} # }
```
