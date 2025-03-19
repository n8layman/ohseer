#' Perform OCR on an Image using Mistral AI
#'
#' This function sends an image to Mistral AI for Optical Character Recognition (OCR)
#' and returns the extracted text and layout information.
#'
#' @author Nathan C. Layman
#'
#' @param image_url Character string. The URL to the image to process with OCR.
#' @param model Character string. The OCR model to use. Default is "mistral-ocr-latest".
#' @param include_image_base64 Logical. Whether to include base64-encoded images in the response. Default is TRUE.
#' @param api_key Character string. The Mistral AI API key. Default is to retrieve from environment variable "MISTRAL_API_KEY".
#' @param endpoint Character string. The OCR API endpoint. Default is "https://api.mistral.ai/v1/ocr".
#'
#' @return A list containing the OCR results, including extracted text and layout information.
#'
#' @examples
#' \dontrun{
#' # Perform OCR on an image from a URL
#' ocr_results <- mistral_ocr_process_image("https://example.com/receipt.png")
#' }
#'
#' @export
#'
#' @importFrom httr2 request req_headers req_body_json req_perform resp_body_json
#' @importFrom stringr str_squish
mistral_ocr_process_image <- function(image_url, model = "mistral-ocr-latest", include_image_base64 = TRUE,
                                   api_key = Sys.getenv("MISTRAL_API_KEY"),
                                   endpoint = "https://api.mistral.ai/v1/ocr") {
  # Validate inputs
  if (is.null(api_key) || api_key == "") {
    stop("API key not found. Please set the MISTRAL_API_KEY environment variable or provide it as a parameter.")
  }
  
  if (is.null(image_url) || image_url == "") {
    stop("Image URL is required.")
  }
  
  # Clean API key
  api_key <- stringr::str_squish(api_key)
  
  # Prepare request body
  request_body <- list(
    model = model,
    document = list(
      type = "image_url",
      image_url = image_url
    )
  )
  
  # Add include_image_base64 if specified
  if (!is.null(include_image_base64)) {
    request_body$include_image_base64 <- include_image_base64
  }
  
  # Make the API request
  message("Sending image for OCR processing...")
  response <- tryCatch({
    httr2::request(endpoint) |>
      httr2::req_headers(
        "Content-Type" = "application/json",
        "Authorization" = paste0("Bearer ", api_key)
      ) |>
      httr2::req_body_json(request_body) |>
      httr2::req_perform()
  }, error = function(e) {
    stop("OCR processing request failed: ", e$message)
  })
  
  # Parse and return the JSON response
  message("OCR processing complete.")
  httr2::resp_body_json(response)
}
