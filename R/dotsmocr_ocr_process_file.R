#' Process Document with a Local dots.mocr Model (via ellmer)
#'
#' Renders each page of a PDF (or a single image) to a PNG and sends it to a
#' \code{dots.mocr} model served locally by vLLM, using \pkg{ellmer}
#' (\code{chat_vllm}). dots.mocr (rednote-hilab) is a multilingual document
#' layout-parsing VLM that returns layout elements (bbox, category, text) with
#' tables as HTML and formulas as LaTeX.
#'
#' This targets a model you host yourself. Launch a server with, e.g.:
#' \preformatted{
#' vllm serve rednote-hilab/dots.mocr --tensor-parallel-size 1 \
#'   --chat-template-content-format string --trust-remote-code
#' }
#' then point \code{server} at it (default \code{http://localhost:8000/v1}).
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
#'   "rednote-hilab/dots.mocr" (use "model" if you launched vLLM with
#'   \code{--served-model-name model}).
#' @param pages Integer vector. 1-based page numbers to process. If NULL
#'   (default), processes all pages.
#' @param prompt Character string. The parsing prompt. If NULL, uses the default
#'   full-layout prompt that returns bbox + category + text per element.
#' @param max_tokens Integer. Maximum tokens per page response. Default is 16000.
#' @param temperature Numeric. Sampling temperature. Default is 0.1.
#' @param target_longest_image_dim Integer. Longest-side pixel target when
#'   rendering PDF pages. Default is 1600.
#' @param timeout Numeric. Accepted for interface parity; retries and timeouts
#'   are managed by ellmer. Default is 120.
#'
#' @return A list with \code{structured_output$pages}; each page has
#'   \code{page_number} and the raw model \code{text}.
#'
#' @keywords internal
#'
#' @importFrom ellmer chat_vllm content_image_file params
dotsmocr_ocr_process_file <- function(file_path,
                                      server = Sys.getenv("DOTSMOCR_SERVER", "http://localhost:8000/v1"),
                                      api_key = Sys.getenv("DOTSMOCR_API_KEY"),
                                      model = "rednote-hilab/dots.mocr",
                                      pages = NULL,
                                      prompt = NULL,
                                      max_tokens = 16000,
                                      temperature = 0.1,
                                      target_longest_image_dim = 1600,
                                      timeout = 120) {

  if (is.null(file_path) || !file.exists(file_path)) {
    stop("File not found: ", file_path, call. = FALSE)
  }

  if (is.null(server) || server == "") {
    stop("dots.mocr server URL is required. Set the DOTSMOCR_SERVER environment ",
         "variable or provide the `server` argument (e.g. http://localhost:8000/v1).",
         call. = FALSE)
  }

  server <- sub("/+$", "", stringr::str_squish(server))
  api_key <- stringr::str_squish(api_key)
  credentials <- function() if (nzchar(api_key)) api_key else "EMPTY"

  # Default dots.mocr full-layout prompt (bbox + category + text per element)
  if (is.null(prompt)) {
    prompt <- paste0(
      "Please output the layout information from the PDF image, including each ",
      "layout element's bbox, its category, and the corresponding text content ",
      "within the bbox.\n\n",
      "1. Bbox format: [x1, y1, x2, y2]\n",
      "2. Layout Categories: the possible categories are Caption, Footnote, ",
      "Formula, List-item, Page-footer, Page-header, Picture, Section-header, ",
      "Table, Text, and Title.\n",
      "3. Text Extraction & Formatting Rules:\n",
      "   - Picture: no text.\n",
      "   - Formula: LaTeX.\n",
      "   - Table: HTML.\n",
      "   - All others: Markdown.\n\n",
      "The output must be a single JSON array, sorted in natural reading order."
    )
  }

  # Reuse the shared PDF-to-PNG renderer from the olmOCR provider
  page_files <- olmocr_render_pages(
    file_path = file_path,
    pages = pages,
    target_longest_image_dim = target_longest_image_dim
  )
  on.exit(unlink(page_files$tmp_files), add = TRUE)

  out_pages <- vector("list", length(page_files$paths))

  for (i in seq_along(page_files$paths)) {
    page_number <- page_files$page_numbers[i]
    message("dots.mocr: processing page ", page_number, " (", i, "/",
            length(page_files$paths), ")")

    chat <- ellmer::chat_vllm(
      base_url = server,
      model = model,
      credentials = credentials,
      params = ellmer::params(temperature = temperature, max_tokens = max_tokens),
      echo = "none"
    )

    text <- tryCatch(
      chat$chat(
        ellmer::content_image_file(page_files$paths[i], resize = "none"),
        prompt
      ),
      error = function(e) {
        stop("dots.mocr request failed for page ", page_number, ": ",
             conditionMessage(e),
             "\nIs the vLLM server running at ", server, "?", call. = FALSE)
      }
    )

    out_pages[[i]] <- list(page_number = page_number, text = text)
  }

  message("dots.mocr processing complete.")

  list(
    model = model,
    server = server,
    structured_output = list(pages = out_pages)
  )
}
