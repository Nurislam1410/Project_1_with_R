# AI Prompts Log — Project 1 (CLT Monte Carlo Investigation)

Per the course's AI-use policy (`r_midterm_review.qmd`, §1): AI use is encouraged, not restricted — the requirement is that I can explain and defend whatever it helped produce, not that I avoid it. This file tracks that, separate from the analysis file itself.

For each entry: the prompt(s) used, what the AI suggested, what I changed and why, how I tested/verified it, and any errors or incorrect suggestions I caught.

---

## Entry 1 — Reusable Monte Carlo simulation + diagnostics functions

**Date:** 2026-10-11
**Tool:** Claude app (separate from this Claude Code mentoring session — see below)

**Prompt sent:**

> I am working on a school project in R. I am studying the Central Limit Theorem using Monte Carlo simulation — this means taking many random samples and looking at what happens to their averages.
>
> I will test 5 different populations, one at a time. I do not want to write the same code 5 times. So please write small reusable functions I can call again with different inputs each time, instead of one fixed script.
>
> Please write:
> 1. A function that takes a random number generator (for example `rexp` or `rnorm`), a sample size `n`, and a number of repeats `B`. It should take `B` samples of size `n`, find the mean of each sample, and return all the sample means.
> 2. A function that takes those sample means, plus the population's true mean and standard deviation, and gives me: the average of the sample means, the standard deviation of the sample means, the expected standard deviation (population standard deviation divided by the square root of `n`), skewness, excess kurtosis, and a Shapiro-Wilk test result. The Shapiro-Wilk test only works on up to 5000 values, so if I give it more than 5000 sample means, pick a random 5000 of them first.
> 3. A function that makes a histogram of the sample means with a normal curve drawn on top, and a Q-Q plot.
>
> Please use only base R, no `tidyverse` or other packages, because I need to understand and explain every line. Please add short comments explaining what each part does.
>
> I will set the random seed myself before calling these functions — please do not put `set.seed()` inside them.

**Iteration before sending:** the first draft of this prompt (worked out with Claude Code, my mentoring session, not the model that answered it) used denser language — "not a one-off script," `simulate_means()` as an unexplained function name, "theoretical SE" — that I didn't actually understand well enough to evaluate the response against. Rewrote it in plain language before sending, same technical content, nothing dropped (double-checked the Shapiro-Wilk 5000-value subsampling requirement specifically, since that one almost got lost in the simplification pass).

**What the AI returned:** `clt_functions.R` with three functions — `simulate_means(rng, n, B, ...)`, `summarize_means(means, mu, sigma, n)`, `plot_means(means, mu, sigma, n, main)`. Matched all 3 requirements, including the 5000-value Shapiro-Wilk subsampling. Tested it themselves on Exponential (n=30, B=10000) and Uniform (n=30, B=2000) as a sanity check before handing it back.

**How I checked it:**
- Read through the actual code myself (not just trusted the natural-language summary) — confirmed no `set.seed()` inside the functions, confirmed the Shapiro-Wilk subsampling logic matches what I asked for, confirmed base R only.
- Flagged for myself (before running anything) that `simulate_means()` assumes the generator's first argument is the sample count — true for `rexp`/`rnorm`/`rbinom`, but the Six-Sided Die population uses `sample()`, whose first argument is the *values* to draw from, not a count. Still need to test `simulate_means(sample, n=30, B=100, x=1:6, replace=TRUE)` directly to confirm R's named-argument matching makes this work before trusting it for the die.

**Verdict:** good first response, no forced follow-up prompt needed — the code was already complete and correct. File committed to the repo as `clt_functions.R`.

---

## Entry 2 — Reusable `.qmd` template for the remaining 4 distributions

**Date:** 2026-10-12
**Tool:** Claude app (separate from this Claude Code mentoring session)

**Prompt sent:**

> For my school project I currently have one Quarto file completed (only one population having been dealt with); I need to use the same section headings and code structure for four more populations and so I don't want to write everything out by hand each time.
>
> Sure then, here is a template consisting of the following section headings, along with a brief comment explaining what should be included in each: what population, what I expected, which sample sizes and the reason for choosing them, when it became normal (with the final answer in a box), why I chose that value, and what surprised me. Between the sections, include code fragments that call your own simulate_means() and summarize_means() functions for each sample size, reset the seed before carrying out each sample size, and then produce a results table and the plots.
>
> Substitute in values that vary according to the population, such as the name of the population, the random generator function, the mean, the standard deviation, and the sample sizes — in order that I may insert them each time.

**Iteration before sending:** a first draft of this prompt explicitly asked for the YAML header to be generated. I cut that after noticing RStudio already auto-generates the YAML block when a new Quarto file is created, so asking for it was redundant. Shortened overall, same technical content requested.

**What the AI returned:** a template `.qmd` with a single `settings` code chunk at the top holding everything that changes per population (`pop_name`, a `rng` generator closure, `pop_mean`, `pop_sd`, `sample_sizes` vector, `B`, `seed`, `final_n`), a `for` loop over `sample_sizes` that resets the seed and calls `simulate_means()`/`summarize_means()` once per `n` (instead of one hand-written chunk per `n`), a results table via `do.call(rbind, ...)` with `signif()` applied to the p-value column so small p-values don't print as 0, a plots loop, and a `callout-important` box for the final answer using inline `` `r final_n` ``.

**How I checked it:**
- Read through the actual code myself. Confirmed it sources `clt_functions.R` and calls `simulate_means()`/`summarize_means()`/`plot_means()` with the exact same signatures already verified in Entry 1 — no new unverified function behavior introduced.
- Confirmed `set.seed(seed)` resets inside the loop before every `n`, matching the course's reproducibility requirement.
- Caught two problems before trusting it: (1) the example/default seed in the template is `2026`, not my actual `7828` — must change every time I copy this for a new population; (2) the AI saved the file with the same name (`standard_normal.qmd`) as my already-completed Standard Normal file, risking an overwrite. Renaming before reuse and only using it for the 4 remaining populations, not to redo Standard Normal.

**Verdict:** adopted — the settings-chunk + loop design is more scalable than my manual per-`n` chunks from Entry 1, especially for populations where I'll test more than 3 sample sizes. Used as the starting template for Six-Sided Die, Exponential, Binomial Small, and Cauchy, with the seed and filename corrected each time.
