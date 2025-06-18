## code to prepare `starfish` dataset goes here
library(embr)
library(jmbr)

bIntercept <- 1
bTemp <- -0.04
bSite <- c(0, -0.3, 0.5)
sYear <- 0.6
sYearSite <- 0.2
sDispersion <- 1
nyear <- 10
nsite <- 3
npersiteyear <- 5
nObs <- nsite * nyear * npersiteyear # 10 obs at each site in each year

set.seed(123)

bYear <- rnorm(nyear, 0, sYear)
bYearSite <- matrix(rnorm(nsite * nyear, 0, sYearSite), nrow = nyear, ncol = nsite)
temp <- rnorm(nObs, mean = 12, sd = 2) # Temperature varies per obs
site <- rep(1:nsite, each = nyear * npersiteyear) # Site ID
site_names <- c("Site A", "Site B", "Site C")

year <- rep(1:nyear, times = nsite * npersiteyear) # Year ID

initial_values <- tibble(
  term = c(
    "bYear[1]", "bYear[2]", "bYear[3]", "bYear[4]",
    "bYear[5]", "bYear[6]", "bYear[7]", "bYear[8]", "bYear[9]",
    "bYear[10]", "bIntercept", "bSite[1]", "bSite[2]", "bSite[3]",
    "bYearSite[1,1]", "bYearSite[2,1]", "bYearSite[3,1]",
    "bYearSite[4,1]", "bYearSite[5,1]", "bYearSite[6,1]",
    "bYearSite[7,1]", "bYearSite[8,1]", "bYearSite[9,1]",
    "bYearSite[10,1]", "bYearSite[1,2]", "bYearSite[2,2]",
    "bYearSite[3,2]", "bYearSite[4,2]", "bYearSite[5,2]",
    "bYearSite[6,2]", "bYearSite[7,2]", "bYearSite[8,2]",
    "bYearSite[9,2]", "bYearSite[10,2]", "bYearSite[1,3]",
    "bYearSite[2,3]", "bYearSite[3,3]", "bYearSite[4,3]",
    "bYearSite[5,3]", "bYearSite[6,3]", "bYearSite[7,3]",
    "bYearSite[8,3]", "bYearSite[9,3]", "bYearSite[10,3]",
    "bTemp", "sYear", "sYearSite", "sDispersion"
  ),
  value = c(bYear, bIntercept, bSite, bYearSite, bTemp, sYear, sYearSite, sDispersion)
)

# Linear predictor and simulation
eYearSite <- rep(NA, nObs)
for (i in 1:nObs) {
  eYearSite[i] <- bYearSite[year[i], site[i]]
}
eCount <- rep(NA, nObs)
log(eCount) <- bIntercept + bTemp * temp + bSite[site] + bYear[year] + eYearSite
eDispersion <- rgamma(nObs, shape = 1 / sDispersion^2, rate = 1 / sDispersion^2)
count <- rpois(nObs, eCount * eDispersion) # Overdispersed counts

hist(count)

# Data frame
starfish <- tibble::tibble(
  count = count,
  temp = temp,
  site = factor(site_names[site]),
  year = factor(2010 + year)
)

usethis::use_data(starfish, overwrite = TRUE)

