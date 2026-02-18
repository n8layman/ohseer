# Upload File to Tensorlake

This function uploads a file to Tensorlake and returns a file ID that
can be used for parsing operations.

## Usage

``` r
tensorlake_upload_file(
  file_path,
  tensorlake_api_key,
  labels = NULL,
  base_url = "https://api.tensorlake.ai"
)
```

## Arguments

- file_path:

  Character string. Path to the local file to upload.

- tensorlake_api_key:

  Character string. Tensorlake API key.

- labels:

  List. Optional metadata labels to attach to the file.

- base_url:

  Character string. Base URL for Tensorlake API. Default is
  "https://api.tensorlake.ai".

## Value

List containing:

- file_id:

  Unique identifier for the uploaded file

## Author

Nathan C. Layman
