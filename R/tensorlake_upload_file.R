#' Upload File to Tensorlake
#'
#' This function uploads a file to Tensorlake and returns a file ID that can be
#' used for parsing operations.
#'
#' @author Nathan C. Layman
#'
#' @param file_path Character string. Path to the local file to upload.
#' @param tensorlake_api_key Character string. Tensorlake API key.
#' @param labels List. Optional metadata labels to attach to the file.
#' @param base_url Character string. Base URL for Tensorlake API. Default is "https://api.tensorlake.ai".
#'
#' @return List containing:
#'   \describe{
#'     \item{file_id}{Unique identifier for the uploaded file}
#'   }
#'
#' @export
#'
#' @importFrom httr2 request req_headers req_auth_bearer_token req_body_multipart req_perform resp_body_json
tensorlake_upload_file <- function(file_path,
                                    tensorlake_api_key,
                                    labels = NULL,
                                    base_url = "https://api.tensorlake.ai") {

  # Validate inputs
  if (is.null(file_path) || !file.exists(file_path)) {
    stop("File not found: ", file_path, call. = FALSE)
  }

  if (is.null(tensorlake_api_key) || tensorlake_api_key == "") {
    stop("Tensorlake API key is required.", call. = FALSE)
  }

  # Build endpoint URL
  endpoint <- paste0(base_url, "/documents/v2/files")

  # Prepare multipart body
  body_parts <- list(
    file_bytes = curl::form_file(file_path)
  )

  # Add labels if provided
  if (!is.null(labels)) {
    body_parts$labels <- jsonlite::toJSON(labels, auto_unbox = TRUE)
  }

  # Make the API request
  message("Uploading file to Tensorlake...")
  response <- httr2::request(endpoint) |>
    httr2::req_method("PUT") |>
    httr2::req_auth_bearer_token(tensorlake_api_key) |>
    httr2::req_body_multipart(!!!body_parts) |>
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

  message("File uploaded. File ID: ", result$file_id %||% "unknown")
  return(result)
}
