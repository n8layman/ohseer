#' Detect Text in Document with AWS Textract (Synchronous)
#'
#' This function calls the AWS Textract DetectDocumentText API (synchronous) to extract
#' plain text from documents. This is faster than AnalyzeDocument but doesn't extract
#' structured data like forms or tables. Note: This is a synchronous operation with a
#' 5 MB file size limit. For larger files, the function automatically converts the
#' first 2 pages to PNG format.
#'
#' @author Nathan C. Layman
#'
#' @param file_path Character string. Path to a local PDF, PNG, JPEG, or TIFF file.
#' @param aws_access_key_id Character string. AWS access key ID.
#' @param aws_secret_access_key Character string. AWS secret access key.
#' @param aws_region Character string. AWS region. Default is "us-east-1".
#'
#' @return List containing the raw Textract API response with Blocks.
#'
#' @section Warning:
#' This function uses the synchronous Textract API which has a **5 MB file size limit**.
#' For PDFs larger than 5 MB, only the first 2 pages will be automatically extracted and
#' converted to PNG format. For full document processing of large files, consider using
#' the asynchronous S3-based Textract workflow or an alternative service like Google
#' Document AI (20 MB limit) or Azure Document Intelligence (500 MB limit).
#'
#' @export
textract_detect_document_text <- function(file_path,
                                          aws_access_key_id,
                                          aws_secret_access_key,
                                          aws_region = "us-east-1") {

  # Check file size and handle PDFs over 5MB by extracting first 2 pages
  file_size <- file.info(file_path)$size
  file_size_mb <- file_size / 1024 / 1024
  temp_file <- NULL

  if (file_size_mb > 5 && grepl("\\.pdf$", file_path, ignore.case = TRUE)) {
    message("File exceeds 5 MB limit. Extracting first 2 pages...")
    temp_file <- tempfile(fileext = ".pdf")
    pdftools::pdf_subset(file_path, pages = 1:2, output = temp_file)
    file_path <- temp_file
    file_size <- file.info(file_path)$size
    file_size_mb <- file_size / 1024 / 1024
    message("Reduced file size: ", round(file_size_mb, 2), " MB")

    # Check if still too large after extraction
    if (file_size_mb > 5) {
      unlink(temp_file)
      stop(
        "First 2 pages (", round(file_size_mb, 2), " MB) still exceed 5 MB limit. ",
        "Please use S3 and asynchronous processing.",
        call. = FALSE
      )
    }
  } else if (file_size_mb > 5) {
    stop(
      "File size (", round(file_size_mb, 2), " MB) exceeds the 5 MB limit for synchronous processing. ",
      "Please use a smaller file or upload to S3 and use asynchronous processing.",
      call. = FALSE
    )
  }

  # Read file as raw bytes
  file_bytes <- readBin(file_path, "raw", file_size)

  # Clean up temp file if created
  if (!is.null(temp_file)) {
    on.exit(unlink(temp_file), add = TRUE)
  }

  # Create Textract client with credentials
  textract <- paws.machine.learning::textract(
    config = list(
      credentials = list(
        creds = list(
          access_key_id = aws_access_key_id,
          secret_access_key = aws_secret_access_key
        )
      ),
      region = aws_region
    )
  )

  # Make the API request
  message("Sending document to AWS Textract DetectDocumentText...")
  result <- tryCatch({
    textract$detect_document_text(
      Document = list(
        Bytes = file_bytes
      )
    )
  }, error = function(e) {
    stop("Textract DetectDocumentText request failed: ", e$message, call. = FALSE)
  })

  # Return the result
  message("Text detection complete.")
  return(result)
}
