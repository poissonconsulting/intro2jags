## code to prepare `lm_data` dataset goes here

bIntercept <- 10
bSlope <- 1.3
sigma <- 3

n <- 100

set.seed(101)

x <- rnorm(n, 0, 10)
mu <- bIntercept + bSlope * x

y <- rnorm(n, mu, sigma)

lm_data <- tibble(
  x = x,
  y = y
)

usethis::use_data(lm_data, overwrite = TRUE)

plot(y~x,data = lm_data)
