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

#' Stamp a file or directory with a header
#'
#' This is the main entry point for the filestamp package. It automatically
#' detects if the path is a file or directory and calls the appropriate function.
#'
#' @param path Character. Path to file or directory to stamp.
#' @param template Character or stamp_template object. Template to use for stamping.
#' @param action Character. Action to perform: "modify", "dryrun", or "backup".
#' @param ... Additional arguments passed to stamp_file or stamp_dir.
#'
#' @return Result object, invisibly.
#' @export
stamp <- function(path, template = NULL, action = "modify", ...) {
  if (file.info(path)$isdir) {
    stamp_dir(path, template, action, ...)
  } else {
    stamp_file(path, template, action, ...)
  }
}
