# Add an author to a file header

A convenience wrapper around
[`stamp_update()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_update.md)
that appends an author to the header's author field without duplicating
anyone already listed (see
[`author_add()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/author_add.md)).

## Usage

``` r
stamp_add_author(
  file,
  author,
  action = "modify",
  recursive = FALSE,
  pattern = NULL
)
```

## Arguments

- file:

  Character. Path to a file or directory to update.

- author:

  Character. Author to add.

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
[`stamp_bump_year()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_bump_year.md)

## Examples

``` r
file <- tempfile(fileext = ".R")
writeLines(c("# Copyright (c) 2020", "# Author: Jane Doe", "", "x <- 1"), file)

stamp_add_author(file, "Sam Smith")
readLines(file)[2]
#> [1] "# Author: Jane Doe and Sam Smith"
```
