# Check if lines look like file header fields

A header line is a comment (or bare, for multi-line comment blocks) line
whose content *starts* with a recognizable header field such as
`Copyright (c) ...`, `Author: ...`, or `License: ...`. Anchoring the
match to the start of the comment content avoids false positives from
documentation comments (e.g. roxygen's `#' @author`), prose that merely
mentions a license, markdown syntax, and code that manipulates these
keywords.

## Usage

``` r
is_header_line(lines)
```

## Arguments

- lines:

  Character vector. Lines to test.

## Value

Logical vector. TRUE for lines that look like header fields.
