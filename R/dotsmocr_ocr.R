#' Process Document with a Local dots.mocr Model
#'
#' Runs a document through \code{dots.mocr} (rednote-hilab), a multilingual
#' document layout-parsing VLM, served locally by vLLM. Because dots.mocr is a
#' GPU model, this function calls an existing vLLM server through its
#' OpenAI-compatible API rather than running the model in-process; point it at
#' your server with the \code{server} argument.
#'
#' @author Nathan C. Layman
#'
#' @param file_path Character string. Path to a local PDF, PNG, or JPEG file.
#' @param server Character string. Base URL of the OpenAI-compatible endpoint.
#'   Default retrieves from environment variable "DOTSMOCR_SERVER", falling back
#'   to "http://localhost:8000/v1".
#' @param api_key Character string. Bearer token, usually empty for a local
#'   server. Default retrieves from environment variable "DOTSMOCR_API_KEY".
#' @param model Character string. Served model name. Default is
#'   "rednote-hilab/dots.mocr".
#' @param pages Integer vector. 1-based page numbers to process. If NULL
#'   (default), processes all pages.
#' @param prompt Character string. Custom parsing prompt. If NULL, uses the
#'   default full-layout prompt.
#' @param max_tokens Integer. Maximum tokens per page response. Default is 16000.
#' @param target_longest_image_dim Integer. Longest-side pixel target when
#'   rendering PDF pages. Default is 1600.
#' @param output_file Character string. Optional path to save the JSON response.
#'   Default is NULL (no file output).
#' @param timeout Numeric. Accepted for interface parity; ellmer manages retries
#'   and timeouts. Default is 120.
#'
#' @return List with \code{structured_output$pages} (one entry per page with
#'   \code{page_number} and raw \code{text}). Pass to
#'   \code{\link{dotsmocr_extract_pages}} for a normalized page list.
#'
#' @seealso \code{\link{dotsmocr_extract_pages}}, \code{\link{ohseer_ocr}}
#'
#' @examples
#' \dontrun{
#' # Against a local vLLM server (default http://localhost:8000/v1)
#' result <- dotsmocr_ocr("paper.pdf")
#' pages <- dotsmocr_extract_pages(result)
#'
#' # Custom server / served model name
#' result <- dotsmocr_ocr(
#'   "paper.pdf",
#'   server = "http://gpu-box:8000/v1",
#'   model = "model"
#' )
#' }
#'
#' @export
#'
#' @importFrom jsonlite write_json
dotsmocr_ocr <- function(file_path,
                         server = Sys.getenv("DOTSMOCR_SERVER", "http://localhost:8000/v1"),
                         api_key = Sys.getenv("DOTSMOCR_API_KEY"),
                         model = "rednote-hilab/dots.mocr",
                         pages = NULL,
                         prompt = NULL,
                         max_tokens = 16000,
                         target_longest_image_dim = 1600,
                         output_file = NULL,
                         timeout = 120) {

  if (is.null(file_path) || !file.exists(file_path)) {
    stop("File not found: ", file_path, call. = FALSE)
  }

  result <- dotsmocr_ocr_process_file(
    file_path = file_path,
    server = server,
    api_key = api_key,
    model = model,
    pages = pages,
    prompt = prompt,
    max_tokens = max_tokens,
    target_longest_image_dim = target_longest_image_dim,
    timeout = timeout
  )

  if (!is.null(output_file)) {
    jsonlite::write_json(result, output_file, auto_unbox = TRUE, pretty = TRUE)
    message("Output saved to: ", output_file)
  }

  result
}
