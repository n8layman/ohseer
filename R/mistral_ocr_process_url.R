#' Perform OCR on a Document using Mistral AI
#'
#' This function sends a document to Mistral AI for Optical Character Recognition (OCR)
#' and returns the extracted text and layout information.
#'
#' @author Nathan C. Layman
#'
#' @param document_url Character string. The URL to the document to process with OCR.
#' @param model Character string. The OCR model to use. Default is "mistral-ocr-2512".
#' @param include_image_base64 Logical. Whether to include base64-encoded images in the response. Default is TRUE.
#' @param document_annotation_format List. Optional structured output format specification.
#'   Use list(type = "json_schema", json_schema = schema) for structured extraction.
#' @param document_annotation_prompt Character string. Optional prompt to guide structured extraction.
#' @param table_format Character string. Format for tables: "markdown" or "html". Default is "markdown".
#' @param extract_header Logical. Whether to extract page headers separately. Default is TRUE.
#'   Only available in OCR 2512 (OCR 3) or newer.
#' @param extract_footer Logical. Whether to extract page footers separately. Default is TRUE.
#'   Only available in OCR 2512 (OCR 3) or newer.
#' @param api_key Character string. The Mistral AI API key. Default is to retrieve from environment variable "MISTRAL_API_KEY".
#' @param endpoint Character string. The OCR API endpoint. Default is "https://api.mistral.ai/v1/ocr".
#'
#' @return A list containing the OCR results, including extracted text and layout information.
#'
#' @export
#'
#' @importFrom httr2 request req_headers req_body_json req_perform resp_body_json
#' @importFrom stringr str_squish
mistral_ocr_process_url <- function(document_url,
                              model = "mistral-ocr-2512",
                              include_image_base64 = TRUE,
                              document_annotation_format = NULL,
                              document_annotation_prompt = NULL,
                              table_format = "markdown",
                              extract_header = TRUE,
                              extract_footer = TRUE,
                              api_key = Sys.getenv("MISTRAL_API_KEY"),
                              endpoint = "https://api.mistral.ai/v1/ocr") {
  # Validate inputs
  if (is.null(api_key) || api_key == "") {
    stop("API key not found. Please set the MISTRAL_API_KEY environment variable or provide it as a parameter.")
  }
  
  if (is.null(document_url) || document_url == "" || !is.character(document_url)) {
    stop("Valid document URL is required.")
  }
  
  # Clean API key
  api_key <- stringr::str_squish(api_key)
  
  # Prepare request body
  request_body <- list(
    model = model,
    document = list(
      type = "document_url",
      document_url = document_url
    ),
    include_image_base64 = include_image_base64,
    table_format = table_format,
    extract_header = extract_header,
    extract_footer = extract_footer
  )

  # Add structured output parameters if provided
  if (!is.null(document_annotation_format)) {
    request_body$document_annotation_format <- document_annotation_format
  }

  if (!is.null(document_annotation_prompt)) {
    request_body$document_annotation_prompt <- document_annotation_prompt
  }
  
  # Debug: Print the request body
  message("Request body: ", jsonlite::toJSON(request_body, auto_unbox = TRUE))
  
  # Make the API request
  message("Sending document for OCR processing...")
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
