#' Get Parse Result from Tensorlake
#'
#' This function retrieves the result of a Tensorlake parse job using the parse ID.
#' Tensorlake parsing is typically fast, but large documents may take a few seconds.
#'
#' @author Nathan C. Layman
#'
#' @param parse_id Character string. The parse job ID returned from tensorlake_parse_document().
#' @param tensorlake_api_key Character string. Tensorlake API key.
#' @param base_url Character string. Base URL for Tensorlake API. Default is "https://api.tensorlake.ai".
#'
#' @return List containing the parsed document data including:
#'   \describe{
#'     \item{status}{Job status (processing, completed, failed)}
#'     \item{result}{Parsed document content with text, tables, and structured data}
#'     \item{metadata}{Document metadata}
#'   }
#'
#' @keywords internal
#'
#' @importFrom httr2 request req_headers req_auth_bearer_token req_perform resp_body_json
tensorlake_get_parse_result <- function(parse_id,
                                         tensorlake_api_key,
                                         base_url = "https://api.tensorlake.ai") {

  # Validate inputs
  if (is.null(parse_id) || parse_id == "") {
    stop("Parse ID is required.", call. = FALSE)
  }

  if (is.null(tensorlake_api_key) || tensorlake_api_key == "") {
    stop("Tensorlake API key is required.", call. = FALSE)
  }

  # Build endpoint URL
  endpoint <- paste0(base_url, "/documents/v2/parse/", parse_id)

  # Make the API request
  response <- httr2::request(endpoint) |>
    httr2::req_headers(
      "Content-Type" = "application/json"
    ) |>
    httr2::req_auth_bearer_token(tensorlake_api_key) |>
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

  return(result)
}
