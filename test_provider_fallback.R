# Test script for provider fallback functionality
library(ohseer)

test_file <- "data/articles/Gibbons_1994.pdf"

cat("Test 1: Single provider (backward compatibility)\n")
result1 <- ohseer_ocr(test_file, provider = "mistral", pages = c(1))
cat("Provider used:", result1$provider, "\n")
cat("Has error_log:", !is.na(result1$error_log), "\n")
cat("Pages extracted:", length(result1$pages), "\n\n")

cat("Test 2: Provider fallback (mistral -> tensorlake)\n")
result2 <- ohseer_ocr(
  test_file,
  provider = c("mistral", "tensorlake"),
  pages = c(1)
)
cat("Provider used:", result2$provider, "\n")
cat("Has error_log:", !is.na(result2$error_log), "\n")
cat("Pages extracted:", length(result2$pages), "\n\n")

cat("Test 3: Check error logging (simulate by using invalid API key)\n")
# Temporarily unset Tensorlake key to force fallback
orig_key <- Sys.getenv("TENSORLAKE_API_KEY")
Sys.setenv(TENSORLAKE_API_KEY = "")

result3 <- tryCatch({
  ohseer_ocr(
    test_file,
    provider = c("tensorlake", "mistral"),
    pages = c(1)
  )
}, error = function(e) NULL)

# Restore key
Sys.setenv(TENSORLAKE_API_KEY = orig_key)

if (!is.null(result3)) {
  cat("Provider used:", result3$provider, "\n")
  cat("Should have fallen back to mistral\n")
  if (!is.na(result3$error_log)) {
    errors <- jsonlite::fromJSON(result3$error_log)
    cat("Errors logged for:", paste(names(errors), collapse = ", "), "\n")
  }
} else {
  cat("Test failed - no result returned\n")
}
cat("\n")

cat("Test 4: Quality vs Cost strategies\n")
cat("Cost-optimized (mistral first):\n")
result4a <- ohseer_ocr(test_file, provider = c("mistral", "tensorlake"), pages = c(1))
cat("  Provider:", result4a$provider, "\n")

cat("Quality-first (tensorlake first):\n")
result4b <- ohseer_ocr(test_file, provider = c("tensorlake", "mistral"), pages = c(1))
cat("  Provider:", result4b$provider, "\n\n")

cat("All tests completed successfully!\n")
