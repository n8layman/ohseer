# ohseer Usage Examples

Complete guide to using all three OCR providers (Claude Opus 4.5, Mistral OCR 3, Tensorlake) with structured output compatible with ecoextract.

---

## Quick Start

All three providers follow the same pattern:
1. Call `{provider}_ocr()` to process document
2. Call `{provider}_extract_pages()` to get Tensorlake-compatible format
3. Use with ecoextract or other downstream tools

---

## 1. Claude Opus 4.5 (#1 OCR Arena)

### Basic Usage

```r
library(ohseer)

# Set API key (or use ANTHROPIC_API_KEY environment variable)
Sys.setenv(ANTHROPIC_API_KEY = "your-api-key")

# Process document
result <- claude_ocr("document.pdf")

# Extract pages in Tensorlake format
pages <- claude_extract_pages(result)

# Access structured data
pages[[1]]$page_number     # Page number
pages[[1]]$page_header     # Running headers
pages[[1]]$section_header  # Section titles
pages[[1]]$text           # Body text
pages[[1]]$tables         # Tables (content, markdown, html, summary)
pages[[1]]$other          # Figures, captions, etc.
```

### Model Selection

```r
# Use Opus 4.5 for maximum accuracy (default)
result <- claude_ocr("document.pdf", model = "claude-opus-4.5-20250514")

# Use Sonnet 4.5 for faster/cheaper processing
result <- claude_ocr("document.pdf", model = "claude-sonnet-4.5-20250929")
```

### Save Output

```r
# Save raw API response
result <- claude_ocr("document.pdf", output_file = "claude_result.json")

# Save Tensorlake-formatted pages
pages <- claude_extract_pages(result)
jsonlite::write_json(pages, "pages.json", auto_unbox = TRUE, pretty = TRUE)
```

### Use with ecoextract

```r
library(ecoextract)

# Process document
result <- claude_ocr("scientific_paper.pdf")
pages <- claude_extract_pages(result)

# Convert to JSON for ecoextract
json_content <- jsonlite::toJSON(pages, auto_unbox = TRUE, pretty = TRUE)

# Use with ecoextract functions
# (ecoextract workflow continues from here)
```

---

## 2. Mistral OCR 3

### Basic Usage

```r
library(ohseer)

# Set API key
Sys.setenv(MISTRAL_API_KEY = "your-api-key")

# Process document (now with OCR 3 and header/footer extraction)
result <- mistral_ocr("document.pdf")

# Extract pages
pages <- mistral_extract_pages(result)
```

### Structured Output (Tensorlake-Compatible)

The key to getting Mistral OCR 3 to return Tensorlake-formatted data is using `document_annotation_format`:

```r
# Define Tensorlake-compatible schema
tensorlake_schema <- list(
  type = "object",
  properties = list(
    pages = list(
      type = "array",
      items = list(
        type = "object",
        required = c("page_number", "text", "tables"),
        properties = list(
          page_number = list(type = "integer"),
          page_header = list(
            type = "array",
            items = list(type = "string")
          ),
          section_header = list(
            type = "array",
            items = list(type = "string")
          ),
          text = list(
            type = "string",
            description = "All body text with paragraphs separated by newlines"
          ),
          tables = list(
            type = "array",
            items = list(
              type = "object",
              properties = list(
                content = list(type = "string"),
                markdown = list(type = "string"),
                html = list(type = "string"),
                summary = list(type = "string")
              )
            )
          ),
          other = list(
            type = "array",
            items = list(
              type = "object",
              properties = list(
                type = list(type = "string"),
                content = list(type = "string")
              )
            )
          )
        )
      )
    )
  )
)

# Process with structured output
result <- mistral_ocr(
  "document.pdf",
  document_annotation_format = list(
    type = "json_schema",
    json_schema = tensorlake_schema
  ),
  document_annotation_prompt = "Extract all document structure including headers, sections, text, tables, and other elements",
  extract_header = TRUE,  # Extract headers separately (OCR 3 feature)
  extract_footer = TRUE   # Extract footers separately (OCR 3 feature)
)

# Extract pages (will use structured output if available)
pages <- mistral_extract_pages(result)
```

