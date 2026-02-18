#' Process Document with Claude OCR
#'
#' This function processes a local PDF or image file using Claude's document understanding
#' capabilities and returns structured OCR results.
#'
#' @author Nathan C. Layman
#'
#' @param file_path Character string. Path to a local PDF, PNG, JPEG, or other supported image file.
#' @param api_key Character string. The Anthropic API key. Default is to retrieve from environment variable "ANTHROPIC_API_KEY".
#' @param model Character string. The Claude model to use. Default is "claude-opus-4.5-20250514".
#' @param max_tokens Integer. Maximum tokens in response. Default is 16000.
#' @param extraction_prompt Character string. Custom prompt for extraction. If NULL, uses default Tensorlake-compatible prompt.
#' @param endpoint Character string. The Claude Messages API endpoint. Default is "https://api.anthropic.com/v1/messages".
#'
#' @return A list containing the Claude API response with structured OCR data.
#'
#' @keywords internal
#'
#' @importFrom httr2 request req_headers req_body_json req_perform resp_body_json
#' @importFrom base64enc base64encode
claude_ocr_process_file <- function(file_path,
                                     api_key = Sys.getenv("ANTHROPIC_API_KEY"),
                                     model = "claude-opus-4.5-20250514",
                                     max_tokens = 16000,
                                     extraction_prompt = NULL,
                                     endpoint = "https://api.anthropic.com/v1/messages") {

  # Validate inputs
  if (is.null(api_key) || api_key == "") {
    stop("API key not found. Please set the ANTHROPIC_API_KEY environment variable or provide it as a parameter.",
         call. = FALSE)
  }

  if (is.null(file_path) || !file.exists(file_path)) {
    stop("File not found: ", file_path, call. = FALSE)
  }

  # Detect media type
  ext <- tolower(tools::file_ext(file_path))
  media_type <- switch(ext,
    "pdf" = "application/pdf",
    "png" = "image/png",
    "jpg" = "image/jpeg",
    "jpeg" = "image/jpeg",
    "gif" = "image/gif",
    "webp" = "image/webp",
    stop("Unsupported file type: ", ext, ". Supported: PDF, PNG, JPG, JPEG, GIF, WEBP", call. = FALSE)
  )

  # Determine content type (document vs image)
  content_type <- if (ext == "pdf") "document" else "image"

  # Read file and encode to base64
  message("Reading and encoding file...")
  file_data <- readBin(file_path, "raw", file.info(file_path)$size)
  base64_data <- base64enc::base64encode(file_data)

  # Default extraction prompt for Tensorlake-compatible output
  if (is.null(extraction_prompt)) {
    extraction_prompt <- 'Extract all content from this document and return it as JSON with this structure:

{
  "pages": [
    {
      "page_number": 1,
      "page_header": ["Running header text if present"],
      "section_header": ["Section title if present"],
      "text": "All body text content with paragraphs separated by \\n\\n",
      "tables": [
        {
          "content": "Plain text representation of table",
          "markdown": "Markdown formatted table using | separators",
          "html": "<table>HTML representation</table>",
          "summary": "Brief description of what the table contains"
        }
      ],
      "other": [
        {
          "type": "figure_caption",
          "content": "Figure 1. Caption text..."
        }
      ]
    }
  ]
}

Instructions:
- Identify page boundaries (for multi-page PDFs, increment page_number)
- Extract running headers (journal name, article title, page numbers in margins)
- Identify section headings (Introduction, Methods, etc.)
- Preserve all body text with paragraph breaks
- For tables: provide plain text, markdown, and HTML representations, plus a summary
- Capture figure captions, footnotes, etc. in the "other" array with appropriate type labels
- Return ONLY the JSON, no additional text'
  }

  # Build request content
  content <- list(
    list(
      type = content_type,
      source = list(
        type = "base64",
        media_type = media_type,
        data = base64_data
      )
    ),
    list(
      type = "text",
      text = extraction_prompt
    )
  )

  # Build request body
  request_body <- list(
    model = model,
    max_tokens = max_tokens,
    messages = list(
      list(
        role = "user",
        content = content
      )
    )
  )

  # Make the API request
  message("Sending document to Claude for OCR processing...")
  response <- tryCatch({
    httr2::request(endpoint) |>
      httr2::req_headers(
        "Content-Type" = "application/json",
        "x-api-key" = api_key,
        "anthropic-version" = "2023-06-01"
      ) |>
      httr2::req_body_json(request_body) |>
      httr2::req_perform()
  }, error = function(e) {
    stop("Claude OCR request failed: ", e$message, call. = FALSE)
  })

  # Parse and return the JSON response
  message("OCR processing complete.")
  result <- httr2::resp_body_json(response)

  # Extract the text content and parse as JSON
  if (!is.null(result$content) && length(result$content) > 0) {
    text_content <- result$content[[1]]$text
    # Try to parse as JSON
    tryCatch({
      result$structured_output <- jsonlite::fromJSON(text_content, simplifyVector = FALSE)
    }, error = function(e) {
      warning("Could not parse Claude response as JSON. Returning raw text.", call. = FALSE)
      result$structured_output <- NULL
      result$raw_text <- text_content
    })
  }

  return(result)
}
