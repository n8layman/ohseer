# Tensorlake Quick Start Guide

Quick reference for using Tensorlake with `ohseer`.

## Setup (One Time)

1. Get API key from https://cloud.tensorlake.ai
2. Set environment variable:
   ```r
   Sys.setenv(TENSORLAKE_API_KEY = "your-key-here")
   ```

Or add to `.env` file:
```bash
TENSORLAKE_API_KEY=your-key-here
```

## Basic Usage

### Parse a Document

```r
library(ohseer)

# Parse entire document
result <- tensorlake_ocr("document.pdf")

# Parse specific pages
result <- tensorlake_ocr("document.pdf", pages = "1-5")
```

### Extract Structured Page Data

```r
library(jsonlite)

# Extract structured data from first 2 pages
pages <- tensorlake_extract_pages(result, pages = c(1, 2))

# Access first page
page1 <- pages[[1]]
page1$page_header      # Journal citation, page headers
page1$section_header   # Article title, section headers
page1$text            # Body text (markdown format)
page1$tables          # List of tables with content/markdown/html
page1$other           # Other fragment types

# Convert to JSON for LLM processing
json_data <- toJSON(pages, auto_unbox = TRUE, pretty = TRUE)
```

### Get Metadata

```r
# Access metadata directly from result
result$total_pages        # Total pages in document
result$parsed_pages_count # Pages successfully parsed
result$status            # Parse status
result$usage             # API usage stats
```

## Common Workflows

### Extract Citation Info from Academic Paper

```r
# Parse only first 2 pages (faster, cheaper for citations)
result <- tensorlake_ocr("paper.pdf", pages = c(1, 2))

# Extract all parsed pages (just pages 1-2)
pages <- tensorlake_extract_pages(result)

# Get citation components
page1 <- pages[[1]]
citation <- page1$page_header     # e.g., "Journal Name, 30(3), 1994, pp. 439-444"
title <- page1$section_header     # Article title
authors_text <- page1$text        # Contains authors and affiliations

# Convert to JSON for LLM extraction
json_for_llm <- toJSON(pages, auto_unbox = TRUE, pretty = TRUE)

# Send json_for_llm to Claude or another LLM to extract:
# - Authors, affiliations, journal, volume, pages, year, DOI, etc.
```

### Extract Tables from Document

```r
# Parse entire document
result <- tensorlake_ocr("report.pdf")

# Extract all pages
pages <- tensorlake_extract_pages(result)

# Process tables from each page
for (page in pages) {
  if (length(page$tables) > 0) {
    cat("Page", page$page_number, "has", length(page$tables), "table(s)\n")
    for (tbl in page$tables) {
      cat(tbl$markdown, "\n\n")  # Markdown format
      # Also available: tbl$html, tbl$content, tbl$summary
    }
  }
}
```

### Get Structured Data for Multiple Pages

```r
# Parse entire document
result <- tensorlake_ocr("document.pdf")

# Extract all pages (default behavior)
all_pages <- tensorlake_extract_pages(result)

# Process each page
for (page in all_pages) {
  cat("=== PAGE", page$page_number, "===\n")
  cat("Headers:", paste(page$page_header, collapse = "; "), "\n")
  cat("Sections:", paste(page$section_header, collapse = "; "), "\n")
  cat("Tables:", length(page$tables), "\n")
  cat("Text length:", nchar(page$text), "chars\n\n")
}
```

## Output Structure Quick Reference

```r
result$
  ├─ parse_id              # Unique parse job ID
  ├─ status                # "successful" when done
  ├─ total_pages           # Total pages
  ├─ parsed_pages_count    # Pages parsed
  ├─ pages[]               # Array of page data
  │  └─ page_fragments[]   # Content on each page
  │     ├─ fragment_type   # "text", "table", "section_header", etc.
  │     ├─ content         # The actual content
  │     ├─ reading_order   # Order to read fragments
  │     └─ bbox            # Position on page
  ├─ chunks[]              # Text chunks
  ├─ created_at            # Start timestamp
  ├─ finished_at           # End timestamp
  └─ usage                 # API usage stats
```

## Fragment Types

| Type | Description |
|------|-------------|
| `page_header` | Page headers |
| `page_number` | Page numbers |
| `section_header` | Section/chapter headings |
| `text` | Regular paragraphs |
| `table` | Tables |
| `table_caption` | Table captions |
| `figure` | Images/figures |
| `figure_caption` | Figure captions |

## Tips

- **For citations**: Parse only pages 1-2 to save time and cost
- **Check status**: Always verify `result$status == "successful"`
- **Reading order**: Use `reading_order` field to maintain document flow
- **Processing time**: Typically ~1 second per page

## Troubleshooting

**API Key Error**
```r
Error: Tensorlake API key not found
```
→ Set `TENSORLAKE_API_KEY` environment variable

**Timeout Error**
```r
Error: Parse job timed out after 60 seconds
```
→ Increase timeout: `tensorlake_ocr("file.pdf", max_wait_seconds = 120)`

**Parse Failed**
```r
result$status == "failed"
```
→ Check error details or contact Tensorlake support

## More Information

- [Full Vignette](vignettes/tensorlake-output-structure.Rmd)
- [Setup Guide](TENSORLAKE_SETUP.md)
- [Tensorlake Docs](https://docs.tensorlake.ai)
