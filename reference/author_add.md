# Build an author-add updater

Returns a function that appends an author to an author field without
duplicating anyone already listed. Pass it as a named update to
[`stamp_update()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_update.md),
or use
[`stamp_add_author()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_add_author.md)
to apply it directly to a file.

## Usage

``` r
author_add(new_author)
```

## Arguments

- new_author:

  Character. Author to add.

## Value

A function of the current field value, suitable as an update in
[`stamp_update()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_update.md).

## See also

[`stamp_update()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_update.md),
[`stamp_add_author()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_add_author.md),
[`year_extend()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/year_extend.md)

## Examples

``` r
add <- author_add("Sam Smith")
add("Jane Doe")
#> [1] "Jane Doe and Sam Smith"
```
