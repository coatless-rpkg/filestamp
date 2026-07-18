# Stamp all files in a directory with a header

Stamp all files in a directory with a header

## Usage

``` r
stamp_dir(
  dir,
  template = NULL,
  action = "modify",
  pattern = NULL,
  recursive = FALSE,
  ...
)
```

## Arguments

- dir:

  Character. Path to directory to stamp.

- template:

  Character or stamp_template object. Template to use for stamping.

- action:

  Character. Action to perform: "modify", "dryrun", or "backup".

- pattern:

  Character. File pattern to match (passed to list.files).

- recursive:

  Logical. Whether to search recursively.

- ...:

  Additional arguments passed to stamp_file.

## Value

stamp_dir_results object.
