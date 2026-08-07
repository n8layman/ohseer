#' Process Document with olmOCR
#'
#' Runs a document through olmOCR, an open-weights 7B vision-language OCR model
#' from the Allen Institute for AI (AI2). olmOCR converts PDFs and images into
#' clean, natural-reading-order markdown, removing headers and footers and
#' handling equations, tables, handwriting, and multi-column layouts.
#'
#' Because olmOCR is a GPU model, this function calls an existing
#' OpenAI-compatible endpoint rather than running the model locally. Point it at
#' a hosted provider (DeepInfra, Parasail, Cirrascale) or your own vLLM server
#' via the \code{server} argument. See the package README for provider setup.
#'
#' @author Nathan C. Layman
#'
#' @param file_path Character string. Path to a local PDF, PNG, or JPEG file.
#' @param api_key Character string. Provider API key (Bearer token). Default
#'   retrieves from environment variable "OLMOCR_API_KEY". May be empty for an
#'   unauthenticated local vLLM server.
#' @param server Character string. Base URL of the OpenAI-compatible endpoint.
#'   Default retrieves from environment variable "OLMOCR_SERVER", falling back to
#'   DeepInfra ("https://api.deepinfra.com/v1/openai").
#' @param model Character string. Model identifier as registered with the
#'   provider. Default is "allenai/olmOCR-2-7B-1025". Note that model names differ
#'   between providers (e.g. Cirrascale uses "olmOCR-2-7B-1025").
#' @param pages Integer vector. 1-based page numbers to process. If NULL
#'   (default), processes all pages.
#' @param max_tokens Integer. Maximum tokens per page response. Default is 8000.
#' @param target_longest_image_dim Integer. Longest-side pixel target used when
#'   rendering PDF pages. Default is 1288.
#' @param extraction_prompt Character string. Custom prompt. If NULL, uses the
#'   default olmOCR no-anchoring prompt.
#' @param output_file Character string. Optional path to save the JSON response.
#'   Default is NULL (no file output).
#' @param timeout Numeric. Per-request timeout in seconds. Default is 120.
#'
#' @return List with \code{structured_output$pages} containing one entry per page
#'   (\code{page_number}, raw \code{text}), plus the \code{model} and \code{server}
#'   used. Pass to \code{\link{olmocr_extract_pages}} for a normalized page list.
#'
#' @seealso \code{\link{olmocr_extract_pages}}, \code{\link{ohseer_ocr}}
#'
#' @examples
#' \dontrun{
#' # Using DeepInfra (default endpoint), key in OLMOCR_API_KEY
#' result <- olmocr_ocr("document.pdf")
#' pages <- olmocr_extract_pages(result)
#'
#' # Using Parasail
#' result <- olmocr_ocr(
#'   "document.pdf",
#'   server = "https://api.parasail.io/v1",
#'   model = "allenai/olmOCR-2-7B-1025"
#' )
#'
#' # Using a local vLLM server (no key needed)
#' result <- olmocr_ocr(
#'   "document.pdf",
#'   server = "http://localhost:8000/v1",
#'   api_key = "",
#'   model = "olmocr"
#' )
#' }
#'
#' @export
#'
#' @importFrom jsonlite write_json
olmocr_ocr <- function(file_path,
                       api_key = Sys.getenv("OLMOCR_API_KEY"),
                       server = Sys.getenv("OLMOCR_SERVER", "https://api.deepinfra.com/v1/openai"),
                       model = "allenai/olmOCR-2-7B-1025",
                       pages = NULL,
                       max_tokens = 8000,
                       target_longest_image_dim = 1288,
                       extraction_prompt = NULL,
                       output_file = NULL,
                       timeout = 120) {

  if (is.null(file_path) || !file.exists(file_path)) {
    stop("File not found: ", file_path, call. = FALSE)
  }

  result <- olmocr_ocr_process_file(
    file_path = file_path,
    api_key = api_key,
    server = server,
    model = model,
    pages = pages,
    max_tokens = max_tokens,
    target_longest_image_dim = target_longest_image_dim,
    extraction_prompt = extraction_prompt,
    timeout = timeout
  )

  if (!is.null(output_file)) {
    jsonlite::write_json(result, output_file, auto_unbox = TRUE, pretty = TRUE)
    message("Output saved to: ", output_file)
  }

  result
}
