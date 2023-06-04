library(tidyverse)
library(LRTesteR)
library(statmod)

########################
# Type I simulation
########################

# define experiment
typeI <- expand_grid(dist = c("normal", "gamma", "uniform", "inverse gaussian"), n = seq(25, 200, 25), iteration = 1:100) %>%
  arrange(dist, n, iteration)

# make data
# All random number generators have mean 1
generate_data <- function(dist, n) {
  if (dist == "normal") {
    out <- rnorm(n = n, mean = 1, sd = 2)
  } else if (dist == "gamma") {
    out <- rgamma(n = n, shape = 1, rate = 1)
  } else if (dist == "uniform") {
    out <- runif(n = n, min = 0, max = 2)
  } else {
    out <- rinvgauss(n = n, mean = 1)
  }

  return(out)
}

# run tests
set.seed(1)
typeI <- typeI %>%
  mutate(x = map2(.x = dist, .y = n, .f = generate_data))

test_one <- function(x) {
  out <- empirical_mu_one_sample(x = x, mu = 1)
  return(out)
}

test_two <- function(x) {
  out <- wilcox.test(x = x, mu = 1)
  return(out)
}

typeI <- typeI %>%
  mutate(
    LR = map(x, test_one),
    LR_P = map_dbl(LR, chuck, "p.value")
  )

typeI <- typeI %>%
  mutate(
    WIL = map(x, test_two),
    WIL_P = map_dbl(WIL, chuck, "p.value")
  )

# Sanity check results
typeI %>%
  summarise(across(contains("_P"), min))
typeI %>%
  summarise(across(contains("_P"), max))

# save results
typeI %>%
  saveRDS("data/typeI.rds")
rm(typeI, test_one, test_two)

########################
# Type II simulation
########################

# define experiment
typeII <- expand_grid(dist = c("normal", "gamma", "uniform", "inverse gaussian"), n = seq(25, 200, 25), iteration = 1:100) %>%
  arrange(dist, n, iteration)

# run tests
set.seed(1)
typeII <- typeII %>%
  mutate(x = map2(.x = dist, .y = n, .f = generate_data))

test_one <- function(x) {
  out <- empirical_mu_one_sample(x = x, mu = .75)
  return(out)
}

test_two <- function(x) {
  out <- wilcox.test(x = x, mu = .75)
  return(out)
}

typeII <- typeII %>%
  mutate(
    LR = map(x, test_one),
    LR_P = map_dbl(LR, chuck, "p.value")
  )

typeII <- typeII %>%
  mutate(
    WIL = map(x, test_two),
    WIL_P = map_dbl(WIL, chuck, "p.value")
  )

# Sanity check results
typeII %>%
  summarise(across(contains("_P"), min))
typeII %>%
  summarise(across(contains("_P"), max))

# save results
typeII %>%
  saveRDS("data/typeII.rds")
rm(typeII, generate_data, test_one, test_two)
