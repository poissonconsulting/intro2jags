set.seed(123)

# Parameters
n_trays <- 200
mean_seeds_per_tray <- 20
tray_sizes <- rpois(n_trays, lambda = mean_seeds_per_tray)
n_seeds <- sum(tray_sizes)

# Tray-level info
tray_id <- factor(rep(1:n_trays, times = tray_sizes))
herbicide_tray <- factor(sample(c("no", "yes"), size = n_trays, replace = TRUE))
herbicide <- factor(rep(herbicide_tray, times = tray_sizes))

# Seed-level covariates
seed_mass <- runif(n_seeds, 0.5, 3.0)
watering_freq <- factor(sample(c("Low", "Medium", "High"), n_seeds, replace = TRUE))
soil_type <- factor(sample(c("Sandy", "Loamy", "Clay", "Peaty", "Chalky", "Silty"), n_seeds, replace = TRUE))

# Map to factors
watering_index <- as.numeric(factor(watering_freq))
soil_index <- as.numeric(factor(soil_type))
herbicide_index <- ifelse(herbicide == "yes", 1, 0)

# Effects
beta_0 <- -2
beta_mass <- 0.4
beta_herbicide <- -1.2
soil_effects <- rnorm(6, 0, 0.2)  # length = number of soil types
tray_effects <- rnorm(n_trays, 0, 0.5)

# Linear predictor
lp <- beta_0 +
  beta_mass * seed_mass +
  beta_herbicide * herbicide_index +
  soil_effects[soil_index] +
  tray_effects[tray_id]

# Simulate outcome
prob <- plogis(lp)
germinated <- rbinom(n_seeds, size = 1, prob = prob)

# Assemble data frame
seed_data <- data.frame(
  tray_id = tray_id,
  herbicide = herbicide,
  seed_mass = seed_mass,
  watering_freq = watering_freq,
  soil_type = soil_type,
  germinated = germinated
)

seed_data$seed_depth <- runif(nrow(seed_data), 4, 8)
seed_data$planting_time <- sample(8:16, nrow(seed_data), replace = TRUE)  # e.g. 8am–4pm

# Save data
seeds <- tibble::as_tibble(seed_data)
usethis::use_data(seeds, overwrite = TRUE)

