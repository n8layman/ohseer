#' Process Document with olmOCR (via ellmer)
#'
#' Renders each page of a PDF (or a single image) to a PNG and sends it to an
#' olmOCR model served behind any OpenAI-compatible endpoint, using \pkg{ellmer}
#' (\code{chat_openai_compatible}). Works with hosted providers that serve olmOCR
#' (DeepInfra, Parasail, Cirrascale) and with a local or remote vLLM server
#' started via \code{vllm serve allenai/olmOCR-2-7B-1025-FP8}.
#'
#' olmOCR is a 7B vision-language model served on a GPU; this package only calls
#' an existing endpoint, it does not run the model locally.
#'
#' @author Nathan C. Layman
#'
#' @param file_path Character string. Path to a local PDF, PNG, or JPEG file.
#' @param api_key Character string. API key for the serving provider. Default
#'   retrieves from environment variable "OLMOCR_API_KEY". May be empty for an
#'   unauthenticated local vLLM server.
#' @param server Character string. Base URL of the OpenAI-compatible endpoint,
#'   e.g. "https://api.deepinfra.com/v1/openai" or "http://localhost:8000/v1".
#'   Default retrieves from environment variable "OLMOCR_SERVER", falling back to
#'   DeepInfra.
#' @param model Character string. Model identifier as registered with the
#'   provider. Default is "allenai/olmOCR-2-7B-1025".
#' @param pages Integer vector. 1-based page numbers to process. If NULL
#'   (default), processes all pages. Ignored for single-image inputs.
#' @param max_tokens Integer. Maximum tokens in each per-page response. Default is 8000.
#' @param temperature Numeric. Sampling temperature. Default is 0.1.
#' @param target_longest_image_dim Integer. Pixel dimension of the longest side
#'   used when rendering PDF pages. Default is 1288 (olmOCR's default).
#' @param extraction_prompt Character string. Custom prompt. If NULL, uses the
#'   default olmOCR no-anchoring prompt.
#' @param timeout Numeric. Accepted for interface parity; request retries and
#'   timeouts are managed by ellmer. Default is 120.
#'
#' @return A list with \code{structured_output$pages}; each page has
#'   \code{page_number} and the raw model \code{text} (markdown with a YAML front
#'   matter header).
#'
#' @keywords internal
#'
#' @importFrom ellmer chat_openai_compatible content_image_file params
olmocr_ocr_process_file <- function(file_path,
                                    api_key = Sys.getenv("OLMOCR_API_KEY"),
                                    server = Sys.getenv("OLMOCR_SERVER", "https://api.deepinfra.com/v1/openai"),
                                    model = "allenai/olmOCR-2-7B-1025",
                                    pages = NULL,
                                    max_tokens = 8000,
                                    temperature = 0.1,
                                    target_longest_image_dim = 1288,
                                    extraction_prompt = NULL,
                                    timeout = 120) {

  if (is.null(file_path) || !file.exists(file_path)) {
    stop("File not found: ", file_path, call. = FALSE)
  }

  if (is.null(server) || server == "") {
    stop("olmOCR server URL is required. Set the OLMOCR_SERVER environment variable ",
         "or provide the `server` argument (e.g. https://api.deepinfra.com/v1/openai).",
         call. = FALSE)
  }

  server <- sub("/+$", "", stringr::str_squish(server))
  api_key <- stringr::str_squish(api_key)
  # Local vLLM needs no real key; ellmer still requires a credentials function
  credentials <- function() if (nzchar(api_key)) api_key else "EMPTY"

  # Default olmOCR "no anchoring" prompt used by recent olmOCR models
  if (is.null(extraction_prompt)) {
    extraction_prompt <- paste0(
      "Attached is one page of a document that you must process. ",
      "Just return the plain text representation of this document as if you were reading it naturally.\n",
      "Convert equations to LateX and tables to markdown.\n",
      "Return your output as markdown, with a front matter section on top ",
      "specifying values for the primary_language, is_rotation_valid, ",
      "rotation_correction, is_table, and is_diagram parameters."
    )
  }

  # Render the input to one PNG per page
  page_files <- olmocr_render_pages(
    file_path = file_path,
    pages = pages,
    target_longest_image_dim = target_longest_image_dim
  )
  on.exit(unlink(page_files$tmp_files), add = TRUE)

  out_pages <- vector("list", length(page_files$paths))

  for (i in seq_along(page_files$paths)) {
    page_number <- page_files$page_numbers[i]
    message("olmOCR: processing page ", page_number, " (", i, "/", length(page_files$paths), ")")

    chat <- ellmer::chat_openai_compatible(
      base_url = server,
      model = model,
      credentials = credentials,
      params = ellmer::params(temperature = temperature, max_tokens = max_tokens),
      echo = "none"
    )

    text <- tryCatch(
      chat$chat(
        ellmer::content_image_file(page_files$paths[i], resize = "none"),
        extraction_prompt
      ),
      error = function(e) {
        stop("olmOCR request failed for page ", page_number, ": ", conditionMessage(e),
             call. = FALSE)
      }
    )

    out_pages[[i]] <- list(page_number = page_number, text = text)
  }

  message("olmOCR processing complete.")

  list(
    model = model,
    server = server,
    structured_output = list(pages = out_pages)
  )
}


