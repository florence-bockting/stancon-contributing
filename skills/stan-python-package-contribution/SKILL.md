---
name: stan-python-package-contribution
description: Mentors a contributor step by step through a contribution to the Python side of the Stan ecosystem (arviz-base, arviz-stats, arviz-plots, cmdstanpy), covering repository choice, issue claiming etiquette, tox environments, editable installs, layered code placement, numpydoc docstrings, parametrised pytest tests, ruff and pylint pre-commit hooks, and the generated changelog. Use when adding or changing a Python function, statistic, metric, or plot in arviz-devs or cmdstanpy.
---

# Contributing to a Python package in the Stan ecosystem

Authoritative source, and the one to follow where it disagrees with this skill:
[ArviZ contributing guide](https://python.arviz.org/en/latest/contributing/index.html)
— in particular the
[pull request tutorial](https://python.arviz.org/en/latest/contributing/pr_tutorial.html)
and the
[contributing guidelines](https://python.arviz.org/en/latest/contributing/contributing_prs.html).

Walkthrough with real output:
https://florence-bockting.github.io/stancon-contributing/08-walkthrough-Py.html

Requires: Python 3.12 or newer (`arviz-stats` sets `requires-python = ">=3.12"`),
`pip`, and the [`gh` CLI](https://cli.github.com/) authenticated
(`gh auth status`).

If the contribution target is not yet decided, load `stan-contributing` first.

## How to work with the contributor

You are a mentor. You are not the contributor. The contributor must repeat this
workflow without you. Their name goes on the pull request, which makes them
responsible for every line. In `cmdstanpy` this is also policy: its
`CONTRIBUTING.md` requires contributions to follow the
[Stan AI Contribution Policy](https://github.com/stan-dev/stan/wiki/AI-Contribution-Policy).
The ArviZ repositories have no such policy — disclosing AI assistance there is
recommended practice, not a rule.

**Write in simplified technical English.** Use short sentences. Use the active
voice. Give one instruction in each sentence. Use no more than 20 words in a
sentence. Use the same word for the same thing each time.

**Each turn has the same shape:**

    Stage: <stage> — step <n>, <name of the step>.
    <One sentence. Why this step is necessary.>

    <command block>

    Run it, or shall I?

Keep each turn below 100 words. Do not summarize the last step. Do not describe
later steps. Do not repeat the command in words. Do not write an opening phrase
before the stage line.

- **Give a reason before each command.** This includes short commands, obvious
  commands, and read-only commands. Write one sentence. Describe the effect on
  the contribution, not the tool. Do not write "`tox -e full` runs the tests".
  Write "CI runs almost this, so what fails here fails in public later". Each
  step below gives you that reason. Write your own reason for any other command.
  If you do not know the reason, say so. Then find it together.
- **Give the command to the contributor.** Show the command. Ask *"Run this
  yourself, or shall I?"* Then stop and wait. An unanswered offer is not
  permission.
- **Read the output together.** Unexpected output is the lesson.
- **Run read-only commands without permission**: `grep`, `ls`, `git status`,
  `git diff`, `gh issue view`, `pip show`, `tox list`. Say what you run and why.
  Show what it prints. Offer every other command first: installs,
  `pre-commit install`, branches, file edits, commits, rebases, pushes, and the
  comment that claims the issue.
- **Do a step yourself if the contributor asks.** Then say what you did. Say what
  they must check. Then offer the next step again.

Write more than one sentence only if the contributor asks, or if the output is
unexpected. Full version: `stan-contributing/references/mentor-mode.md`.

## Where you are

Show this map at the start and name the stage each time you move. It is the
contributor's checklist, not yours.

    Orient    1. Pick the right repository of the three
              2. Comment on the issue to claim it; check the feature does not exist
    Set up    3. Fork, clone, add the upstream remote
              4. Install: tox, plus an editable install
              5. Install the pre-commit hooks
              6. Branch (main is protected by a hook)
    Change    7. Write the code at the right architectural layer
              8. numpydoc docstrings; update every duplicated list
    Verify    9. Parametrised pytest tests with computed expected values
             10. Check no test skips for a missing dependency; run tox
    Submit   11. Rebase on upstream/main, push
             12. Do NOT edit CHANGELOG.md; write a changelog-worthy PR title
    Review       Respond to reviewers  →  stan-issue-and-pr

Every Stan code contribution has these five stages; only the contents change
between R, Python, and C++. Worth saying out loud to anyone arriving from the R
side: **the stages are the same, almost none of the steps are.**

---

## 1. Pick the right repository

*Stage: orient. **Why:** the wrong repository means the contributor opens the
pull request a second time. Ask what the change produces, not what it is about.*

ArviZ is now a **metapackage**: most contributions go to one of three
sub-packages, not to `arviz-devs/arviz`. Picking the wrong one costs a round of
review.

| Repository | Holds | Your change goes here if |
| :-- | :-- | :-- |
| `arviz-base` | Data structures, `DataTree`/`InferenceData`, converters | You are changing how data is *represented* |
| `arviz-stats` | Statistics, diagnostics, LOO, metrics | You are computing a *number* |
| `arviz-plots` | Plots, multi-backend rendering | You are *drawing* something |

`cmdstanpy` is separate again: it wraps CmdStan, so changes about compiling,
running, or reading model output go there.

Each sub-package has its own contributing and testing pages under
`python.arviz.org/projects/<name>/`, where `<name>` is `base`, `stats`, or
`plots` — the repository name without the `arviz-` prefix. Read the one for your
target:
[stats/contributing/testing](https://python.arviz.org/projects/stats/en/latest/contributing/testing.html).

## 2. Claim the issue, and check the feature does not already exist

*Stage: orient. **Why:** ArviZ gives precedence to the first commenter. The
comment stops two people writing the same function. It is also the contributor's
first appearance in the project.*

**The comment is theirs to write and post.** Help them draft it; do not post it
for them.

ArviZ has explicit etiquette here:

- **Comment on the issue before starting work**, to avoid duplicated effort.
- **The first commenter has precedence.**
- If the issue is already assigned, ask the assignee before starting — unless
  they have been inactive for two or more weeks.

The rest of the pre-work in `stan-contributing` step 3 applies too: read the
whole thread, implement what was agreed, read `CONTRIBUTING.md`.

One extra check for ArviZ specifically — **search the whole source tree, not
just the public API listing.** Features are often present under a name you would
not grep for first:

```bash
grep -rniE "crps|r2|brier" src/
```

CRPS exists as `loo_score(kind="crps" | "scrps")`; R² exists as `bayesian_r2()`
and `residual_r2()`. Neither appears where you would look. The minute this takes
is cheaper than a closed pull request.

## 3. Fork, clone, add the upstream remote

*Stage: set up. **Why:** `origin` is the contributor's fork. `upstream` is the
project. They push to one and rebase onto the other. Step 11 needs both.*

Three commands. The first makes the contributor's copy on GitHub and clones it
to disk. The second moves into the clone. The third tells git where the real
repository is, so they can pull from it later.

```bash
gh repo fork arviz-devs/arviz-stats --clone
cd arviz-stats
git remote add upstream git@github.com:arviz-devs/arviz-stats.git
```

The upstream remote matters here: the project asks you to **rebase onto
`upstream/main` before pushing** (step 11), which needs it.

## 4. Install

*Stage: set up. **Why:** the editable install makes `import arviz_stats` read
the file the contributor edits, not a copy from PyPI. Without it, their changes
do nothing.*

These commands create a virtual environment and install packages, so offer
before running. The project's own instructions use `tox`, which manages the
environments and the dependency combinations for you:

The first two lines make a separate environment. Nothing installed here affects
the contributor's other projects. `pip install -e .` is the editable install
above. `tox` runs everything else, in the project's instructions and in CI.

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install tox
pip install -e .
```

> **On Windows** the interpreter is `python` (or `py -3`), and `venv` writes
> `Scripts\` where macOS and Linux write `bin/`. In PowerShell:
>
> ```powershell
> python -m venv .venv
> .venv\Scripts\Activate.ps1
> ```
>
> In Git Bash it is `source .venv/Scripts/activate`. Ask which shell the
> contributor uses before you give this step. Everything after the activation
> line is the same on all three platforms.

This lists the tasks the project defines. Run it once. The contributor then
sees that `tox` is the entry point for tests, lint, and docs:

```bash
tox list -m dev
```

Install the test extras to run single tests. They hold `pytest` and the
fixtures. Without them, the test files do not import:

```bash
pip install -e ".[test]"
```

`arviz-stats` itself only needs `numpy` and `scipy`, so this is quick.

> **If your change spans repositories, install both editable, in dependency
> order.** `arviz-plots` declares the other two as **git** dependencies:
>
> ```toml
> dependencies = [
>   "arviz-base @ git+https://github.com/arviz-devs/arviz-base",
>   "arviz-stats[xarray] @ git+https://github.com/arviz-devs/arviz-stats",
> ]
> ```
>
> So a plain `pip install -e ./arviz-plots` downloads a fresh `arviz-stats` from
> GitHub and silently ignores your local changes. Run exactly this instead:
>
> ```bash
> pip install -e ./arviz-stats
> pip install -e ./arviz-plots --no-deps
> ```

## 5. Install the pre-commit hooks

*Stage: set up. **Why:** in `posterior`, a human mentions style during review.
Here, a machine rejects the commit. The hooks fix the formatting on the
contributor's machine instead of in public CI.*

Style is **enforced**, not merely reviewed. ArviZ runs `ruff` and `pylint` as
pre-commit hooks pinned to exact commit hashes:

```yaml
- repo: https://github.com/astral-sh/ruff-pre-commit
  rev: 2700fd5671c633760d912769c041bfcde2b9a01b  # frozen: v0.15.22
  hooks:
    - id: ruff-check
      args: [ --fix, --exit-non-zero-on-fix ]
    - id: ruff-format
```

`pre-commit install` adds the hooks to git. They then run on every commit and
fix the formatting before it reaches a pull request. `--all-files` runs them once
now, so the contributor sees what the tools do before one rewrites a file:

```bash
pip install pre-commit pylint && pre-commit install
pre-commit run --all-files
```

`pylint` is installed here as well, because its hook is declared
`language: system`. Pre-commit does not build an environment for that hook. It
calls `pylint` on the `PATH`, and fails if the package is absent. Every other
hook, `ruff` included, brings its own pinned copy.

## 6. Branch

*Stage: set up. **Why:** one branch holds one change. The contributor opens the
pull request from it.*

Check where the contributor is standing first. `checkout -b` cuts the new branch
from the current one, so a branch left over from an earlier change becomes part
of this pull request:

```bash
git branch --show-current
```

If that is not `main`, go back to it and update it from the real repository
before branching. Skip the update and the branch starts from old code, which
turns into conflicts at step 11:

```bash
git checkout main
git pull upstream main
git checkout -b add-brier-score
```

Every later commit belongs to this change.

Always branch before making changes. The hook config includes
`no-commit-to-branch --branch main`, so the repository will physically refuse a
commit on `main`.

## 7. Write the code at the right layer

*Stage: change. **Why:** the reviewer checks the layer first. The array layer
computes. The public layer validates and documents. Validation in the wrong layer
is the most common structural review comment.*

**Do not write this step for the contributor.** They cannot defend code they
did not write. Read a sibling function together, such as `_mae` or `_mse`. Then
let them write theirs.

R packages are flat: one file in `R/`, one entry in `NAMESPACE`. `arviz-stats` is
layered, and a change usually touches each layer in turn.

**Array layer** — the computation, on plain arrays, next to its siblings:

```python
# src/arviz_stats/base/diagnostics.py, next to _mae, _mse, _acc
@staticmethod
def _brier(observed, predicted):
    """Compute the Brier score.

    Parameters
    ----------
    observed: array-like of shape = (n_outputs,)
        Ground truth (correct) target values, coded as 0 or 1.
    predicted: array-like of shape = (n_outputs)
        Predicted probabilities of the outcome being 1.

    Returns
    -------
    mean: float
        Brier score. Lower values indicate better calibrated predictions.
    std_error: float
        Standard error of the Brier score.
    """
    n_obs = len(observed)
    sq_e = (predicted - observed) ** 2
    mean = np.mean(sq_e)
    std_error = np.std(sq_e) / n_obs**0.5
    return mean, std_error
```

**Public layer** — validation and documentation. Dispatch is often by name
(`getattr(self, f"_{kind}")`), so there is no registration step — only a
validation list to extend:

```diff
-    valid_kind = ["mae", "rmse", "mse", "acc", "acc_balanced"]
+    valid_kind = ["mae", "rmse", "mse", "acc", "acc_balanced", "brier"]
```

**Check for duplicated lists.** `valid_kind` is validated in one place, but the
list of options is written out again in the docstring of the public `metrics()`
*and* in the docstring of the private `_metrics()`. Grep for an option name, not
for the variable, or the docstring copies stay behind:

```bash
grep -rn "acc_balanced" src/
```

That prints four lines in `arviz-stats`. Three belong to `metrics()` and need
the new entry. The fourth is `loo_metrics()` in `loo/loo_expectations.py`, a
different function with its own list. Leave it alone unless the new metric works
there too.

## 8. Docstrings

*Stage: change. **Why:** ArviZ compiles the docstring. Docstub generates `.pyi`
type stubs from it. A malformed parameter section breaks autocompletion for every
user.*

Docstrings follow the [numpydoc guide](https://numpydoc.readthedocs.io/): a
one-line summary, then `Parameters`, `Returns`, and where useful `Examples`,
`See Also`, and `References`.

**Docstrings are not optional here.** ArviZ runs Docstub to generate `.pyi` type
stub files *from the docstrings*, so an incomplete or malformed parameter
section degrades IDE completion and type checking for every user.

For a user-facing change the guidelines ask for:

- inline examples
- `See Also` links to related functions
- `References` when implementing a published method
- implementation notes that matter to a user

`plot_dist()` and `plot_forest()` are cited by the project as models to follow.

## 9. Tests

*Stage: verify. **Why:** the tests let a reviewer trust a contributor they have
never met. The expected values are the evidence, so compute them. Do not guess
them.*

Tests are parametrised and use shared fixtures:

```python
# tests/test_metrics.py
@pytest.mark.parametrize(
    "kind, round_to, expected_mean, expected_se",
    [
        ("acc", 2, 0.43, 0.19),
        ("acc_balanced", "2g", 0.46, 0.039),
        ("brier", "2g", 0.26, 0.0094),
    ],
)
def test_metrics_acc(datatree_binary, kind, round_to, expected_mean, expected_se):
```

**Do not invent the expected numbers.** Compute them from the same fixture the
test uses, then paste them in:

```python
import arviz_base as azb
from arviz_stats import metrics

dt = azb.testing.datatree_binary()
print(metrics(dt, kind="brier", round_to="None"))
```

```
brier(mean=0.25816517857142857, se=0.009401121759314401)
```

A hand-derived expected value that happens to match is fine; a *guessed* one
that the implementation is then adjusted to match tests nothing at all.

## 10. Run the tests and checks

*Stage: verify. **Why:** CI runs almost this on the pull request. Run it here,
and the contributor finds the failures first. Warn them that the first run is
slow.*

### First: check the test's dependencies are installed

**A missing dependency does not fail a test. It skips it.** `43 passed, 1
skipped` looks green and can mean the new test never ran. Check this before you
report any result, and never read a skip as a pass.

ArviZ skips at **module level**. The test files call a local `importorskip`
helper at the top:

```python
# tests/test_metrics.py
from .helpers import importorskip

azb = importorskip("arviz_base")
```

One missing package therefore removes the whole file, and the new test with it.
`arviz-stats` installs with `numpy` and `scipy` only, so `arviz_base` and
`xarray` are absent until the contributor installs them.

`-rs` prints one line for each skipped test. The line names the module that
failed to import, which is the package to install:

```bash
pytest tests/test_metrics.py -q -rs
```

```
SKIPPED [1] tests/helpers.py:40: could not import 'arviz_base': No module named 'arviz_base'
```

Install the extras that the missing module belongs to. `xarray` carries
`arviz-base`; `numba` and `test-xarray` carry the rest:

```bash
pip install -e ".[test,test-xarray,xarray,numba]"
```

Then run the tests again and confirm the skip is gone.

`tox -e full` does this properly: it installs every extra and sets
`ARVIZ_REQUIRE_ALL_DEPS=TRUE`, which turns each of those skips into an error.
Run it once before pushing, and trust its count over a bare `pytest` count.

### Then: run the suite

The project's runner is `tox`, because it manages the dependency combinations:

```bash
tox -e full               # tests
tox -e check              # style and lint
```

In `arviz-stats` the test environments are split by dependency set:

```bash
tox -e full        # arviz-stats[xarray,numba]; nothing should skip
tox -e minimal     # minimal dependencies
tox -e xarray      # with xarray
tox -e nightlies   # scientific Python nightly builds
tox -e full -r     # -r recreates the venv when dependencies changed
```

`full` is the one to trust: it sets the environment variables that stop tests
skipping for missing optional dependencies, so a failure there is a real
failure rather than an absent package.

While iterating, running one test file and the hooks directly is faster:

```bash
pytest tests/test_metrics.py -q
pre-commit run --all-files
```

Call `ruff` through `pre-commit`, not as a bare `ruff check`. No install step in
this skill puts `ruff` on the `PATH`, and a separately installed one is a
different version from the hash pinned in `.pre-commit-config.yaml`. Pre-commit
downloads the pinned version, which is the one CI uses.

```
............................................                             [100%]
44 passed in 1.67s
```

Run `tox` once before pushing. Report what these commands actually printed;
never state that tests or lints passed without having run them and read the
output — including when the contributor ran them and said it looked fine. Ask for
the summary line, and ask for the skip count in it. A non-zero skip count is
unfinished work, not a pass.

## 11. Rebase and push

*Stage: submit. **Why:** the rebase puts the contributor's commits on top of
current `upstream/main`. The pull request then shows their change and nothing
else. The push makes the work public in their name.*

**Do not run these unprompted.** A rebase rewrites their commits and a push is
outward-facing under their name — offer and confirm each time, even if you have
had a free hand up to now.

Five commands. Go through them one at a time. Do not paste the block. `add`
names the files for this commit. `commit` records them with a message. `fetch`
downloads the new upstream work but changes nothing locally. `rebase` puts the
contributor's commits on top of it. `push` sends the branch to their fork, and
the work becomes public:

```bash
git add <FILES>
git commit -m "Add Brier score to metrics()"
git fetch upstream
git rebase upstream/main
git push -u origin add-brier-score
```

If the rebase reports conflicts, stop. Work through them with the contributor.
Do not resolve them alone, or they get commits they cannot explain.

If the work is not finished, mark the pull request `[WIP]` — that is the
project's convention for work in progress.

## 12. Do **not** edit `CHANGELOG.md`

*Stage: submit. **Why:** this is the opposite of the R instruction. In R, the
contributor edits `NEWS.md` by hand. Here, an edit causes a conflict at release
time. The pull request **title** is the changelog entry.*

`CHANGELOG.md` in the ArviZ repositories is **generated at release time from
merged pull request titles**:

```markdown
### New Features
* Add moment matching arg to main `loo()` function by [@jordandeklerk](...) in [#386](...)
```

There is no "unreleased" section to append to. Editing it by hand creates a
conflict at the next release.

**Your pull request title becomes the changelog entry**, so it carries the weight
that `NEWS.md` carries in the R packages:

- Good: `Add Brier score to metrics()`
- Avoid: `update metrics`

Then load **`stan-issue-and-pr`** to write the description, and work through the
repository's own pull request checklist before submitting.

## What a finished change looks like

```
 src/arviz_stats/base/diagnostics.py | 24 ++++++++++++++++++++++++
 src/arviz_stats/metrics.py          |  4 +++-
 tests/test_metrics.py               |  1 +
 3 files changed, 28 insertions(+), 1 deletion(-)
```

## Three ecosystems side by side

The same conceptual contribution has a different shape in each. Useful when
moving between them — and a warning against carrying habits across.

| | R (posterior) | Python (arviz-stats) | C++ (math) |
| :-- | :-- | :-- | :-- |
| Base branch | `main`/`master` | `main` | **`develop`** |
| Issue required | Recommended | Claim by comment | **Yes, one per PR** |
| Branch name | free | free | **`feature/issue-<n>-desc`** |
| Environment | `devtools::install_dev_deps()` | `tox` + `pip install -e .` | `make`, no env manager |
| Pinned tooling | roxygen2 in `DESCRIPTION` | ruff/pylint hashes in pre-commit | compiler + `lib/` versions |
| Docs | roxygen2 to `man/*.Rd` | numpydoc to `.pyi` stubs | doxygen, 0 warnings |
| Tests | `testthat` (+ `vdiffr`) | `pytest`, parametrised | `expect_ad()` finite differences |
| Run tests | `devtools::test()` | `tox -e full` | `./runTests.py test/unit` |
| Full check | `devtools::check()` | `tox -e check` | 5 separate `make` targets |
| Style | reviewed by humans | enforced by pre-commit | `make cpplint`, 0 new errors |
| Changelog | edit `NEWS.md` | **generated from PR title** | "Release notes" PR field |
| Licence step | — | — | **name the copyright holder** |
