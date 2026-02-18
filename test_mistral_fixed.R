library(ohseer)

cat("Testing Mistral OCR 3 with correct schema format...\n\n")

test_file <- "data/articles/0090-3558-30_3_439.pdf"

# Correct Mistral schema format
mistral_schema <- list(
  type = "json_schema",
  json_schema = list(
    name = "tensorlake_format",
    strict = TRUE,
    schema = list(
      type = "object",
      title = "TensorlakeFormat",
      properties = list(
        pages = list(
          type = "array",
          items = list(
            type = "object",
            properties = list(
              page_number = list(
                type = "integer",
                description = "Page number"
              ),
              page_header = list(
                type = "array",
                items = list(type = "string"),
                description = "Running headers"
              ),
              section_header = list(
                type = "array", 
                items = list(type = "string"),
                description = "Section headings"
              ),
              text = list(
                type = "string",
                description = "All body text"
              ),
              tables = list(
                type = "array",
                items = list(
                  type = "object",
                  properties = list(
                    content = list(type = "string", description = "Plain text"),
                    markdown = list(type = "string", description = "Markdown table"),
                    html = list(type = "string", description = "HTML table"),
                    summary = list(type = "string", description = "Table description")
                  ),
                  required = c("content", "markdown", "html", "summary"),
                  additionalProperties = FALSE
                )
              ),
              other = list(
                type = "array",
                items = list(
                  type = "object",
                  properties = list(
                    type = list(type = "string"),
                    content = list(type = "string")
                  ),
                  required = c("type", "content"),
                  additionalProperties = FALSE
                )
              )
            ),
            required = c("page_number", "text", "tables"),
            additionalProperties = FALSE
          )
        )
      ),
      required = c("pages"),
      additionalProperties = FALSE
    )
  )
)

cat("Testing with correct Mistral schema format...\n")
tryCatch({
  result <- mistral_ocr(
    test_file,
    document_annotation_format = mistral_schema,
    document_annotation_prompt = "Extract all document structure"
  )
  
  cat("✓ Mistral OCR 3 works!\n")
  pages <- mistral_extract_pages(result)
  cat("✓ Extracted", length(pages), "pages\n")
  cat("\nPage 1:\n")
  cat("  - page_number:", pages[[1]]$page_number, "\n")
  cat("  - text length:", nchar(pages[[1]]$text), "chars\n")
  
}, error = function(e) {
  cat("✗ Error:", e$message, "\n")
})
