#' Display Images from Mistral AI API Responses
#'
#' This function extracts and displays images from Mistral AI API response objects.
#' It handles the decoding of base64-encoded image data and renders the image
#' using R's plotting system.
#'
#' @param mistral_response A list object containing the Mistral API response
#' @param page Integer. The page number within the response to extract the image from (Default: 1)
#' @param image Integer. The image number within the specified page to display (Default: 1)
#'
#' @return Invisibly returns NULL while displaying the image as a side effect
#'
#' @examples
#' \dontrun{
#' # Assuming 'response' contains a Mistral API response with images
#' mistral_preview_image(response)
#' 
#' # To display the second image on the first page
#' mistral_preview_image(response, page = 1, image = 2)
#' }
#'
#' @author Nathan C. Layman
#'
#' @importFrom base64enc base64decode
#' @importFrom magick image_read
#'
#' @export
mistral_preview_image <- function(mistral_response, page = 1, image = 1) {
   
  base64_string <- mistral_response$pages[[page]][["images"]][[image]]$image_base64

  # Clean the base64 string
  # 1. Remove the header
  clean_base64_string <- sub("^data:image/[^;]+;base64", "", base64_string)
  
  # Decode the base64 string
  image_decoded <- base64enc::base64decode(clean_base64_string)
  
  # Read the image directly from the raw binary data using magick
  plot(magick::image_read(image_decoded))

}
