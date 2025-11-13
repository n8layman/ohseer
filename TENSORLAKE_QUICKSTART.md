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

### Extract Text

```r
# Get text by page
text_pages <- tensorlake_extract_text(result)

# Get text from first 2 pages
first_two <- tensorlake_extract_text(result, pages = 1:2)

# Get all text as single string
full_text <- paste(tensorlake_extract_text(result), collapse = "\n\n")
```

### Extract Tables

```r
# Get all tables
tables <- tensorlake_extract_tables(result)

# Access table data
table1 <- tables[[1]]
table1$page_number     # Page where table appears
table1$content$content # Text content
table1$content$html    # HTML representation
```

### Get Metadata

```r
metadata <- tensorlake_extract_metadata(result)

metadata$total_pages        # Total pages in document
metadata$parsed_pages_count # Pages successfully parsed
metadata$processing_time    # Processing time in seconds
metadata$usage              # API usage stats
```

## Common Workflows

### Extract Citation Info from Academic Paper

```r
# Parse first 2 pages (where citation info usually is)
result <- tensorlake_ocr("paper.pdf", pages = "1-2")

# Get text
citation_text <- paste(
  tensorlake_extract_text(result),
  collapse = "\n\n"
)

# Now use an LLM to extract structured citation data
# (title, authors, journal, DOI, etc.)
```

### Extract All Tables from Report

```r
# Parse document
result <- tensorlake_ocr("report.pdf")

# Get all tables
tables <- tensorlake_extract_tables(result)

# Process each table
for (i in seq_along(tables)) {
  cat("Table", i, "on page", tables[[i]]$page_number, "\n")
  cat(tables[[i]]$content$content, "\n\n")
}
```

### Get Full Document Text

```r
# Parse document
result <- tensorlake_ocr("document.pdf")

# Extract all text maintaining page breaks
text_by_page <- tensorlake_extract_text(result)
for (i in seq_along(text_by_page)) {
  cat("=== PAGE", i, "===\n")
  cat(text_by_page[i], "\n\n")
}

# Or as single string
full_text <- paste(text_by_page, collapse = "\n\n")
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
