# Check if file has a header

Looks for header field lines (see
[`header_field_lines()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/header_field_lines.md))
in the first 30 lines of the file. Documentation comments such as
roxygen blocks, YAML metadata fields (e.g. `author:` in an R Markdown
document or a YAML config), and markdown syntax are not considered
headers.

## Usage

``` r
has_header(file)
```

## Arguments

- file:

  Character. Path to file.

## Value

Logical. TRUE if file has a header.
