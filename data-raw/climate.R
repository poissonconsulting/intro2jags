## code to prepare `climate` dataset goes here

set.seed(78)

# Sample size
n <- 100

# Simulate predictor variables
elevation <- runif(n, min = 0, max = 3000)     # Elevation (meters)
distance_coast <- runif(n, min = 0, max = 500) # Distance from coast (km)

# True parameter values
beta0 <- 1.2       # Intercept
beta1 <- -0.003    # Elevation effect (higher elevations = cooler temperatures)
beta2 <- 0.008     # Distance from coast effect (continental effect = warmer)
sigma <- 1.8       # Residual SD

# Simulate temperature anomalies (can be positive or negative)
# Positive = warmer than baseline, Negative = cooler than baseline
temp_anomaly <- beta0 + beta1 * elevation + beta2 * distance_coast + rnorm(n, 0, sigma)

# Create dataset
climate_data <- data.frame(
  Temp_Anomaly = temp_anomaly,        # Temperature anomaly in °C
  Elevation = elevation,
  Distance_Coast = distance_coast
)

climate <- as.tibble(climate_data) %>% 
  rename(
    temp_anomaly = Temp_Anomaly,
    elev = Elevation,
    dist_coast = Distance_Coast
  )
  
usethis::use_data(climate, overwrite = TRUE)

if (FALSE) {
# Quick visualization
plot(climate_data$Elevation, climate_data$Temp_Anomaly, 
     xlab = "Elevation (m)", 
     ylab = "Temperature Anomaly (°C)",
     main = "Temperature Anomaly vs Elevation")
abline(h = 0, lty = 2)  # Reference line at zero

# JAGS model setup
library(jagsUI)

# Prepare data for JAGS
jags_data <- list(
  Temp_Anomaly = climate_data$Temp_Anomaly,
  Elevation = climate_data$Elevation,
  Distance_Coast = climate_data$Distance_Coast,
  N = nrow(climate_data)
)

# Write JAGS model
sink("temp_model.txt")
cat("model {
  # Priors
  beta0 ~ dnorm(0, 0.1)           # Prior for intercept
  beta1 ~ dnorm(0, 0.01)          # Prior for elevation effect
  beta2 ~ dnorm(0, 0.01)          # Prior for distance from coast effect
  sigma ~ dunif(0, 5)             # Prior for residual SD
  tau <- 1 / (sigma * sigma)      # Precision
  
  # Likelihood
  for (i in 1:N) {
    mu[i] <- beta0 + beta1 * Elevation[i] + beta2 * Distance_Coast[i]
    Temp_Anomaly[i] ~ dnorm(mu[i], tau)
  }
}")
sink()

# MCMC settings
params <- c("beta0", "beta1", "beta2", "sigma")
ni <- 2000    # Number of iterations
nb <- 500     # Number of burn-in
nc <- 3       # Number of chains

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