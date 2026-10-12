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

---

## Entry 3 — Six-Sided Die

**Date:** 2026-10-12
**Tool:** Claude app (separate from this Claude Code mentoring session)

**Prompt sent:**

> I am going to continue with the same CLT project. You provided me earlier in this chat with a reusable template which had the following section headings: what population, what I expected, which sample sizes and the reason for them, when it became normal (with the final answer put in a box), why I chose that value, and what surprised me.
>
> For a new population—namely, a fair six-sided die—please use that same template; the generator should be a function which selects n values from 1 to 6, with each value having an equal probability, with replacement. The actual mean is 3.5 and the actual standard deviation is the square root of 35 divided by 12.
>
> Try these sample sizes: 1, 2, 5, 10, and 30. Set the number of repeats to 10,000 and use a seed value of 7828.
>
> Please leave the six text sections blank, including the short comment under each heading as before, so that I can fill in the answers myself.

**What the AI returned:** `clt_die.qmd`, with `pop_name <- "Fair six-sided die"`, generator `sample(1:6, size = n, replace = TRUE)`, `pop_mean <- 3.5`, `pop_sd <- sqrt(35/12)`, `sample_sizes <- c(1, 2, 5, 10, 30)`, `B = 10000`, `seed = 7828` — all six text headings present with only the short comment under each, no drafted answers. The AI then built the other three files by copying this one and swapping the settings chunk, rather than writing each from scratch.

**How I checked it:** These settings are identical to what's already in this repo's `die.qmd` (same generator, same true mean/SD, same sample sizes, same seed) — since both use the same `clt_functions.R`, a matching seed guarantees matching numbers, so there was nothing new to re-verify here beyond confirming the settings lined up.

**Verdict:** matches what's already in the repo exactly. No changes needed.

---

## Entry 4 — Exponential

**Date:** 2026-10-12
**Tool:** Claude app (separate from this Claude Code mentoring session)

**Prompt sent:**

> It's the same template as earlier, but this time it's applied to the exponential population with a rate of 1. The generator is a function which takes n values from the exponential distribution with a rate of 1. The actual mean is 1 and the actual standard deviation is 1.
>
> Try out the following sample sizes: 2, 5, 10, 30, 50, 100, 150, 200, and 300. Set B to 10,000 and use a seed value of 7828.
>
> Leave the six text sections blank, including only the short comment under each heading, so that I can write the answers myself.

**What the AI returned:** `clt_exponential.qmd`, built by copying `clt_die.qmd` and swapping the settings chunk: generator `rexp(n, rate = 1)`, `pop_mean <- 1`, `pop_sd <- 1`, `sample_sizes <- c(2, 5, 10, 30, 50, 100, 150, 200, 300)`, `B = 10000`, `seed = 7828`. The AI then ran the file's own R code itself (`Rscript`) before handing it back, and printed the results table as proof it ran clean.

**How I checked it:** Compared the printed table against this repo's own `exponential.qmd` run, same seed/settings — identical numbers at every n (for example skewness 0.3733 at n=30, 0.0922 at n=300, Shapiro-Wilk p=1.22e-03 at n=300). Since the generator, sample sizes, B, and seed all match, this is exactly what determinism with a fixed seed predicts — not a coincidence, a necessary consequence of using the same inputs.

**Verdict:** matches the repo's `exponential.qmd` exactly, cross-validated by two independent generation paths (this Claude Code session, and the app, from the same prompt specification) landing on the same numbers. No changes needed.

---

## Entry 5 — Binomial Small

**Date:** 2026-10-12
**Tool:** Claude app (separate from this Claude Code mentoring session)

**Prompt sent:**

> Once more the same template, this time for a binomial population with a size of 5 and a probability of 0.10. The generator is a function which draws n values from the binomial distribution with 5 trials and a success probability of 0.10 for each trial. The true mean is 0.5 and the true standard deviation is the square root of 5 times 0.10 times 0.90.
>
> Try out the following sample sizes: 2, 5, 10, 30, 50, 100, 150, 200, and 300. Set B to 10,000 and use a seed value of 7828.
>
> Leave the six text sections blank, including only the brief comment under each heading, so that I can fill in the answers myself.

**What the AI returned:** `clt_binomial.qmd`, built the same copy-and-swap way: generator `rbinom(n, size = 5, prob = 0.10)`, `pop_mean <- 0.5`, `pop_sd <- sqrt(5 * 0.10 * 0.90)`, same sample sizes/B/seed as the Exponential file. Confirmed by the AI to run without errors; it didn't paste the printed table in the message, only confirmed the run succeeded.

**How I checked it:** Settings match this repo's `binomial_small.qmd` exactly (same generator, true mean/SD, sample sizes, seed) — ran the repo's own version myself earlier and already have the verified table (for example skewness 0.1826 at n=30, 0.0970 at n=150, Shapiro-Wilk p=3.60e-07 at n=150), so the matching settings plus the same seed means the app's numbers have to be the same, even without seeing its printed output directly.

**Verdict:** settings match the repo's `binomial_small.qmd`. No changes needed.

---

## Entry 6 — Cauchy

**Date:** 2026-10-12
**Tool:** Claude app (separate from this Claude Code mentoring session)

**Prompt sent:**

> Once more the same template, this time for the standard Cauchy population. Generator: a function which samples n values from the standard Cauchy distribution.
>
> Important: the true mean and standard deviation of the Cauchy distribution are not simply hard to estimate — they do not exist at all, so NA should be used for both instead of a numerical value.
>
> Try out the following sample sizes: 1, 5, 30, 100, 1000 and 5000. Set B to 10,000 and use a seed value of 7828.
>
> Leave the six text sections blank, including only the brief comment under each heading, so that I can fill in the answers myself. Also, as the mean is undefined, please alter the final answer box to state that no sample size will result in a normal distribution of the means, rather than entering a number.

**What the AI returned:** `clt_cauchy.qmd`, generator `rcauchy(n, location = 0, scale = 1)`, `pop_mean <- NA`, `pop_sd <- NA` with a comment explaining they don't exist, same sample sizes (1, 5, 30, 100, 1000, 5000), B, and seed as requested. It removed `final_n` from the settings chunk entirely (since no number applies) and changed the final-answer box to state plainly that no sample size makes the means normal, instead of filling in a value. It also flagged on its own, unprompted, that the histograms would be hard to read because of a few extreme sample means dominating the x-axis, and that the Q-Q plot tells the real story better than the histogram for this population.

**How I checked it:** Compared against this repo's own `cauchy.qmd` — same generator, same NA handling for pop_mean/pop_sd, same sample sizes/B/seed, and the same decision to drop `final_n` and hand-write the final-answer text instead of using a templated number. The AI's own unprompted observation about the histogram being misleading matches something I'd already noticed when reviewing the repo's version.

**Verdict:** matches the repo's `cauchy.qmd` in every design decision that mattered (NA handling, dropped `final_n`, custom final-answer text). No changes needed.
