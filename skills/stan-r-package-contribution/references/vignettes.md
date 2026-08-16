# Contributing a vignette or documentation change

Documentation contributions are the easiest way to start. Based on a real
section added to `loo`'s `vignettes/loo2-example.Rmd`.

## What you can skip

A vignette change touches `vignettes/*.Rmd` and nothing else:

- No `NAMESPACE` entry — nothing is exported
- No `devtools::document()` — there is no roxygen block
- No unit test — there is no function to test

The review is about correctness and clarity of prose, not about code structure.
That does **not** make it a lower-effort contribution: the prose has to be right.

## Vignettes usually do not run

Vignettes that fit real models are far too slow for CRAN, so they are guarded.
In `loo`, in the YAML header:

```yaml
params:
  EVAL: !r identical(Sys.getenv("NOT_CRAN"), "true")
```

and in a shared knitr child file:

```r
opts_chunk$set(
  eval = if (isTRUE(exists("params"))) params$EVAL else FALSE,
  ...
)
```

So **every chunk is `eval = FALSE` unless `NOT_CRAN=true`**. If you render
normally, your new chunk produces no output and you have verified nothing.

Set the variable, then render. This form works on every platform, from the R
console:

```r
withr::with_envvar(c(NOT_CRAN = "true"), {
  rmarkdown::render("vignettes/loo2-example.Rmd")
})
```

The shell one-liner below does the same thing, but `VAR=value command` is POSIX
syntax: macOS, Linux, and Git Bash on Windows. It does not work in PowerShell or
`cmd.exe`:

```bash
NOT_CRAN=true Rscript -e 'rmarkdown::render("vignettes/loo2-example.Rmd")'
```

```
...
24/33 [loo2]
26/33 [plot-loo2]
28/33 [reloo]
33/33
Output created: loo2-example.html
```

This refits every model in the vignette. It takes minutes, not seconds. Budget
for it.

Check the guard mechanism in the specific repository before assuming it matches
`loo`'s — grep the vignette header and any child `.Rmd` files it includes.

## Write against what the reader can already see

Reuse objects the vignette has already computed. A new section that builds on an
existing `loo1` object costs nothing extra to run and stays consistent with the
surrounding text. Introducing a fresh model fit for one paragraph adds minutes to
every render, forever.

## Verify every function and link you mention

Draft prose is where invented APIs creep in. Check names against the actual
namespace before writing them:

```bash
grep -oE "^export\([^)]*\)" NAMESPACE | grep -iE "kfold|moment|pareto"
```

```
export(kfold)
export(loo_moment_match)
export(pareto_k_ids)
export(pareto_k_influence_values)
export(pareto_k_table)
export(pareto_k_values)
```

While drafting the `loo` section, a plausible-sounding `loo_mixis()` turned out
not to exist — the mixture-importance-sampling vignette exports no function by
that name. The text linked the vignette by title instead.

The same applies to URLs and cross-vignette links. Check them.

## Structure that reviews well

The `loo` section that worked was organised as: what the diagnostic *means*,
then how to tell the two common causes apart, then remedies **in increasing
order of cost** — more draws, moment matching, mixture importance sampling,
`kfold()` — each linking to the vignette that covers it.

Naming the cheap fix first is a real service to the reader, and it is the kind
of ordering decision a reviewer will notice.

## Still update `NEWS.md`

Some projects skip changelog entries for documentation. `loo` does not — its
`NEWS.md` mentions vignettes repeatedly. Check the file before deciding.

```markdown
* Add a section to the _Using the loo package_ vignette describing what to do
when the Pareto $k$ estimates are too high, covering `pareto_k_ids()`, moment
matching, mixture importance sampling, and `kfold()`.
```

## Rendering as part of the check

Confirm the vignette builds cleanly before opening the pull request:

```r
devtools::build_vignettes()
```
