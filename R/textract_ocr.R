#' Process Document with AWS Textract OCR
#'
#' This function processes a document with AWS Textract service and returns the OCR results.
#' It's an alternative to mistral_ocr() that provides better structured output for forms and tables.
#'
#' @author Nathan C. Layman
#'
#' @param file_path Character string. Path to a local PDF, PNG, JPEG, or TIFF file.
#' @param features Character vector. Features to extract. Options: "TABLES", "FORMS", "LAYOUT", "SIGNATURES".
#'   Default is c("TABLES", "FORMS") for structured extraction. Set to NULL for simple text extraction.
#' @param aws_access_key_id Character string. AWS access key ID. Default retrieves from environment variable "AWS_ACCESS_KEY_ID".
#' @param aws_secret_access_key Character string. AWS secret access key. Default retrieves from environment variable "AWS_SECRET_ACCESS_KEY".
#' @param aws_region Character string. AWS region. Default retrieves from environment variable "AWS_REGION" or "us-east-1" if not set.
#' @param output_file Character string. Optional path to save the JSON response to a file. Default is NULL (no file output).
#'
#' @return List. The parsed response from AWS Textract containing:
#'   \describe{
#'     \item{Blocks}{List of detected blocks (text, tables, forms, etc.)}
#'     \item{DocumentMetadata}{Metadata about the document}
#'   }
#'
#' @examples
#' \dontrun{
#' # Process a PDF with structured extraction (tables and forms)
#' result <- textract_ocr("document.pdf")
#'
#' # Just extract text (faster, no structured data)
#' result <- textract_ocr("document.pdf", features = NULL)
#'
#' # Extract citation metadata from the result
#' metadata <- textract_extract_metadata(result)
#'
#' # Save output to JSON file
#' result <- textract_ocr("document.pdf", output_file = "result.json")
#' }
#'
#' @export
#'
#' @importFrom jsonlite write_json
textract_ocr <- function(file_path,
                         features = c("TABLES", "FORMS"),
                         aws_access_key_id = Sys.getenv("AWS_ACCESS_KEY_ID"),
                         aws_secret_access_key = Sys.getenv("AWS_SECRET_ACCESS_KEY"),
                         aws_region = Sys.getenv("AWS_REGION", unset = "us-east-1"),
                         output_file = NULL) {

  # Validate inputs
  if (is.null(aws_access_key_id) || aws_access_key_id == "") {
    stop("AWS access key ID not found. Please set the AWS_ACCESS_KEY_ID environment variable or provide it as a parameter.")
  }

  if (is.null(aws_secret_access_key) || aws_secret_access_key == "") {
    stop("AWS secret access key not found. Please set the AWS_SECRET_ACCESS_KEY environment variable or provide it as a parameter.")
  }

  if (is.null(file_path) || !file.exists(file_path)) {
    stop("File not found: ", file_path)
  }

  # Determine which API to call based on features
  if (is.null(features) || length(features) == 0) {
    # Simple text detection (faster, synchronous)
    message("Using DetectDocumentText (text only, no structured data)...")
    result <- textract_detect_document_text(
      file_path = file_path,
      aws_access_key_id = aws_access_key_id,
      aws_secret_access_key = aws_secret_access_key,
      aws_region = aws_region
    )
  } else {
    # Analyze document with features (structured extraction)
    message("Using AnalyzeDocument with features: ", paste(features, collapse = ", "))
    result <- textract_analyze_document(
      file_path = file_path,
      features = features,
      aws_access_key_id = aws_access_key_id,
      aws_secret_access_key = aws_secret_access_key,
      aws_region = aws_region
    )
  }

  # Save to file if requested
  if (!is.null(output_file)) {
    jsonlite::write_json(result, output_file, auto_unbox = TRUE, pretty = TRUE)
    message("Output saved to: ", output_file)
  }

  return(result)
}
