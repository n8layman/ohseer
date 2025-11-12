#' Analyze Document with AWS Textract (Structured Extraction)
#'
#' This function calls AWS Textract AnalyzeDocument API to extract structured data
#' including forms (key-value pairs), tables, and layout from documents.
#'
#' @author Nathan C. Layman
#'
#' @param file_path Character string. Path to a local PDF, PNG, JPEG, or TIFF file.
#' @param features Character vector. Features to extract: "TABLES", "FORMS", "LAYOUT", "SIGNATURES".
#' @param aws_access_key_id Character string. AWS access key ID.
#' @param aws_secret_access_key Character string. AWS secret access key.
#' @param aws_region Character string. AWS region. Default is "us-east-1".
#'
#' @return List containing the raw Textract API response with Blocks.
#'
#' @export
#'
#' @importFrom httr2 request req_body_json req_headers req_auth_aws_v4 req_perform resp_body_json
#' @importFrom jsonlite toJSON
textract_analyze_document <- function(file_path,
                                      features = c("TABLES", "FORMS"),
                                      aws_access_key_id,
                                      aws_secret_access_key,
                                      aws_region = "us-east-1") {

  # Read file as raw bytes
  file_bytes <- readBin(file_path, "raw", file.info(file_path)$size)
  file_base64 <- base64enc::base64encode(file_bytes)

  # Prepare request body
  request_body <- list(
    Document = list(
      Bytes = file_base64
    ),
    FeatureTypes = as.list(features)
  )

  # AWS Textract endpoint
  endpoint <- paste0("https://textract.", aws_region, ".amazonaws.com")
  target <- "Textract.AnalyzeDocument"

  # Make the API request
  message("Sending document to AWS Textract AnalyzeDocument...")
  response <- tryCatch({
    httr2::request(endpoint) |>
      httr2::req_headers(
        "Content-Type" = "application/x-amz-json-1.1",
        "X-Amz-Target" = target
      ) |>
      httr2::req_body_json(request_body) |>
      httr2::req_auth_aws_v4(
        aws_access_key_id = aws_access_key_id,
        aws_secret_access_key = aws_secret_access_key,
        aws_service = "textract",
        aws_region = aws_region
      ) |>
      httr2::req_perform()
  }, error = function(e) {
    stop("Textract AnalyzeDocument request failed: ", e$message)
  })

  # Parse and return the JSON response
  message("Document analysis complete.")
  result <- httr2::resp_body_json(response)

  return(result)
}
