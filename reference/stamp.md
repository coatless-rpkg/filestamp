# Stamp a file or directory with a header

This is the main entry point for the filestamp package. It automatically
detects if the path is a file or directory and calls the appropriate
function.

## Usage

``` r
stamp(path, template = NULL, action = "modify", ...)
```

## Arguments

- path:

  Character. Path to file or directory to stamp.

- template:

  Character or stamp_template object. Template to use for stamping.

- action:

  Character. Action to perform: "modify", "dryrun", or "backup".

- ...:

  Additional arguments passed to stamp_file or stamp_dir.

## Value

Result object, invisibly.
