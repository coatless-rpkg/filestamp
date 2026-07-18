# Build a copyright-year updater

Returns a function that extends a copyright field to the current year,
keeping the owner name and any existing start year. Pass it as a named
update to
[`stamp_update()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_update.md),
or use
[`stamp_bump_year()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_bump_year.md)
to apply it directly to a file.

## Usage

``` r
year_extend(initial_year = NULL)
```

## Arguments

- initial_year:

  Character or NULL. Start year to use when the field has no year yet.

## Value

A function of the current field value, suitable as an update in
[`stamp_update()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_update.md).

## See also

[`stamp_update()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_update.md),
[`stamp_bump_year()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_bump_year.md),
[`author_add()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/author_add.md)

## Examples

``` r
extend <- year_extend()
extend("Acme Corp 2020")
#> [1] "Acme Corp 2020-2026"
```