if (FALSE) {
  # TEST model
  model <- embr::model(
    code = "model{
  bIntercept ~ dnorm(0, 4^-2)
  bTemp ~ dnorm(0, 2^-2)

  bSite[1] <- 0
  for (i in 2:nsite) {
    bSite[i] ~ dnorm(0, 2^-2)
  }

  sYear ~ dexp(1)
  for (i in 1:nyear) {
    bYear[i] ~ dnorm(0, sYear^-2)
  }
  sYearSite ~ dexp(1)
  for (i in 1:nyear) {
    for (j in 1:nsite) {
      bYearSite[i, j] ~ dnorm(0, sYearSite^-2)
    }
  }

  sDispersion ~ dexp(1)

  for (i in 1:nObs) {
    log(eCount[i]) <- bIntercept + bTemp * temp[i] + bSite[site[i]] + bYear[year[i]] + bYearSite[year[i], site[i]]
    eDispersion[i] ~ dgamma(sDispersion^-2, sDispersion^-2)
    count[i] ~ dpois(eCount[i] * eDispersion[i])
  }
}",
    new_expr = "
  for (i in 1:nObs) {
    log(eCount[i]) <- bIntercept + bTemp * temp[i] + bSite[site[i]] + bYear[year[i]] + bYearSite[year[i], site[i]]
    prediction[i] <- eCount[i]
    fit[i] <- eCount[i]
    residual[i] <- res_gamma_pois(count[i], fit[i], sDispersion)
  }
  ",
    new_expr_vec = TRUE,
    select_data = list(
      temp = c(-5, 30),
      site = factor(),
      year = factor(),
      count = c(0L, 1000L)
    ),
    random_effects = list(
      bYear = "year",
      bYearSite = c("year", "site")
    )
  )

  analysis <- embr::analyse(model, data = starfish, nthin = 100L)

  coef <- coef(analysis, simplify = TRUE, param_type = "all") %>%
    mutate(term = as.character(term))

  coef %>% print(n = nrow(.))

  # Preds vs data generating values
  gp <- ggplot(coef) +
    geom_pointrange(aes(x = term, y = estimate, ymin = lower, ymax = upper)) +
    geom_point(data = initial_values, aes(x = term, y = value), colour = "red") +
    guides(x = guide_axis(angle = 90))

  sbf_open_window()
  sbf_print(gp)

  # year
  year <- predict(analysis, "year", term = "eCount")

  gp <- ggplot(year) +
    geom_pointrange(aes(x = year, y = estimate, ymin = lower, ymax = upper)) +
    xlab("Year") +
    ylab("Count") +
    NULL

  sbf_open_window(3)
  sbf_print(gp)

  # Site
  site <- predict(analysis, "site", term = "eCount")

  gp <- ggplot(site) +
    geom_pointrange(aes(x = site, y = estimate, ymin = lower, ymax = upper)) +
    xlab("Site") +
    ylab("Count") +
    NULL

  sbf_open_window(3)
  sbf_print(gp)

  # Site year
  site_year <- predict(analysis, c("site", "year"), term = "eCount")

  gp <- ggplot(site_year) +
    geom_pointrange(aes(x = year, y = estimate, ymin = lower, ymax = upper)) +
    facet_grid(rows = vars(site)) +
    xlab("Year") +
    ylab("Count") +
    NULL

  sbf_open_window(3)
  sbf_print(gp)

  # Temp
  temp <- predict(analysis, "temp", term = "eCount")

  gp <- ggplot(temp) +
    aes(x = temp) +
    geom_line(aes(y = estimate)) +
    geom_line(aes(y = lower), linetype = "dotted") +
    geom_line(aes(y = upper), linetype = "dotted") +
    xlab("Temperature (˚C)") +
    ylab("Count") +
    NULL

  sbf_open_window(3)
  sbf_print(gp)


  # Residuals
  data <- starfish
  data$residual <- residuals(analysis)$estimate

  gp <- ggplot(data = data, aes(x = residual)) +
    geom_histogram(binwidth = 1 / 2, color = "white")

  sbf_open_window()
  sbf_print(gp)

  sbf_save_plot(x_name = "res_hist", report = FALSE)

  data$fit <- fitted(analysis)$estimate

  gp <- ggplot(data = data, aes(x = fit, y = residual)) +
    geom_point(alpha = 1 / 2) +
    geom_hline(yintercept = 0, linetype = "dotted")

  sbf_open_window()
  sbf_print(gp)

  sbf_save_plot(x_name = "res_fit", report = FALSE)

  ppc <- posterior_predictive_check(analysis)

  ppc %>% print()

  sbf_save_table(ppc, caption = "Model posterior predictive checks")
}

if (FALSE) {
  # Plots of raw data
  gp <- ggplot(starfish) +
    geom_point(aes(x = year, y = count)) +
    xlab("Year") +
    ylab("Count") +
    NULL

  sbf_open_window(4, 3)
  sbf_print(gp)


  sbf_open_window(4, 3)
  sbf_print(gp)

  gp <- ggplot(starfish) +
    geom_point(aes(x = temp, y = count)) +
    xlab("Temperature (˚C)") +
    ylab("Count") +
    NULL

  sbf_open_window(3, 3)
  sbf_print(gp)

  gp <- ggplot(starfish) +
    geom_point(aes(x = site, y = count)) +
    xlab("Site") +
    ylab("Count") +
    NULL

  sbf_open_window(4, 3)
  sbf_print(gp)
}
