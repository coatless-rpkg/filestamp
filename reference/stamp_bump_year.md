# Bump the copyright year in a file header

A convenience wrapper around
[`stamp_update()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_update.md)
that extends the header's copyright field to the current year, keeping
the owner and start year (see
[`year_extend()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/year_extend.md)).

## Usage

``` r
stamp_bump_year(file, action = "modify", recursive = FALSE, pattern = NULL)
```

## Arguments

- file:

  Character. Path to a file or directory to update.

- action:

  Character. Action to perform: "modify", "dryrun", or "backup".

- recursive:

  Logical. When `file` is a directory, descend into subdirectories.

- pattern:

  Character or NULL. When `file` is a directory, only update files whose
  name matches this pattern.

## Value

TRUE invisibly on success, or a `stamp_update_preview` object when
`action = "dryrun"`.

## See also

[`stamp_update()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_update.md),
[`stamp_add_author()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_add_author.md)

## Examples

``` r
file <- tempfile(fileext = ".R")
writeLines(c("# Copyright (c) 2020", "# Author: Jane", "", "x <- 1"), file)

stamp_bump_year(file)
readLines(file)[1]
#> [1] "# Copyright (c) 2020-2026"
```
