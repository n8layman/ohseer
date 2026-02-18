# Test script for unified ohseer_ocr() interface
library(ohseer)

# Test file
test_file <- "data/articles/Gibbons_1994.pdf"

# Test 1: Basic usage with Mistral (since we have API key set up)
cat("Test 1: Basic usage with Mistral\n")
result_mistral <- ohseer_ocr(
  test_file,
  provider = "mistral",
  pages = c(1, 2),
  extract_header = TRUE,
  extract_footer = TRUE
)

cat("Provider:", result_mistral$provider, "\n")
cat("Pages extracted:", length(result_mistral$pages), "\n")
cat("First page index:", result_mistral$pages[[1]]$index, "\n")
cat("First page has markdown:", !is.null(result_mistral$pages[[1]]$markdown), "\n")
cat("\n")

# Test 2: Provider fallback pattern
cat("Test 2: Provider fallback pattern\n")
ocr_with_fallback <- function(file_path, providers = c("mistral", "tensorlake")) {
  for (provider in providers) {
    result <- tryCatch({
      cat("  Trying", provider, "...\n")
      ohseer_ocr(file_path, provider = provider, pages = c(1, 2))
    }, error = function(e) {
      cat("  Failed:", e$message, "\n")
      NULL
    })

    if (!is.null(result)) {
      cat("  Success with", provider, "\n")
      return(result)
    }
  }
  stop("All providers failed")
}

result_fallback <- ocr_with_fallback(test_file)
cat("Fallback result provider:", result_fallback$provider, "\n")
cat("\n")

# Test 3: Extract pages = FALSE (raw response)
cat("Test 3: Raw response (extract_pages = FALSE)\n")
raw_result <- ohseer_ocr(
  test_file,
  provider = "mistral",
  extract_pages = FALSE
)

cat("Raw result has pages field:", !is.null(raw_result$pages), "\n")
cat("Can manually extract pages:", !is.null(mistral_extract_pages(raw_result, pages = c(1, 2))), "\n")
cat("\n")

cat("All tests passed!\n")
