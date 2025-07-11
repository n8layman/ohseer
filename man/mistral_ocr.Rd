% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mistral_ocr.R
\name{mistral_ocr}
\alias{mistral_ocr}
\title{Process Document with Mistral AI OCR}
\usage{
mistral_ocr(
  input,
  input_type = "auto",
  api_key = Sys.getenv("MISTRAL_API_KEY"),
  model = "mistral-ocr-latest",
  include_image_base64 = TRUE,
  output_file = NULL,
  ...
)
}
\arguments{
\item{input}{Either a character string with a URL, a path to a local file, or a file ID from a previous upload.}

\item{input_type}{Character string. Type of input: "auto", "url", "file", or "file_id". Default is "auto".}

\item{api_key}{Character string. The Mistral AI API key. Default is to retrieve from environment variable "MISTRAL_API_KEY".}

\item{model}{Character string. The model to use for OCR processing. Default is "mistral-ocr-latest".}

\item{include_image_base64}{Logical. Whether to include base64-encoded images in the response. Default is TRUE.}

\item{output_file}{Character string. Optional path to save the JSON response to a file. Default is NULL (no file output).}
}
\value{
List. The parsed response from the Mistral AI OCR API containing recognized text and metadata.
}
\description{
This function processes a document with Mistral AI OCR service and returns the recognized text and metadata.
It automatically detects whether the input is a URL, local file path, or file ID.
}
\examples{
\dontrun{
# Process a document with auto-detection of input type
result <- mistral_ocr("https://arxiv.org/pdf/2201.04234")
result <- mistral_ocr("path/to/local/document.pdf")
result <- mistral_ocr("00edaf84-95b0-45db-8f83-f71138491f23")

# Explicitly specify input type
result <- mistral_ocr("https://arxiv.org/pdf/2201.04234", input_type = "url")
}

}
\author{
Nathan C. Layman
}
