# The Stan Ecosystem: A Map for New Contributors

*A guide to the repositories in [github.com/stan-dev](https://github.com/stan-dev), how they relate to each other, and how they map onto the Bayesian workflow.*

Stan is not one piece of software — it's an **ecosystem** of ~50 repositories that together take a user from "I have data and a scientific question" to "I have a fitted, checked, and validated Bayesian model." Understanding the ecosystem's layers is the fastest way to understand where a new contributor can plug in.

---

## 1. The Layer Model

Think of the ecosystem as four concentric layers, from the C++ core outward to the applied-statistics tools:

```
┌───────────────────────────────────────────────────────────────────┐
│  LAYER 4 — Workflow & downstream analysis (mostly R packages)      │
│  posterior · bayesplot · loo · priorsense · projpred · shinystan   │
│  rstanarm · rstantools · posteriordb                               │
├───────────────────────────────────────────────────────────────────┤
│  LAYER 3 — User-facing interfaces (one per language)                │
│  cmdstanr · cmdstanpy · rstan · pystan2 (archived) · MatlabStan …   │
├───────────────────────────────────────────────────────────────────┤
│  LAYER 2 — The command-line engine                                  │
│  cmdstan                                                             │
├───────────────────────────────────────────────────────────────────┤
│  LAYER 1 — The compiler & the math                                  │
│  stanc3 (Stan → C++ transpiler)  +  stan (algorithms & services)    │
│  math (C++ autodiff library — the actual computational engine)      │
└───────────────────────────────────────────────────────────────────┘
```

A Stan program written by a user is: **parsed and transpiled by `stanc3` → compiled into a C++ executable that links `stan` (algorithms) and `math` (autodiff) → run via `cmdstan` (or a language interface) → the resulting posterior draws are analyzed with `posterior`, `bayesplot`, `loo`, etc.**

---

## 2. Repository Catalogue

### Layer 1 — Core engine (C++ / OCaml)

| Repo | Language | What it does |
|---|---|---|
| **[math](https://github.com/stan-dev/math)** | C++ | The Stan Math Library: a template library for **automatic differentiation** (forward, reverse, and mixed mode, to arbitrary order), plus a huge collection of differentiable probability density functions, linear algebra routines (Cholesky, eigendecompositions, sparse matrices), ODE/algebraic/DAE solvers, and special functions. This is the computational heart of Stan — every gradient that HMC/NUTS needs comes from here. Depends on Eigen, Boost, SUNDIALS, and Intel TBB (for threading). |
| **[stanc3](https://github.com/stan-dev/stanc3)** | OCaml | The **Stan-to-C++ transpiler** (the third-generation compiler, replacing the old C++-based `stanc`). Parses the Stan modeling language, type-checks it, optimizes the abstract syntax tree, and emits C++ that calls into `math`. Also powers linting/formatting (`stanc --auto-format`) and IDE tooling. This is where new **language features** (new syntax, tuples, sparse types, etc.) get implemented. |
| **[stan](https://github.com/stan-dev/stan)** | C++ | The **algorithms and services layer**: NUTS/HMC sampling, ADVI and Pathfinder (variational/approximate inference), L-BFGS optimization, Laplace approximation, and the "services" API that all interfaces call into (a stable C++ API so `cmdstan`, `rstan`, etc. don't need to know implementation details). Depends on `math`; the generated model code from `stanc3` gets compiled against this. |

### Layer 2 — Command-line engine

| Repo | Language | What it does |
|---|---|---|
| **[cmdstan](https://github.com/stan-dev/cmdstan)** | C++/Make | The **command-line interface** to Stan. Takes a `.stan` file, invokes `stanc3` to transpile it, compiles the resulting C++ against `stan`+`math`, and produces a standalone executable that can sample, optimize, or run variational inference from the shell, writing results to CSV. Nearly every higher-level interface (R, Python, Julia, MATLAB, Stata, Mathematica) is a wrapper that either calls the CmdStan executable or embeds the same services layer directly. |

### Layer 3 — Language interfaces

| Repo | Language | What it does |
|---|---|---|
| **[cmdstanr](https://github.com/stan-dev/cmdstanr)** | R | Lightweight R wrapper around CmdStan. Compiles/runs models as external processes and returns results as `posterior`-package objects. The **recommended** modern R interface (BSD-3 license, tracks new Stan features immediately). |
| **[cmdstanpy](https://github.com/stan-dev/cmdstanpy)** | Python | The Python analogue of `cmdstanr` — thin wrapper around CmdStan, returns draws as NumPy/Pandas/xarray objects. The **recommended** modern Python interface. |
| **[rstan](https://github.com/stan-dev/rstan)** | R | The original, more tightly-integrated R interface: embeds Stan directly via Rcpp rather than shelling out to CmdStan. Still widely used (and what `rstanarm` builds on) but heavier to keep in sync with new Stan releases; GPL-3 licensed. |
| **[pystan2](https://github.com/stan-dev/pystan2)** *(archived)* | Python | The legacy embedded Python interface, superseded by `cmdstanpy` and a modern `pystan` (built on `httpstan`). |
| **[httpstan](https://github.com/stan-dev/httpstan)** | Python/C++ | HTTP micro-service interface to Stan; the backend used by the current `pystan` package. |
| MatlabStan, Stan.jl, MathematicaStan, StataStan | — | Community-maintained wrappers for MATLAB, Julia, Mathematica, and Stata, generally calling out to CmdStan. |
| **[rstanarm](https://github.com/stan-dev/rstanarm)** | R (+ Stan) | Not strictly an "interface" but sits at the interface/analysis boundary: provides **`lme4`/`glm`-style formula syntax** for common regression models (GLMs, hierarchical/multilevel models, GAMs, survival models) with **pre-compiled Stan programs**, so users get Bayesian regression without writing Stan code. Tightly integrated with `bayesplot`, `loo`, and `shinystan`. |

### Layer 4 — Workflow & downstream analysis (mostly R, framework-agnostic in spirit)

| Repo | Language | What it does |
|---|---|---|
| **[posterior](https://github.com/stan-dev/posterior)** | R | Defines standard **draws formats** (`draws_array`, `draws_df`, `draws_matrix`, `draws_rvars`, …) and provides the core diagnostic functions everyone else depends on: `rhat()`, `ess_bulk()`, `ess_tail()`, `summarise_draws()`. Think of it as the shared "data frame for MCMC output" that lets `bayesplot`, `loo`, `cmdstanr`, and `brms` interoperate. |
| **[bayesplot](https://github.com/stan-dev/bayesplot)** | R | ggplot2-based **visualization** of posteriors and diagnostics: trace plots, `mcmc_rhat()`/`mcmc_neff()`, posterior-predictive-check plots (`ppc_dens_overlay`, `ppc_intervals`), pair plots for detecting divergences, NUTS-energy diagnostics. |
| **[loo](https://github.com/stan-dev/loo)** | R | **Approximate leave-one-out cross-validation** via Pareto-smoothed importance sampling (PSIS-LOO), plus WAIC and model comparison/averaging (`loo_compare`, `loo_model_weights`). The standard tool for out-of-sample predictive model comparison in the Stan ecosystem. |
| **[priorsense](https://github.com/stan-dev/priorsense)** | R | **Power-scaling sensitivity analysis**: diagnoses how sensitive posterior conclusions are to the choice of prior and to the likelihood, without refitting the model many times. |
| **[projpred](https://github.com/stan-dev/projpred)** | R | **Projection predictive variable selection** — finds a small, interpretable submodel that best approximates the predictions of a larger reference model (from `rstanarm`/`brms`). Used for feature selection under a full Bayesian workflow rather than ad hoc thresholding. |
| **[shinystan](https://github.com/stan-dev/shinystan)** | R | Interactive **Shiny GUI** for exploring posterior draws and MCMC diagnostics visually (works with `rstan`, `rstanarm`, or any MCMC output). |
| **[rstantools](https://github.com/stan-dev/rstantools)** | R | Developer tooling for **building your own R package that includes pre-compiled Stan models** (the same machinery `rstanarm` and `brms` are built on). Relevant if you want to *build on* Stan rather than *contribute to* it. |
| **[posteriordb](https://github.com/stan-dev/posteriordb)** (+ `posteriordb-r`, `posteriordb-python`) | data + R/Python | A curated **database of models, data, and gold-standard reference posteriors** (e.g., Eight Schools, radon, roaches) used to benchmark inference algorithms for accuracy and speed — essential for anyone developing or testing new samplers. |

### Documentation, examples, and infrastructure

| Repo | What it does |
|---|---|
| **[docs](https://github.com/stan-dev/docs)** | Source for the Stan Reference Manual, Functions Reference, and CmdStan User's Guide (built with Quarto → mc-stan.org/docs). Great first contribution: fixing docs is low-risk and high-value. |
| **[example-models](https://github.com/stan-dev/example-models)** | A large library of worked Stan models (many translated from BUGS/JAGS textbooks), useful both as learning material and as regression-test fodder. |
| **[stan-dev.github.io](https://github.com/stan-dev/stan-dev.github.io)** | Source for the mc-stan.org website. |
| **[performance-tests-cmdstan](https://github.com/stan-dev/performance-tests-cmdstan)** | Benchmarking harness that runs CmdStan against a model suite (often via `posteriordb`) to catch performance regressions release over release. |
| **[design-docs](https://github.com/stan-dev/design-docs)** | Functional and technical specifications for major proposed changes (new language syntax, new algorithms). Read this to see where Stan is heading and to learn the process for proposing a big change yourself. |
| **[ci-scripts](https://github.com/stan-dev/ci-scripts)**, **[jenkins-shared-libraries](https://github.com/stan-dev/jenkins-shared-libraries)** | Continuous-integration tooling shared across repos (Jenkins pipelines, release scripts). |
| **[r-packages](https://github.com/stan-dev/r-packages)** | Hosts the Stan-dev CRAN-like R package repository (`mc-stan.org/r-packages`) so users can install `cmdstanr` etc. without waiting on CRAN. |

### Adjacent but *not* in the `stan-dev` org (worth knowing about)

- **[brms](https://github.com/paul-buerkner/brms)** (Paul Bürkner) — `lme4`-style formula interface to Stan, more flexible than `rstanarm` (custom families, nonlinear/distributional models), generates Stan code on the fly rather than using pre-compiled models. Interoperates fully with `posterior`, `bayesplot`, `loo`, `projpred`.
- **ArviZ** (Python) — the Python-side analogue of `posterior`+`bayesplot`+`loo` combined, used heavily with `cmdstanpy`.

---

## 3. How the Repos Are Connected

### 3.1 Dependency graph (build/runtime dependencies)

```
math  ──────────────┐
                     ├──▶  stan  ──▶  cmdstan  ──┬──▶ cmdstanr ──▶ rstanarm ──┬─▶ bayesplot
stanc3 (compiler) ───┘                            │                          ├─▶ loo
                                                   ├──▶ cmdstanpy             ├─▶ shinystan
                                                   │                          ├─▶ projpred
                                                   └──▶ MatlabStan/Stan.jl/…  └─▶ posterior

rstan ──▶ rstanarm  (rstan is the legacy embedded path; rstanarm can use either rstan or cmdstanr as backend)
posterior ──▶ used by cmdstanr, cmdstanpy, bayesplot, loo, priorsense (shared draws format & diagnostics)
posteriordb ──▶ used by performance-tests-cmdstan and by algorithm developers testing stan/math changes
rstantools ──▶ used to build rstanarm-like packages (developer-facing, not itself a runtime dependency)
```

This is literally the historical dependency chain the Stan devs describe: **`math ← stan ← pystan/rstan/cmdstan ← rstanarm/statastan/matlabstan/... ← stanc3`** as the compiler feeding all of them.

### 3.2 Conceptual grouping — "which repo do I touch if I want to change X?"

| If you want to... | Touch this repo |
|---|---|
| Add a new probability distribution, a faster gradient, or fix a numerical bug in autodiff | **math** |
| Add new Stan language syntax (e.g., tuples, new types) | **stanc3** |
| Add or improve a sampling algorithm (e.g., NUTS variants, Pathfinder) | **stan** |
| Change how the CLI exposes options, outputs CSV/JSON | **cmdstan** |
| Improve the R or Python user experience (better error messages, parallelism, plotting hooks) | **cmdstanr** / **cmdstanpy** |
| Add a diagnostic or summary statistic that should be available everywhere | **posterior** |
| Add a new visualization | **bayesplot** |
| Improve cross-validation or model comparison methods | **loo** |
| Add a new pre-built regression model family | **rstanarm** |
| Improve documentation or add a tutorial | **docs**, **example-models** |
| Add a benchmark model or reference posterior | **posteriordb** |

### 3.3 Conceptual (workflow) grouping

The four layers map neatly onto the phases of the Bayesian workflow (see §4): **Layer 1–2** = *computation* (does the sampler run correctly and efficiently), **Layer 3** = *specification and fitting* (how you write and run the model), **Layer 4** = *checking, comparison, and decision-making* (what you do with the draws once you have them). A new contributor with a statistics background will likely gravitate to Layer 4 packages; someone with a systems/compilers background to `stanc3`/`math`/`stan`.

---

## 4. Repositories Mapped onto the Bayesian Workflow

This mapping follows the structure of Gelman, Vehtari, McElreath et al., *Bayesian Workflow* (2026) — see the [book's website and case studies](https://avehtari.github.io/Bayesian-Workflow/) — together with Aki Vehtari's [case studies](https://users.aalto.fi/~ave/casestudies.html). The book's own case studies (e.g., Ch. 24 "Roaches" for LOO, Ch. 21 "Dogs" for posterior predictive checks, Ch. 31 for simulation-based calibration) are excellent walkthroughs that use exactly these tools.

| Workflow stage | Typical question | Repos used | Example |
|---|---|---|---|
| **1. Build the model** | Write down the generative model / likelihood + priors | **stanc3** (language), **example-models**, **posteriordb** (borrow a template) | Write `eight_schools.stan` with `data`, `parameters`, `model` blocks. |
| **2. Simulate to capture uncertainty (prior/fake-data checks)** | Does the model produce sensible fake data before I touch real data? | **cmdstanr**/**cmdstanpy** (`$sample()` with priors only, or generate fake data in `generated quantities`), **bayesplot** (`ppc_*` on prior draws) | Sample from the prior predictive with data-generating code in `generated quantities`, plot with `bayesplot::ppc_dens_overlay()`. This is the "simulated data of movie ratings" pattern from Ch. 16 of the workflow book. |
| **3. Fit the model** | Run MCMC / get posterior draws | **cmdstan**, **cmdstanr**, **cmdstanpy**, **rstan**, **rstanarm** (for standard GLMs) | `mod <- cmdstan_model("model.stan"); fit <- mod$sample(data = stan_data, chains = 4)`. |
| **4. Diagnose the fit** | Did the sampler actually work? (R-hat, ESS, divergences, tree depth) | **posterior** (`summarise_draws()`, `rhat()`, `ess_bulk()`), **bayesplot** (`mcmc_trace()`, `mcmc_pairs()` for divergences, `mcmc_nuts_energy()`), **shinystan** (interactive GUI) | `fit$summary()` in cmdstanr calls `posterior::summarise_draws()` under the hood; `bayesplot::mcmc_trace(fit$draws())` for trace plots; `launch_shinystan(fit)` for interactive diagnostics. This is the core of Ch. 12, "Diagnosing and fixing problems with fitting." |
| **5. Posterior predictive checking** | Does the fitted model reproduce features of the observed data? | **bayesplot** (`ppc_*` functions), **posterior** | `y_rep <- fit$draws("y_rep"); bayesplot::ppc_dens_overlay(y, y_rep)` — directly mirrors Ch. 21 ("Dogs") and Ch. 18 ("Nabiximols clinical trial") case studies. |
| **6. Model comparison / selection** | Which of several models predicts best out-of-sample? | **loo** (PSIS-LOO, `loo_compare`), **posteriordb** (for benchmark comparisons) | `loo1 <- fit1$loo(); loo2 <- fit2$loo(); loo_compare(loo1, loo2)` — this is Ch. 24 ("Roaches") and Ch. 9.4 ("Model selection using predictive performance") almost verbatim. |
| **7. Prior/likelihood sensitivity** | How much do conclusions depend on subjective prior choices? | **priorsense** | `powerscale_sensitivity(fit)` flags parameters whose posterior is unduly sensitive to the prior — relevant to Ch. 17, "Prior specification for regression models." |
| **8. Variable/feature selection** | Which predictors actually matter, in a way consistent with the full-model uncertainty? | **projpred** (on an `rstanarm`/`brms` reference model) | `varsel(refmodel); suggest_size(vs)` — related to Ch. 28, "Models for regression coefficients and variable selection." |
| **9. Model expansion / iterative building** | Add hierarchical structure, non-linearity, or measurement-error components once the simple model is validated | **stanc3**/Stan language, **bayesplot** for re-checking, **loo** for re-comparing | Iteratively grow a model as in Ch. 19 ("Building up to a hierarchical model: Coronavirus testing") or Ch. 25 ("Golf putting"). |
| **10. Simulation-based calibration (SBC)** | Is my *fitting procedure* well-calibrated across the whole prior, not just for one dataset? | **cmdstanr**/**cmdstanpy** (repeated simulate-fit-rank loop), **posterior** | Draw θ from the prior, simulate y, fit, rank true θ among posterior draws, repeat many times, check rank uniformity — the subject of Ch. 31 and Talts et al.'s SBC method, now with dedicated helper packages (e.g. `SBC` R package, built on `posterior`). |
| **11. Decision analysis** | Use the posterior to make a decision under uncertainty | **posterior** (draws of derived quantities), custom `generated quantities` blocks | Ch. 20, "Using a fitted model for decision analysis: Mixture model for time series competition" — compute expected utility over posterior draws. |
| **12. Approximate inference for speed / large-scale iteration** | Need a fast approximate posterior during early model iteration | **stan**'s Pathfinder/ADVI algorithms, exposed via **cmdstanr**/**cmdstanpy** (`$pathfinder()`, `$variational()`) | Useful during the exploratory "throw away 10 model variants" phase before committing to full MCMC for the final model — see Ch. 13, "Approximate algorithms and approximate models." |
| **13. Formula-based / no-code Stan modeling** | Fit a standard GLMM without writing Stan code | **rstanarm** (pre-compiled) or **brms** (generates code on the fly, not in `stan-dev` org but interoperable) | `stan_glmer(y ~ x + (1|group), family = poisson(), data = df)`. |
| **14. Benchmarking new inference methods** | I'm developing a new sampler/algorithm and need ground truth | **posteriordb**, **performance-tests-cmdstan** | Test your prototype against Eight Schools / radon / roaches reference posteriors with known-good draws. |

---

## 5. Suggested "First Contribution" Entry Points by Interest

| Your background | Good first repos |
|---|---|
| Statistics / applied Bayesian modeling | `bayesplot`, `loo`, `priorsense`, `example-models`, `docs` |
| R programming | `cmdstanr`, `posterior`, `bayesplot`, `shinystan`, `rstanarm` |
| Python programming | `cmdstanpy`, `httpstan` |
| C++ / performance / numerics | `math` (many `good-first-issue` labels), `stan` |
| Compilers / PL theory / OCaml | `stanc3` |
| DevOps / CI | `ci-scripts`, `jenkins-shared-libraries`, `performance-tests-cmdstan` |
| Technical writing | `docs`, `example-models`, `stan-dev.github.io` |

The `help-wanted` and `good-first-issue` labels are actively maintained across these repos, and the Stan Discourse forums (with a "Developers" tag) and the Stan Slack are the right place to ask before diving in.

---

## 6. Further Resources

- Aki Vehtari, [Bayesian Workflow book & case studies](https://avehtari.github.io/Bayesian-Workflow/) — chapter-by-chapter, runnable R/Stan code for every stage above.
- Aki Vehtari, [older case studies](https://users.aalto.fi/~ave/casestudies.html) — additional worked examples (many predate the book and complement it).
- Aki Vehtari, [Cross-validation FAQ](https://users.aalto.fi/~ave/CV-FAQ.html) — deep dive specifically into the `loo`/PSIS-LOO methodology.
- [Introduction to Stan for New Developers (Wiki)](https://github.com/stan-dev/stan/wiki/Introduction-to-Stan-for-New-Developers) — the canonical dependency-chain description and contribution process.
- [mc-stan.org](https://mc-stan.org) — installation, documentation, and case-study hub for all of the above.
