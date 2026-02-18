# Detect Text in Document with AWS Textract (Synchronous)

This function calls the AWS Textract DetectDocumentText API
(synchronous) to extract plain text from documents. This is faster than
AnalyzeDocument but doesn't extract structured data like forms or
tables. Note: This is a synchronous operation with a 5 MB file size
limit. For larger files, the function automatically converts the first 2
pages to PNG format.

## Usage

``` r
textract_detect_document_text(
  file_path,
  aws_access_key_id,
  aws_secret_access_key,
  aws_region = "us-east-1"
)
```

## Arguments

- file_path:

  Character string. Path to a local PDF, PNG, JPEG, or TIFF file.

- aws_access_key_id:

  Character string. AWS access key ID.

- aws_secret_access_key:

  Character string. AWS secret access key.

- aws_region:

  Character string. AWS region. Default is "us-east-1".

## Value

List containing the raw Textract API response with Blocks.

## Warning

This function uses the synchronous Textract API which has a **5 MB file
size limit**. For PDFs larger than 5 MB, only the first 2 pages will be
automatically extracted and converted to PNG format. For full document
processing of large files, consider using the asynchronous S3-based
Textract workflow or an alternative service like Google Document AI (20
MB limit) or Azure Document Intelligence (500 MB limit).

## Author

Nathan C. Layman
