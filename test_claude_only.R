library(ohseer)

cat("Testing Claude Opus 4-6 OCR...\n\n")

# Test with small file
test_file <- "data/articles/0090-3558-30_3_439.pdf"

tryCatch({
  result <- claude_ocr(test_file, model = "claude-opus-4-6", max_tokens = 16000)
  cat("✓ Claude OCR completed\n")
  
  pages <- claude_extract_pages(result)
  cat("✓ Extracted", length(pages), "pages\n")
  cat("\nPage 1 preview:\n")
  cat("  - page_number:", pages[[1]]$page_number, "\n")
  cat("  - text length:", nchar(pages[[1]]$text), "chars\n")
  cat("  - tables:", length(pages[[1]]$tables), "\n")
  
  if (!is.null(result$usage)) {
    cat("\nToken usage:\n")
    cat("  - Input:", result$usage$input_tokens, "\n")
    cat("  - Output:", result$usage$output_tokens, "\n")
  }
  
  cat("\n✓ Claude Opus 4-6 works!\n")
}, error = function(e) {
  cat("\n✗ Error:", e$message, "\n")
})
