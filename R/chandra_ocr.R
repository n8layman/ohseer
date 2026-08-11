#' Process Document with Chandra OCR (Datalab)
#'
#' Runs a document through Chandra, Datalab's document OCR model, via their
#' hosted conversion API. Chandra is oriented toward complex and academic
#' documents: it handles intricate tables, equations, forms, and handwriting,
#' preserves reading order, and extracts embedded figures/images as files.
#'
#' The Datalab API is asynchronous; this function submits the file and polls
#' until the result is ready. See \code{\link{chandra_extract_pages}} to
#' normalize the output into the per-page format shared across providers.
#'
#' @author Nathan C. Layman
#'
#' @param file_path Character string. Path to a local PDF, PNG, JPEG, or other
#'   supported document.
#' @param api_key Character string. Datalab API key, sent in the \code{X-Api-Key}
#'   header. Default retrieves from environment variable "DATALAB_API_KEY".
#' @param output_format Character string. One of "markdown" (default), "html",
#'   "json", or "chunks".
#' @param mode Character string. Quality/speed tradeoff: "fast", "balanced"
#'   (default), or "accurate".
#' @param use_llm Logical. If TRUE, adds an LLM pass to improve accuracy on
#'   tables, forms, and inline math (higher cost). Default is FALSE.
#' @param langs Character string. Optional comma-separated OCR language hints
#'   (e.g. "English"). Default is NULL (auto).
#' @param max_pages Integer. Optional cap on pages processed. Default is NULL.
#' @param output_file Character string. Optional path to save the JSON response.
#'   Default is NULL (no file output).
#' @param timeout Numeric. Maximum seconds to wait for the async job. Default is 300.
#'
#' @return List with \code{structured_output} containing the paginated
#'   \code{markdown}, \code{output_format}, \code{page_count}, \code{images}
#'   (named list of base64 strings), and \code{metadata}. Pass to
#'   \code{\link{chandra_extract_pages}} for a normalized page list.
#'
#' @seealso \code{\link{chandra_extract_pages}}, \code{\link{ohseer_ocr}}
#'
#' @examples
#' \dontrun{
#' # Key in DATALAB_API_KEY
#' result <- chandra_ocr("paper.pdf")
#' pages <- chandra_extract_pages(result)
#'
#' # Higher accuracy with the LLM table pass
#' result <- chandra_ocr("paper.pdf", mode = "accurate", use_llm = TRUE)
#'
#' # Access extracted figures (base64, keyed by filename)
#' figures <- result$structured_output$images
#' }
#'
#' @export
#'
#' @importFrom jsonlite write_json
chandra_ocr <- function(file_path,
                        api_key = Sys.getenv("DATALAB_API_KEY"),
                        output_format = "markdown",
                        mode = "balanced",
                        use_llm = FALSE,
                        langs = NULL,
                        max_pages = NULL,
                        output_file = NULL,
                        timeout = 300) {

  if (is.null(file_path) || !file.exists(file_path)) {
    stop("File not found: ", file_path, call. = FALSE)
  }

  result <- chandra_ocr_process_file(
    file_path = file_path,
    api_key = api_key,
    output_format = output_format,
    mode = mode,
    use_llm = use_llm,
    langs = langs,
    max_pages = max_pages,
    timeout = timeout
  )

  if (!is.null(output_file)) {
    jsonlite::write_json(result, output_file, auto_unbox = TRUE, pretty = TRUE)
    message("Output saved to: ", output_file)
  }

  result
}
