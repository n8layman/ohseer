#!/usr/bin/env Rscript
# Test OCR Providers: Claude Opus 4.5, Mistral OCR 3, Tensorlake
#
# This script processes a test document with all three providers and compares:
# 1. Output structure compatibility
# 2. Cost estimation
# 3. Processing time
# 4. Data quality (headers, tables, text)

library(ohseer)

# Configuration
test_file <- "data/articles/0090-3558-30_3_439.pdf"  # Smallest test file (~838KB)
output_dir <- "test_results"
dir.create(output_dir, showWarnings = FALSE)

# Helper function to print structure comparison
print_structure_summary <- function(pages, provider_name) {
  cat("\n", strrep("=", 60), "\n", sep = "")
  cat("PROVIDER:", provider_name, "\n")
  cat(strrep("=", 60), "\n")

  cat("Total pages:", length(pages), "\n")

  if (length(pages) > 0) {
    page1 <- pages[[1]]
    cat("\nPage 1 Structure:\n")
    cat("  - page_number:", page1$page_number, "\n")
    cat("  - page_header:", length(page1$page_header), "items\n")
    if (length(page1$page_header) > 0) {
      cat("    ", substr(paste(page1$page_header, collapse = " | "), 1, 80), "...\n")
    }
    cat("  - section_header:", length(page1$section_header), "items\n")
    if (length(page1$section_header) > 0) {
      cat("    ", substr(paste(page1$section_header, collapse = " | "), 1, 80), "...\n")
    }
    cat("  - text length:", nchar(page1$text), "characters\n")
    cat("    Preview:", substr(page1$text, 1, 100), "...\n")
    cat("  - tables:", length(page1$tables), "items\n")
    if (length(page1$tables) > 0) {
      cat("    Table 1 fields:", paste(names(page1$tables[[1]]), collapse = ", "), "\n")
    }
    cat("  - other:", length(page1$other), "items\n")
  }
}

# Helper function to validate structure
validate_tensorlake_format <- function(pages, provider_name) {
  cat("\nValidating", provider_name, "output structure...\n")

  errors <- c()

  if (!is.list(pages)) {
    errors <- c(errors, "Pages is not a list")
    return(errors)
  }

  for (i in seq_along(pages)) {
    page <- pages[[i]]

    # Check required fields
    required_fields <- c("page_number", "page_header", "section_header", "text", "tables", "other")
    missing_fields <- setdiff(required_fields, names(page))
    if (length(missing_fields) > 0) {
      errors <- c(errors, paste0("Page ", i, " missing fields: ", paste(missing_fields, collapse = ", ")))
    }

    # Check field types
    if (!is.numeric(page$page_number) && !is.integer(page$page_number)) {
      errors <- c(errors, paste0("Page ", i, " page_number is not numeric"))
    }

    if (!is.character(page$page_header) && !is.list(page$page_header)) {
      errors <- c(errors, paste0("Page ", i, " page_header is not character vector"))
    }

    if (!is.character(page$section_header) && !is.list(page$section_header)) {
      errors <- c(errors, paste0("Page ", i, " section_header is not character vector"))
    }

    if (!is.character(page$text)) {
      errors <- c(errors, paste0("Page ", i, " text is not character"))
    }

    if (!is.list(page$tables)) {
      errors <- c(errors, paste0("Page ", i, " tables is not a list"))
    }

    # Check table structure
    if (length(page$tables) > 0) {
      for (j in seq_along(page$tables)) {
        table <- page$tables[[j]]
        required_table_fields <- c("content", "markdown", "html", "summary")
        missing_table_fields <- setdiff(required_table_fields, names(table))
        if (length(missing_table_fields) > 0) {
          errors <- c(errors, paste0("Page ", i, " table ", j, " missing fields: ", paste(missing_table_fields, collapse = ", ")))
        }
      }
    }
  }

  if (length(errors) == 0) {
    cat("  ✓ Structure is valid and compatible with Tensorlake format\n")
  } else {
    cat("  ✗ Structure validation FAILED:\n")
    for (error in errors) {
      cat("    -", error, "\n")
    }
  }

  return(errors)
}

cat("\n")
cat("╔════════════════════════════════════════════════════════════╗\n")
cat("║  OCR Provider Comparison Test                              ║\n")
cat("╚════════════════════════════════════════════════════════════╝\n")
cat("\nTest file:", test_file, "\n")
cat("Output directory:", output_dir, "\n")

# Check API keys
api_keys <- list(
  ANTHROPIC_API_KEY = Sys.getenv("ANTHROPIC_API_KEY"),
  MISTRAL_API_KEY = Sys.getenv("MISTRAL_API_KEY"),
  TENSORLAKE_API_KEY = Sys.getenv("TENSORLAKE_API_KEY")
)

