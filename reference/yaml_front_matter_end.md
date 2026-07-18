# Find the end of a YAML front matter block

Find the end of a YAML front matter block

## Usage

``` r
yaml_front_matter_end(content)
```

## Arguments

- content:

  Character vector. File content lines.

## Value

Integer. Line number of the closing fence, or 0 if the file does not
start with YAML front matter.