#' Render PDF pages (or a single image) to PNG files for image-based OCR models
#'
#' Shared helper used by the olmOCR and dots.mocr providers.
#'
#' @param file_path Character string. Path to a PDF, PNG, or JPEG file.
#' @param pages Integer vector or NULL. 1-based pages to render (PDF only).
#' @param target_longest_image_dim Integer. Longest-side pixel target for PDFs.
#'
#' @return A list with \code{paths} (rendered PNG paths in page order),
#'   \code{page_numbers} (1-based page numbers), and \code{tmp_files}
#'   (temporary files to clean up).
#'
#' @keywords internal
olmocr_render_pages <- function(file_path, pages, target_longest_image_dim) {

  ext <- tolower(tools::file_ext(file_path))

  # Single-image inputs are used as-is
  if (ext %in% c("png", "jpg", "jpeg")) {
    if (!is.null(pages) && !all(pages == 1)) {
      warning("`pages` is ignored for single-image inputs.", call. = FALSE)
    }
    return(list(paths = file_path, page_numbers = 1L, tmp_files = character(0)))
  }

  if (ext != "pdf") {
    stop("Unsupported file type: ", ext, ". Supported: PDF, PNG, JPG, JPEG.", call. = FALSE)
  }

  if (!requireNamespace("pdftools", quietly = TRUE)) {
    stop("The 'pdftools' package is required to render PDF pages. ",
         "Install it with install.packages('pdftools').", call. = FALSE)
  }

  n_pages <- pdftools::pdf_info(file_path)$pages
  page_numbers <- if (is.null(pages)) seq_len(n_pages) else pages

  invalid <- page_numbers[page_numbers < 1 | page_numbers > n_pages]
  if (length(invalid) > 0) {
    stop("Requested page(s) out of range (document has ", n_pages, " pages): ",
         paste(invalid, collapse = ", "), call. = FALSE)
  }

  # Page sizes are in points (1/72 inch); pick a dpi per page so the longest
  # rendered side lands near target_longest_image_dim pixels.
  sizes <- pdftools::pdf_pagesize(file_path)

  tmp_dir <- tempfile("olmocr_pages_")
  dir.create(tmp_dir)

  paths <- character(length(page_numbers))
  for (i in seq_along(page_numbers)) {
    p <- page_numbers[i]
    longest_pt <- max(sizes$width[p], sizes$height[p])
    longest_in <- longest_pt / 72
    dpi <- if (longest_in > 0) target_longest_image_dim / longest_in else 150
    out <- file.path(tmp_dir, sprintf("page_%03d.png", p))
    pdftools::pdf_convert(
      file_path,
      format = "png",
      pages = p,
      dpi = dpi,
      filenames = out,
      verbose = FALSE
    )
    paths[i] <- out
  }

  list(paths = paths, page_numbers = page_numbers, tmp_files = c(paths, tmp_dir))
}
