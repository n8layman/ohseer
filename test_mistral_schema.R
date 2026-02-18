library(ohseer)

cat("Testing Mistral OCR 3 structured output...\n\n")

test_file <- "data/articles/0090-3558-30_3_439.pdf"

# Simpler schema to start
simple_schema <- list(
  type = "object",
  properties = list(
    pages = list(
      type = "array",
      items = list(
        type = "object",
        properties = list(
          page_number = list(type = "integer"),
          text = list(type = "string")
        )
      )
    )
  )
)

cat("Test 1: Simple schema\n")
tryCatch({
  result <- mistral_ocr(
    test_file,
    document_annotation_format = list(
      type = "json_schema",
      json_schema = simple_schema
    ),
    document_annotation_prompt = "Extract text from each page"
  )
  cat("✓ Simple schema works!\n")
  cat("Response keys:", paste(names(result), collapse = ", "), "\n")
}, error = function(e) {
  cat("✗ Error:", e$message, "\n")
})

cat("\n")
