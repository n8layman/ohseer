#' Process Document with AWS Textract OCR (Synchronous)
#'
#' This function processes a document with AWS Textract service (synchronous API) and returns
#' the OCR results. It's an alternative to mistral_ocr() that provides better structured output
#' for forms and tables. Note: This uses synchronous processing with a 5 MB file size limit.
#' For larger PDFs, the function automatically converts the first 2 pages to PNG format.
#'
#' @author Nathan C. Layman
#'
#' @param file_path Character string. Path to a local PDF, PNG, JPEG, or TIFF file.
#' @param features Character vector. Features to extract. Options: "TABLES", "FORMS", "LAYOUT", "SIGNATURES".
#'   Default is c("TABLES", "FORMS") for structured extraction. Set to NULL for simple text extraction.
#' @param aws_access_key_id Character string. AWS access key ID. Default retrieves from environment variable "AWS_ACCESS_KEY_ID".
#' @param aws_secret_access_key Character string. AWS secret access key. Default retrieves from environment variable "AWS_SECRET_ACCESS_KEY".
#' @param aws_region Character string. AWS region. Default retrieves from environment variable "AWS_REGION" or "us-east-1" if not set.
#' @param max_pages Integer. Maximum number of pages to process for large PDFs. Default is 2. Set to NULL to process all pages (will chunk automatically).
#' @param output_file Character string. Optional path to save the JSON response to a file. Default is NULL (no file output).
#'
#' @return List. The parsed response from AWS Textract containing:
#'   \describe{
#'     \item{Blocks}{List of detected blocks (text, tables, forms, etc.)}
#'     \item{DocumentMetadata}{Metadata about the document}
#'   }
#'
#' @section Warning:
#' This function uses the synchronous Textract API which has a **5 MB file size limit**.
#' For PDFs larger than 5 MB, only the first 2 pages will be automatically extracted and
#' converted to PNG format. For full document processing of large files, consider using
#' the asynchronous S3-based Textract workflow or an alternative service like Google
#' Document AI (20 MB limit) or Azure Document Intelligence (500 MB limit).
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
                         max_pages = 2,
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
