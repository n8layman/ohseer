#' Extract Metadata from AWS Textract Response
#'
#' This convenience function parses AWS Textract output to extract citation metadata
#' and other structured information from document headers. Useful for extracting
#' titles, authors, DOIs, journal names, dates, etc. from academic papers.
#'
#' @author Nathan C. Layman
#'
#' @param textract_response List. Response from textract_ocr().
#'
#' @return List with the following structure:
#'   \describe{
#'     \item{text}{Character string. Full document text with line breaks.}
#'     \item{key_value_pairs}{Data frame with columns: key, value, confidence. Contains extracted metadata like "Title:", "Author:", etc.}
#'     \item{tables}{List of data frames, one per table.}
#'     \item{pages}{Integer. Number of pages processed.}
#'   }
#'
#' @examples
#' \dontrun{
#' # Process document with Textract
#' result <- textract_ocr("paper.pdf")
#'
#' # Extract citation metadata
#' metadata <- textract_extract_metadata(result)
#'
#' # Access extracted key-value pairs (e.g., Title, Authors, DOI)
#' metadata$key_value_pairs
#' }
#'
#' @export
textract_extract_metadata <- function(textract_response) {

  # Extract blocks
  blocks <- textract_response$Blocks
  if (is.null(blocks) || length(blocks) == 0) {
    warning("No blocks found in Textract response.")
    return(list(
      text = "",
      key_value_pairs = NULL,
      tables = NULL,
      pages = 0
    ))
  }

  # Extract full text (LINE blocks)
  text_lines <- sapply(blocks, function(block) {
    if (!is.null(block$BlockType) && block$BlockType == "LINE") {
      return(block$Text)
    }
    return(NULL)
  })
  text_lines <- unlist(text_lines[!sapply(text_lines, is.null)])
  full_text <- paste(text_lines, collapse = "\n")

  # Count pages
  page_blocks <- sapply(blocks, function(block) {
    if (!is.null(block$BlockType) && block$BlockType == "PAGE") {
      return(TRUE)
    }
    return(FALSE)
  })
  num_pages <- sum(unlist(page_blocks))

  # Extract key-value pairs (FORMS)
  key_value_pairs <- textract_extract_key_value_pairs(blocks)

  # Extract tables
  tables <- textract_extract_tables(blocks)

  # Return structured result
  result <- list(
    text = full_text,
    key_value_pairs = key_value_pairs,
    tables = tables,
    pages = num_pages
  )

  return(result)
}


#' Extract Key-Value Pairs from Textract Blocks
#'
#' @param blocks List of Textract blocks
#' @return Data frame with key-value pairs or NULL
#' @keywords internal
textract_extract_key_value_pairs <- function(blocks) {

  # Find KEY_VALUE_SET blocks
  kv_blocks <- Filter(function(block) {
    !is.null(block$BlockType) && block$BlockType == "KEY_VALUE_SET"
  }, blocks)

  if (length(kv_blocks) == 0) {
    return(NULL)
  }

  # Separate keys and values
  keys <- Filter(function(block) {
    !is.null(block$EntityTypes) && "KEY" %in% block$EntityTypes
  }, kv_blocks)

  values <- Filter(function(block) {
    !is.null(block$EntityTypes) && "VALUE" %in% block$EntityTypes
  }, kv_blocks)

  if (length(keys) == 0) {
    return(NULL)
  }

  # Build key-value pairs
  kv_pairs <- lapply(keys, function(key_block) {
    # Get key text
    key_text <- textract_get_block_text(key_block, blocks)

    # Find associated value
    value_id <- NULL
    if (!is.null(key_block$Relationships)) {
      for (rel in key_block$Relationships) {
        if (!is.null(rel$Type) && rel$Type == "VALUE") {
          value_id <- rel$Ids[[1]]
          break
        }
      }
    }

    # Get value text
    value_text <- ""
    if (!is.null(value_id)) {
      value_block <- Find(function(b) !is.null(b$Id) && b$Id == value_id, blocks)
      if (!is.null(value_block)) {
        value_text <- textract_get_block_text(value_block, blocks)
      }
    }

    # Get confidence
    confidence <- ifelse(!is.null(key_block$Confidence), key_block$Confidence, NA)

    return(data.frame(
      key = key_text,
      value = value_text,
      confidence = confidence,
      stringsAsFactors = FALSE
    ))
  })

  # Combine into data frame
  if (length(kv_pairs) > 0) {
    result <- do.call(rbind, kv_pairs)
    return(result)
  }

  return(NULL)
}


