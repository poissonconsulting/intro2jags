pkg_attach <- function(pkg) {
  loc <- if (pkg %in% loadedNamespaces()) dirname(getNamespaceInfo(pkg, "path"))
  do.call(
    "library",
    list(pkg, lib.loc = loc, character.only = TRUE, warn.conflicts = FALSE)
  )
}

pkgs_attach <- function(pkgs, name) {
  msg(name, ": ", paste(pkgs, collapse = " "))

  suppressPackageStartupMessages(
    lapply(pkgs, pkg_attach)
  )
  invisible()
}

pkg_list_attach <- function(pkg_list) {
  msg("Attaching intro2jags packages")

  mapply(pkgs_attach, pkg_list, names(pkg_list))
}
