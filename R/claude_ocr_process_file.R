#' Process Document with Claude OCR (via ellmer)
#'
#' Processes a local PDF or image with Claude's document understanding using
#' \pkg{ellmer} for structured output, returning Tensorlake-compatible page data.
#' The output schema is enforced with an \code{ellmer} type specification, so the
#' model reliably returns pages, tables, and other elements.
#'
#' @author Nathan C. Layman
#'
#' @param file_path Character string. Path to a local PDF, PNG, JPEG, GIF, or WEBP file.
#' @param api_key Character string. The Anthropic API key. Default retrieves from
#'   environment variable "ANTHROPIC_API_KEY".
#' @param model Character string. The Claude model to use. Default is "claude-opus-4-6".
#' @param max_tokens Integer. Maximum tokens in the response. Default is 16000.
#' @param extraction_prompt Character string. Custom task prompt. If NULL, uses a
#'   default prompt (the output structure itself is enforced by the type schema).
#' @param pages Integer vector. Accepted for interface parity; Claude reads the
#'   whole document, so page selection is applied later in
#'   \code{\link{claude_extract_pages}}. Default NULL.
#'
#' @return A list with \code{structured_output$pages}: a list with one entry per
#'   page (\code{page_number}, \code{page_header}, \code{section_header},
#'   \code{text}, \code{tables}, \code{other}).
#'
#' @keywords internal
#'
#' @importFrom ellmer chat_anthropic content_pdf_file content_image_file params
#'   type_object type_array type_string type_integer
claude_ocr_process_file <- function(file_path,
                                     api_key = Sys.getenv("ANTHROPIC_API_KEY"),
                                     model = "claude-opus-4-6",
                                     max_tokens = 16000,
                                     extraction_prompt = NULL,
                                     pages = NULL) {

  # Validate inputs
  if (is.null(api_key) || api_key == "") {
    stop("API key not found. Please set the ANTHROPIC_API_KEY environment variable or provide it as a parameter.",
         call. = FALSE)
  }

  if (is.null(file_path) || !file.exists(file_path)) {
    stop("File not found: ", file_path, call. = FALSE)
  }

  # Attach the document as PDF or image content
  ext <- tolower(tools::file_ext(file_path))
  doc_content <- switch(
    ext,
    "pdf" = ellmer::content_pdf_file(file_path),
    "png" = ,
    "jpg" = ,
    "jpeg" = ,
    "gif" = ,
    "webp" = ellmer::content_image_file(file_path, resize = "none"),
    stop("Unsupported file type: ", ext, ". Supported: PDF, PNG, JPG, JPEG, GIF, WEBP", call. = FALSE)
  )

  if (is.null(extraction_prompt)) {
    extraction_prompt <- paste0(
      "Extract all content from this document in natural reading order. ",
      "For each page capture: running headers (journal name, article title, ",
      "margin page numbers), section headings, all body text with paragraphs ",
      "separated by blank lines, every table (as plain text, markdown, and HTML ",
      "with a short summary), and any other elements such as figure captions or ",
      "footnotes labelled with a type. Increment page_number for each page."
    )
  }

  # Tensorlake-compatible output schema, enforced by ellmer
  type_table <- ellmer::type_object(
    content = ellmer::type_string("Plain text representation of the table"),
    markdown = ellmer::type_string("Markdown table using | separators"),
    html = ellmer::type_string("HTML <table> representation"),
    summary = ellmer::type_string("Brief description of the table")
  )
  type_other <- ellmer::type_object(
    type = ellmer::type_string("Element type, e.g. figure_caption or footnote"),
    content = ellmer::type_string("Element text content")
  )
  type_page <- ellmer::type_object(
    page_number = ellmer::type_integer("1-based page number"),
    page_header = ellmer::type_array(ellmer::type_string(), "Running header text, if present"),
    section_header = ellmer::type_array(ellmer::type_string(), "Section titles on the page"),
    text = ellmer::type_string("All body text, paragraphs separated by blank lines"),
    tables = ellmer::type_array(type_table, "Tables found on the page"),
    other = ellmer::type_array(type_other, "Other elements, e.g. captions or footnotes")
  )
  type_doc <- ellmer::type_object(
    pages = ellmer::type_array(type_page, "One entry per page in reading order")
  )

  message("Sending document to Claude for OCR processing...")
  chat <- ellmer::chat_anthropic(
    model = model,
    credentials = function() api_key,
    params = ellmer::params(max_tokens = max_tokens),
    echo = "none"
  )

  result <- tryCatch(
    chat$chat_structured(doc_content, extraction_prompt, type = type_doc, convert = FALSE),
    error = function(e) stop("Claude OCR request failed: ", conditionMessage(e), call. = FALSE)
  )

  message("OCR processing complete.")

  if (is.null(result$pages)) {
    stop("Claude returned no pages. The response may not have matched the schema.", call. = FALSE)
  }

  list(
    model = model,
    structured_output = list(pages = result$pages)
  )
}
