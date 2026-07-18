# Stamp a single file with a header

Stamp a single file with a header

## Usage

``` r
stamp_file(file, template = NULL, action = "modify", ...)
```

## Arguments

- file:

  Character. Path to file to stamp.

- template:

  Character or stamp_template object. Template to use for stamping.

- action:

  Character. Action to perform: "modify", "dryrun", or "backup".

- ...:

  Additional arguments passed to render_template.

## Value

Result object, invisibly.
