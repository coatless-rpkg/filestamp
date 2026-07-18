# Update an existing file header

Revise a header that is already in a file, changing only the fields you
name. Each update is either a replacement value or a function that
receives the current value of the field and returns the new one.
[`year_extend()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/year_extend.md)
and
[`author_add()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/author_add.md)
build the two most useful such functions, and
[`stamp_edits()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_edits.md)
bundles a set of them for reuse. For the common tasks there are also
dedicated verbs,
[`stamp_bump_year()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_bump_year.md)
and
[`stamp_add_author()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_add_author.md).

## Usage

``` r
stamp_update(file, ..., action = "modify", recursive = FALSE, pattern = NULL)
```

## Arguments

- file:

  Character. Path to a file or directory to update.

- ...:

  Named updates to apply to header fields (each value is a new value or
  a function of the field's current value), or a single
  [`stamp_edits()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_edits.md)
  bundle.

- action:

  Character. Action to perform: "modify", "dryrun", or "backup".

- recursive:

  Logical. When `file` is a directory, descend into subdirectories.

- pattern:

  Character or NULL. When `file` is a directory, only update files whose
  name matches this pattern.

## Value

TRUE invisibly on success (a `stamp_update_preview` for
`action = "dryrun"`), or a `stamp_dir_results` object when `file` is a
directory.

## Details

If `file` is a directory, every already-stamped file it contains is
updated and a `stamp_dir_results` object is returned.

## See also

[`stamp_bump_year()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_bump_year.md),
[`stamp_add_author()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_add_author.md),
[`stamp_edits()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_edits.md),
[`year_extend()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/year_extend.md),
[`author_add()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/author_add.md)

## Examples

``` r
file <- tempfile(fileext = ".R")
writeLines(c("# Copyright (c) 2020", "# Author: Jane", "", "x <- 1"), file)

stamp_update(file, copyright = year_extend(), author = author_add("Sam"))
readLines(file)[1:2]
#> [1] "# Copyright (c) 2020-2026" "# Author: Jane and Sam"   
```
