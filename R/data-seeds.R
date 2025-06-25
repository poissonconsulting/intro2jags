#' Seed Germination measurements.
#'
#' Includes seed germination as a binary response variable, with other 
#' measurements.
#'
#'
#' This is a simulated dataset.
#'
#' @format A tibble with 4,022 rows and 9 variables:
#' \describe{
#'   \item{tray_id}{a factor denoting the ID number of the tray}
#'   \item{herbicide}{a factor denoting the whether ("yes") or not ("no") the 
#'   tray underwent herbicide treatment}
#'   \item{seed_mass}{a number denoting the mass of the seed, in grams}
#'   \item{watering_freq}{a factor denoting the watering frequency for a seed}
#'   \item{soil_type}{a factor denoting the soil type (Chalky, Loamy, Sandy,
#'   Silty, Clay, Peaty)}
#'   \item{germinated}{an integer denoting whether (1) or not (0) the seed 
#'   successfully germinated}
#'   \item{seed_depth}{distance between top of soil and where seed was placed,
#'   in cm}
#'   \item{planting_time}{the hour of the day that the seed was planted}
#' }
"seeds"
