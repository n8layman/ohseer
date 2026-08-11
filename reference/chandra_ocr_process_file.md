# Process Document with Chandra OCR (Datalab)

Submits a document to Datalab's document conversion API, which is
powered by the Chandra OCR model, and polls until the result is ready.
Chandra is academic-document oriented: it handles complex tables,
equations, forms and handwriting, and extracts figures/images as files.
Output is returned as paginated markdown plus a dictionary of extracted
images.

## Usage

``` r
chandra_ocr_process_file(
  file_path,
  api_key = Sys.getenv("DATALAB_API_KEY"),
  output_format = "markdown",
  mode = "balanced",
  use_llm = FALSE,
  langs = NULL,
  max_pages = NULL,
  endpoint = "https://www.datalab.to/api/v1/convert",
  timeout = 300,
  poll_interval = 2
)
```

## Arguments

- file_path:

  Character string. Path to a local PDF, PNG, JPEG, or other supported
  document.

- api_key:

  Character string. Datalab API key, sent in the `X-Api-Key` header.
  Default retrieves from environment variable "DATALAB_API_KEY".

- output_format:

  Character string. One of "markdown" (default), "html", "json", or
  "chunks".

- mode:

  Character string. Quality/speed tradeoff: "fast", "balanced"
  (default), or "accurate".

- use_llm:

  Logical. If TRUE, use an LLM pass to improve accuracy on tables,
  forms, and inline math (higher cost). Default is FALSE.

- langs:

  Character string. Optional comma-separated OCR language hints (e.g.
  "English"). Default is NULL (auto).

- max_pages:

  Integer. Optional cap on pages processed. Default is NULL.

- endpoint:

  Character string. Datalab convert endpoint. Default is
  "https://www.datalab.to/api/v1/convert".

- timeout:

  Numeric. Maximum seconds to wait for the async job. Default is 300.

- poll_interval:

  Numeric. Seconds between status polls. Default is 2.

## Value

A list mirroring the other providers, containing `structured_output`
with the raw `markdown` (paginated), `output_format`, `page_count`,
`images` (named list of base64 strings), and `metadata`.

## Details

The Datalab API is asynchronous: this function POSTs the file, then
polls the returned check URL until `status == "complete"`. Results are
deleted from Datalab's servers one hour after completion.

## Author

Nathan C. Layman
