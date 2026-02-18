library(ohseer)
library(httr2)

# Test schema directly
schema <- list(
  type = "json_schema",
  json_schema = list(
    name = "test",
    strict = TRUE,
    schema = list(
      type = "object",
      properties = list(
        text = list(type = "string")
      ),
      required = list("text"),  # Should be array
      additionalProperties = FALSE
    )
  )
)

# Upload file first
file_id <- mistral_ocr_upload_file("data/articles/0090-3558-30_3_439.pdf")$id
doc_url <- mistral_ocr_get_file_url(file_id)

# Make direct API call to see error
response <- tryCatch({
  request("https://api.mistral.ai/v1/ocr") |>
    req_headers(
      "Content-Type" = "application/json",
      "Authorization" = paste0("Bearer ", Sys.getenv("MISTRAL_API_KEY"))
    ) |>
    req_body_json(list(
      model = "mistral-ocr-2512",
      document = list(type = "document_url", document_url = doc_url),
      document_annotation_format = schema
    )) |>
    req_error(is_error = \(resp) FALSE) |>  # Don't error on non-200
    req_perform()
}, error = function(e) e)

cat("Status:", resp_status(response), "\n")
cat("Body:\n")
cat(resp_body_string(response), "\n")
