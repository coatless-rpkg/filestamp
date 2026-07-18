# Bundle header edits for reuse

Collects a set of named header updates into a reusable object you can
inspect and apply to one or many files with
[`stamp_update()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_update.md).
Each edit is a new value or a function of the field's current value,
exactly as in
[`stamp_update()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_update.md).

## Usage

``` r
stamp_edits(...)
```

## Arguments

- ...:

  Named header edits. Each value is a new value or a function of the
  field's current value (see
  [`year_extend()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/year_extend.md)
  and
  [`author_add()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/author_add.md)).

## Value

A `stamp_edits` object.

## See also

[`stamp_update()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_update.md),
[`year_extend()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/year_extend.md),
[`author_add()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/author_add.md)

## Examples

``` r
edits <- stamp_edits(copyright = year_extend(), author = author_add("Sam"))
edits
#> 
#> ── Header edits ──
#> 
#> • copyright: extend the copyright year
#> • author: add "Sam"

file <- tempfile(fileext = ".R")
writeLines(c("# Copyright (c) 2020", "# Author: Jane", "", "x <- 1"), file)
stamp_update(file, edits)
```
