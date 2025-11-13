#' Process Document with Tensorlake OCR
#'
#' This function processes a document with Tensorlake's high-accuracy parsing service
#' (91.7% accuracy) and returns the OCR results. The function uploads the file, submits
#' a parse job, polls for completion, and returns the final result.
#'
#' @author Nathan C. Layman
#'
#' @param file_path Character string. Path to a local PDF, DOCX, PPTX, image, or text file.
#' @param tensorlake_api_key Character string. Tensorlake API key. Default retrieves from
#'   environment variable "TENSORLAKE_API_KEY".
#' @param max_wait_seconds Numeric. Maximum seconds to wait for parsing to complete. Default is 60.
#' @param poll_interval Numeric. Seconds between status checks. Default is 2.
#' @param output_file Character string. Optional path to save the JSON response to a file.
#'   Default is NULL (no file output).
#'
#' @return List. The parsed response from Tensorlake containing:
#'   \describe{
#'     \item{status}{Parse job status}
#'     \item{result}{Parsed document content with text, tables, and structured data}
#'     \item{metadata}{Document metadata}
#'   }
#'
#' @section Note:
#' Tensorlake offers superior accuracy (91.7%) compared to AWS Textract (88.4%) and
#' does not have the 5 MB file size limit of Textract's synchronous API. Pricing is
#' competitive at $0.01 per page.
#'
#' @examples
#' \dontrun{
#' # Process entire PDF with Tensorlake
#' result <- tensorlake_ocr("document.pdf")
#'
#' # Save output to JSON file
#' result <- tensorlake_ocr("document.pdf", output_file = "result.json")
#'
#' # Extract structured data from first 2 pages
#' pages <- tensorlake_extract_pages(result, pages = c(1, 2))
#' }
#'
#' @export
#'
#' @importFrom jsonlite write_json
tensorlake_ocr <- function(file_path,
                           tensorlake_api_key = Sys.getenv("TENSORLAKE_API_KEY"),
                           max_wait_seconds = 60,
                           poll_interval = 2,
                           output_file = NULL) {

  # Validate inputs
  if (is.null(tensorlake_api_key) || tensorlake_api_key == "") {
    stop("Tensorlake API key not found. Please set the TENSORLAKE_API_KEY environment variable or provide it as a parameter.",
         call. = FALSE)
  }

  if (is.null(file_path) || !file.exists(file_path)) {
    stop("File not found: ", file_path, call. = FALSE)
  }

  # Step 1: Upload file
  upload_response <- tensorlake_upload_file(
    file_path = file_path,
    tensorlake_api_key = tensorlake_api_key
  )

  file_id <- upload_response$file_id

  if (is.null(file_id)) {
    stop("Failed to get file ID from upload response.", call. = FALSE)
  }

  # Step 2: Submit parse job (parses entire document)
  parse_response <- tensorlake_parse_document(
    file_id = file_id,
    tensorlake_api_key = tensorlake_api_key,
    pages = NULL  # Tensorlake API doesn't support page selection
  )

  parse_id <- parse_response$parse_id %||% parse_response$id

  if (is.null(parse_id)) {
    stop("Failed to get parse ID from Tensorlake response.", call. = FALSE)
  }

  # Step 3: Poll for completion
  message("Waiting for parse job to complete...")
  start_time <- Sys.time()
  result <- NULL

  while (TRUE) {
    # Check if we've exceeded max wait time
    elapsed <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
    if (elapsed > max_wait_seconds) {
      stop("Parse job timed out after ", max_wait_seconds, " seconds. Parse ID: ", parse_id,
           call. = FALSE)
    }

    # Get current status
    result <- tensorlake_get_parse_result(
      parse_id = parse_id,
      tensorlake_api_key = tensorlake_api_key
    )

    status <- result$status %||% "unknown"

    if (status %in% c("completed", "successful")) {
      message("Parsing complete!")
      break
    } else if (status == "failed") {
      stop("Parse job failed. Error: ", result$error %||% "Unknown error", call. = FALSE)
    } else if (status %in% c("processing", "pending", "queued")) {
      message("Status: ", status, " (", round(elapsed, 1), "s elapsed)")
      Sys.sleep(poll_interval)
    } else {
      message("Unknown status: ", status, ". Continuing to poll...")
      Sys.sleep(poll_interval)
    }
  }

  # Save to file if requested
  if (!is.null(output_file)) {
    jsonlite::write_json(result, output_file, auto_unbox = TRUE, pretty = TRUE)
    message("Output saved to: ", output_file)
  }

  return(result)
}
