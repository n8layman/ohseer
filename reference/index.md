# Package index

## Unified Interface

Consistent OCR interface across all providers (recommended)

- [`ohseer_ocr()`](https://n8layman.github.io/ohseer/reference/ohseer_ocr.md)
  : Unified OCR Interface for Multiple Providers with Automatic Fallback

## Tensorlake OCR

Process documents with Tensorlake OCR API

- [`tensorlake_ocr()`](https://n8layman.github.io/ohseer/reference/tensorlake_ocr.md)
  : Process Document with Tensorlake OCR
- [`tensorlake_extract_pages()`](https://n8layman.github.io/ohseer/reference/tensorlake_extract_pages.md)
  : Extract Page Content by Fragment Type

## Mistral OCR

Process documents with Mistral OCR API

- [`mistral_ocr()`](https://n8layman.github.io/ohseer/reference/mistral_ocr.md)
  : Process Document with Mistral AI OCR
- [`mistral_extract_pages()`](https://n8layman.github.io/ohseer/reference/mistral_extract_pages.md)
  : Extract Page Content from Mistral OCR Results
- [`mistral_ocr_upload_file()`](https://n8layman.github.io/ohseer/reference/mistral_ocr_upload_file.md)
  : Upload File to Mistral AI API for OCR Processing
- [`mistral_ocr_get_file_metadata()`](https://n8layman.github.io/ohseer/reference/mistral_ocr_get_file_metadata.md)
  : Retrieve File Metadata from Mistral AI API
- [`mistral_ocr_get_file_url()`](https://n8layman.github.io/ohseer/reference/mistral_ocr_get_file_url.md)
  : Get Temporary URL for Downloading File from Mistral AI API
- [`mistral_ocr_process_url()`](https://n8layman.github.io/ohseer/reference/mistral_ocr_process_url.md)
  : Perform OCR on a Document using Mistral AI
- [`mistral_ocr_process_image()`](https://n8layman.github.io/ohseer/reference/mistral_ocr_process_image.md)
  : Perform OCR on an Image using Mistral AI

## Mistral Preview

Generate HTML previews of Mistral OCR results

- [`mistral_preview_page()`](https://n8layman.github.io/ohseer/reference/mistral_preview_page.md)
  : Preview Mistral OCR Page as HTML
- [`mistral_preview_html()`](https://n8layman.github.io/ohseer/reference/mistral_preview_html.md)
  : Preview Mistral OCR Page as HTML with Embedded Images
- [`mistral_embed_images()`](https://n8layman.github.io/ohseer/reference/mistral_embed_images.md)
  : Embed Base64 Images in Markdown Content

## Claude OCR

Process documents with Claude API using structured outputs

- [`claude_ocr()`](https://n8layman.github.io/ohseer/reference/claude_ocr.md)
  : Process Document with Claude Opus 4.5 OCR
- [`claude_extract_pages()`](https://n8layman.github.io/ohseer/reference/claude_extract_pages.md)
  : Extract Page Content from Claude OCR Results

## AWS Textract

Process documents with AWS Textract

- [`textract_ocr()`](https://n8layman.github.io/ohseer/reference/textract_ocr.md)
  : Process Document with AWS Textract OCR (Synchronous)
- [`textract_extract_metadata()`](https://n8layman.github.io/ohseer/reference/textract_extract_metadata.md)
  : Extract Metadata from AWS Textract Response
- [`textract_analyze_document()`](https://n8layman.github.io/ohseer/reference/textract_analyze_document.md)
  : Analyze Document with AWS Textract (Synchronous, Structured
  Extraction)
- [`textract_detect_document_text()`](https://n8layman.github.io/ohseer/reference/textract_detect_document_text.md)
  : Detect Text in Document with AWS Textract (Synchronous)
