# =============================================================
# Central Limit Theorem - Monte Carlo simulation helpers
# Base R only. Set your own seed with set.seed() BEFORE calling.
# =============================================================


# -------------------------------------------------------------
# 1. simulate_means()
# Takes B random samples of size n and returns the B sample means.
#   rng : a random number function whose first argument is the
#         sample size, e.g. rexp, rnorm, runif
#   n   : size of each sample
#   B   : number of samples (repeats)
#   ... : any extra arguments for rng, e.g. rate = 2 for rexp
# -------------------------------------------------------------
simulate_means <- function(rng, n, B, ...) {
  means <- numeric(B)              # empty vector to hold B means

  for (b in seq_len(B)) {          # repeat B times
    x <- rng(n, ...)               # draw one sample of size n
    means[b] <- mean(x)            # store that sample's mean
  }

  return(means)                    # vector of B sample means
}


# -------------------------------------------------------------
# 2. summarize_means()
# Compares the simulated sample means to what the CLT predicts.
#   means : vector of sample means (from simulate_means)
#   mu    : true population mean
#   sigma : true population standard deviation
#   n     : sample size used (needed for sigma / sqrt(n))
# Returns a one-row data frame, so results for several
# populations can be stacked together with rbind().
# -------------------------------------------------------------
summarize_means <- function(means, mu, sigma, n) {

  # Basic summaries of the sample means
  avg_means   <- mean(means)          # should be close to mu
  sd_means    <- sd(means)            # observed spread of the means
  expected_sd <- sigma / sqrt(n)      # spread the CLT predicts

  # Skewness and excess kurtosis from central moments
  d  <- means - avg_means             # deviations from the average
  m2 <- mean(d^2)                     # 2nd central moment (variance)
  m3 <- mean(d^3)                     # 3rd central moment
  m4 <- mean(d^4)                     # 4th central moment
  skewness        <- m3 / m2^1.5      # 0 for a normal distribution
  excess_kurtosis <- m4 / m2^2 - 3    # 0 for a normal distribution

  # Shapiro-Wilk test only accepts 3 to 5000 values,
  # so take a random subset of 5000 if there are more
  if (length(means) > 5000) {
    sw_input <- sample(means, 5000)   # random 5000, no repeats
  } else {
    sw_input <- means
  }
  sw <- shapiro.test(sw_input)        # H0: the data are normal

  # Put everything in one row
  result <- data.frame(
    n               = n,
    B               = length(means),
    mean_of_means   = avg_means,
    true_mean       = mu,
    sd_of_means     = sd_means,
    expected_sd     = expected_sd,
    skewness        = skewness,
    excess_kurtosis = excess_kurtosis,
    shapiro_W       = unname(sw$statistic),
    shapiro_p       = sw$p.value
  )
  return(result)
}


# -------------------------------------------------------------
# 3. plot_means()
# Draws, side by side:
#   left : histogram of the sample means with the normal curve
#          the CLT predicts, N(mu, sigma / sqrt(n)), on top
#   right: normal Q-Q plot of the sample means
#   main : optional title, e.g. "Exponential, n = 30"
# -------------------------------------------------------------
plot_means <- function(means, mu, sigma, n, main = "Sample means") {

  old_par <- par(mfrow = c(1, 2))     # two plots in one row
  on.exit(par(old_par))               # restore layout when done

  # Histogram on the density scale (freq = FALSE) so the
  # normal curve and the bars use the same y-axis
  hist(means, breaks = 50, freq = FALSE,
       col = "lightgray", border = "white",
       main = main, xlab = "Sample mean")

  # Normal curve predicted by the CLT
  curve(dnorm(x, mean = mu, sd = sigma / sqrt(n)),
        add = TRUE, col = "red", lwd = 2)

  # Q-Q plot: points near the line mean the means look normal
  qqnorm(means, main = paste("Normal Q-Q:", main))
  qqline(means, col = "red", lwd = 2)
}


# =============================================================
# Example use (exponential population with rate 1:
# true mean = 1, true sd = 1)
# =============================================================
# set.seed(123)
# m <- simulate_means(rexp, n = 30, B = 10000, rate = 1)
# summarize_means(m, mu = 1, sigma = 1, n = 30)
# plot_means(m, mu = 1, sigma = 1, n = 30, main = "Exponential, n = 30")
#
# Stacking results from several populations:
# res <- rbind(
#   summarize_means(m, 1, 1, 30),
#   summarize_means(simulate_means(runif, 30, 10000), 0.5, sqrt(1/12), 30)
# )
# res
