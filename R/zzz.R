.onAttach <- function(libname, pkgname) {
  pkg_list <- pkg_list_to_attach()
  if (!length(pkg_list)) {
    return()
  }
  pkg_list_attach(pkg_list)
}
