# Contributing a plot to bayesplot

What differs from the standard R workflow when the contribution is a plotting
function. Based on a real `ppc_curve_overlay()` implementation against
[bayesplot #201](https://github.com/stan-dev/bayesplot/issues/201).

## Contents

- [A plot is a file, a topic, and a `_data()` twin](#a-plot-is-a-file-a-topic-and-a-data-twin)
- [Registration is automatic, but only after document()](#registration-is-automatic-but-only-after-document)
- [vdiffr snapshot tests](#vdiffr-snapshot-tests)
- [Your visual tests will silently skip](#your-visual-tests-will-silently-skip)
- [Snapshots are specific to the machine that wrote them](#snapshots-are-specific-to-the-machine-that-wrote-them)
- [Reviewing a changed snapshot](#reviewing-a-changed-snapshot)
- [Look at your plot](#look-at-your-plot)

## A plot is a file, a topic, and a `_data()` twin

bayesplot groups plots into families. A new family means a new file — say
`R/ppc-curves.R` — with a shared documentation block at the top:

```r
#' PPC curves
#'
#' @name PPC-curves
#' @family PPCs
#'
#' @template args-y-yrep
#' @template return-ggplot-or-data
```

`@template` pulls in a reusable roxygen fragment from `man-roxygen/`. bayesplot
keeps argument documentation there so it stays consistent across dozens of
functions. **Do not retype an argument description that already has a template.**

Nearly every plotting function has a `*_data()` companion returning the data
frame the plot is built from, and it must be exported too:

```r
#' @rdname PPC-curves
#' @export
ppc_curve_overlay_data <- function(y, yrep, x = NULL, ...) {
  check_ignored_arguments(...)

  y <- validate_y(y)
  yrep <- validate_predictions(yrep, length(y))
  x <- validate_x(x, y)

  data <- ppc_data(y, yrep)
  data$x_value <- x[data$y_id]
  # lines are drawn in row order, so sort within each draw
  dplyr::arrange(data, .data$rep_id, .data$x_value)
}
```

Note the `validate_*()` helpers and `check_ignored_arguments()` — bayesplot's
own, used by every plotting function. Use them.

## Registration is automatic, but only after `document()`

`available_ppc()` greps the namespace exports, so no manual registration is
needed — but the export has to exist first:

```r
devtools::document()
"ppc_curve_overlay" %in% available_ppc()
```

```
[1] TRUE
```

If this returns `FALSE`, you have not re-documented since adding `@export`.

## Expect a wide `man/` diff — and check it is the right kind

Declaring `@family PPCs` adds a cross-reference to every other family member:

```
 NAMESPACE                  | 2 ++
 man/PPC-calibration.Rd     | 3 ++-
 man/PPC-censoring.Rd       | 3 ++-
 man/PPC-distributions.Rd   | 3 ++-
 ... 10 PPC-*.Rd files total
```

```diff
 \code{\link{PPC-censoring}},
+\code{\link{PPC-curves}},
 \code{\link{PPC-discrete}},
```

That is correct and must be committed. Family cross-references, yes; hundreds of
reformatted `\link{}` calls, no — that is the roxygen2 version mismatch.

## vdiffr snapshot tests

bayesplot uses [`vdiffr`](https://vdiffr.r-lib.org/) for visual regression
testing: plots are compared against stored SVG snapshots rather than merely
checked for errors. **Any new plotting function, or any change to an existing
plot's appearance, needs one.**

```r
test_that("ppc_curve_overlay renders correctly", {
  testthat::skip_on_cran()
  testthat::skip_if_not_installed("vdiffr")
  skip_on_r_oldrel()

  p_base <- ppc_curve_overlay(vdiff_y, vdiff_yrep)
  vdiffr::expect_doppelganger("ppc_curve_overlay (default)", p_base)
})
```

## Your visual tests will silently skip

Run the file directly and the snapshot tests never execute:

```r
testthat::test_file("tests/testthat/test-ppc-curves.R")
```

```
SKIP: 'test-ppc-curves.R:52:3' -- Reason: On CRAN

[ FAIL 0 | WARN 0 | SKIP 1 | PASS 17 ]
```

`skip_on_cran()` skips unless `NOT_CRAN` is set. `devtools::test()` sets it for
you; calling `testthat` directly does not. Set it yourself instead. This form
works on every platform, and it works from the R console the contributor already
has open:

```r
withr::with_envvar(c(NOT_CRAN = "true"), {
  devtools::load_all()
  testthat::test_file("tests/testthat/test-ppc-curves.R")
})
```

The shell equivalent is shorter, but `VAR=value command` is POSIX syntax. It
works in Terminal on macOS and Linux, and in Git Bash on Windows. It fails in
PowerShell and `cmd.exe`, where the variable is set on its own line
(`$env:NOT_CRAN = "true"`) and the single quotes around the R expression do not
quote anything:

```bash
NOT_CRAN=true Rscript -e 'devtools::load_all(); testthat::test_file("tests/testthat/test-ppc-curves.R")'
```

```
WARNING: Adding new file snapshot: 'tests/testthat/_snaps/ppc-curves/ppc-curve-overlay-default.svg'
WARNING: Adding new file snapshot: 'tests/testthat/_snaps/ppc-curves/ppc-curve-overlay-x-values.svg'
WARNING: Adding new file snapshot: 'tests/testthat/_snaps/ppc-curves/ppc-curve-overlay-y-as-both.svg'
WARNING: Adding new file snapshot: 'tests/testthat/_snaps/ppc-curves/ppc-curve-overlay-y-as-points.svg'

[ FAIL 0 | WARN 4 | SKIP 0 | PASS 21 ]
```

21 passing instead of 17, and four SVGs written. For a *new* plot those warnings
are expected. **Those SVGs are part of your pull request — commit them.**

## Snapshots are specific to the machine that wrote them

A vdiffr snapshot is an SVG, and an SVG records text as glyph positions. Those
positions come from the fonts installed on the machine that rendered the plot.
The same `ggplot` object therefore produces slightly different SVGs on Windows,
macOS, and Linux, and different ones again on two Linux machines with different
font packages.

This has two consequences for a pull request:

- **Snapshots you write are still the right thing to commit.** Write them,
  inspect them, commit them. The point below is about *reading failures*, not
  about withholding files.
- **A failing snapshot in CI may be a font difference, not a bug.** vdiffr is
  built for this: it runs its comparisons only under a controlled font setup, and
  `skip_on_cran()` plus the `skip_on_r_oldrel()` guard in the test above exist so
  that snapshots do not fail on machines nobody controls. If a snapshot the
  contributor did not touch fails on their machine, suspect fonts before
  suspecting the plot.

Say this to the contributor before they open the pull request, especially on
Windows or macOS. A first-time contributor who sees eleven unrelated snapshot
failures locally usually concludes they broke the package and stops.

## Reviewing a changed snapshot

When you change an *existing* plot, `devtools::test()` flags the differing
snapshots. Review them before accepting:

```r
testthat::snapshot_review()
```

This opens a Shiny app showing old vs. new side by side. Only accept a change
that is the one you intended.

## Look at your plot

Tests confirm a `ggplot` object comes back. They do not confirm it is sensible.

A first draft of one documentation example used

```r
yrep <- t(sapply(1:25, function(i) rnorm(1, x^2, 0.1) + x^2))
```

which centres `yrep` on `2x²`. The predictive draws floated far above the
observed data, and every test still passed. Rendering it once caught it
immediately. Render your example and look at it.
