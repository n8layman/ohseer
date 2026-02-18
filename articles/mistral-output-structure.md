# Understanding Mistral OCR Output Structure

## Introduction

This vignette explains the native structure of objects returned by
Mistral’s OCR functions. The `ohseer` package returns Mistral’s native
format without post-processing, allowing applications to handle
transformations as needed.

### Basic Usage

``` r
library(ohseer)

# Parse a document with Mistral OCR
result <- mistral_ocr("document.pdf",
                     extract_header = TRUE,
                     extract_footer = TRUE)

# Extract pages (returns native Mistral format)
pages <- mistral_extract_pages(result)
```

## Output Structure

The
[`mistral_ocr()`](https://n8layman.github.io/ohseer/reference/mistral_ocr.md)
function returns a list with Mistral’s complete response structure.

### Top-Level Fields

``` r
str(result, max.level = 1)
```

Key top-level fields include:

- **`id`**: Unique job identifier
- **`object`**: Object type (typically “document_ocr”)
- **`model`**: Model used (e.g., “mistral-ocr-2512”)
- **`usage`**: Token usage statistics
- **`pages`**: List of page objects (detailed below)
- **`created`**: Timestamp of creation

## Page Structure

Each element in `result$pages` represents one page and contains:

### Page Fields

``` r
page1 <- result$pages[[1]]
str(page1, max.level = 1)
```

Each page object has these 8 fields:

- **`index`**: 0-based page number (first page = 0)
- **`markdown`**: Full page content in markdown format
- **`images`**: Array of extracted images (base64 or URLs)
- **`tables`**: Array of table objects (detailed below)
- **`hyperlinks`**: Array of hyperlinks detected on the page
- **`header`**: Page header text (when `extract_header = TRUE`)
- **`footer`**: Page footer text (when `extract_footer = TRUE`)
- **`dimensions`**: Page dimensions object

### Example Page Structure

``` r
{
  "index": 0,
  "markdown": "# Page Title\n\nPage content here...",
  "images": [],
  "tables": [...],
  "hyperlinks": [],
  "header": "JOURNAL NAME - Volume 1",
  "footer": "Page 1",
  "dimensions": {
    "dpi": 200,
    "height": 1942,
    "width": 2828
  }
}
```

## Table Structure

Tables are extracted and stored in the `tables` array of each page.

### Table Fields

``` r
table1 <- page1$tables[[1]]
str(table1)
```

Each table has 3 fields:

- **`id`**: Unique table identifier (e.g., “tbl-0.md”)
- **`content`**: Markdown-formatted table content
- **`format`**: Format type (typically “markdown”)

### Example Table

``` r
{
  "id": "tbl-0.md",
  "content": "| Species | Location | Age (years) |\n| --- | --- | --- |\n| E. camaldu... ",
  "format": "markdown"
}
```

### Table References in Markdown

Tables are referenced in the page markdown using markdown link syntax:

``` markdown
See Table 1 below:

[tbl-0.md](tbl-0.md)
```

The actual table content is in the `tables` array, not embedded in the
markdown.

## Headers and Footers

When you enable header/footer extraction, Mistral separates them from
the main content.

### Extraction Options

``` r
result <- mistral_ocr("document.pdf",
                     extract_header = TRUE,  # Extract running headers
                     extract_footer = TRUE)  # Extract page numbers/footers
```

### Header/Footer Format

Headers and footers can be:

- **String**: `"CHAPTER FIVE\n64 RETENTION OF TREES WITH HOLLOWS"`
- **Empty object**: [`{}`](https://rdrr.io/r/base/Paren.html) (when no
  header/footer detected)
- **NULL**: When extraction is disabled

### Benefits of Extraction

Extracting headers/footers separately:

1.  Removes repetitive content from page markdown
2.  Preserves page numbers and running headers for reference
3.  Keeps body text cleaner for downstream processing

## Dimensions Object

Each page includes dimension information for rendering calculations.

``` r
page1$dimensions
```

### Dimension Fields

- **`dpi`**: Dots per inch (resolution)
- **`height`**: Page height in pixels
- **`width`**: Page width in pixels

## Extracting Information

### Get Specific Pages

Use
[`mistral_extract_pages()`](https://n8layman.github.io/ohseer/reference/mistral_extract_pages.md)
to filter to specific pages:

``` r
# Extract first 3 pages only
first_three <- mistral_extract_pages(result, pages = c(1, 2, 3))

# Note: page numbers in the pages argument are 1-based
# But the 'index' field in each page is 0-based
```

### Extract All Text

Combine markdown from all pages:

``` r
all_text <- sapply(result$pages, function(p) p$markdown)
full_document <- paste(all_text, collapse = "\n\n")
```

### Extract All Tables

Collect all tables from the document:

``` r
all_tables <- list()
for (i in seq_along(result$pages)) {
  page <- result$pages[[i]]
  if (length(page$tables) > 0) {
    for (j in seq_along(page$tables)) {
      all_tables[[length(all_tables) + 1]] <- list(
        page_number = i,  # 1-based for human readability
        page_index = page$index,  # 0-based as in original
        table_id = page$tables[[j]]$id,
        content = page$tables[[j]]$content
      )
    }
  }
}

# View table summary
do.call(rbind, lapply(all_tables, function(t) {
  data.frame(
    page = t$page_number,
    table_id = t$table_id,
    chars = nchar(t$content)
  )
}))
```

### Parse Table Markdown

Convert markdown tables to data frames:

``` r
library(knitr)

# Get first table
table1 <- result$pages[[1]]$tables[[1]]

# Parse markdown to data frame (requires knitr)
# Note: This is a simple approach; more robust parsing may be needed
lines <- strsplit(table1$content, "\n")[[1]]
# Remove separator line (usually second line with ---)
data_lines <- lines[!grepl("^\\|?[-\\s]+\\|[-\\s]+", lines)]

# You can also send the markdown to an LLM for structured extraction
```

### Extract Hyperlinks

Access all hyperlinks found on pages:

``` r
for (i in seq_along(result$pages)) {
  page <- result$pages[[i]]
  if (length(page$hyperlinks) > 0) {
    cat("Page", i, "hyperlinks:\n")
    print(page$hyperlinks)
  }
}
```

## Complete Example

Here’s a complete workflow for processing a scientific paper:

``` r
library(ohseer)
library(jsonlite)

# 1. Parse the document with header/footer extraction
result <- mistral_ocr("paper.pdf",
                     extract_header = TRUE,
                     extract_footer = TRUE,
                     table_format = "markdown")

# 2. Extract all pages
pages <- mistral_extract_pages(result)

# 3. Examine first page structure
page1 <- pages[[1]]
cat("Page", page1$index + 1, "\n")  # +1 for 1-based display
cat("Header:", page1$header, "\n")
cat("Footer:", if(is.null(page1$footer) || length(page1$footer) == 0) "None" else page1$footer, "\n")
cat("Tables:", length(page1$tables), "\n")
cat("Images:", length(page1$images), "\n")

# 4. Extract all tables with page information
all_tables <- list()
for (page in pages) {
  for (table in page$tables) {
    all_tables[[length(all_tables) + 1]] <- list(
      page = page$index + 1,  # Convert to 1-based
      id = table$id,
      markdown = table$content
    )
  }
}

cat("Total tables found:", length(all_tables), "\n")

# 5. Convert to JSON for downstream processing
json_output <- toJSON(pages, auto_unbox = TRUE, pretty = TRUE)

# 6. Process with your application
# Applications can implement their own transformations based on needs
```

## Key Differences from Other Providers

### Index Numbering

- **Mistral**: Uses 0-based indexing in the `index` field (first page =
  0)
- **Tensorlake**: Uses 1-based `page_number` (first page = 1)

Always remember this when filtering or displaying page numbers.

### Table Handling

- **Mistral**: Tables referenced as `[tbl-0.md](tbl-0.md)` in markdown,
  full content in `tables` array
- **Tensorlake**: Tables embedded in page fragments with fragment type

### No Post-Processing

The `ohseer` package returns Mistral’s native format without
transformation. This means:

- Applications control their own data transformations
- No imposed structure that may not fit all use cases
- Direct access to all fields Mistral provides
- Simpler, more maintainable package code

## Tips and Best Practices

1.  **Page Numbering**: Always be aware of the 0-based `index` vs
    1-based page references:

    ``` r
    # To get "page 1" (human numbering):
    page1 <- pages[[1]]  # R uses 1-based indexing
    # But page1$index will be 0
    ```

2.  **Header/Footer Extraction**: Enable these for cleaner body text:

    ``` r
    result <- mistral_ocr("doc.pdf", extract_header = TRUE, extract_footer = TRUE)
    ```

3.  **Table Format**: Request markdown format for easier parsing:

    ``` r
    result <- mistral_ocr("doc.pdf", table_format = "markdown")
    ```

4.  **Image Handling**: Use `include_image_base64 = TRUE` to get images:

    ``` r
    result <- mistral_ocr("doc.pdf", include_image_base64 = TRUE)
    # Access with: pages[[1]]$images
    ```

5.  **JSON Export**: For LLM processing, convert to JSON:

    ``` r
    library(jsonlite)
    json_str <- toJSON(pages, auto_unbox = TRUE, pretty = TRUE)
    # Send to Claude, GPT, etc. for structured extraction
    ```

6.  **Validate Results**: Check that OCR completed successfully:

    ``` r
    if (is.null(result$pages) || length(result$pages) == 0) {
      stop("OCR returned no pages")
    }
    ```

## Further Reading

- [Mistral Setup
  Guide](https://n8layman.github.io/ohseer/MISTRAL_SETUP.md)
- [Tensorlake Output
  Structure](https://n8layman.github.io/ohseer/articles/tensorlake-output-structure.md)
- [Package README](https://n8layman.github.io/ohseer/README.md)
- Mistral AI API documentation: <https://docs.mistral.ai>
