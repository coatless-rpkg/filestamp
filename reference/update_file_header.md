# Update file header

Update file header

## Usage

``` r
update_file_header(file, header, requested = names(header$fields))
```

## Arguments

- file:

  Character. Path to file.

- header:

  List. Header information from extract_header.

- requested:

  Character. Field names the caller asked to update; a warning is
  emitted for any of these not found in the header.

## Value

TRUE invisibly on success.
