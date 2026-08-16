# Worked example: a new function in posterior

A real contribution to [posterior #238](https://github.com/stan-dev/posterior/issues/238),
labelled `feature` and `good first issue`. Every command and every piece of
output below was actually run.

This shows what the workflow steps look like in practice, including the parts
that went wrong.

> **This is a transcript, not a script.** The commands appear here in the bare
> order they were run, because that is what happened. Do not relay them to a
> contributor that way: the rule in
> [mentor-mode.md](../../stan-contributing/references/mentor-mode.md) holds
> everywhere — say why, then give one command, then read the output together.
> Use this file for what it shows about *judgement* — how the thread was mined
> for the agreed design, what the gotcha turned out to be, what went wrong — not
> as a sequence to replay.

## Contents

- [Step 1: mine the thread for the agreed design](#step-1-mine-the-thread-for-the-agreed-design)
- [Step 5: write the function](#step-5-write-the-function)
- [A gotcha you only find by running it](#a-gotcha-you-only-find-by-running-it)
- [Step 6: document and inspect the diff](#step-6-document-and-inspect-the-diff)
- [Step 7: test](#step-7-test)
- [Step 8: NEWS.md](#step-8-newsmd)
- [Step 10: the pull request description](#step-10-the-pull-request-description)
- [Things that went wrong](#things-that-went-wrong)

## Step 1: mine the thread for the agreed design

The issue body is one sentence:

> It would be nice if there was a `summarise_draws()` helper function along the
> lines of `brms_summary_measures()`, which only returned the typical four
> **brms** summary columns for the mean, SD, and 95% intervals.

That is not enough to start coding. The design is in the comments, where the
maintainers converged on a signature:

> We could have something like
>
> ```r
> brms_summary_measures(robust = FALSE, names = "posterior")
> ```
>
> where `robust` decides on whether we use mean/sd or median/mad. And `names`
> could be either "brms" or "posterior". The reason I prefer "posterior" as
> default is that eventually in brms 3.0, brms names will be aligned with
> posterior names anyway.
>
> — @paul-buerkner

**This is the single highest-value habit.** Implementing what the issue *title*
says instead of what the thread *agreed* is the most common reason a
well-written pull request is sent back. Two maintainers had already discussed
and rejected an alternative here — a `col_name` argument on `summarise_draws()`
itself. Without reading the comments you might build exactly the thing they
turned down.

## Step 5: write the function

`default_summary_measures()`, `default_convergence_measures()` and
`default_mcse_measures()` all live in `R/summarise_draws.R`, so the new function
goes directly below them.

```r
#' @rdname draws_summary
#' @export
brms_summary_measures <- function(robust = FALSE, names = "posterior") {
  robust <- as_one_logical(robust)
  names <- match.arg(names, c("posterior", "brms"))
  point <- if (robust) "median" else "mean"
  spread <- if (robust) "mad" else "sd"
  if (names == "posterior") {
    out <- list(point, spread, ~quantile2(.x, probs = c(0.025, 0.975)))
    out <- stats::setNames(out, c(point, spread, "quantile2"))
  } else {
    out <- list(
      Estimate = point,
      Est.Error = spread,
      # quantile2() names its output after 'probs', so rename to match brms
      Q = ~stats::setNames(
        quantile2(.x, probs = c(0.025, 0.975)), c("Q2.5", "Q97.5")
      )
    )
  }
  out
}
```

Two things here came from reading the existing code rather than guessing:

- `as_one_logical()` is posterior's own internal validator, in `R/misc.R`. Using
  the project's helpers instead of `stopifnot()` is what "follow the style of the
  existing code" means in practice.
- Unlike its siblings, this function returns a **list**, not a character vector,
  because the 2.5%/97.5% quantiles need non-default arguments passed to
  `quantile2()`. Deviating from a sibling's return type is fine when there is a
  reason — but say so in the pull request.

## A gotcha you only find by running it

The documentation for `summarise_draws()` says functions "can be specified in any
format supported by `as_function()`". True — but if you return a *list*, every
element must be named. This fails:

```r
list(mean = "mean", sd = "sd", ~quantile2(.x, probs = c(0.025, 0.975)))
```

```
Error in do.call(funs[[m]], args) :
  'what' must be a function or character string
```

The reason is visible in the source. `summarise_draws.draws()` labels unnamed
arguments by deparsing the call:

```r
calls <- substitute(list(...))[-1]
calls <- ulapply(calls, deparse_pretty)
```

When you pass a single list, `calls` has length 1 while `funs` has length 3, so
the lookup for the unnamed third element runs off the end. Naming every element
avoids it.

Worth mentioning in the pull request — it may deserve its own issue. Reporting a
rough edge you hit while implementing is a contribution in itself.

## Step 6: document and inspect the diff

Add the new parameters to the shared roxygen block, extend `@return`, add
examples, then:

```r
devtools::document()
```

```bash
git diff --stat
```

```
 NAMESPACE                             |  1 +
 R/summarise_draws.R                   | 42 +++++++++++++++++++++++++++++++++++
 man/draws_summary.Rd                  | 24 ++++++++++++++++++++
 tests/testthat/test-summarise_draws.R | 39 ++++++++++++++++++++++++++++++++
 4 files changed, 106 insertions(+)
```

The export appeared automatically:

```diff
 export(bind_draws)
+export(brms_summary_measures)
 export(cdf)
```

## Step 7: test

```r
test_that("brms_summary_measures works correctly", {
  x <- as_draws_df(example_draws())

  sum_x <- summarise_draws(x, brms_summary_measures())
  expect_equal(names(sum_x), c("variable", "mean", "sd", "q2.5", "q97.5"))
  expect_equal(mean(x$mu), as.numeric(sum_x$mean[sum_x$variable == "mu"]))

  sum_x <- summarise_draws(x, brms_summary_measures(robust = TRUE))
  expect_equal(names(sum_x), c("variable", "median", "mad", "q2.5", "q97.5"))

  sum_x <- summarise_draws(x, brms_summary_measures(names = "brms"))
  expect_equal(
    names(sum_x), c("variable", "Estimate", "Est.Error", "Q2.5", "Q97.5")
  )
})

test_that("brms_summary_measures errors on invalid input", {
  expect_error(brms_summary_measures(names = "rstanarm"), "should be one of")
  expect_error(brms_summary_measures(robust = "yes"))
})
```

All four combinations of the two arguments, plus the failure modes. Then the
full suite:

```r
devtools::test()
```

```
[ FAIL 0 | WARN 0 | SKIP 11 | PASS 2040 ]
```

And a by-hand confirmation that the output is what the issue asked for:

```r
x <- example_draws("eight_schools")
summarise_draws(x, brms_summary_measures())
```

```
# A tibble: 10 × 5
   variable  mean    sd    q2.5 q97.5
   <chr>    <dbl> <dbl>   <dbl> <dbl>
 1 mu        4.18  3.40  -2.16   10.2
 2 tau       4.16  3.58   0.174  14.6
 3 theta[1]  6.75  6.30  -2.81   22.7
 ...
```

```r
summarise_draws(x, brms_summary_measures(names = "brms"))
```

```
# A tibble: 10 × 5
   variable Estimate Est.Error    Q2.5 Q97.5
   <chr>       <dbl>     <dbl>   <dbl> <dbl>
 1 mu           4.18      3.40  -2.16   10.2
 2 tau          4.16      3.58   0.174  14.6
 ...
```

## Step 8: NEWS.md

```markdown
# posterior (development version)

### Enhancements

* Add `brms_summary_measures()`, a helper for `summarise_draws()` that returns
the summary measures used by the **brms** package, with `robust` and `names`
arguments to select mean/sd vs. median/mad and posterior vs. brms column
names. (#238)
```

## Step 10: the pull request description

**Title:** `Add brms_summary_measures() helper for summarise_draws()`

**Body:**

> Closes #238.
>
> **Description**
>
> Adds `brms_summary_measures()`, which returns the summary measures used by the
> brms summary output so they can be passed to `summarise_draws()`. It follows
> the signature agreed in the issue thread,
> `brms_summary_measures(robust = FALSE, names = "posterior")`, where `robust`
> selects mean/sd vs. median/mad and `names` selects posterior-style (`mean`,
> `sd`, `q2.5`, `q97.5`) vs. brms-style (`Estimate`, `Est.Error`, `Q2.5`,
> `Q97.5`) column names.
>
> Unlike the neighbouring `default_*_measures()` functions it returns a named
> list rather than a character vector, because the 2.5%/97.5% quantiles need
> arguments passed to `quantile2()`.
>
> **Breaking changes**
>
> None. This only adds a new exported function.
>
> **Tests**
>
> Added `test_that("brms_summary_measures works correctly")` and an input
> validation test to `tests/testthat/test-summarise_draws.R`, covering all four
> combinations of `robust` and `names`. `devtools::test()` passes (0 failures,
> 2040 passing).
>
> **Documentation**
>
> Documented under the existing `draws_summary` topic alongside the
> `default_*_measures()` functions, with examples. `NEWS.md` updated.
>
> **Open questions**
>
> * Every element of the returned list has to be named, otherwise
>   `summarise_draws()` errors with `'what' must be a function or character
>   string` — the `calls <- substitute(list(...))[-1]` lookup indexes past the
>   end for unnamed elements. Should I open a separate issue for that?
> * I kept `names = "posterior"` as the default, per the discussion in the
>   thread.

Note what the "Open questions" section does: it surfaces uncertainty instead of
hiding it. Reviewers prefer that.

## Things that went wrong

Every one of these cost time, and all are ordinary:

1. **Picked a contribution that should not exist.** The first candidate was
   `mcse_var()`. Variance is `sd²`, so it is derivable from the existing
   `mcse_sd()` — a reviewer would rightly close it. *Ask whether the change is
   wanted before asking whether it is correct.*
2. **Picked a "gap" that was a deliberate design.** The first bayesplot
   candidate, `ppc_scatter_avg_vs_x()`, looked conspicuously missing next to
   `ppc_error_scatter_avg_vs_x()`. It is missing because the maintainers
   consolidated those variants into an `x` argument, and the remaining one is
   deprecated. *An asymmetry in an API is often a decision, not an oversight.*
3. **Ran `document()` with the wrong roxygen2 version.** 47 files changed instead
   of 4.
4. **Wrote a plot example that was numerically wrong** but passed every test.
5. **Chased a bug too deep for its purpose.** A rendering bug where a rug plot
   appeared in matplotlib but not plotly turned out to involve plotly's
   open-marker size semantics *and* its default outline width of zero — a
   genuine bug, but fixing it teaches plotly internals, not how to contribute.
   *Scope a first contribution so the workflow is the hard part, not the domain.*
6. **Proposed things that already existed.** CRPS and R² are both already in
   arviz-stats, under names you would not grep for first.

The mechanics — fork, branch, test, push — are the easy part, learnable in an
afternoon. The hard parts are choosing something genuinely wanted, reading the
issue thread properly, and keeping the diff small enough that somebody can
review it.
