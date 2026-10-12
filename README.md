# Project 1: CLT Monte Carlo Simulation

MATH 167R — investigating how the Central Limit Theorem behaves in practice: at what sample size `n` does the sampling distribution of the sample mean start looking normal, for five different populations, including one (Cauchy) where it never does.

## How to reproduce

Each `.qmd` file is self-contained: it sources `clt_functions.R`, then simulates and reports on its own population. Render any file with Quarto, or run `source("clt_functions.R")` in R first if you only want the code chunks.

All files use `set.seed(7828)` (last four digits of my student ID) reset immediately before each simulation, and `B = 10000` Monte Carlo repeats throughout, so results are reproducible exactly as reported.

## Files

| File | What it does |
|---|---|
| `clt_functions.R` | Shared helpers: `simulate_means()` draws B samples of size n and returns their means; `summarize_means()` compares the simulated means to CLT predictions (mean, SD, skewness, excess kurtosis, Shapiro-Wilk test); `plot_means()` draws the histogram + Q-Q plot pair. |
| `standard_normal.qmd` | Standard Normal population. Already normal by construction — looks normal from n = 1. |
| `die.qmd` | Six-sided die. Symmetric but discrete; needs n = 10 before kurtosis settles. |
| `exponential.qmd` | Exponential(rate = 1). Right-skewed; needs n = 300 before skewness drops below threshold, far past the "n = 30" rule of thumb. |
| `binomial_small.qmd` | Binomial(size = 5, prob = 0.10). Also skew-driven; needs n = 150. |
| `cauchy.qmd` | Standard Cauchy. Population mean and variance are undefined, so the CLT's own precondition fails — no n makes the sample means normal. |
| `reproducibility_experiment.qmd` | Reruns the Standard Normal case with a different seed (4242 vs. 7828) to check whether the conclusions, not just the exact numbers, hold up. |
| `final_summary.qmd` | **Start here for conclusions.** Cross-distribution comparison table plus write-up: is there a universal n = 30 rule, which populations converged fastest/slowest and why, what heavy tails (Cauchy) break, and what the reproducibility check showed. |
| `AI_PROMPTS_LOG.md` | Record of AI prompts used on this project, what each returned, how it was checked, and the verdict. |

## Method, in short

For each population and each tested `n`: draw B = 10,000 samples of size n, take their means, then compare the resulting distribution of means against the CLT's prediction using skewness, excess kurtosis, the Shapiro-Wilk test, a histogram against the predicted normal curve, and a Q-Q plot — not any single diagnostic alone. See `final_summary.qmd` for why that matters (the Shapiro-Wilk test flags different, equally-normal data at different n depending on the random seed).
