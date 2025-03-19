#' Retrieve File Metadata from Mistral AI API
#'
#' This function retrieves file metadata from the Mistral AI API using its file ID.
#'
#' @author Nathan C. Layman
#'
#' @param file_id Character string. The ID of the file to retrieve.
#' @param api_key Character string. The Mistral AI API key. Default is to retrieve from environment variable "MISTRAL_API_KEY".
#' @param endpoint_base Character string. Base URL for the Mistral AI API. Default is "https://api.mistral.ai/v1".
#'
#' @return A list containing the file metadata from the API response.
#'
#' @examples
#' \dontrun{
#' # Retrieve file metadata
#' file_metadata <- mistral_ocr_get_file_metadata("00edaf84-95b0-45db-8f83-f71138491f23")
#' 
#' # Use a custom API endpoint
#' file_metadata <- mistral_ocr_get_file_metadata("00edaf84-95b0-45db-8f83-f71138491f23", 
#'                                         endpoint_base = "https://api.custom-mistral.ai/v1")
#' }
#'
#' @export
#'
#' @importFrom httr2 request req_headers req_method req_perform resp_body_json
#' @importFrom stringr str_squish
mistral_ocr_get_file_metadata <- function(file_id, api_key = Sys.getenv("MISTRAL_API_KEY"),
                                  endpoint_base = "https://api.mistral.ai/v1") {
  # Validate inputs
  if (is.null(api_key) || api_key == "") {
    stop("API key not found. Please set the MISTRAL_API_KEY environment variable or provide it as a parameter.")
  }
  
  if (is.null(file_id) || file_id == "") {
    stop("File ID is required.")
  }
  
  # Clean API key
  api_key <- stringr::str_squish(api_key)
  
  # Define API endpoint
  url <- paste0(endpoint_base, "/files/", file_id)
  
  # Make the API request
  message("Retrieving file metadata from Mistral AI...")
  response <- tryCatch({
    httr2::request(url) |>
      httr2::req_method("GET") |>
      httr2::req_headers(
        "Authorization" = paste0("Bearer ", api_key)
      ) |>
      httr2::req_perform()
  }, error = function(e) {
    stop("File retrieval request failed: ", e$message)
  })
  
  # Parse and return the JSON response
  httr2::resp_body_json(response)
}
