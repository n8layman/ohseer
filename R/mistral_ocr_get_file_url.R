#' Get Temporary URL for Downloading File from Mistral AI API
#'
#' This function obtains a temporary download URL for a file stored in the Mistral AI service.
#'
#' @author Nathan C. Layman
#'
#' @param file_id Character string. The ID of the file to download.
#' @param expiry Numeric. The number of hours the URL will remain valid. Default is 24.
#' @param api_key Character string. The Mistral AI API key. Default is to retrieve from environment variable "MISTRAL_API_KEY".
#' @param endpoint_base Character string. Base URL for the Mistral AI API. Default is "https://api.mistral.ai/v1".
#'
#' @return A list containing the temporary URL and related metadata.
#'
#' @examples
#' \dontrun{
#' # Get a temporary URL that expires in 24 hours
#' url_data <- mistral_ocr_get_file_url("00edaf84-95b0-45db-8f83-f71138491f23")
#' 
#' # Get a temporary URL that expires in 48 hours
#' url_data <- mistral_ocr_get_file_url("00edaf84-95b0-45db-8f83-f71138491f23", expiry = 48)
#' }
#'
#' @export
#'
#' @importFrom httr2 request req_method req_headers req_url_query req_perform resp_body_json
#' @importFrom stringr str_squish
mistral_ocr_get_file_url <- function(file_id, expiry = 24, api_key = Sys.getenv("MISTRAL_API_KEY"),
                                   endpoint_base = "https://api.mistral.ai/v1") {
  # Validate inputs
  if (is.null(api_key) || api_key == "") {
    stop("API key not found. Please set the MISTRAL_API_KEY environment variable or provide it as a parameter.")
  }
  
  if (is.null(file_id) || file_id == "") {
    stop("File ID is required.")
  }
  
  if (!is.numeric(expiry) || expiry <= 0) {
    stop("Expiry must be a positive number representing hours.")
  }
  
  # Clean API key
  api_key <- stringr::str_squish(api_key)
  
  # Define API endpoint
  url <- paste0(endpoint_base, "/files/", file_id, "/url")
  
  # Make the API request
  message("Getting temporary download URL from Mistral AI...")
  response <- tryCatch({
    httr2::request(url) |>
      httr2::req_method("GET") |>
      httr2::req_headers(
        "Accept" = "application/json",
        "Authorization" = paste0("Bearer ", api_key)
      ) |>
      httr2::req_url_query(expiry = as.character(expiry)) |>
      httr2::req_perform()
  }, error = function(e) {
    stop("Failed to get download URL: ", e$message)
  })
  
  # Parse and return the JSON response
  httr2::resp_body_json(response)$url
}
