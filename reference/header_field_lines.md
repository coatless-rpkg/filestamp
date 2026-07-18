# Identify header field lines in file content

Comment-marked field lines always count. Bare (marker-less) field lines
– the body of Python docstrings, C block comments, and the like – only
count when a block-comment opener appears on the same or an earlier
line, so data files (YAML configs and friends) are not mistaken for
headers.

## Usage

``` r
header_field_lines(lines)
```

## Arguments

- lines:

  Character vector. File content lines.

## Value

Logical vector. TRUE for lines that are part of a header.