### Header and Footer Extraction

**IMPORTANT**: Mistral OCR 3 has dedicated parameters to extract headers and footers:

```r
# Enable header/footer extraction (default = TRUE in updated code)
result <- mistral_ocr(
  "document.pdf",
  extract_header = TRUE,  # Extracts running headers (journal name, page numbers, etc.)
  extract_footer = TRUE   # Extracts footers (page numbers, copyright, etc.)
)

# Headers and footers are now separated from main content
# This was the main reason for switching to Tensorlake originally
```

### Table Formatting

```r
# Get tables in HTML format
result <- mistral_ocr("document.pdf", table_format = "html")

# Get tables in Markdown format (default)
result <- mistral_ocr("document.pdf", table_format = "markdown")
```

### Cost Optimization

```r
# Use batch API for 50% discount ($0.001/page instead of $0.002/page)
# (Batch API usage depends on your API client setup)

# With annotations (structured output): $0.003/page
result <- mistral_ocr(
  "document.pdf",
  document_annotation_format = list(type = "json_schema", json_schema = schema)
)
```

---

## 3. Tensorlake

### Basic Usage

```r
library(ohseer)

# Set API key
Sys.setenv(TENSORLAKE_API_KEY = "your-api-key")

# Process document
result <- tensorlake_ocr("document.pdf")

# Extract pages
pages <- tensorlake_extract_pages(result)
```

### Process Specific Pages

```r
# Process only first 5 pages (saves cost and time)
result <- tensorlake_ocr("document.pdf", pages = 1:5)

# Process specific pages
result <- tensorlake_ocr("document.pdf", pages = c(1, 3, 5))

# Extract specific pages
pages <- tensorlake_extract_pages(result, pages = c(1, 2))
```

### Exclude Fragment Types

```r
# By default, all fragment types are included (including headers/footers)
pages <- tensorlake_extract_pages(result)

# Exclude certain types if needed
pages <- tensorlake_extract_pages(
  result,
  exclude_types = c("page_number", "page_footer")
)
```

---

## Comparison: When to Use Each Provider

### Use Claude Opus 4.5 When:
- Maximum accuracy is critical
- Processing legal, medical, or high-value documents
- Document has complex handwriting
- Tables are intricate or nested
- Multi-page context is important
- Budget allows ~$0.05-0.09/page

### Use Mistral OCR 3 When:
- Processing millions of pages (cost-sensitive)
- Documents are relatively clean/standard
- Need structured output at lowest cost
- Batch processing is available
- Budget: $0.001-0.003/page

### Use Tensorlake When:
- Need balance of accuracy and cost
- Processing academic/scientific papers
- Good fragment-type classification needed
- Async processing for large files
- Budget: $0.01/page

---

## Provider Feature Comparison

| Feature | Claude Opus 4.5 | Mistral OCR 3 | Tensorlake |
|---------|----------------|---------------|------------|
| **Accuracy Rank** | #1 (ELO 1696) | #19 (ELO 1434) | Not ranked |
| **Cost/Page** | ~$0.045-0.09 | $0.001-0.003 | $0.01 |
| **Structured Output** | Yes (native) | Yes (annotations) | Yes (native) |
| **Header/Footer Extraction** | Yes | Yes (extract_header/footer) | Yes |
| **Table Formats** | Markdown, HTML | Markdown, HTML | Markdown, HTML, Text |
| **Handwriting** | Excellent | Good | Good |
| **Multi-page Context** | Excellent | Good | Good |
| **Batch Discount** | 50% | 50% | N/A |
| **File Size Limit** | None | None | None |

---

## Complete Example: Processing a Scientific Paper

