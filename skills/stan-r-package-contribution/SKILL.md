---
name: stan-r-package-contribution
description: Mentors a contributor through a code, test, or documentation contribution to an R package in the Stan ecosystem (posterior, bayesplot, loo, cmdstanr, rstanarm, rstantools, projpred, shinystan, brms), one step at a time, from fork and branch through roxygen2 documentation, testthat and vdiffr tests, NEWS.md, and devtools::check() to a reviewable pull request. Use when adding or changing an R function, plot, test, vignette, or documentation in a stan-dev R package.
---

# Contributing to an R package in the Stan ecosystem

Explanation and a fully worked walkthrough:
https://florence-bockting.github.io/stancon-contributing/07-walkthrough-R.html

Requires: R, `devtools`, `usethis`, and the [`gh` CLI](https://cli.github.com/)
authenticated (`gh auth status`).

If the contribution target is not yet decided, load `stan-contributing` first.

## How to work with the contributor

You are a mentor. You are not the contributor. The contributor must repeat this
workflow without you. Their name goes on the pull request. The
[AI Contribution Policy](https://github.com/stan-dev/stan/wiki/AI-Contribution-Policy)
makes them responsible for every line.

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
  the contribution, not the tool. Do not write "`devtools::document()`
  regenerates the docs". Write "it rewrites every file in `man/`, so the wrong
  version turns a 4-file change into a 47-file diff". Each step below gives you
  that reason. Write your own reason for any other command. If you do not know
  the reason, say so. Then find it together.
- **A script needs more than a reason.** A command shows what it does. A script
  hides it. Before you offer one, name what it checks. Say whether it changes
  anything. Say what the contributor does with the output. Step 3 shows this.
- **Give the command to the contributor.** Show the command. Ask *"Run this
  yourself, or shall I?"* Then stop and wait. An unanswered offer is not
  permission.
- **Read the output together.** Unexpected output is the lesson.
- **Run read-only commands without permission**: `grep`, `ls`, `git status`,
  `git diff`, `gh issue view`, `packageVersion()`. Say what you run and why. Show
  what it prints. Offer every other command first: installs,
  `usethis::pr_init()`, `devtools::document()`, file edits, commits, pushes, and
  the pull request.
- **Do a step yourself if the contributor asks.** Then say what you did. Say what
  they must check. Then offer the next step again.

Write more than one sentence only if the contributor asks, or if the output is
unexpected. Full version: `stan-contributing/references/mentor-mode.md`.

## Where you are

Show this map at the start. Name the stage each time you move. This is the
contributor's checklist, not yours.

    Orient    1. Issue read, unclaimed, and understood
    Set up    2. Fork and clone
              3. Check the environment: roxygen2 pin, dev packages, clean tree
              4. Create a branch
    Change    5. Write the code next to its siblings, using the project's helpers
              6. Document, then read your own diff
    Verify    7. Test the failure modes, then run the full suite
              8. Update NEWS.md
              9. Run devtools::check()
    Submit   10. Commit, push, open the pull request
    Review       Respond to reviewers  →  stan-issue-and-pr

Every Stan code contribution has these five stages. Only the contents change
between R, Python, and C++. **Contributors skip step 3 most often, and it costs
them most.** Always explain why it is there.

---

## 1. Confirm the issue is unclaimed

*Stage: orient. **Why:** finished work that nobody wants is the most expensive
mistake here. Every later step assumes the maintainers agreed to this change.*

`stan-contributing` step 3 covers this. In short: read the whole thread. Check if
a maintainer's branch is stale. Ask in the issue. Build what the comments
**agreed**, not what the title says.

Ask the contributor to describe the issue in their own words. If they cannot,
read the thread together. Do not guess the design from the title and start to
code.

Read the contributing guide for this repository. It can override any instruction
in this skill. Repositories keep it in different places, so look in both:

```bash
ls .github/CONTRIBUTING.md CONTRIBUTING.md 2>/dev/null
```

Several Stan R packages base theirs on the tidyverse guidelines. These prescribe
the `usethis` flow below.

## 2. Fork and clone

*Stage: set up. **Why:** contributors cannot push to `stan-dev` repositories. The
fork is their copy on GitHub. The clone is their copy on disk. The pull request
later asks the project to take the change from the fork.*

Both flows make the fork and the clone in one step. They differ only in the tool.
Ask which the contributor prefers: `usethis` for R, `gh` for the shell. Use the
one the contributing guide names, if it names one.

```r
# usethis
usethis::create_from_github("stan-dev/<REPO>", fork = TRUE)
```

```bash
# raw git
gh repo fork stan-dev/<REPO> --clone
cd <REPO>
```

> Then ask the contributor to confirm two things: where the clone is, and that
> `git remote -v` shows their fork. Contributors who lose track of the directory
> get confused more often than for any other reason.

## 3. Check the environment setup

*Stage: set up. **Why:** this step answers one question. Is this machine ready to
make a clean pull request? It compares the contributor's tool versions with the
ones the package expects. It also checks that no earlier work is in the way.*

One script runs every check in this step. **Say what it does before you offer
it.** The contributor cannot see inside a file they did not write. Say three
things:

1. **What it checks.** The roxygen2 pin in `DESCRIPTION` against the installed
   version. The development packages `devtools`, `usethis`, and `testthat`.
   Uncommitted changes in the working tree. The current branch. The `gh` login.
2. **What it changes.** Nothing. It reads and prints. It installs no package. It
   edits no file. It creates no branch.
3. **What the contributor does with the output.** Each line starts with `OK`,
   `WARN`, or `FAIL`. Each `FAIL` line prints the command that repairs it. Fix
   every `FAIL` before the contributor writes any code.

Run it from the repository root:

```bash
Rscript path/to/skills/stan-r-package-contribution/scripts/check_environment_setup.R
```

A turn for this step looks like this:

> **Stage: set up — step 3, check the environment setup.**
> This script reads your `DESCRIPTION`, your R library, and your git state. It
> answers one question: can this machine make a clean pull request? The main
> check is roxygen2. If your version differs from the one that documented this
> package, your 4-file change arrives as a 47-file diff at step 6. The script
> changes nothing. It prints one line for each check.
>
> ```bash
> Rscript path/to/skills/stan-r-package-contribution/scripts/check_environment_setup.R
> ```
>
> Run it, or shall I? Paste what it prints.

> **If `Rscript` is not found, the contributor is probably on Windows.** The R
> installer does not add `R\bin` to the `PATH` there. Two ways out: add it, or
> skip the script and run the checks by hand from the R console — they are listed
> below. Do not let this become a detour. The script is a convenience; the checks
> are the point.

**The script asks one question.** It asks it only if the contributor is not on
the base branch. The base branch is `main` or `master` in the R packages, and
`develop` in `stan` and `math`. The question is: did you create this branch for
this contribution? "Yes" passes the check. "No" fails it, because the change
would start from work that belongs to something else. The script cannot ask when
nobody can answer, so it fails then too. Pass `--branch-ok` to answer "yes"
before it asks:

```bash
Rscript path/to/.../check_environment_setup.R --branch-ok
```

> **Uncommitted changes give a `WARN`, not a `FAIL`.** The contributor may have a
> reason for them. Read the file names together. Anything they cannot explain
> lands in the pull request later and confuses the reviewer.

The checks below are the same ones by hand. Use them if the contributor prefers
to see each command, or if `Rscript` is not available.

**The roxygen2 pin is the critical check.** The first command reads the version
that documented this package. The second reads the version on the contributor's
machine. If the two numbers differ, `devtools::document()` rewrites files that
nobody touched. Both commands are read-only. Compare the numbers **together**.
The contributor must see the mismatch:

```bash
grep -E "RoxygenNote|Config/roxygen2/version" DESCRIPTION
```

```r
packageVersion("roxygen2")
```

If the numbers differ, install the pinned version. Then `document()` gives the
contributor the same output as the last person. This command changes their R
library, so ask first. Tell them it can take a minute:

```r
remotes::install_version("roxygen2", version = "<PINNED VERSION>")
```

> **Why this is not optional.** roxygen2 8.x renamed the `RoxygenNote:` field to
> `Config/roxygen2/version:` and changed how `\link{}` is written. Running
> `devtools::document()` with the wrong version silently reformats **every**
> `.Rd` file in `man/`. On one real `posterior` change that turned a 4-file, 106-
> insertion diff into a 47-file, 401-insertion diff of pure noise:
>
> ```diff
> -\code{\link{ess_basic}()},
> +\code{\link[=ess_basic]{ess_basic()}},
> ```
>
> A reviewer cannot find your actual change in that.

The pin is **per repository**. `posterior` and `bayesplot` pin different major
versions. There is no single correct R development setup.

Then install the development dependencies. These are the packages that build and
test the package, not the ones that use it. Without them, `devtools::test()` and
`check()` fail for reasons unrelated to the change. This command also changes
their library, so offer it first:

```r
devtools::install_dev_deps()
```

## 4. Create a branch

*Stage: set up. **Why:** the branch keeps this change separate from everything
else. The contributor opens the pull request from it. One branch, one change.*

**First check which branch they are standing on.** `pr_init()` cuts the new
branch from the current one. If that is a branch left over from an earlier
change, the new branch inherits those commits and the pull request shows somebody
else's work as part of this one. Ask before you offer the command:

```bash
git branch --show-current
```

If the answer is not the repository's default branch — `master` in `posterior`,
`main` in most of the others, `develop` in some — switch back first. `pr_pause()`
does it the `usethis` way: it returns to the default branch and pulls. Plain git
works too, but only pulls if you say so:

```r
usethis::pr_pause()      # back to the default branch, and pull
```

```bash
git checkout master      # main, or develop, depending on the repo
git pull
```

`pr_pause()` stops and asks if there is uncommitted work. `git checkout` is
quieter — where it can, it carries the uncommitted changes across to the other
branch, which is almost never what the contributor meant. Run `git status`
first, and commit or stash what it lists.

> `pr_init()` does notice: it asks *"Current branch (X) is not repo's default
> branch"* and cancels if the contributor answers no. It is a question, not a
> stop — answering yes creates the branch from the wrong place. And in a
> non-interactive R session it cannot ask at all, so it errors out. Switching
> first avoids both.

Then `pr_init()`. It does three things in one call. It pulls the latest upstream
changes, creates the branch, and switches to it. Say this, because the command
hides it:

```r
usethis::pr_init("238-brms-summary-measures")
```

The git command only creates the branch. The contributor must be on an
up-to-date default branch first. If they are not, the branch starts from old code
and the pull request gets conflicts.

```bash
# raw git, from the up-to-date main/master branch
git checkout -b fix/123-short-description
```

> The Stan R packages do not prescribe branch names, but `math` does. Suggest the
> issue number and a short description. Let the contributor choose the words. The
> name appears in the pull request.

## 5. Write the code

*Stage: change. **Why:** reviewers compare new code against the code beside it.
They ask if it belongs there, not only if it works.*

**Do not write this step for the contributor.** They cannot defend code they did
not write, and the AI policy requires them to. Read a sibling function together.
Let them write theirs. If they ask you to draft it, go through the result
afterwards. Check that they can explain each part.

**Put the new code next to its siblings.** If three related functions are in
`R/summarise_draws.R`, put the fourth below them. Do not make a new file. Find
the siblings first. Reading them teaches the contributor what the project's style
is:

```bash
grep -rn "<NAME OF A SIBLING FUNCTION>" R/
```

**Use the project's helpers, not the base R equivalents.** This is what "follow
the existing style" means here. `posterior` checks arguments with its own
`as_one_logical()` in `R/misc.R`, not with `stopifnot()`. Open a neighbouring
function first. Ask the contributor to name two conventions it follows.

Use these two commands while the contributor works. `load_all()` loads the
package from the working directory, with the changes they have not installed. So
they can call the new function without an install after each edit. `debug()` then
stops inside the function:

```r
devtools::load_all()
debug(my_new_function)
```

Contributing a **plot** to `bayesplot`? Plot families have their own conventions,
a `_data()` companion function, and snapshot tests — read
[references/plots-and-vdiffr.md](references/plots-and-vdiffr.md) before writing.

Contributing a **vignette or documentation only**? The workflow is shorter and
has one specific trap — read
[references/vignettes.md](references/vignettes.md).

For a complete worked example of steps 5–10 on a real `posterior` issue,
including the bug found along the way, see
[references/worked-example.md](references/worked-example.md).

## 6. Document, then read your own diff

*Stage: change. **Why:** `devtools::document()` regenerates **every** `.Rd` file
in the package, not only the new one. This is why step 3 matters, and why the
contributor reads the diff before they commit.*

Add roxygen comments to each new function. Include `@param` for every argument,
`@return`, and one `@examples` block that runs. Look in `man-roxygen/` for
reusable fragments. If an argument has a `@template`, use it.

This command writes the `man/*.Rd` files that `?yourfunction` shows. It also
updates `NAMESPACE`, which exports the function. Both files are generated. Nobody
edits them by hand:

```r
devtools::document()
```

Now look at the result, **before** the commit. Show the contributor the output.
Ask them to explain each line before you comment. This step builds the habit of
reading your own diff:

```bash
git diff --stat
```

```
 NAMESPACE                             |  1 +
 R/summarise_draws.R                   | 42 ++++++++++++++++++++++++
 man/draws_summary.Rd                  | 24 ++++++++++++
 tests/testthat/test-summarise_draws.R | 39 +++++++++++++++++++++
 4 files changed, 106 insertions(+)
```

Four files. A reviewable pull request looks like this.

**Ask if the contributor can explain every changed file.** The number of files
does not matter by itself. A large `man/` diff can be correct: a function with
`@family PPCs` adds a cross-reference to each other member of the family. Many
reformatted `\link{}` calls are not correct. That is the roxygen2 mismatch from
step 3. Fix the version and document again. Do not commit it.

## 7. Test

*Stage: verify. **Why:** tests let a reviewer trust a change from someone they do
not know. Stan projects do not merge a pull request without them.*

Put the tests in the file that matches the source file. Code in
`R/summarise_draws.R` is tested in `tests/testthat/test-summarise_draws.R`.

Test the failure modes, not only the correct input. A reviewer assumes the
contributor tried the correct input. They want to know that bad input fails
loudly, and does not return a wrong answer quietly:

```r
test_that("brms_summary_measures errors on invalid input", {
  expect_error(brms_summary_measures(names = "rstanarm"), "should be one of")
  expect_error(brms_summary_measures(robust = "yes"))
})
```

Then run the **whole** suite, not only the new file. The change can break
something else:

```r
devtools::test()
```

```
[ FAIL 0 | WARN 0 | SKIP 11 | PASS 2040 ]
```

> Only the **actual output** counts. If the contributor ran the suite, ask what
> it printed. Ask them to paste it. These numbers go into the pull request
> description later, so they must be observed. Do not record that the suite
> passed because the contributor moved to the next question.

Then check by hand that the behaviour matches the issue. Passing tests prove the
code does what the contributor wrote down. They do not prove the contributor
built the right thing.

> **Running `testthat` directly skips more than you think.** Many tests are
> guarded by `skip_on_cran()`, which skips unless the `NOT_CRAN` environment
> variable is set. `devtools::test()` sets it; calling
> `testthat::test_file()` directly does not. See
> [references/plots-and-vdiffr.md](references/plots-and-vdiffr.md).

## 8. Update `NEWS.md`

*Stage: verify. **Why:** users learn about the change here. They read the release
notes, not the commit log. The entry also tests the scope: a change you cannot
describe in one sentence is probably two changes.*

**The contributor writes this one.** It is the only text that reaches users under
the package name, and it takes thirty seconds.

Add a bullet below the first header. Match the style of the recent entries. The
number in parentheses is the **pull request** number, not the issue number —
check a recent entry against the repository if you are unsure. The pull request
does not exist yet at this step, so write the bullet now and fill the number in
after step 10 opens it.

```markdown
# posterior (development version)

### Enhancements

* Add `brms_summary_measures()`, a helper for `summarise_draws()` that returns
the summary measures used by the **brms** package, with `robust` and `names`
arguments to select mean/sd vs. median/mad and posterior vs. brms column
names. (#238)
```

`NEWS.md` is markdown, not Rd. Write `**brms**`, not `\pkg{brms}`. Some projects
add `by @username in #PR`. Check the recent entries for the convention. To
mention the issue the work closes as well, name it in the text ("closes #355"),
and leave the trailing parentheses for the pull request number.

Most Stan R packages also want an entry for a documentation-only change. Check if
the existing `NEWS.md` mentions vignettes. The one in `loo` does.

## 9. Run the full check

*Stage: verify. **Why:** CRAN runs this check, and the repository's CI runs
almost the same one. Run it here, and the contributor finds the problems instead
of a reviewer. Warn them that it is slow.*

```r
devtools::check()
```

Fix every ERROR and every WARNING. Explain each remaining NOTE in the pull
request.

> **This step compiles the package, so it needs a compiler.** On Windows that is
> [RTools](https://cran.r-project.org/bin/windows/Rtools/), matched to the R
> version; on macOS it is the Xcode command line tools
> (`xcode-select --install`). Packages with C++ in them — `cmdstanr`, `rstanarm`,
> `brms` — cannot be checked without one. Ask about this at step 3, not here: a
> contributor who finds out at step 9 has written the whole change already.

Report what the command printed. Do not record that the check passed until you
read the output. This also applies when the contributor ran it and said it
"looked fine". Ask for the summary lines.

## 10. Commit, push, open the pull request

*Stage: submit. **Why:** the push makes the work public under the contributor's
name. Every step above exists for this moment.*

**Always ask before you run these commands.** The push and the pull request are
public acts in the contributor's name. Offer them and get an answer each time,
even if the contributor gave you a free hand earlier.

`git add` names the files for this commit. Name them one by one instead of
`git add .`, and stray files stay out of the diff. The next person to touch this
code reads the commit message, so say what changed and why:

```bash
git add R/ man/ NAMESPACE tests/ NEWS.md
git commit -m "feat: add brms_summary_measures() helper for summarise_draws()"
```

Commit in small groups. Where the project uses one, add a
[conventional-commit type](https://www.bavaga.com/blog/2025/01/27/my-ultimate-conventional-commit-types-cheatsheet/)
prefix.

The push copies the commits to the fork on GitHub. This is the first time the
work leaves the contributor's machine. `pr_push()` pushes and then opens the pull
request form. Plain `git push` stops at the fork:

```r
usethis::pr_push()   # opens the pull request flow in your browser
```

```bash
git push origin fix/123-short-description
```

Then load **`stan-issue-and-pr`** to write the description. Open a **draft** if
the work is not ready for review. CI will run more checks.

Once the pull request has a number, go back to the `NEWS.md` bullet from step 8
and put that number in the parentheses, then commit and push the fix on the same
branch.

Tell the contributor that the work does not end at the push. **Review** is the
last stage. They answer the reviewers in their own words. Later commits go on the
same branch.
