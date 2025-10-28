#' Embed Base64 Images in Markdown Content
#'
#' This function processes markdown content and replaces image references with
#' embedded base64 data URIs from a Mistral OCR response object. This allows
#' images to be displayed inline in HTML without external files.
#'
#' @param markdown_text Character string. The markdown content to process.
#' @param mistral_response A Mistral OCR response object containing pages with image data.
#' @param page_num Integer. The page number to extract images from (default: 1).
#'
#' @return Character string. The processed markdown with embedded image data URIs.
#'
#' @details
#' The function looks for image references in the markdown and replaces them with
#' HTML img tags containing base64-encoded image data. This is useful for rendering
#' OCR results in Shiny applications or R Markdown documents.
#'
#' Supported image reference patterns:
#' - `![img-0.jpeg](img-0.jpeg)`, `![img-1.jpeg](img-1.jpeg)`, etc. (Mistral's default format)
#' - `![image1]`, `![image2]`, etc.
#' - `![1]`, `![2]`, etc.
#' - Generic `![](...)` patterns
#'
#' @examples
#' \dontrun{
#' # Process markdown with embedded images
#' markdown_with_images <- mistral_embed_images(
#'   markdown_text = ocr_result$pages[[1]]$markdown,
#'   mistral_response = ocr_result,
#'   page_num = 1
#' )
#' }
#'
#' @author Nathan C. Layman
#'
#' @export
mistral_embed_images <- function(markdown_text, mistral_response, page_num = 1) {

  # Extract the page data
  page_data <- mistral_response$pages[[page_num]]

  # Check if there are images in this page
  if (is.null(page_data[["images"]]) || length(page_data[["images"]]) == 0) {
    return(markdown_text)
  }

  processed_text <- markdown_text

  # Process each image
  for (i in seq_along(page_data[["images"]])) {
    image_data <- page_data[["images"]][[i]]

    # Get the base64 string
    base64_string <- image_data$image_base64

    # Clean the base64 string if it has a data URI header
    if (grepl("^data:image/", base64_string)) {
      # Already has the data URI prefix, use as-is
      data_uri <- base64_string
    } else {
      # Add the data URI prefix
      data_uri <- paste0("data:image/png;base64,", base64_string)
    }

    # Create an HTML img tag
    img_html <- sprintf('<img src="%s" style="max-width: 100%%; height: auto;" alt="Page %d, Image %d" />',
                        data_uri, page_num, i)

    # Image index (0-based in Mistral's naming: img-0.jpeg, img-1.jpeg, etc.)
    img_idx <- i - 1

    # Replace various markdown image reference patterns
    # Pattern 1: ![img-{idx}.jpeg](img-{idx}.jpeg) or similar file extensions
    pattern1 <- sprintf("!\\[img-%d\\.[^]]+\\]\\(img-%d\\.[^)]+\\)", img_idx, img_idx)
    if (grepl(pattern1, processed_text)) {
      processed_text <- gsub(pattern1, img_html, processed_text)
      next
    }

    # Pattern 2: ![image{i}](...) or ![image{i}]
    pattern2 <- sprintf("!\\[image%d\\](\\([^)]*\\))?", i)
    if (grepl(pattern2, processed_text)) {
      processed_text <- gsub(pattern2, img_html, processed_text)
      next
    }

    # Pattern 3: ![{i}](...) or ![{i}]
    pattern3 <- sprintf("!\\[%d\\](\\([^)]*\\))?", i)
    if (grepl(pattern3, processed_text)) {
      processed_text <- gsub(pattern3, img_html, processed_text)
      next
    }

    # Pattern 4: ![](...) - replace the i-th occurrence
    pattern4 <- "!\\[\\]\\([^)]*\\)"
    matches <- gregexpr(pattern4, processed_text)
    if (matches[[1]][1] != -1 && length(matches[[1]]) >= i) {
      # Get the position of the i-th match
      match_pos <- matches[[1]][i]
      match_len <- attr(matches[[1]], "match.length")[i]

      # Replace only this specific occurrence
      before <- substr(processed_text, 1, match_pos - 1)
      after <- substr(processed_text, match_pos + match_len, nchar(processed_text))
      processed_text <- paste0(before, img_html, after)
    }
  }

  return(processed_text)
}
