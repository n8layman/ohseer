#' Parse Document with Tensorlake API
#'
#' This function submits a document to Tensorlake for parsing using a file ID from
#' tensorlake_upload_file(). Tensorlake offers high-accuracy document parsing (91.7%
#' accuracy) with support for tables, forms, and structured data extraction.
#'
#' @author Nathan C. Layman
#'
#' @param file_id Character string. Tensorlake file ID from tensorlake_upload_file().
#' @param tensorlake_api_key Character string. Tensorlake API key.
#' @param pages Character string. Optional page range to parse (e.g., "1-5" or "1,3,5").
#' @param base_url Character string. Base URL for Tensorlake API. Default is "https://api.tensorlake.ai".
#'
#' @return List containing the parse job details including:
#'   \describe{
#'     \item{parse_id}{Unique ID for the parse job}
#'     \item{status}{Job status (processing, completed, failed)}
#'     \item{result}{Parsed document content (when completed)}
#'   }
#'
#' @keywords internal
#'
#' @importFrom httr2 request req_headers req_auth_bearer_token req_body_json req_perform resp_body_json
tensorlake_parse_document <- function(file_id,
                                       tensorlake_api_key,
                                       pages = NULL,
                                       base_url = "https://api.tensorlake.ai") {

  # Validate inputs
  if (is.null(file_id) || file_id == "") {
    stop("File ID is required.", call. = FALSE)
  }

  if (is.null(tensorlake_api_key) || tensorlake_api_key == "") {
    stop("Tensorlake API key is required.", call. = FALSE)
  }

  # Prepare request body with file_id
  request_body <- list(
    file_id = file_id
  )

  # Add optional parameters
  if (!is.null(pages)) {
    request_body$pages <- pages
  }

  # Make the API request
  message("Sending document to Tensorlake for parsing...")
  endpoint <- paste0(base_url, "/documents/v2/parse")

  response <- httr2::request(endpoint) |>
    httr2::req_auth_bearer_token(tensorlake_api_key) |>
    httr2::req_body_json(request_body) |>
    httr2::req_error(body = function(resp) {
      tryCatch({
        body <- httr2::resp_body_json(resp)
        paste0("Tensorlake Error: ", body$message %||% body$error %||% "Unknown error")
      }, error = function(e) {
        paste0("HTTP ", httr2::resp_status(resp), ": ", httr2::resp_body_string(resp))
      })
    }) |>
    httr2::req_perform()

  # Parse response
  result <- httr2::resp_body_json(response)

  message("Document parsing initiated. Parse ID: ", result$parse_id %||% result$id %||% "unknown")
  return(result)
}
