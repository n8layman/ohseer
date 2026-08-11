# Render PDF pages (or a single image) to PNG files for image-based OCR models

Shared helper used by the olmOCR and dots.mocr providers.

## Usage

``` r
olmocr_render_pages(file_path, pages, target_longest_image_dim)
```

## Arguments

- file_path:

  Character string. Path to a PDF, PNG, or JPEG file.

- pages:

  Integer vector or NULL. 1-based pages to render (PDF only).

- target_longest_image_dim:

  Integer. Longest-side pixel target for PDFs.

## Value

A list with `paths` (rendered PNG paths in page order), `page_numbers`
(1-based page numbers), and `tmp_files` (temporary files to clean up).
