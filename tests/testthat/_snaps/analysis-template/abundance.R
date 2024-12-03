# Abundance Analysis
# 2024-12-03

# Clear environment ------------------------------------------------------------
rm(list = ls())

# Install and load course package ----------------------------------------------
if (!requireNamespace(jagscourse)) {
  install.packages("remotes")
  remotes::install_github("poissonconsulting/jagscourse")
}

library(jagscourse24)

# Load data --------------------------------------------------------------------

# Clean/tidy data --------------------------------------------------------------

# Prepare data for JAGS --------------------------------------------------------
# TODO: numericize??/get nObs etc.?
data <- list(
  
)

# Code model -------------------------------------------------------------------
sink("mod.txt")
cat("model{
  # Priors

  # Likelihood
  for (i in 1:nObs)
}")
sink()

# Initial values ---------------------------------------------------------------
inits <- function() {
  list(
    
  )
}  

# Parameters to monitor --------------------------------------------------------
params_to_monitor <- c()

# MCMC tuning parameters -------------------------------------------------------
nc <- 3       # Number of MCMC chains
nt <- 1       # Thinning rate
nb <- 500     # Number of burn-iterations
ni <- 1000    # Total number of iterations

# Run JAGS model ---------------------------------------------------------------
mod1 <- jagsUI::jags(
  data = data, 
  inits = inits, 
  parameters.to.save = params_to_monitor, 
  model.file = "model.txt", 
  n.chains = nc, 
  n.thin = nt, 
  n.iter = ni, 
  n.burnin = nb
)

# Summarize posteriors and evaluate convergence --------------------------------
print(mod1, digits = 3)

# Make predictions -------------------------------------------------------------

# Model validation -------------------------------------------------------------
