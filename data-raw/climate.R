## code to prepare `climate` dataset goes here
set.seed(78)
# Sample size
n <- 100
# Simulate predictor variables
elevation <- runif(n, min = 0, max = 3000) # Elevation (meters)
latitude <- runif(n, min = 25, max = 65) # Latitude (degrees North)
# True parameter values
beta0 <- 6      # Higher intercept
beta1 <- -0.002 # Elevation effect
beta2 <- -0.06  # Latitude effect
sigma <- 2.8    # More noise for wider spread

# Simulate temperature anomalies (can be positive or negative)
# Positive = warmer than baseline, Negative = cooler than baseline
temp_anomaly <- beta0 + beta1 * elevation + beta2 * latitude + rnorm(n, 0, sigma)
# Create dataset
climate_data <- data.frame(
  Temp_Anomaly = temp_anomaly, # Temperature anomaly in °C
  Elevation = elevation,
  Latitude = latitude
)
climate <- as_tibble(climate_data) %>%
  rename(
    temp_anomaly = Temp_Anomaly,
    elev = Elevation,
    lat = Latitude
  )
usethis::use_data(climate, overwrite = TRUE)
if (FALSE) {
  # Quick visualization
  plot(climate_data$Elevation, climate_data$Temp_Anomaly,
       xlab = "Elevation (m)",
       ylab = "Temperature Anomaly (°C)",
       main = "Temperature Anomaly vs Elevation"
  )
  abline(h = 0, lty = 2) # Reference line at zero
  
  # Additional plot for latitude
  plot(climate_data$Latitude, climate_data$Temp_Anomaly,
       xlab = "Latitude (°N)",
       ylab = "Temperature Anomaly (°C)",
       main = "Temperature Anomaly vs Latitude"
  )
  abline(h = 0, lty = 2) # Reference line at zero
  
  # JAGS model setup
  library(jagsUI)
  # Prepare data for JAGS
  jags_data <- list(
    Temp_Anomaly = climate_data$Temp_Anomaly,
    Elevation = climate_data$Elevation,
    Latitude = climate_data$Latitude,
    N = nrow(climate_data)
  )
  # Write JAGS model
  sink("temp_model.txt")
  cat("model {
  # Priors
  beta0 ~ dnorm(0, 0.1)           # Prior for intercept
  beta1 ~ dnorm(0, 0.01)          # Prior for elevation effect
  beta2 ~ dnorm(0, 0.01)          # Prior for latitude effect
  sigma ~ dunif(0, 5)             # Prior for residual SD
  tau <- 1 / (sigma * sigma)      # Precision
  # Likelihood
  for (i in 1:N) {
    mu[i] <- beta0 + beta1 * Elevation[i] + beta2 * Latitude[i]
    Temp_Anomaly[i] ~ dnorm(mu[i], tau)
  }
}")
  sink()
  # MCMC settings
  params <- c("beta0", "beta1", "beta2", "sigma")
  ni <- 2000 # Number of iterations
  nb <- 500 # Number of burn-in
  nc <- 3 # Number of chains
  # Run JAGS model
  temp_mod <- jags(
    data = jags_data,
    parameters.to.save = params,
    model.file = "temp_model.txt",
    n.chains = nc,
    n.iter = ni,
    n.burnin = nb
  )
  # Print results
  print(temp_mod)
}