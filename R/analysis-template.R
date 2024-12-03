#' Use Analysis Template
#' 
#' Creates a templated R file in the root directory. The name of the file takes 
#' the value of the `analysis` argument.
#'
#' @inheritParams params
#' @export
#'
#' @examples
#' \dontrun{
#' # This will create a file called "abundance.R" in the root directory.
#' analysis_template('abundance')
#' }
analysis_template <- function(analysis, open = rlang::is_interactive()) {
  stopifnot(rlang::is_string(analysis))
  usethis::use_template(
    template = glue::glue("analysis.R"),
    save_as = glue::glue("{analysis}.R"),
    data = list(
      analysis = stringr::str_to_title(
        paste0(glue::glue("{analysis}"), " Analysis")
      ),
      date = as.Date(Sys.time())
    ),
    open = open,
    package = "intro2jags"
  )
}