cat("\nAPI Key Status:\n")
for (key_name in names(api_keys)) {
  status <- if (nchar(api_keys[[key_name]]) > 0) "✓ Set" else "✗ Missing"
  cat("  ", key_name, ":", status, "\n")
}

# Test results storage
results <- list()

# ============================================================================
# TEST 1: Tensorlake (baseline)
# ============================================================================

if (nchar(api_keys$TENSORLAKE_API_KEY) > 0) {
  cat("\n\n", strrep("█", 60), "\n", sep = "")
  cat("TEST 1: Tensorlake (Baseline)\n")
  cat(strrep("█", 60), "\n")

  tryCatch({
    start_time <- Sys.time()

    cat("\nProcessing with Tensorlake...\n")
    result_tensorlake <- tensorlake_ocr(
      test_file,
      max_wait_seconds = 120,
      output_file = file.path(output_dir, "tensorlake_raw.json")
    )

    cat("Extracting pages...\n")
    pages_tensorlake <- tensorlake_extract_pages(result_tensorlake)

    end_time <- Sys.time()
    processing_time <- as.numeric(difftime(end_time, start_time, units = "secs"))

    # Save pages
    jsonlite::write_json(
      pages_tensorlake,
      file.path(output_dir, "tensorlake_pages.json"),
      auto_unbox = TRUE,
      pretty = TRUE
    )

    # Print summary
    print_structure_summary(pages_tensorlake, "Tensorlake")

    # Validate structure
    errors <- validate_tensorlake_format(pages_tensorlake, "Tensorlake")

    # Store results
    results$tensorlake <- list(
      success = TRUE,
      pages = length(pages_tensorlake),
      processing_time = processing_time,
      cost_estimate = length(pages_tensorlake) * 0.01,
      structure_valid = length(errors) == 0,
      errors = errors
    )

    cat("\nProcessing time:", round(processing_time, 2), "seconds\n")
    cat("Estimated cost: $", sprintf("%.4f", results$tensorlake$cost_estimate), "\n")

  }, error = function(e) {
    cat("\n✗ Tensorlake test FAILED:", e$message, "\n")
    results$tensorlake <<- list(success = FALSE, error = e$message)
  })
} else {
  cat("\n⊘ Skipping Tensorlake (no API key)\n")
}

# ============================================================================
# TEST 2: Mistral OCR 3
# ============================================================================

if (nchar(api_keys$MISTRAL_API_KEY) > 0) {
  cat("\n\n", strrep("█", 60), "\n", sep = "")
  cat("TEST 2: Mistral OCR 3 (with Header/Footer Extraction)\n")
  cat(strrep("█", 60), "\n")

  tryCatch({
    start_time <- Sys.time()

    cat("\nProcessing with Mistral OCR 3...\n")
    cat("(Using standard OCR with header/footer extraction)\n")
    result_mistral <- mistral_ocr(
      test_file,
      extract_header = TRUE,
      extract_footer = TRUE,
      table_format = "markdown",
      output_file = file.path(output_dir, "mistral_raw.json")
    )

    cat("Extracting pages...\n")
    pages_mistral <- mistral_extract_pages(result_mistral)

    end_time <- Sys.time()
    processing_time <- as.numeric(difftime(end_time, start_time, units = "secs"))

    # Save pages
    jsonlite::write_json(
      pages_mistral,
      file.path(output_dir, "mistral_pages.json"),
      auto_unbox = TRUE,
      pretty = TRUE
    )

    # Print summary
    print_structure_summary(pages_mistral, "Mistral OCR 3")

    # Validate structure
    errors <- validate_tensorlake_format(pages_mistral, "Mistral OCR 3")

    # Estimate cost (basic OCR with header/footer extraction)
    pages_processed <- length(pages_mistral)
    cost_estimate <- pages_processed * 0.002  # $0.002/page for basic OCR

    # Store results
    results$mistral <- list(
      success = TRUE,
      pages = pages_processed,
      processing_time = processing_time,
      cost_estimate = cost_estimate,
      structure_valid = length(errors) == 0,
      errors = errors
    )

    cat("\nProcessing time:", round(processing_time, 2), "seconds\n")
    cat("Estimated cost: $", sprintf("%.4f", cost_estimate), "\n")

  }, error = function(e) {
    cat("\n✗ Mistral OCR 3 test FAILED:", e$message, "\n")
    results$mistral <<- list(success = FALSE, error = e$message)
  })
} else {
  cat("\n⊘ Skipping Mistral OCR 3 (no API key)\n")
}

# ============================================================================
# TEST 3: Claude Opus 4.5
# ============================================================================

