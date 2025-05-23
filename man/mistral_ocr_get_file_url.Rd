% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mistral_ocr_get_file_url.R
\name{mistral_ocr_get_file_url}
\alias{mistral_ocr_get_file_url}
\title{Get Temporary URL for Downloading File from Mistral AI API}
\usage{
mistral_ocr_get_file_url(
  file_id,
  expiry = 24,
  api_key = Sys.getenv("MISTRAL_API_KEY"),
  endpoint_base = "https://api.mistral.ai/v1"
)
}
\arguments{
\item{file_id}{Character string. The ID of the file to download.}

\item{expiry}{Numeric. The number of hours the URL will remain valid. Default is 24.}

\item{api_key}{Character string. The Mistral AI API key. Default is to retrieve from environment variable "MISTRAL_API_KEY".}

\item{endpoint_base}{Character string. Base URL for the Mistral AI API. Default is "https://api.mistral.ai/v1".}
}
\value{
A list containing the temporary URL and related metadata.
}
\description{
This function obtains a temporary download URL for a file stored in the Mistral AI service.
}
\examples{
\dontrun{
# Get a temporary URL that expires in 24 hours
url_data <- mistral_ocr_get_file_url("00edaf84-95b0-45db-8f83-f71138491f23")

# Get a temporary URL that expires in 48 hours
url_data <- mistral_ocr_get_file_url("00edaf84-95b0-45db-8f83-f71138491f23", expiry = 48)
}

}
\author{
Nathan C. Layman
}
