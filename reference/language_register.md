# Register a new language

Register a new language

## Usage

``` r
language_register(
  name,
  extensions,
  comment_single,
  comment_multi_start = NULL,
  comment_multi_end = NULL
)
```

## Arguments

- name:

  Character. Language name.

- extensions:

  Character vector. File extensions.

- comment_single:

  Character. Single-line comment marker.

- comment_multi_start:

  Character or NULL. Multi-line comment start.

- comment_multi_end:

  Character or NULL. Multi-line comment end.

## Value

stamp_language object, invisibly.
