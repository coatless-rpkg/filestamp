# Package index

## Stamp files and directories

Add a header to a single file or to every file in a directory.

- [`stamp()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp.md)
  : Stamp a file or directory with a header
- [`stamp_file()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_file.md)
  : Stamp a single file with a header
- [`stamp_dir()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_dir.md)
  : Stamp all files in a directory with a header

## Update existing headers

Revise a header that is already in a file, changing only the fields you
name.

- [`stamp_update()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_update.md)
  : Update an existing file header
- [`stamp_bump_year()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_bump_year.md)
  : Bump the copyright year in a file header
- [`stamp_add_author()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_add_author.md)
  : Add an author to a file header
- [`stamp_edits()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_edits.md)
  : Bundle header edits for reuse
- [`year_extend()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/year_extend.md)
  : Build a copyright-year updater
- [`author_add()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/author_add.md)
  : Build an author-add updater

## Templates

Choose a built-in license template or build your own.

- [`stamp_templates()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_templates.md)
  : List available templates
- [`stamp_template_default()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_template_default.md)
  : Get default template
- [`stamp_template_load()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_template_load.md)
  : Load template from YAML
- [`stamp_template_create()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_template_create.md)
  : Create a new template
- [`stamp_template_describe()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_template_describe.md)
  : Define template fields
- [`stamp_template_field()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_template_field.md)
  : Define individual field
- [`stamp_template_content()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_template_content.md)
  : Create template content with multiline support

## Variables

The values that fill a template’s `{{...}}` placeholders.

- [`stamp_variables()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_variables.md)
  : Get built-in variables
- [`stamp_variables_add()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_variables_add.md)
  : Add custom variable
- [`stamp_variables_list()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/stamp_variables_list.md)
  : List all available variables

## Languages

Detect a file’s comment style and register new languages.

- [`languages()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/languages.md)
  : List all registered languages
- [`detect_language()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/detect_language.md)
  : Detect language based on file extension
- [`language_register()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/language_register.md)
  : Register a new language
- [`language_get()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/language_get.md)
  : Get registered language

## Inspecting files

- [`has_header()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/has_header.md)
  : Check if file has a header
- [`is_file()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/is_file.md)
  : Check if path is a file
- [`backup_file()`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/backup_file.md)
  : Create backup of file

## Print methods

- [`print(`*`<stamp_dir_results>`*`)`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/print.stamp_dir_results.md)
  : Print method for directory results
- [`print(`*`<stamp_edits>`*`)`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/print.stamp_edits.md)
  : Print method for header edits
- [`print(`*`<stamp_file_info>`*`)`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/print.stamp_file_info.md)
  : Print method for file info
- [`print(`*`<stamp_language>`*`)`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/print.stamp_language.md)
  : Print method for language
- [`print(`*`<stamp_preview>`*`)`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/print.stamp_preview.md)
  : Print method for stamp preview
- [`print(`*`<stamp_template>`*`)`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/print.stamp_template.md)
  : Print method for templates
- [`print(`*`<stamp_update_preview>`*`)`](https://r-pkg.thecoatlessprofessor.com/filestamp/reference/print.stamp_update_preview.md)
  : Print method for update preview
