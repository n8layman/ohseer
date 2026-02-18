# Get Temporary URL for Downloading File from Mistral AI API

This function obtains a temporary download URL for a file stored in the
Mistral AI service.

## Usage

``` r
mistral_ocr_get_file_url(
  file_id,
  expiry = 24,
  api_key = Sys.getenv("MISTRAL_API_KEY"),
  endpoint_base = "https://api.mistral.ai/v1"
)
```

## Arguments

- file_id:

  Character string. The ID of the file to download.

- expiry:

  Numeric. The number of hours the URL will remain valid. Default is 24.

- api_key:

  Character string. The Mistral AI API key. Default is to retrieve from
  environment variable "MISTRAL_API_KEY".

- endpoint_base:

  Character string. Base URL for the Mistral AI API. Default is
  "https://api.mistral.ai/v1".

## Value

A list containing the temporary URL and related metadata.

## Author

Nathan C. Layman

## Examples

``` r
if (FALSE) { # \dontrun{
# Get a temporary URL that expires in 24 hours
url_data <- mistral_ocr_get_file_url("00edaf84-95b0-45db-8f83-f71138491f23")

# Get a temporary URL that expires in 48 hours
url_data <- mistral_ocr_get_file_url("00edaf84-95b0-45db-8f83-f71138491f23", expiry = 48)
} # }
```
