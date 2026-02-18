# OCR Provider Cost & Accuracy Comparison

This document compares the three OCR providers supported by `ohseer` in
terms of cost, accuracy (OCR Arena ranking), and key features.

**Last Updated:** February 2026

------------------------------------------------------------------------

## Pricing Summary

| Provider            | Standard Cost       | Batch/Discount Cost                   | Structured Output               | Notes                                    |
|---------------------|---------------------|---------------------------------------|---------------------------------|------------------------------------------|
| **Claude Opus 4.5** | ~\$0.15-0.25/page\* | ~\$0.075-0.125/page\* (50% Batch API) | Yes (native)                    | \#1 OCR Arena, token-based pricing       |
| **Mistral OCR 3**   | \$0.002/page        | \$0.001/page (50% Batch API)          | \$0.003/page (with annotations) | \#19 OCR Arena, page-based pricing       |
| **Tensorlake**      | \$0.01/page         | N/A                                   | Yes (native)                    | Not on OCR Arena, 91.7% accuracy claimed |

\* *Claude pricing is token-based, not page-based. Estimates assume
~3,000 input tokens + ~3,000 output tokens per average page with
tables/structure. Actual costs vary by document complexity.*

------------------------------------------------------------------------

## Detailed Pricing

### 1. Claude Opus 4.5 (Anthropic)

**API Pricing (2026):** - Input: \$5 per million tokens (\$0.005 per 1K
tokens) - Output: \$25 per million tokens (\$0.025 per 1K tokens) -
**Batch API**: 50% discount on all token costs

**Estimated Cost Per Page:**

Assuming an average document page with moderate complexity (text +
tables + structure extraction): - Input tokens: ~3,000 tokens (PDF
page + extraction prompt) - Output tokens: ~3,000 tokens (structured
JSON with text, tables, headers)

**Standard API:** - Input cost: 3K tokens × \$0.005 = \$0.015 - Output
cost: 3K tokens × \$0.025 = \$0.075 - **Total: ~\$0.09 per page**

**Batch API (50% discount):** - **Total: ~\$0.045 per page**

**Cost Optimization:** - Prompt caching can reduce costs by up to 90%
for repeated processing - Cache writes: \$6.25/MTok (25% surcharge) -
Cache reads: \$0.50/MTok (90% discount)

**Important Note:** These are estimates. Actual costs depend on: -
Document complexity (more tables/structure = more output tokens) - Page
text density - Number of tables per page - Use of prompt caching

For simple text-only pages, costs could be as low as \$0.03-0.05/page.
For complex multi-table scientific documents, costs could reach
\$0.20-0.30/page.

### 2. Mistral OCR 3

**API Pricing (2026):** - Standard: \$2 per 1,000 pages = **\$0.002 per
page** - Batch API: \$1 per 1,000 pages = **\$0.001 per page** (50%
discount) - Annotations (structured output): \$3 per 1,000 pages =
**\$0.003 per page**

**Key Features:** - Fixed page-based pricing (predictable costs) -
Structured output via JSON schema annotations - 74% win rate over
Mistral OCR 2 - Backward compatible with OCR 2

### 3. Tensorlake

**API Pricing (2026):** - Standard: **\$0.01 per page** - No batch
discount listed - Structured output included in base price

**Key Features:** - Claims 91.7% accuracy (vs 88.4% for AWS Textract) -
No file size limits (unlike AWS Textract’s 5MB synchronous limit) -
Async processing for large documents - Native structured output with
fragment types

------------------------------------------------------------------------

## OCR Arena Rankings (February 2026)

| Rank   | Model                 | ELO  | Win Rate | Battles |
|--------|-----------------------|------|----------|---------|
| **1**  | **Opus 4.5 (Medium)** | 1696 | 71.2%    | 1217    |
| 2      | Gemini 3 Preview      | 1661 | 72.9%    | 1951    |
| 3      | Gemini 2.5 Pro        | 1655 | 72.2%    | 1915    |
| …      | …                     | …    | …        | …       |
| **19** | **Mistral OCR v3**    | 1434 | 39.0%    | 195     |

*Tensorlake is not ranked on OCR Arena.*

------------------------------------------------------------------------

## Cost vs Accuracy Trade-offs

### Best Accuracy (Highest Quality)

**Claude Opus 4.5** - \#1 on OCR Arena - Cost: ~\$0.045-0.09/page (Batch
API) - Use when: Maximum accuracy is critical, complex handwriting,
scientific documents, legal/medical docs

### Best Value (Cost/Performance Balance)

**Tensorlake** - 91.7% claimed accuracy - Cost: \$0.01/page - Use when:
Good balance of accuracy and cost, processing large volumes, structured
documents

### Lowest Cost

**Mistral OCR 3** - Industry-leading low price - Cost:
\$0.001-0.003/page - Use when: Budget is primary concern, processing
massive volumes (millions of pages), acceptable accuracy for simpler
documents

------------------------------------------------------------------------

## Recommendation by Use Case

### High-Value Documents (Legal, Medical, Research)

→ **Claude Opus 4.5** - Highest accuracy minimizes costly errors -
Superior handwriting recognition - Best table extraction

### Large-Scale Production Workloads

→ **Tensorlake** or **Mistral OCR 3 Batch** - Tensorlake: Better
accuracy, structured output - Mistral Batch: Lowest cost at scale

### Scientific/Technical Documents

→ **Claude Opus 4.5** or **Tensorlake** - Both handle complex tables
well - Claude excels at multi-page context - Tensorlake offers good
accuracy at lower cost

### Budget-Constrained Projects

→ **Mistral OCR 3 Batch** - \$0.001/page for batch processing -
Acceptable accuracy for many use cases - Structured output available

------------------------------------------------------------------------

## Example: Processing 10,000 Pages

| Provider        | Standard Cost | Batch/Optimized Cost       | Accuracy Rank              |
|-----------------|---------------|----------------------------|----------------------------|
| Claude Opus 4.5 | \$900-2,500\* | \$450-1,250\*              | \#1 (ELO 1696)             |
| Mistral OCR 3   | \$20          | \$10 (\$30 w/ annotations) | \#19 (ELO 1434)            |
| Tensorlake      | \$100         | \$100                      | Not ranked (91.7% claimed) |

\* *Costs vary based on document complexity. Lower end for simple text,
higher end for complex multi-table documents.*

------------------------------------------------------------------------

## Sources

- [Claude Opus 4.5 Pricing -
  Anthropic](https://platform.claude.com/docs/en/about-claude/pricing)
- [Claude Opus 4.5 Pricing Guide -
  CometAPI](https://www.cometapi.com/the-guide-to-claude-opus-4--4-5-api-pricing-in-2026/)
- [Mistral OCR 3 Announcement](https://mistral.ai/news/mistral-ocr-3)
- [Mistral OCR 3 Pricing -
  VentureBeat](https://venturebeat.com/technology/mistral-launches-ocr-3-to-digitize-enterprise-documents-touts-74-win-rate)
- [Tensorlake Pricing](https://www.tensorlake.ai/pricing)
- [OCR Arena Leaderboard](https://www.ocrarena.ai/leaderboard)

------------------------------------------------------------------------

## Notes

- All pricing current as of February 2026
- Costs exclude API call overhead, storage, and data transfer
- Batch API discounts typically require minimum volume commitments
- Prompt caching (Claude) can significantly reduce costs for repeated
  processing patterns
- Actual costs may vary based on document characteristics and API usage
  patterns
