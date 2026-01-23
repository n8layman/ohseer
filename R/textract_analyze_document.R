#' Analyze Document with AWS Textract (Synchronous, Structured Extraction)
#'
#' This function calls the AWS Textract AnalyzeDocument API (synchronous) to extract
#' structured data including forms (key-value pairs), tables, and layout from documents.
#' Note: This is a synchronous operation with a 5 MB file size limit. For larger files,
#' the function automatically converts the first 2 pages to PNG format.
#'
#' @author Nathan C. Layman
#'
#' @param file_path Character string. Path to a local PDF, PNG, JPEG, or TIFF file.
#' @param features Character vector. Features to extract: "TABLES", "FORMS", "LAYOUT", "SIGNATURES".
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
textract_analyze_document <- function(file_path,
                                      features = c("TABLES", "FORMS"),
                                      aws_access_key_id,
                                      aws_secret_access_key,
                                      aws_region = "us-east-1") {

  # Check file size and handle PDFs over 5MB by converting first 2 pages to PNG
  file_size <- file.info(file_path)$size
  file_size_mb <- file_size / 1024 / 1024
  temp_files <- NULL
  multi_page <- FALSE

  if (file_size_mb > 5 && grepl("\\.pdf$", file_path, ignore.case = TRUE)) {
    if (!requireNamespace("pdftools", quietly = TRUE)) {
      stop(
        "File size (", round(file_size_mb, 2), " MB) exceeds the 5 MB limit. ",
        "Install 'pdftools' to automatically convert large PDFs: install.packages('pdftools')",
        call. = FALSE
      )
    }
    message("File exceeds 5 MB limit. Converting first 2 pages to PNG...")
    # Convert first 2 pages to PNG (more compatible format)
    png_files <- pdftools::pdf_convert(file_path, pages = 1:2, format = "png", dpi = 150, verbose = FALSE)
    temp_files <- png_files

    # If multiple pages, we'll process them separately and combine results
    if (length(png_files) > 1) {
      multi_page <- TRUE
      file_path <- png_files[1]  # Start with first page
    } else {
      file_path <- png_files[1]
    }

    file_size <- file.info(file_path)$size
    file_size_mb <- file_size / 1024 / 1024
    message("Converted to PNG. File size: ", round(file_size_mb, 2), " MB per page")
  } else if (file_size_mb > 5) {
    stop(
      "File size (", round(file_size_mb, 2), " MB) exceeds the 5 MB limit for synchronous processing. ",
      "Please use a smaller file or upload to S3 and use asynchronous processing.",
      call. = FALSE
    )
  }

  # Read file as raw bytes
  file_bytes <- readBin(file_path, "raw", file_size)

  # Clean up temp files if created
  if (!is.null(temp_files)) {
    on.exit(unlink(temp_files), add = TRUE)
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
  message("Sending document to AWS Textract AnalyzeDocument...")
  result <- textract$analyze_document(
    Document = list(
      Bytes = file_bytes
    ),
    FeatureTypes = features
  )

  # If we have multiple pages, process them and combine
  if (multi_page && length(temp_files) > 1) {
    message("Processing additional pages...")
    for (i in 2:length(temp_files)) {
      page_bytes <- readBin(temp_files[i], "raw", file.info(temp_files[i])$size)
      page_result <- textract$analyze_document(
        Document = list(
          Bytes = page_bytes
        ),
        FeatureTypes = features
      )
      # Combine blocks from all pages
      result$Blocks <- c(result$Blocks, page_result$Blocks)
    }
    # Update page count
    result$DocumentMetadata$Pages <- length(temp_files)
  }

  # Return the result
  message("Document analysis complete.")
  return(result)
}
