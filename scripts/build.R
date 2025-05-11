roxygen2md::roxygen2md()

styler::style_pkg(
  scope = "line_breaks",
  filetype = c("R", "Rmd"),
  exclude_files = c("_snaps/analysis-template/abundance.R$")
)

lintr::lint_package(linters = lintr::linters_with_defaults(
  line_length_linter = lintr::line_length_linter(1000),
  object_name_linter = lintr::object_name_linter(regexes = ".*")),
  # exclusions = c()
)

devtools::test()
devtools::document()

# Note: Only use pkgdown to build a documentation website for public facing packages
pkgdown::build_site()

devtools::check()
