# The Stan ecosystem, package by package

Which repository a contribution belongs in, and what each package depends on.

## Contents

- [The four layers](#the-four-layers)
- [Layer 1–2: compiler, math, CmdStan](#layer-12-compiler-math-cmdstan)
- [Layer 3: language interfaces](#layer-3-language-interfaces)
- [Layer 4: workflow and analysis](#layer-4-workflow-and-analysis)
- [The Python / ArviZ stack](#the-python--arviz-stack)
- [What a minimal workflow touches](#what-a-minimal-workflow-touches)

## The four layers

Most projects live under [`stan-dev`](https://github.com/stan-dev); ArviZ lives
under [`arviz-devs`](https://github.com/arviz-devs) and `brms` under its author's
account.

1. **Compiler and math** — `stanc3`, `stan`, `math`. The fundamental building
   blocks: transpilation, autodiff, core inference algorithms.
2. **Command-line engine** — `cmdstan`. Drives compilation and execution.
3. **Language interfaces** — `cmdstanr`, `cmdstanpy`, `rstan`. Host-language
   wrappers.
4. **Workflow and analysis** — `posterior`, `bayesplot`, `loo`, `priorsense`,
   and others. Visualisation, diagnostics, cross-validation, sensitivity
   analysis.

Layers 3 and 4 are where a first contribution normally belongs: they are in R or
Python, they have `good first issue` labels, and a mistake there is cheap.

## Layer 1–2: compiler, math, CmdStan

| Package | Description | Relations | Language |
|---------|-------------|-----------|----------|
| [`math`](https://mc-stan.org/math/) | Autodiff library for distributions, linear algebra, and gradients | Used by generated model code | C++ |
| [`stanc3`](https://github.com/stan-dev/stanc3) | Compiler that translates `.stan` to C++ | Feeds `cmdstan` and `rstan` | OCaml |
| [`stan`](https://github.com/stan-dev/stan) | Inference algorithms and services (HMC/NUTS, etc.) | Built on `math`; used via `cmdstan` / `rstan` | C++ |
| [`cmdstan`](https://github.com/stan-dev/cmdstan) | Command-line engine to compile and run Stan models | Wraps `stanc3` + `stan` + `math`; backend for `cmdstanr` / `cmdstanpy` | C++ / CLI |

For `math` and `stan`, load `stan-math-contribution` — they share the
[developer process](https://github.com/stan-dev/stan/wiki/Developer-process-overview),
which differs substantially from the R and Python workflows. `stanc3` is OCaml
and is not covered; see the [Developer Wiki](https://github.com/stan-dev/stan/wiki).

## Layer 3: language interfaces

| Package | Description | Relations | Language |
|---------|-------------|-----------|----------|
| [`cmdstanr`](https://github.com/stan-dev/cmdstanr) | R wrapper around CmdStan; returns `CmdStanMCMC` | Calls `cmdstan`; used with `posterior`, `bayesplot`, `loo` | R |
| [`cmdstanpy`](https://github.com/stan-dev/cmdstanpy) | Python wrapper around CmdStan; returns `CmdStanMCMC` | Calls `cmdstan`; used with `arviz` | Python |
| [`rstan`](https://github.com/stan-dev/rstan) | R interface that embeds Stan in-process; returns `stanfit` | Alternative to CmdStan; used by `rstanarm` and `rstantools` | R |

## Layer 4: workflow and analysis

| Package | Description | Relations | Language |
|---------|-------------|-----------|----------|
| [`brms`](https://github.com/paul-buerkner/brms) | Multilevel / distributional regression via formulas; returns `brmsfit` | Generates Stan; backends `cmdstanr` / `rstan` | R |
| [`rstanarm`](https://github.com/stan-dev/rstanarm/) | Precompiled applied regression models; returns `stanreg` | Built on `rstan` | R |
| [`posterior`](https://github.com/stan-dev/posterior/) | Manipulate and summarise draws (R-hat, ESS, etc.) | Shared draws API for `cmdstanr` and analysis packages | R |
| [`bayesplot`](https://mc-stan.org/bayesplot/) | ggplot2 plots for MCMC diagnostics, PPC, posteriors | Uses draws from interfaces / `posterior` | R |
| [`loo`](https://github.com/stan-dev/loo/) | Approximate LOO-CV (PSIS-LOO), WAIC, model weights | Needs pointwise `log_lik` | R |
| [`priorsense`](https://github.com/n-kall/priorsense) | Prior and likelihood sensitivity (power-scaling) | Uses `posterior` | R |
| [`projpred`](https://mc-stan.org/projpred/) | Projection predictive variable selection | Uses `stanreg` or `brmsfit` as reference | R |
| [`shinystan`](https://github.com/stan-dev/shinystan/) | Interactive Shiny GUI for MCMC diagnostics | Uses `stanfit` / `stanreg` | R |
| [`rstantools`](https://github.com/stan-dev/rstantools/) | Tools to ship Stan models inside R packages | Scaffolding used by e.g. `rstanarm` | R |
| [`posteriordb`](https://github.com/stan-dev/posteriordb) | Models, data, and reference posteriors | Shared resource for testing, teaching, CI | R / Python / data |

## The Python / ArviZ stack

ArviZ is no longer one package. Picking the wrong one of the three costs a round
of review.

| Repository | Holds | Your change goes here if |
| :-- | :-- | :-- |
| [`arviz-base`](https://github.com/arviz-devs/arviz-base) | Data structures, `DataTree`/`InferenceData`, converters | You are changing how data is *represented* |
| [`arviz-stats`](https://github.com/arviz-devs/arviz-stats) | Statistics, diagnostics, LOO, metrics | You are computing a *number* |
| [`arviz-plots`](https://github.com/arviz-devs/arviz-plots) | Plots, multi-backend rendering | You are *drawing* something |

`arviz-plots` declares the other two as **git** dependencies, so
`pip install -e` pulls development versions from GitHub rather than PyPI. This
matters when a change spans repositories — see
`stan-python-package-contribution`.

## What a minimal workflow touches

Tracing a single user-facing task through the stack is the quickest way to see
which layer owns what:

1. The user writes `model.stan` and a `data.json`.
2. `cmdstanr` / `cmdstanpy` calls **`cmdstan`**.
3. `cmdstan` invokes **`stanc3`** to transpile the model to C++, then compiles
   and links it against **`math`** (built-in functions, autodiff) and **`stan`**
   (HMC/NUTS).
4. The resulting standalone executable produces draws.
5. **`posterior`** / **`arviz-base`** hold the draws; **`bayesplot`** /
   **`arviz-plots`** plot them; **`loo`** / **`arviz-stats`** score them.

Higher-level frameworks sit on top: `brms` generates and compiles custom Stan
code per model; `rstanarm` ships precompiled programs for common families.
