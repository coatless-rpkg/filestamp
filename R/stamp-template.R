# Copyright (c) 2025
# Author: James J Balamuta
# License: GNU Affero General Public License v3.0 or later
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

#' Create a new template
#'
#' @param name Character. Name of template.
#' @param fields stamp_template_fields object. Template fields.
#' @param content stamp_template_content object. Template content.
#'
#' @return stamp_template object.
#' @export
stamp_template_create <- function(name, fields = NULL, content = NULL) {
  structure(
    list(
      name = name,
      fields = fields,
      content = content
    ),
    class = "stamp_template"
  )
}

#' Define template fields
#'
#' @param ... Named list of stamp_template_field objects.
#'
#' @return stamp_template_fields object.
#' @export
stamp_template_describe <- function(...) {
  fields <- list(...)
  structure(fields, class = "stamp_template_fields")
}

#' Define individual field
#'
#' @param name Character. Field name.
#' @param default Any. Default value of field.
#' @param required Logical. Whether field is required.
#'
#' @return stamp_template_field object.
#' @export
stamp_template_field <- function(name, default = NULL, required = FALSE) {
  structure(
    list(
      name = name,
      default = default,
      required = required
    ),
    class = "stamp_template_field"
  )
}

#' Create template content with multiline support
#'
#' @param ... Character strings to be concatenated.
#'
#' @return stamp_template_content object.
#' @export
stamp_template_content <- function(...) {
  content <- paste0(...)
  structure(content, class = "stamp_template_content")
}

#' Get default template
#'
#' @return stamp_template object.
#' @export
stamp_template_default <- function() {
  template_path <- system.file("templates", "default.yml", package = "filestamp")
  if (template_path == "") {
    # Fall back to built-in default
    return(stamp_template_create(
      name = "default",
      fields = stamp_template_describe(
        copyright = stamp_template_field("copyright", "{{company}} {{year}}", required = TRUE),
        author = stamp_template_field("author", "{{user}}", required = TRUE),
        license = stamp_template_field("license", "All rights reserved.", required = TRUE),
        last_updated = stamp_template_field("last_updated", "{{date_full}}", required = FALSE)
      ),
      content = stamp_template_content(
        "Copyright (c) {{copyright}}\n",
        "Author: {{author}}\n",
        "License: {{license}}\n",
        "Last updated: {{last_updated}}"
      )
    ))
  }

  stamp_template_load("default")
}

#' Load template from YAML
#'
#' @param name Character. Name of template.
#'
#' @return stamp_template object.
#' @export
stamp_template_load <- function(name) {
  # Find template file in inst/templates
  template_path <- system.file("templates", paste0(name, ".yml"), package = "filestamp")

  if (template_path == "") {
    cli::cli_abort("Template not found: {name}")
  }

  # Parse YAML
  template_yaml <- yaml::read_yaml(template_path)

  # Templates use one of two YAML field shapes: a named mapping
  # (default.yml) or a list of records with a `name:` key (agpl-3.yml).
  # Resolve a name for each field so downstream rendering, which keys off
  # names(template$fields), works for both shapes.
  raw_fields <- template_yaml$fields
  field_names <- names(raw_fields)
  if (is.null(field_names)) {
    field_names <- rep("", length(raw_fields))
  }
  for (i in seq_along(raw_fields)) {
    if (!nzchar(field_names[i])) {
      field_names[i] <- raw_fields[[i]]$name %||% ""
    }
  }

  fields <- lapply(seq_along(raw_fields), function(i) {
    field <- raw_fields[[i]]
    stamp_template_field(
      name = field$name %||% field_names[i],
      default = field$default,
      required = field$required %||% FALSE
    )
  })
  names(fields) <- field_names

  stamp_template_create(
    name = template_yaml$name,
    fields = structure(fields, class = "stamp_template_fields"),
    content = structure(template_yaml$content, class = "stamp_template_content")
  )
}

#' List available templates
#'
#' @return Character vector of template names.
#' @export
stamp_templates <- function() {
  # Find template files in inst/templates
  template_dir <- system.file("templates", package = "filestamp")

  if (template_dir == "") {
    return(character(0))
  }

  # List YAML files
  templates <- list.files(
    path = template_dir,
    pattern = "\\.yml$",
    full.names = FALSE
  )

  # Remove extension
  templates <- sub("\\.yml$", "", templates)

  templates
}

#' Render template with variables
#'
#' @param template stamp_template object. Template to render.
#' @param file Character. Path to file.
#' @param ... Additional variables.
#'
#' @return Character. Rendered template.
#' @keywords internal
render_template <- function(template, file, ...) {
  # Work on a private copy of the shared variable environment. Because
  # environments have reference semantics, writing template fields or
  # per-call values into the cached environment would leak them into every
  # later render in the session, so copy the bindings into a fresh env.
  base <- stamp_variables()
  vars <- new.env(parent = emptyenv())
  for (nm in ls(base)) vars[[nm]] <- base[[nm]]

  # Add file to environment
  vars$file <- file

  dots <- list(...)

  # Add template fields to environment, enforcing required fields
  if (!is.null(template$fields)) {
    for (field_name in names(template$fields)) {
      field <- template$fields[[field_name]]
      supplied <- field_name %in% names(dots)
      value <- if (supplied) dots[[field_name]] else field$default

      if (isTRUE(field$required) && !supplied &&
          (is.null(field$default) || !nzchar(paste0(field$default)))) {
        cli::cli_abort(c(
          "Required template field {.field {field_name}} was not supplied.",
          "i" = "Provide it, e.g. {.code stamp_file(file, {field_name} = \"...\")}."
        ))
      }

      # Skip empty/NULL values so rendering never crashes on an empty
      # replacement (leaves the placeholder untouched instead)
      if (!is.null(value)) {
        vars[[field_name]] <- value
      }
    }
  }

  # Add custom variables
  for (name in names(dots)) {
    vars[[name]] <- dots[[name]]
  }

  # Render content
  content <- template$content

  # Process template with recursive variable resolution
  # to handle nested variables
  max_iterations <- 10  # Prevent infinite loops
  iteration <- 0

  # TODO: Handle nested variables more gracefully via whiskers?
  repeat {
    iteration <- iteration + 1
    original_content <- content

    # Replace variables in content
    for (var_name in ls(vars)) {
      var_value <- if (is.function(vars[[var_name]])) {
        tryCatch({
          vars[[var_name]]()
        }, error = function(e) {
          paste0("{{", var_name, "}}")
        })
      } else {
        vars[[var_name]]
      }

      # Convert var_value to character; skip empty/non-scalar values so an
      # empty replacement can never crash gsub (leaves placeholder in place)
      var_value <- as.character(var_value)
      if (length(var_value) != 1) next

      pattern <- paste0("\\{\\{", var_name, "\\}\\}")
      content <- gsub(pattern, var_value, content, fixed = FALSE)
    }

    # Check if we've completed all replacements
    if (content == original_content || iteration >= max_iterations) {
      break
    }
  }

  content
}
