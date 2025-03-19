#' Upload File to Mistral AI API for OCR Processing
#'
#' This function uploads a local file to the Mistral AI API for use with OCR processing.
#'
#' @author Nathan C. Layman
#'
#' @param file_path Character string. Path to the local file to upload.
#' @param purpose Character string. The purpose for which the file is being uploaded. Default is "ocr".
#' @param api_key Character string. The Mistral AI API key. Default is to retrieve from environment variable "MISTRAL_API_KEY".
#' @param endpoint Character string. The Mistral AI API endpoint URL. Default is "https://api.mistral.ai/v1/files".
#'
#' @return List. The parsed response from the Mistral AI API containing file metadata including the file ID.
#'
#' @examples
#' \dontrun{
#' # Upload a local PDF file
#' result <- mistral_ocr_upload_file("path/to/document.pdf")
#' 
#' # Use the returned file ID for OCR processing
#' file_id <- result$id
#' 
#' # Specify a custom endpoint
#' result <- mistral_ocr_upload_file("path/to/document.pdf", 
#'                                  endpoint = "https://api.custom-mistral.ai/v1/files")
#' }
#'
#' @export
#'
#' @importFrom httr2 request req_headers req_url_query req_body_file req_perform resp_body_json
#' @importFrom stringr str_squish
mistral_ocr_upload_file <- function(file_path, purpose = "ocr", api_key = Sys.getenv("MISTRAL_API_KEY"),
                                   endpoint = "https://api.mistral.ai/v1/files") {
  # Validate inputs
  if (is.null(api_key) || api_key == "") {
    stop("API key not found. Please set the MISTRAL_API_KEY environment variable or provide it as a parameter.")
  }
  
  if (!file.exists(file_path)) {
    stop("File does not exist: ", file_path)
  }
  
  # Strip any whitespace or quotes from the API key
  api_key <- stringr::str_squish(api_key)
  
  # Make the API request
  message("Uploading file to Mistral AI...")
  response <- tryCatch({
    httr2::request(endpoint) |>
      httr2::req_headers("Authorization" = paste0("Bearer ", api_key)) |>
      httr2::req_body_multipart(
        purpose = purpose,
        file = curl::form_file(file_path)  # Using curl::form_file instead of httr2::upload_file
      ) |>
      httr2::req_perform()
  }, error = function(e) {
    stop("File upload failed: ", e$message)
  })
    
  # Parse and return the response
  httr2::resp_body_json(response)
}