#' Extract Tables from Textract Blocks
#'
#' @param blocks List of Textract blocks
#' @return List of data frames (one per table) or NULL
#' @keywords internal
textract_extract_tables <- function(blocks) {

  # Find TABLE blocks
  table_blocks <- Filter(function(block) {
    !is.null(block$BlockType) && block$BlockType == "TABLE"
  }, blocks)

  if (length(table_blocks) == 0) {
    return(NULL)
  }

  # Process each table
  tables <- lapply(table_blocks, function(table_block) {
    textract_parse_table(table_block, blocks)
  })

  return(tables)
}


#' Parse a Single Table from Textract Blocks
#'
#' @param table_block Textract TABLE block
#' @param blocks All blocks for reference
#' @return Data frame representing the table
#' @keywords internal
textract_parse_table <- function(table_block, blocks) {

  # Get CELL blocks for this table
  cell_ids <- NULL
  if (!is.null(table_block$Relationships)) {
    for (rel in table_block$Relationships) {
      if (!is.null(rel$Type) && rel$Type == "CHILD") {
        cell_ids <- rel$Ids
        break
      }
    }
  }

  if (is.null(cell_ids)) {
    return(data.frame())
  }

  # Get all cell blocks
  cell_blocks <- Filter(function(block) {
    !is.null(block$Id) && block$Id %in% cell_ids && !is.null(block$BlockType) && block$BlockType == "CELL"
  }, blocks)

  if (length(cell_blocks) == 0) {
    return(data.frame())
  }

  # Determine table dimensions
  max_row <- max(sapply(cell_blocks, function(b) ifelse(!is.null(b$RowIndex), b$RowIndex, 0)))
  max_col <- max(sapply(cell_blocks, function(b) ifelse(!is.null(b$ColumnIndex), b$ColumnIndex, 0)))

  # Create empty matrix
  table_matrix <- matrix("", nrow = max_row, ncol = max_col)

  # Fill matrix with cell text
  for (cell in cell_blocks) {
    row_idx <- cell$RowIndex
    col_idx <- cell$ColumnIndex
    cell_text <- textract_get_block_text(cell, blocks)
    table_matrix[row_idx, col_idx] <- cell_text
  }

  # Convert to data frame
  if (max_row > 1) {
    # Use first row as column names if available
    df <- as.data.frame(table_matrix[-1, , drop = FALSE], stringsAsFactors = FALSE)
    colnames(df) <- table_matrix[1, ]
  } else {
    df <- as.data.frame(table_matrix, stringsAsFactors = FALSE)
  }

  return(df)
}


#' Get Text Content from a Textract Block
#'
#' @param block Textract block
#' @param blocks All blocks for reference
#' @return Character string with block text
#' @keywords internal
textract_get_block_text <- function(block, blocks) {

  # If block has direct text, return it
  if (!is.null(block$Text)) {
    return(block$Text)
  }

  # Otherwise, get text from CHILD blocks
  child_texts <- NULL
  if (!is.null(block$Relationships)) {
    for (rel in block$Relationships) {
      if (!is.null(rel$Type) && rel$Type == "CHILD") {
        child_ids <- rel$Ids
        for (child_id in child_ids) {
          child_block <- Find(function(b) !is.null(b$Id) && b$Id == child_id, blocks)
          if (!is.null(child_block) && !is.null(child_block$Text)) {
            child_texts <- c(child_texts, child_block$Text)
          }
        }
        break
      }
    }
  }

  if (!is.null(child_texts)) {
    return(paste(child_texts, collapse = " "))
  }

  return("")
}