if (TRUE) {
  library(embr)
  library(jmbr)
  library(tidyverse)
  
  # test model
  model <- embr::model(
    code = "model{
      bIntercept ~ dnorm(0, 2^-2)
      bSeedMass ~ dnorm(0, 2^-2)
      
      sSoilType ~ dexp(1)
      for (i in 1:nsoil_type) {
        bSoilType[i] ~ dnorm(0, sSoilType^-2)
      }
      
      bWater[1] <- 0
      for (i in 2:nwatering_freq) {
        bWater[i] ~ dnorm(0, 2^-2)
      }
      
      bHerbicide[1] <- 0
      for (i in 2:nherbicide) {
        bHerbicide[i] ~ dnorm(0, 2^-2)
      }
      
      sTrayID ~ dexp(1)
      for (i in 1:ntray_id) {
        bTrayID[i] ~ dnorm(0, sTrayID^-2)
      }
      
      for (i in 1:nObs) {
        logit(eProb[i]) <- bIntercept + bSeedMass * seed_mass[i] + bSoilType[soil_type[i]] + bWater[watering_freq[i]] + bHerbicide[herbicide[i]] + bTrayID[tray_id[i]]
        germinated[i] ~ dbern(eProb[i])
      }
    }",
    new_expr = "
      for (i in 1:nObs) {
        logit(eProb[i]) <- bIntercept + bSeedMass * seed_mass[i] + bSoilType[soil_type[i]] + bWater[watering_freq[i]] + bHerbicide[herbicide[i]] + bTrayID[tray_id[i]]
        prediction[i] <- eProb[i]
      }
    ",
    new_expr_vec = TRUE,
    random_effects = list(
      bSoilType = "soil_type",
      bTrayID = "tray_id"
    )
  )
  
  embr::set_analysis_mode("report")
  analysis <- embr::analyse(model, seeds, nthin = 15L)
  
  coef(analysis, simplify = TRUE, include_constant = FALSE)
  
  seed_mass <- predict(analysis, "seed_mass")
  
  gp <- ggplot(seed_mass) +
    aes(x = seed_mass, y = estimate) +
    geom_line() +
    geom_line(aes(y = lower), linetype = "dotted") +
    geom_line(aes(y = upper), linetype = "dotted") +
    xlab("Seed Mass (g)") +
    ylab("Probability of Germination") + 
    NULL
  
  gp
  
  soil_type <- predict(analysis, "soil_type")
  
  gp <- ggplot(soil_type) +
    aes(x = soil_type, y = estimate) +
    geom_pointrange(aes(ymin = lower, ymax = upper)) +
    xlab("Soil Type") +
    ylab("Probability of Germination") + 
    NULL
  
  gp
  
  watering_freq <- predict(analysis, "watering_freq")

  gp <- ggplot(watering_freq) +
    aes(x = watering_freq, y = estimate) +
    geom_pointrange(aes(ymin = lower, ymax = upper)) +
    xlab("Watering Frequency") +
    ylab("Probability of Germination") + 
    NULL
  
  gp
  
  herbicide <- predict(analysis, "herbicide")
  
  gp <- ggplot(herbicide) +
    aes(x = herbicide, y = estimate) +
    geom_pointrange(aes(ymin = lower, ymax = upper)) +
    xlab("Herbicide") +
    ylab("Probability of Germination") + 
    NULL
  
  gp
  
  # aggregate data
  agg <- 
    seeds %>% 
    group_by(tray_id) %>% 
    mutate(
      # Calculate binomial values by tray
      seeds = n(), # size parameter
      germinated = sum(germinated), # number of sucesses (response)
      # Average continuous parameters across groups
      seed_mass = mean(seed_mass), 
      seed_depth = mean(seed_depth)
    ) %>% 
    # Remove individual tray cell factor covariates
    select(-soil_type, -planting_time, -watering_freq) %>% 
    # Reduce to one row per tray
    distinct() %>% 
    ungroup()
  
  model <- embr::model(
    code = "model{
      bIntercept ~ dnorm(0, 2^-2)
      bSeedMass ~ dnorm(0, 2^-2)
      
      bHerbicide[1] <- 0
      for (i in 2:nherbicide) {
        bHerbicide[i] ~ dnorm(0, 2^-2)
      }
      
      for (i in 1:nObs) {
        logit(eProb[i]) <- bIntercept + bSeedMass * seed_mass[i] + bHerbicide[herbicide[i]]
        germinated[i] ~ dbinom(eProb[i], seeds[i])
      }
    }",
    new_expr = "
     for (i in 1:nObs) {
        logit(eProb[i]) <- bIntercept + bSeedMass * seed_mass[i] + bHerbicide[herbicide[i]]
        prediction[i] <- eProb[i]
      }
    "
  )
  
  analysis2 <- analyse(model, data = agg, nthin = 10L)
  coef(analysis2, simplify = TRUE, include_constant = FALSE)
  
  seed_mass <- predict(analysis2, "seed_mass")
  
  gp <- ggplot(seed_mass) +
    aes(x = seed_mass, y = estimate) +
    geom_line() +
    geom_line(aes(y = lower), linetype = "dotted") +
    geom_line(aes(y = upper), linetype = "dotted") +
    xlab("Seed Mass (g)") +
    ylab("Probability of Germination") + 
    NULL
  
  gp
  
  herbicide <- predict(analysis2, "herbicide")
  
  gp <- ggplot(herbicide) +
    aes(x = herbicide, y = estimate) +
    geom_pointrange(aes(ymin = lower, ymax = upper)) +
    xlab("Herbicide") +
    ylab("Probability of Germination") + 
    NULL
  
  gp
}