if (nchar(api_keys$ANTHROPIC_API_KEY) > 0) {
  cat("\n\n", strrep("█", 60), "\n", sep = "")
  cat("TEST 3: Claude Opus 4.6 (#1 OCR Arena)\n")
  cat(strrep("█", 60), "\n")

  tryCatch({
    start_time <- Sys.time()

    cat("\nProcessing with Claude Opus 4.6...\n")
    cat("(This may take longer due to detailed extraction)\n")

    result_claude <- claude_ocr(
      test_file,
      model = "claude-opus-4-6",
      max_tokens = 16000,
      output_file = file.path(output_dir, "claude_raw.json")
    )

    cat("Extracting pages...\n")
    pages_claude <- claude_extract_pages(result_claude)

    end_time <- Sys.time()
    processing_time <- as.numeric(difftime(end_time, start_time, units = "secs"))

    # Save pages
    jsonlite::write_json(
      pages_claude,
      file.path(output_dir, "claude_pages.json"),
      auto_unbox = TRUE,
      pretty = TRUE
    )

    # Print summary
    print_structure_summary(pages_claude, "Claude Opus 4.6")

    # Validate structure
    errors <- validate_tensorlake_format(pages_claude, "Claude Opus 4.6")

    # Estimate cost based on token usage
    if (!is.null(result_claude$usage)) {
      input_tokens <- result_claude$usage$input_tokens %||% 0
      output_tokens <- result_claude$usage$output_tokens %||% 0

      # Claude Opus 4.6 pricing: $5/MTok input, $25/MTok output
      cost_estimate <- (input_tokens / 1e6 * 5) + (output_tokens / 1e6 * 25)

      cat("\nToken usage:\n")
      cat("  Input tokens:", format(input_tokens, big.mark = ","), "\n")
      cat("  Output tokens:", format(output_tokens, big.mark = ","), "\n")
    } else {
      # Fallback estimate
      cost_estimate <- length(pages_claude) * 0.09
    }

    # Store results
    results$claude <- list(
      success = TRUE,
      pages = length(pages_claude),
      processing_time = processing_time,
      cost_estimate = cost_estimate,
      structure_valid = length(errors) == 0,
      errors = errors,
      token_usage = result_claude$usage
    )

    cat("\nProcessing time:", round(processing_time, 2), "seconds\n")
    cat("Estimated cost: $", sprintf("%.4f", cost_estimate), "\n")

  }, error = function(e) {
    cat("\n✗ Claude Opus 4.6 test FAILED:", e$message, "\n")
    results$claude <<- list(success = FALSE, error = e$message)
  })
} else {
  cat("\n⊘ Skipping Claude Opus 4.6 (no API key)\n")
}

# ============================================================================
# COMPARISON SUMMARY
# ============================================================================

cat("\n\n")
cat("╔════════════════════════════════════════════════════════════╗\n")
cat("║  COMPARISON SUMMARY                                        ║\n")
cat("╚════════════════════════════════════════════════════════════╝\n")

# Create comparison table
comparison_data <- data.frame(
  Provider = character(),
  Pages = integer(),
  Time_Sec = numeric(),
  Cost_USD = numeric(),
  Valid = character(),
  stringsAsFactors = FALSE
)

for (provider in c("tensorlake", "mistral", "claude")) {
  if (!is.null(results[[provider]]) && results[[provider]]$success) {
    comparison_data <- rbind(comparison_data, data.frame(
      Provider = tools::toTitleCase(provider),
      Pages = results[[provider]]$pages,
      Time_Sec = round(results[[provider]]$processing_time, 2),
      Cost_USD = sprintf("$%.4f", results[[provider]]$cost_estimate),
      Valid = if (results[[provider]]$structure_valid) "✓" else "✗",
      stringsAsFactors = FALSE
    ))
  }
}

if (nrow(comparison_data) > 0) {
  print(comparison_data, row.names = FALSE)

  cat("\n")
  cat("All results saved to:", output_dir, "\n")
  cat("  - *_raw.json: Full API responses\n")
  cat("  - *_pages.json: Tensorlake-compatible extracted pages\n")

  # Overall verdict
  cat("\n")
  cat("Overall Verdict:\n")
  valid_count <- sum(comparison_data$Valid == "✓")
  if (valid_count == nrow(comparison_data)) {
    cat("  ✓ All providers return valid Tensorlake-compatible format\n")
    cat("  ✓ Ready for use with ecoextract package\n")
  } else {
    cat("  ✗ Some providers have structure validation issues\n")
    cat("  ✗ Check errors above for details\n")
  }
} else {
  cat("\n⊘ No successful tests to compare\n")
}

cat("\n")
cat("Test complete!\n")
