msg <- function(...) {
  if (!isTRUE(getOption("intro2jags.quiet"))) {
    packageStartupMessage(...)
  }
}

is_attached <- function(pkg) {
  paste0("package:", pkg) %in% search()
}

pkg_list_to_attach <- function() {
  pkg_list
}
