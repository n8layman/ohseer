#' Process Document with Claude Opus 4.5 OCR
#'
#' This function processes a document with Claude Opus 4.5 (#1 on OCR Arena leaderboard) and
#' returns structured OCR results in Tensorlake-compatible format. Claude provides exceptional
#' accuracy for complex documents, handwriting, tables, and multi-page PDFs.
#'
#' @author Nathan C. Layman
#'
#' @param file_path Character string. Path to a local PDF, PNG, JPEG, or image file.
#' @param api_key Character string. Anthropic API key. Default retrieves from
#'   environment variable "ANTHROPIC_API_KEY".
#' @param model Character string. Claude model to use. Default is "claude-opus-4-6".
#'   Alternative: "claude-sonnet-4-5" for faster/cheaper processing.
#' @param max_tokens Integer. Maximum tokens in response. Default is 16000.
#' @param extraction_prompt Character string. Custom extraction prompt. If NULL, uses default
#'   prompt that generates Tensorlake-compatible JSON structure.
#' @param output_file Character string. Optional path to save the JSON response to a file.
#'   Default is NULL (no file output).
#'
#' @return List. The parsed response from Claude containing:
#'   \describe{
#'     \item{structured_output}{Parsed JSON with pages, tables, and structured data}
#'     \item{content}{Raw response content from Claude}
#'     \item{usage}{Token usage information}
#'   }
#'
#' @section Note:
#' Claude Opus 4.5 ranks #1 on OCR Arena (ELO: 1696, 71.2% win rate) as of Feb 2026.
#' It excels at:
#' - Complex tables and forms
#' - Handwritten text
#' - Multi-page PDFs
#' - Low-quality scans
#' - Scientific/technical documents
#'
#' Pricing varies by model and region. Check Anthropic pricing for current rates.
#'
#' @examples
#' \dontrun{
#' # Process a PDF with Claude Opus 4.5
#' result <- claude_ocr("document.pdf")
#'
#' # Extract pages in Tensorlake format
#' pages <- claude_extract_pages(result)
#'
#' # Use faster/cheaper Sonnet model
#' result <- claude_ocr("document.pdf", model = "claude-sonnet-4.5-20250929")
#'
#' # Save output to file
#' result <- claude_ocr("document.pdf", output_file = "ocr_result.json")
#'
#' # Use with ecoextract
#' library(ecoextract)
#' pages <- claude_extract_pages(result)
#' json_content <- jsonlite::toJSON(pages, auto_unbox = TRUE)
#' }
#'
#' @export
#'
#' @importFrom jsonlite write_json
claude_ocr <- function(file_path,
                       api_key = Sys.getenv("ANTHROPIC_API_KEY"),
                       model = "claude-opus-4-6",
                       max_tokens = 16000,
                       extraction_prompt = NULL,
                       output_file = NULL) {

  # Validate inputs
  if (is.null(api_key) || api_key == "") {
    stop("Anthropic API key not found. Please set the ANTHROPIC_API_KEY environment variable or provide it as a parameter.",
         call. = FALSE)
  }

  if (is.null(file_path) || !file.exists(file_path)) {
    stop("File not found: ", file_path, call. = FALSE)
  }

  # Process the file
  result <- claude_ocr_process_file(
    file_path = file_path,
    api_key = api_key,
    model = model,
    max_tokens = max_tokens,
    extraction_prompt = extraction_prompt
  )

  # Save to file if requested
  if (!is.null(output_file)) {
    jsonlite::write_json(result, output_file, auto_unbox = TRUE, pretty = TRUE)
    message("Output saved to: ", output_file)
  }

  return(result)
}
