#' Process Document with Mistral AI OCR
#'
#' This function processes a document with Mistral AI OCR service and returns the recognized text and metadata.
#' It automatically detects whether the input is a URL, local file path, or file ID.
#'
#' @author Nathan C. Layman
#'
#' @param input Either a character string with a URL, a path to a local file, or a file ID from a previous upload.
#' @param input_type Character string. Type of input: "auto", "url", "file", or "file_id". Default is "auto".
#' @param api_key Character string. The Mistral AI API key. Default is to retrieve from environment variable "MISTRAL_API_KEY".
#' @param model Character string. The model to use for OCR processing. Default is "mistral-ocr-latest".
#' @param include_image_base64 Logical. Whether to include base64-encoded images in the response. Default is TRUE.
#' @param output_file Character string. Optional path to save the JSON response to a file. Default is NULL (no file output).
#' @param timeout Numeric. Timeout in seconds for file upload operations. Default is 60.
#'
#' @return List. The parsed response from the Mistral AI OCR API containing recognized text and metadata.
#'
#' @examples
#' \dontrun{
#' # Process a document with auto-detection of input type
#' result <- mistral_ocr("https://arxiv.org/pdf/2201.04234")
#' result <- mistral_ocr("path/to/local/document.pdf")
#' result <- mistral_ocr("00edaf84-95b0-45db-8f83-f71138491f23")
#'
#' # Explicitly specify input type
#' result <- mistral_ocr("https://arxiv.org/pdf/2201.04234", input_type = "url")
#' }
#'
#' @export
#'
#' @importFrom httr2 request req_headers req_body_json req_perform resp_body_json resp_status resp_body_string
#' @importFrom jsonlite toJSON write_json
#' @importFrom stringr str_detect str_squish
mistral_ocr <- function(input, input_type = "auto", api_key = Sys.getenv("MISTRAL_API_KEY"), 
                        model = "mistral-ocr-latest", include_image_base64 = TRUE, output_file = NULL, timeout = 60, ...) {
  
  # Validate inputs
  if (is.null(api_key) || api_key == "") {
    stop("API key not found. Please set the MISTRAL_API_KEY environment variable or provide it as a parameter.")
  }
  
  if (is.null(input) || input == "") {
    stop("Input document URL, file path, or file ID is required.")
  }
  
  # Clean API key (strip whitespace and quotes)
  api_key <- stringr::str_squish(api_key)
  
  # Auto-detect input type if set to "auto"
  if (input_type == "auto") {
    # Check if input is a URL (starts with http:// or https://)
    if (stringr::str_detect(input, "^https?://")) {
      input_type <- "url"
      message("Auto-detected input type: URL")
    }
    # Check if input is a local file path
    else if (file.exists(input)) {
      input_type <- "file"
      message("Auto-detected input type: local file")
    }
    # Otherwise, assume it's a file ID
    else {
      # Check if it looks like a UUID (basic check)
      if (stringr::str_detect(input, "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")) {
        input_type <- "file_id"
        message("Auto-detected input type: file ID")
      } else {
        # If not a UUID pattern and file doesn't exist, it might be a mistyped file path
        warning("Could not determine input type. Input doesn't exist as a local file and doesn't match URL or file ID patterns. Treating as file ID.")
        input_type <- "file_id"
      }
    }
  }

  ocr_results <- NULL

  if(input_type == "file") {
    response <- mistral_ocr_upload_file(input, timeout = timeout, ...)
    metadata <- mistral_ocr_get_file_metadata(response$id)
    document_url <- mistral_ocr_get_file_url(response$id)
    input_type <- "url"
    input <- document_url
  }

  if(input_type == "url") ocr_results <- mistral_ocr_process_url(input)

  return(ocr_results)
}
