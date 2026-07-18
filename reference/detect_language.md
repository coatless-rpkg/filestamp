# Detect language based on file extension

Detect language based on file extension

## Usage

``` r
detect_language(file)
```

## Arguments

- file:

  Character. Path to file.

## Value

stamp_language object, or NULL if the extension is not registered (so
callers can skip files with no known comment syntax rather than stamping
them with the wrong markers).
