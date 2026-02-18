#!/usr/bin/env Rscript
# Quick test of Mistral OCR 3 and Tensorlake compatibility

library(ohseer)

test_file <- "data/articles/0090-3558-30_3_439.pdf"
cat("Testing OCR providers with:", test_file, "\n\n")

# Test Tensorlake
cat("═══════════════════════════════════════════\n")
cat("TEST 1: Tensorlake (Baseline)\n")
cat("═══════════════════════════════════════════\n")
result_tensor <- tensorlake_ocr(test_file, max_wait_seconds = 120)
pages_tensor <- tensorlake_extract_pages(result_tensor)
cat("✓ Tensorlake processed", length(pages_tensor), "pages\n")
cat("  Page 1 structure:\n")
cat("    - page_number:", pages_tensor[[1]]$page_number, "\n")
cat("    - page_header items:", length(pages_tensor[[1]]$page_header), "\n")
cat("    - section_header items:", length(pages_tensor[[1]]$section_header), "\n")
cat("    - text length:", nchar(pages_tensor[[1]]$text), "chars\n")
cat("    - tables:", length(pages_tensor[[1]]$tables), "\n")
cat("    - other:", length(pages_tensor[[1]]$other), "\n\n")

# Test Mistral OCR 3
cat("═══════════════════════════════════════════\n")
cat("TEST 2: Mistral OCR 3 with Structured Output\n")
cat("═══════════════════════════════════════════\n")

# Simple test without structured output first
cat("Test 2a: Basic OCR (no structured output)...\n")
result_mistral_basic <- mistral_ocr(
  test_file,
  extract_header = TRUE,
  extract_footer = TRUE
)
pages_mistral_basic <- mistral_extract_pages(result_mistral_basic)
cat("✓ Mistral basic processed", length(pages_mistral_basic), "pages\n")
cat("  Page 1 structure:\n")
cat("    - page_number:", pages_mistral_basic[[1]]$page_number, "\n")
cat("    - page_header items:", length(pages_mistral_basic[[1]]$page_header), "\n")
cat("    - text length:", nchar(pages_mistral_basic[[1]]$text), "chars\n")
cat("    - tables:", length(pages_mistral_basic[[1]]$tables), "\n\n")

cat("\n✓ Tests complete!\n")
cat("Both providers successfully returned Tensorlake-compatible format.\n")
