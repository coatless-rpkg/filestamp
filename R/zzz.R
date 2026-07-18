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

#' Register default languages on package load
#'
#' @keywords internal
.onLoad <- function(libname, pkgname) {
  # Register default languages
  # TODO: Consider trying to pre-load languages into an environment?
  language_register(
    "text",
    extensions = c("txt"),
    comment_single = "#"
  )

  language_register(
    "r",
    extensions = c("r", "R"),
    comment_single = "#"
  )

  language_register(
    "python",
    extensions = c("py", "pyw"),
    comment_single = "#",
    comment_multi_start = '"""',
    comment_multi_end = '"""'
  )

  language_register(
    "c",
    extensions = c("c", "h"),
    comment_single = "//",
    comment_multi_start = "/*",
    comment_multi_end = "*/"
  )

  language_register(
    "cpp",
    extensions = c("cpp", "hpp", "cc", "hh", "cxx", "hxx"),
    comment_single = "//",
    comment_multi_start = "/*",
    comment_multi_end = "*/"
  )

  language_register(
    "java",
    extensions = c("java"),
    comment_single = "//",
    comment_multi_start = "/*",
    comment_multi_end = "*/"
  )

  language_register(
    "javascript",
    extensions = c("js", "jsx"),
    comment_single = "//",
    comment_multi_start = "/*",
    comment_multi_end = "*/"
  )

  language_register(
    "typescript",
    extensions = c("ts", "tsx"),
    comment_single = "//",
    comment_multi_start = "/*",
    comment_multi_end = "*/"
  )

  language_register(
    "ruby",
    extensions = c("rb"),
    comment_single = "#",
    comment_multi_start = "=begin",
    comment_multi_end = "=end"
  )

  language_register(
    "rust",
    extensions = c("rs"),
    comment_single = "//",
    comment_multi_start = "/*",
    comment_multi_end = "*/"
  )

  language_register(
    "perl",
    extensions = c("pl", "pm"),
    comment_single = "#"
  )

  language_register(
    "php",
    extensions = c("php"),
    comment_single = "//",
    comment_multi_start = "/*",
    comment_multi_end = "*/"
  )

  language_register(
    "shell",
    extensions = c("sh", "bash"),
    comment_single = "#"
  )

  language_register(
    "sql",
    extensions = c("sql"),
    comment_single = "--",
    comment_multi_start = "/*",
    comment_multi_end = "*/"
  )

  language_register(
    "yaml",
    extensions = c("yml", "yaml"),
    comment_single = "#"
  )

  language_register(
    "markdown",
    extensions = c("md", "markdown"),
    comment_single = "<!--",
    comment_multi_start = "<!--",
    comment_multi_end = "-->"
  )

  language_register(
    "html",
    extensions = c("html", "htm"),
    comment_single = "<!--",
    comment_multi_start = "<!--",
    comment_multi_end = "-->"
  )

  language_register(
    "css",
    extensions = c("css"),
    comment_single = "/*",
    comment_multi_start = "/*",
    comment_multi_end = "*/"
  )

  # C-family languages (// line, /* */ block)
  language_register(
    "go",
    extensions = c("go"),
    comment_single = "//",
    comment_multi_start = "/*",
    comment_multi_end = "*/"
  )

  language_register(
    "kotlin",
    extensions = c("kt", "kts"),
    comment_single = "//",
    comment_multi_start = "/*",
    comment_multi_end = "*/"
  )

  language_register(
    "swift",
    extensions = c("swift"),
    comment_single = "//",
    comment_multi_start = "/*",
    comment_multi_end = "*/"
  )

  language_register(
    "csharp",
    extensions = c("cs", "csx"),
    comment_single = "//",
    comment_multi_start = "/*",
    comment_multi_end = "*/"
  )

  language_register(
    "scala",
    extensions = c("scala", "sc"),
    comment_single = "//",
    comment_multi_start = "/*",
    comment_multi_end = "*/"
  )

  language_register(
    "dart",
    extensions = c("dart"),
    comment_single = "//",
    comment_multi_start = "/*",
    comment_multi_end = "*/"
  )

  # Objective-C uses only .mm; .m is deliberately omitted because it is
  # ambiguous with MATLAB (%) and Mathematica ((* *)) sources.
  language_register(
    "objective-c",
    extensions = c("mm"),
    comment_single = "//",
    comment_multi_start = "/*",
    comment_multi_end = "*/"
  )

  language_register(
    "julia",
    extensions = c("jl"),
    comment_single = "#",
    comment_multi_start = "#=",
    comment_multi_end = "=#"
  )

  language_register(
    "elixir",
    extensions = c("ex", "exs"),
    comment_single = "#"
  )

  language_register(
    "haskell",
    extensions = c("hs"),
    comment_single = "--",
    comment_multi_start = "{-",
    comment_multi_end = "-}"
  )

  language_register(
    "lua",
    extensions = c("lua"),
    comment_single = "--",
    comment_multi_start = "--[[",
    comment_multi_end = "]]"
  )

  language_register(
    "powershell",
    extensions = c("ps1", "psm1", "psd1"),
    comment_single = "#",
    comment_multi_start = "<#",
    comment_multi_end = "#>"
  )

  # LaTeX/TeX; .cls is deliberately omitted (collides with Salesforce Apex
  # and VBA class files, which use different comment syntax).
  language_register(
    "latex",
    extensions = c("tex", "sty", "rnw"),
    comment_single = "%"
  )

  # Fortran free-form only; fixed-form (.f/.for) uses column-1 markers.
  language_register(
    "fortran",
    extensions = c("f90", "f95", "f03", "f08"),
    comment_single = "!"
  )

  language_register(
    "toml",
    extensions = c("toml"),
    comment_single = "#"
  )

  language_register(
    "scss",
    extensions = c("scss"),
    comment_single = "//",
    comment_multi_start = "/*",
    comment_multi_end = "*/"
  )

  language_register(
    "less",
    extensions = c("less"),
    comment_single = "//",
    comment_multi_start = "/*",
    comment_multi_end = "*/"
  )

  # Indented Sass uses // (silent) comments; /* */ would leak into compiled CSS.
  language_register(
    "sass",
    extensions = c("sass"),
    comment_single = "//"
  )

  # R Markdown and Quarto are markdown-family; headers use <!-- --> blocks
  # (comment_single is a placeholder, as with markdown/html).
  language_register(
    "rmarkdown",
    extensions = c("rmd"),
    comment_single = "<!--",
    comment_multi_start = "<!--",
    comment_multi_end = "-->"
  )

  language_register(
    "quarto",
    extensions = c("qmd"),
    comment_single = "<!--",
    comment_multi_start = "<!--",
    comment_multi_end = "-->"
  )
}
