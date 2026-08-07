# ohseer 0.1.0

## New OCR providers

* **olmOCR** (AI2): open-weights vision-language model served over any
  OpenAI-compatible endpoint (DeepInfra, Parasail, Cirrascale, or a local vLLM
  server). Configure with `OLMOCR_API_KEY` and `OLMOCR_SERVER`. Adds
  `olmocr_ocr()` and `olmocr_extract_pages()`.
* **Chandra** (Datalab): hosted academic-document OCR API with strong tables and
  equations and figure extraction. Configure with `DATALAB_API_KEY`. Adds
  `chandra_ocr()` and `chandra_extract_pages()`.
* **dots.mocr** (rednote-hilab): local multilingual layout vision-language model
  served by your own vLLM server. Configure with `DOTSMOCR_SERVER` (defaults to
  `http://localhost:8000/v1`). Adds `dotsmocr_ocr()` and
  `dotsmocr_extract_pages()`.

All three are selectable through the unified `ohseer_ocr()` interface (including
provider fallback) and return the shared Tensorlake-compatible per-page format.

## Improvements

* Chat-based providers now use [ellmer](https://ellmer.tidyverse.org) for the LLM
  plumbing: Claude via `chat_anthropic()` with `type_*()` structured output,
  olmOCR via `chat_openai_compatible()`, and dots.mocr via `chat_vllm()`. The
  bespoke OCR REST APIs (Mistral, Tensorlake, Chandra, Textract) continue to use
  httr2 directly. Claude's structured output is requested with `convert = FALSE`,
  preserving the existing per-page output contract.
* Fixed the package author/citation metadata so `citation("ohseer")` credits
  Nathan Layman (ORCID 0000-0003-2238-6584).

## Dependencies

* Added `ellmer (>= 0.4.0)` to Imports.
* Removed the now-unused `base64enc` dependency.