```r
library(ohseer)
library(ecoextract)

# 1. Choose provider based on needs
# Option A: Maximum accuracy (Claude Opus 4.5)
result <- claude_ocr("paper.pdf")
pages <- claude_extract_pages(result)

# Option B: Cost-optimized (Mistral OCR 3)
schema <- list(...)  # Tensorlake-compatible schema
result <- mistral_ocr(
  "paper.pdf",
  document_annotation_format = list(type = "json_schema", json_schema = schema),
  extract_header = TRUE,
  extract_footer = TRUE
)
pages <- mistral_extract_pages(result)

# Option C: Balanced (Tensorlake)
result <- tensorlake_ocr("paper.pdf")
pages <- tensorlake_extract_pages(result)

# 2. All providers return same structure
str(pages)
# List of 10 (pages)
#  $ :List of 6
#   ..$ page_number   : int 1
#   ..$ page_header   : chr [1:2] "Journal Name" "Volume 10, 2026"
#   ..$ section_header: chr "Introduction"
#   ..$ text          : chr "The study examines..."
#   ..$ tables        :List of 1
#   .. ..$ :List of 4
#   .. .. ..$ content : chr "Species\tCount\n..."
#   .. .. ..$ markdown: chr "| Species | Count |\n..."
#   .. .. ..$ html    : chr "<table><tr><th>Species..."
#   .. .. ..$ summary : chr "Table 1: Species abundance"
#   ..$ other         :List of 1
#   .. ..$ :List of 2
#   .. .. ..$ type   : chr "figure_caption"
#   .. .. ..$ content: chr "Figure 1. Study site map"

# 3. Convert to JSON for ecoextract
json_content <- jsonlite::toJSON(pages, auto_unbox = TRUE, pretty = TRUE)

# 4. Use with ecoextract
db_conn <- DBI::dbConnect(RSQLite::SQLite(), "my_database.db")
ecoextract::create_database_schema(db_conn)

# Store document
doc_id <- ecoextract::add_document(
  db_conn = db_conn,
  document_name = "paper.pdf",
  document_content = json_content
)

# Extract metadata
ecoextract::extract_metadata(doc_id, db_conn)

# Extract records
ecoextract::extract_records(doc_id, db_conn)
```

---

## Troubleshooting

### Headers/Footers Not Extracted (Mistral)

Make sure you're using OCR 3 and have enabled extraction:
```r
result <- mistral_ocr(
  "document.pdf",
  model = "mistral-ocr-2512",  # OCR 3
  extract_header = TRUE,
  extract_footer = TRUE
)
```

### Structured Output Not Working (Mistral)

Ensure you're using the `document_annotation_format` parameter:
```r
result <- mistral_ocr(
  "document.pdf",
  document_annotation_format = list(
    type = "json_schema",
    json_schema = your_schema
  )
)
```

### Claude Response Not Parsed

Check that the structured_output field exists:
```r
result <- claude_ocr("document.pdf")
if (is.null(result$structured_output)) {
  # Claude may have returned non-JSON text
  print(result$raw_text)
}
```

### Cost Higher Than Expected (Claude)

Monitor token usage and optimize:
```r
# Check usage
result$usage

# Reduce max_tokens if needed
result <- claude_ocr("document.pdf", max_tokens = 8000)

# Use Sonnet instead of Opus
result <- claude_ocr("document.pdf", model = "claude-sonnet-4.5-20250929")
```

---

## API Keys Setup

Set environment variables in your `.Renviron` file:

```bash
# Claude Opus 4.5
ANTHROPIC_API_KEY=sk-ant-your-key-here

# Mistral OCR 3
MISTRAL_API_KEY=your-mistral-key-here

# Tensorlake
TENSORLAKE_API_KEY=your-tensorlake-key-here
```

Or set them in your R session:
```r
Sys.setenv(ANTHROPIC_API_KEY = "your-key")
Sys.setenv(MISTRAL_API_KEY = "your-key")
Sys.setenv(TENSORLAKE_API_KEY = "your-key")
```

---

## Additional Resources

- [Cost Comparison](COST_COMPARISON.md) - Detailed pricing analysis
- [OCR Arena Leaderboard](https://www.ocrarena.ai/leaderboard) - Live rankings
- [Claude Pricing](https://platform.claude.com/docs/en/about-claude/pricing)
- [Mistral OCR 3 Docs](https://docs.mistral.ai/models/ocr-3-25-12)
- [Tensorlake Pricing](https://www.tensorlake.ai/pricing)
