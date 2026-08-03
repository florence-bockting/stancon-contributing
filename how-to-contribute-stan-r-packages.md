# How to Contribute to Stan's R Packages

*A practical guide for new and advanced contributors, focused on the R side of the Stan ecosystem: `cmdstanr`, `rstan`, `rstanarm`, `bayesplot`, `loo`, `posterior`, `priorsense`, `projpred`, `shinystan`, `rstantools`.*

This guide combines what the Stan-dev repositories themselves say about contributing (their `CONTRIBUTING.md` files, READMEs, and the `stan-dev/stan` Developer Process wiki) with general good-practice guidance from the open-source and research-software-engineering community (Open Source Guides / GitHub, The Carpentries, CodeRefinery, Software Sustainability Institute / RSE communities, rOpenSci).

---

## 1. Why a Separate Guide for the R Packages?

The C++/OCaml core (`math`, `stanc3`, `stan`, `cmdstan`) follows a fairly heavyweight **GitFlow** process with mandatory continuous-integration gates and a formal design-doc process for major changes. The R packages are lighter-weight, standard **R-package-development workflows** built around `devtools`, `testthat`, `roxygen2`, and CRAN release conventions — closer to what you'd find in any well-run rOpenSci or tidyverse-adjacent package. If you're a statistician, applied researcher, or R developer rather than a systems/compiler person, the R packages are usually the easiest entry point into the Stan ecosystem.

All of the R packages, however, share the same **community norms**: open an issue before large changes, keep pull requests focused, add tests and documentation, and update `NEWS.md`. That common core is what this guide documents.

---

## 2. Types of Contributions — and How the Process Differs

Not all contributions are "write code." Recognizing which type you're making tells you how much process to expect.

| Type | Examples | Typical entry point | Process weight |
|---|---|---|---|
| **A. Bug report** | "`mcmc_trace()` errors on a `draws_rvars` object" | GitHub issue | Low — just needs a clear, reproducible report. No PR required. |
| **B. Documentation fix** | Typo, unclear `@param`, broken link, missing example | Direct small PR (often no issue needed) | Low — usually merged quickly after a light review. |
| **C. Small bug fix** | One-line logic fix, edge-case handling | Issue (if not already reported) → PR | Low–medium — needs a regression test and a `NEWS.md` entry. |
| **D. New feature / new function** | A new `ppc_*()` plot, a new `loo_*()` diagnostic | **Discuss first**: open an issue or post on the Stan Forums *before* writing code | Medium–high — needs design discussion, docs, tests, vignette updates, and maintainer buy-in on scope. |
| **E. API-breaking change** | Renaming an exported function, changing default behavior | Issue + explicit discussion with maintainers, often flagged for a major version | High — needs a deprecation path (see `lifecycle`-style warnings), changelog entry, and sometimes a design note similar to `stan-dev/design-docs`. |
| **F. Cross-package change** | A change to `posterior`'s draws format that other packages rely on | Issue in the "hub" package + downstream awareness (`bayesplot`, `loo`, `cmdstanr`, `rstanarm` all consume `posterior`) | Highest — needs coordination across maintainers, since a change ripples through the dependency graph described in the ecosystem guide. |
| **G. Non-code contributions** | Answering questions on Discourse, improving vignettes/case studies, triaging issues, reviewing others' PRs, translating error messages, adding a `good-first-issue` label | Directly on the forum/issue tracker | Low — no coding required, and this is explicitly one of the most valuable and under-supplied contributions. |
| **H. New downstream package** | Building a new package on top of Stan (à la `rstanarm`/`brms`) | `rstantools` scaffolding + Stan Forums "Developers" category | Separate track — you're a *user* of the Stan build tooling, not a contributor to the `stan-dev` repos, though the same code-quality norms apply if you want it listed as a Stan-dev-adjacent package. |

**Rule of thumb:** the smaller and more clearly-scoped the change (typo, one-line bug fix), the more acceptable it is to just open a PR directly. The larger or more opinionated the change (new feature, changed default, new dependency), the more important it is to **discuss before you code** — this is true across virtually all serious open-source projects, not just Stan, and is the single most common way first-time contributors waste effort (see Pitfalls, §5).

---

## 3. The Contribution Process, Step by Step

This section merges the concrete Stan-dev instructions with general good practice.

### Step 0 — Get oriented (before touching code)

- Read the package's `README.md` and `CONTRIBUTING.md` (present in `bayesplot`, `loo`, `cmdstanr`, `posterior`, and most other Stan-dev R repos).
- Skim `NEWS.md` for the last few releases to understand current direction and terminology.
- Check the **issue tracker** for `good-first-issue` / `help-wanted` labels, and search (don't just skim) both open and *closed* issues/PRs to avoid duplicating past discussion.
- Join the [Stan Forums](https://discourse.mc-stan.org) (tag: *Developers*) and/or Stan Slack — this is the primary place for design discussion, not GitHub issues alone.
- Judge project health/receptiveness the way the Open Source Guides recommend: are issues/PRs getting closed/merged? Are maintainers responsive and friendly? (For the Stan R packages: yes, actively — `jgabry`, `avehtari`, `andrjohns`, `mitzimorris`, and others review regularly.)

### Step 1 — Open (or find) an issue first

For anything beyond a trivial typo fix: **open an issue describing the problem or proposal before writing code.** This lets a maintainer say "yes, do this" or "actually we tried that, here's why it doesn't work" *before* you invest hours in a PR that gets rejected. Comment on the issue to claim it, so two people don't duplicate work.

### Step 2 — Set up your environment

- Fork the repository, clone your fork.
- Install package dependencies, typically via `devtools::install_deps(dependencies = TRUE)`.
- For packages that wrap Stan itself (`cmdstanr`), you'll also need a working CmdStan installation and C++ toolchain — check the package's "Getting started" vignette.
- Load the package for development with `devtools::load_all()` rather than repeatedly reinstalling.

### Step 3 — Create a branch

- Never work directly on `master`/`main`/`develop`.
- Use a descriptive branch name tied to the issue, e.g. `fix/123-ppc-trace-error` or `feature/new-loo-plot` (the Stan core repos formalize this as `bugfix/issue-#-description` / `feature/issue-#-description`; the R packages are more relaxed but the same spirit applies).

### Step 4 — Make focused changes

- **One conceptual change per PR.** If you notice an unrelated bug while fixing your issue, open a *separate* issue/PR for it rather than bundling — bundled PRs are slower to review and harder to revert if something goes wrong. This is explicit Stan core-repo guidance and general good practice everywhere (CodeRefinery, Software Carpentry).
- Follow the existing code style. Most Stan R packages broadly follow the **tidyverse style guide** (snake_case function names, `<-` for assignment, 80-character lines) — look at surrounding code and match it rather than introducing a new style.
- Write **roxygen2** documentation for any new/changed exported function (`@param`, `@return`, `@examples`); several packages (e.g. `loo`) explicitly ask for Markdown-formatted roxygen (`@md` / `Roxygen: list(markdown = TRUE)`).
- Add or update **tests** (`testthat`) covering the new behavior and the specific bug you fixed — a regression test that fails before your fix and passes after is the gold standard.
- Update **`NEWS.md`** with a one-line, user-facing description of the change, referencing the issue/PR number and your GitHub handle (this is the convention visible throughout `bayesplot`'s and `loo`'s changelogs).

### Step 5 — Test locally before pushing

- Run the full test suite: `devtools::test()`.
- Run `devtools::check()` (or `R CMD check`) to catch documentation, namespace, and CRAN-policy issues — this is what the continuous-integration bots will run anyway, so catching problems locally saves review round-trips.
- For plotting packages (`bayesplot`), check that visual outputs actually look right, not just that code runs without erroring.
- If your change affects a package other Stan packages depend on (e.g. `posterior`), consider whether downstream packages still pass their tests against your branch.

### Step 6 — Open the pull request

- Push your branch and open a PR against the correct base branch (check whether the repo uses `master`/`main` directly or a `develop` branch — this varies across Stan-dev repos, unlike the core C++ repos which uniformly use GitFlow).
- Write a clear PR description: what problem this solves, how you solved it, and how you tested it. Link the issue (`Closes #123`).
- Keep the diff as small as reasonably possible — reviewers can meaningfully review ~200–400 lines in one sitting; much more than that and quality of review drops sharply (a well-documented effect in software-engineering research on code review).

### Step 7 — Continuous integration and review

- CI (GitHub Actions in these repos) must pass before a human seriously reviews the PR — "if the code doesn't pass tests, it probably won't get reviewed" is explicit Stan guidance and holds informally for the R packages too.
- A maintainer will review for: correctness, test coverage, documentation, and idiomatic style. Expect **constructive but direct feedback** — this is normal open-source code review, not personal criticism.
- Respond to every comment (even just "done" or "good point, fixed"), push follow-up commits to the same branch (don't open a new PR), and re-request review when ready.
- Be patient: maintainers are often unpaid or juggling many responsibilities. If there's no response after a week or two, a polite ping on the PR (or an `@mention` of a relevant maintainer) is appropriate and expected — not rude.

### Step 8 — Merge and beyond

- Once approved and CI is green, a maintainer merges (contributors typically don't self-merge).
- Delete your branch; sync your fork with upstream.
- For a first-time contributor: celebrate — and consider looking for another `good-first-issue`, or "leveling up" to reviewing other newcomers' PRs, which is itself a high-value, low-friction contribution.

---

## 4. What a Good Issue Looks Like

A good issue does most of the reviewer's diagnostic work for them. The official Stan guidance ("About the Stan Project" page) is explicit: provide as much context as possible, ideally a **small reproducible example**, the **complete error message**, **version information**, and your **compute environment**. Below are two annotated examples for the R packages.

### Example A — a good bug report

> **Title:** `mcmc_trace()` errors on `draws_rvars` objects from `posterior`
>
> **Body:**
> ```
> ### What I'm trying to do
> Plot a trace plot directly from a `posterior::draws_rvars` object returned by cmdstanr.
>
> ### What happens
> `bayesplot::mcmc_trace()` throws an error instead of producing a plot.
>
> ### Reproducible example
> ```r
> library(cmdstanr)
> library(bayesplot)
>
> fit <- cmdstanr_example("logistic")   # ships with cmdstanr
> draws <- fit$draws(format = "draws_rvars")
> mcmc_trace(draws, pars = "beta[1]")
> ```
>
> ### Error message
> ```
> Error in as.array.default(x) :
>   'list' object cannot be coerced to type 'double'
> ```
>
> ### Expected behavior
> Either a trace plot, or a clear error telling me to convert to `draws_array` first.
>
> ### Session info
> - bayesplot 1.11.1, posterior 1.5.0, cmdstanr 0.7.1
> - R 4.3.2, macOS 14.2
>
> ### What I've already checked
> Confirmed `mcmc_trace()` works fine if I first call `posterior::as_draws_array(draws)`, so this looks like a missing conversion/format check rather than a deeper bug.
> ```

**Why this works:** minimal, self-contained, and runnable (uses a built-in example model rather than the reporter's own private data); shows the exact error; states what was expected; includes version/environment info; and — crucially — shows the reporter already did some homework (tested a workaround), which both narrows the diagnosis and signals good faith to the maintainer.

### Example B — a good feature request

> **Title:** Add a `ppc_ecdf_overlay()`-style function that also reports the LOO-PIT
>
> **Body:**
> ```
> ### Problem
> Right now, checking calibration via LOO-PIT requires calling `loo::psis()`
> myself and manually feeding weights into `ppc_loo_pit_overlay()`. For users
> following the Bayesian Workflow book's calibration-checking pattern, this is
> a common enough task that it might deserve a convenience wrapper.
>
> ### Proposed solution
> A function `ppc_loo_pit_ecdf()` that takes `y`, `yrep`, and an `loo` object
> directly and produces an ECDF-difference plot (as recommended in Säilynoja
> et al. 2022) instead of the density-overlay version.
>
> ### Alternatives considered
> Could be a vignette instead of new code — happy to help write either.
>
> ### Willing to implement
> Yes, if this fits the package's scope — would appreciate a quick "go ahead"
> before I put together a PR.
> ```

**Why this works:** states the *problem* before the *solution* (so a maintainer can push back on the framing, not just the implementation); proposes something concrete but stays open to a lighter-weight alternative (a vignette); and explicitly asks for a green light before investing time in code — exactly the "discuss before you code" norm from §2 and §5.

**Anti-example (what to avoid):** *"mcmc_trace doesn't work, please fix"* — no reproducible example, no error message, no version info. This forces the maintainer to do all the diagnostic work themselves and is a common reason issues sit unanswered for a long time.

---

## 5. What a Good Pull Request Description Looks Like

A good PR description lets a reviewer understand *what changed and why* before they read a single line of diff, and shows the reviewer that testing has already been done — so their job is verification, not investigation.

### Example — a good PR description

> **Title:** Fix `mcmc_trace()` error on `draws_rvars` input (#412)
>
> **Body:**
> ```
> ## What this does
> Adds an automatic conversion step so `mcmc_trace()` (and the other MCMC-*
> functions that call the shared `merge_chains()` helper) accept
> `posterior::draws_rvars` objects instead of erroring, matching the
> behavior already documented for `draws_array`/`draws_df`/`draws_matrix`.
>
> ## Why
> Closes #405. `draws_rvars` is one of the four supported formats returned
> by cmdstanr's `$draws()` method, but bayesplot's internal converter never
> handled it, so users hit an opaque coercion error instead of a plot.
>
> ## How I tested it
> - Added a regression test in `test-mcmc-trace.R` that reproduces the
>   original error and checks the fix (`test_that("mcmc_trace accepts
>   draws_rvars", ...)`)
> - Ran the full suite locally: `devtools::test()` — all passing
> - Ran `devtools::check()` — 0 errors, 0 warnings, 0 notes
> - Manually confirmed the resulting plot is visually identical to the
>   equivalent `draws_array` input
>
> ## Scope / what this does *not* do
> This PR only touches the shared conversion helper used by the `mcmc_*`
> family, not the `ppc_*` family, which has a separate (already-working)
> conversion path. I did not change any public function signatures.
>
> ## Checklist
> - [x] Tests added/updated
> - [x] Documentation updated (roxygen `@param` note added to
>       `mcmc_trace()` mentioning supported formats)
> - [x] `NEWS.md` entry added
> - [x] No AI-generated code in this PR / [or: AI-assisted, see disclosure
>       below — see §6]
> ```

**Why this works:**
- **Title** is specific and references the issue number.
- **"What"** and **"Why"** are separated — a reviewer can sanity-check the *reasoning* independently from the *implementation*.
- **"How I tested it"** does the reviewer's verification legwork for them, the single biggest lever for getting a PR reviewed quickly.
- **"Scope"** explicitly draws a boundary — this heads off "why didn't you also fix X" comments and signals the change is intentionally small (§5, Step 4).
- A short **checklist** mirrors the one at the end of this guide and makes it trivial for the reviewer to see nothing was skipped.

**Anti-example (what to avoid):** *"Fixes the bug"* with no description, or a PR that silently fixes three unrelated things at once with no explanation of which lines address which problem. Both dramatically slow down review, since the reviewer now has to reverse-engineer intent from the diff.

---

## 6. Using AI Assistance When Contributing

Generative AI / LLM coding assistants (Claude, Copilot, ChatGPT, Cursor, etc.) are now a normal part of many contributors' workflows — including, likely, for drafting issues, writing tests, or getting unstuck on an API. Stan has an explicit, org-wide **AI Contribution Policy** (effective May 2026, covering all `stan-dev` repositories including the R packages), built on three principles:

### 6.1 The Stan AI Contribution Policy, in brief

1. **Human accountability.** Every PR must be submitted by a **named, accountable individual**. Fully automated or autonomous ("agentic") submissions — i.e., a bot opening PRs with no human named as responsible for the content — are **not accepted**.
2. **Licensing and copyright.** Every contributor still needs to agree to the **Developer Certificate of Origin (DCO) 1.1**, certifying they have the right to submit the code under the project's open-source license — *regardless of how the code was produced*. It's the contributor's responsibility to make sure AI-assisted output doesn't carry incompatible licensing (e.g., code an LLM reproduced near-verbatim from a differently-licensed codebase).
3. **Mandatory disclosure.** Contributors **must disclose** whether AI tools were used in preparing a contribution. If AI was used, the contributor **affirms they have reviewed and understood the code**, and can **explain and defend their changes during review** — the AI having written a line is never an acceptable answer to "why did you do it this way?"

(Full policy: [github.com/stan-dev/stan/wiki/AI-Contribution-Policy](https://github.com/stan-dev/stan/wiki/AI-Contribution-Policy). This is an org-level Stan policy, so it applies to `bayesplot`, `loo`, `posterior`, `cmdstanr`, etc. just as much as to the C++ core — check each repo's own `CONTRIBUTING.md` for whether it adds anything more specific.)

This mirrors what's becoming standard across serious open-source projects: a recent empirical survey of 1,000 popular GitHub repositories found that roughly three-quarters of projects with an AI policy *allow* AI-assisted contributions, about half require disclosure, and about three-quarters require a human genuinely "in the loop" rather than an autonomous agent. Stan's policy sits squarely in that mainstream: **permissive, but not a rubber stamp.**

### 6.2 What this looks like in practice

**Good uses of AI assistance** (broadly welcomed, low risk):
- Drafting/tightening an issue or PR description for clarity (as long as the technical content is accurate and you can defend it).
- Getting unstuck on an unfamiliar API, understanding an error message, or asking "what does this existing function do" while reading code.
- Generating a first draft of boilerplate — e.g. a `testthat` test skeleton, roxygen documentation scaffolding — that you then read, correct, and verify.
- Using AI as a **code-review assistant on your own draft** before you open the PR (a second pair of eyes catching obvious issues), not as a replacement for your own understanding.

**Riskier / discouraged uses:**
- Pasting a whole issue into an agent and submitting whatever comes out without running it, reading it, or understanding it — this fails the "review and understood" and "explain and defend" requirements up front.
- Letting an autonomous agent open PRs unsupervised — explicitly excluded by the "human accountability" clause.
- Using AI-generated code you can't explain when a reviewer asks a follow-up question — this is the fastest way to lose a maintainer's trust, and directly violates the disclosure clause's intent.
- Assuming AI-suggested statistical code is correct without checking it against the actual math — LLMs are well known to confidently produce plausible-looking but wrong numerical/statistical code (e.g., subtly wrong Pareto-k thresholds, incorrect indexing in log-density calculations), which is exactly the kind of error unit tests and human review exist to catch.

### 6.3 How to disclose AI use in a PR

There's no single mandated phrasing, but a short, honest note is enough — for example, at the end of a PR description:

> **AI disclosure:** Used Claude to draft the initial `testthat` test skeleton and to help debug an indexing error in the C++ boundary; all code reviewed, understood, and modified by me before submission.

or, if none was used:

> **AI disclosure:** No AI tools were used in preparing this contribution.

Either line takes ten seconds to write and directly satisfies the policy's transparency requirement — treat it the same way you'd treat noting a co-author.

### 6.4 Why this matters for a statistics-heavy project like Stan

Stan's packages sit downstream of subtle numerical and statistical correctness (e.g., PSIS-LOO diagnostics, R-hat computation, HMC internals) where a plausible-but-wrong AI suggestion is genuinely dangerous — it can look completely reasonable in a diff and still be statistically incorrect. This is a large part of *why* the disclosure-and-accountability framing matters more here than in, say, a UI tweak to a web app: the bar isn't "did the code run," it's "do we understand exactly what it computes and why it's correct," and that understanding has to live in a human, not just in the PR.

---

## 7. First-Time vs. Advanced Contributors

| | **First-time contributors** | **Advanced / recurring contributors** |
|---|---|---|
| **Best entry points** | Documentation fixes, `good-first-issue`-labeled bugs, adding test coverage for existing functions, improving error messages | New features, cross-package refactors, performance work, taking ownership of a subsystem (e.g. a set of `ppc_*` plots, a diagnostic family) |
| **Discussion norms** | Comment on the issue you want to take; ask questions early rather than guessing — maintainers *expect* questions from newcomers and this is explicitly encouraged in Open Source Guides ("do your homework, but it's OK not to know things") | Often can propose and scope work directly via a new issue or forum post; may be asked to write a short design note for larger changes |
| **Review expectations** | Expect several rounds of feedback — this is normal, not a sign you did something wrong; use it as a learning opportunity (this mirrors the Carpentries' framing of code review as pedagogy, not gatekeeping) | Reviews are often faster/lighter for trusted contributors, but cross-cutting changes (e.g. touching `posterior`) still need broad sign-off given downstream impact |
| **Testing bar** | Add a test for *your* change; you're not expected to overhaul the test suite | Expected to think about test coverage holistically, and about backward compatibility / deprecation paths |
| **Non-code path** | Very viable and valuable: triage issues, reproduce bugs, improve vignettes, answer forum questions | Often also mentors newcomers, reviews PRs, writes/updates design docs, represents the package in cross-team (Stan Forums "Developers") discussions |
| **Governance** | No special status needed to contribute | May eventually be invited as a package maintainer/co-maintainer or given commit rights, typically after a track record of quality, unprompted PRs and reviews |

---

## 8. Common Pitfalls (and How to Avoid Them)

1. **Jumping straight to a big PR without discussing first.**
   Maintainers may reject or heavily rework a large, undiscussed PR — not because the code is bad, but because it doesn't fit the intended design or duplicates other in-flight work. *Fix:* open an issue, sketch your approach, wait for a "sounds good" before investing serious time.

2. **Bundling multiple unrelated changes in one PR.**
   Mixing a bug fix with a style reformat with a new feature makes the PR hard to review and impossible to revert cleanly if one part causes a regression. *Fix:* one issue, one branch, one PR.

3. **Skipping tests or documentation "because it's a small change."**
   Small undocumented/untested changes are exactly the ones that silently regress later. *Fix:* even a one-line fix deserves a one-line regression test and a `NEWS.md` entry.

4. **Not running `R CMD check` / the test suite locally.**
   Pushing untested code wastes CI cycles and reviewer time on failures you could have caught yourself. *Fix:* `devtools::test()` and `devtools::check()` before opening the PR, every time.

5. **Ignoring the existing code style.**
   Introducing a different naming convention or formatting style creates unnecessary diff noise and review friction. *Fix:* mimic the surrounding code; when in doubt, follow the tidyverse style guide, which most Stan R packages loosely follow.

6. **Forgetting the ecosystem's dependency chain.**
   A change to `posterior`'s draws-object behavior can silently break `bayesplot`, `loo`, `cmdstanr`, and `rstanarm`, since they all consume it (see the ecosystem dependency map). *Fix:* for changes to "hub" packages, think about (and ideally test against) downstream consumers, and flag this explicitly in your PR description.

7. **Going silent after submitting.**
   Not responding to review comments for weeks causes PRs to go stale and eventually get closed. *Fix:* even a quick "will address this weekend" keeps the PR alive; if you can't continue, say so — someone else may pick it up.

8. **Taking review feedback personally.**
   Direct, terse review comments are about the code, not you — this is standard in technical open source (and explicitly the framing recommended by CodeRefinery/RSE community guidance on code review as a *learning* practice, not a verdict). *Fix:* treat every review round as free mentorship; ask "why" if a suggestion is unclear rather than assuming criticism.

9. **Reinventing rather than searching first.**
   Proposing a "new" feature or filing a "new" bug that's actually a duplicate of a closed issue/PR wastes everyone's time. *Fix:* search closed issues and PRs, not just open ones, before starting.

10. **Underestimating documentation-only and triage contributions.**
    New contributors often assume only code "counts." In practice, clear bug reproductions, vignette fixes, and answering forum questions are consistently cited (by GitHub's own Open Source Guides and by maintainers directly) as some of the most valuable and welcome contributions — and a great low-risk way to build trust before attempting a larger code change.

11. **Not checking which branch to target.**
    Unlike the core C++ repos (uniform GitFlow with a `develop` branch), the R packages vary in whether they use `main`/`master` directly or a `develop` branch. *Fix:* check `CONTRIBUTING.md` or recent merged PRs to see the actual target branch before opening yours.

---

12. **Using AI-generated code you can't personally defend.**
    Submitting a PR built on AI output you haven't verified — or worse, can't explain when asked — violates Stan's AI Contribution Policy and erodes reviewer trust fast. *Fix:* treat AI output as a draft from a very fast, occasionally-wrong collaborator: read it, test it, understand it, and disclose that you used it (§6).

---

## 9. Good Practices from the Wider RSE / Open-Source Community

These are not Stan-specific, but they're exactly the practices Stan's own process (explicitly or implicitly) expects, and are echoed by The Carpentries, CodeRefinery, and Open Source Guides:

- **Write commit messages that explain *why*, not just *what*.** "Fix off-by-one in `ess_bulk()` warmup exclusion" is more useful than "fix bug."
- **Small, frequent commits** are easier to review and bisect than one giant commit.
- **Code review is collaborative learning, not gatekeeping** — for both the reviewer and the reviewed. Reviewers should give constructive, specific feedback ("consider using `vapply` here for type safety" rather than "this is wrong").
- **Automate what can be automated** (linting, formatting, CI-run tests) so human review time is spent on logic and design, not style nitpicks.
- **A friendly, welcoming project attracts and retains contributors.** Conversely, unanswered issues/PRs and terse maintainers repel first-timers — if you notice this happening in a Stan repo, a polite nudge is appropriate.
- **Non-code contributions are first-class.** Documentation, issue triage, and community support measurably improve a project's health and are explicitly encouraged as *equal* contributions, not lesser ones.
- **Give context proactively.** Whether filing an issue or opening a PR, explain the problem, why it matters, and how you verified your fix — this alone resolves most of the friction in maintainer/contributor exchanges.

---

## 7. Checklist: Making a Good Contribution to a Stan R Package

**Before you start**
- [ ] Read the package's `README.md` and `CONTRIBUTING.md`
- [ ] Searched open *and* closed issues/PRs for duplicates
- [ ] Opened an issue (or found an existing one) and gotten at least implicit buy-in for anything beyond a trivial fix
- [ ] Commented on the issue to signal you're working on it

**While working**
- [ ] Forked and cloned the repo; created a dedicated, descriptively-named branch
- [ ] Kept the change scoped to a single issue/concern
- [ ] Followed existing code style (tidyverse-style conventions unless the repo says otherwise)
- [ ] Added/updated roxygen2 documentation for any changed exported function
- [ ] Added/updated `testthat` tests, including a regression test for any bug fix
- [ ] Added a `NEWS.md` entry (with issue/PR number and your handle)
- [ ] Considered downstream impact if touching a "hub" package (`posterior`, `bayesplot`, `rstantools`)

**Before opening the PR**
- [ ] Ran `devtools::test()` — all tests pass
- [ ] Ran `devtools::check()` (or `R CMD check`) — no new warnings/notes/errors
- [ ] Confirmed the target branch (`main`/`master` vs. `develop`) matches the repo's convention
- [ ] Wrote a clear PR description: problem, solution, how it was tested, linked issue

**During review**
- [ ] Waited for CI to pass before expecting/chasing human review
- [ ] Responded to every review comment; pushed follow-ups to the same branch
- [ ] Treated feedback as collaborative, not adversarial; asked for clarification when unsure
- [ ] Kept the PR up to date with the base branch if review takes a while

**After merge**
- [ ] Deleted the feature branch; synced fork with upstream
- [ ] (Optional but encouraged) Looked for another `good-first-issue`, or offered to review someone else's PR

---

## 8. Sources Consulted

- Stan-dev R package repositories and their `README.md`/`CONTRIBUTING.md` files: [`cmdstanr`](https://github.com/stan-dev/cmdstanr), [`bayesplot`](https://github.com/stan-dev/bayesplot), [`loo`](https://github.com/stan-dev/loo), [`posterior`](https://github.com/stan-dev/posterior), [`rstanarm`](https://github.com/stan-dev/rstanarm), [`rstan`](https://github.com/stan-dev/rstan), [`shinystan`](https://github.com/stan-dev/shinystan), [`projpred`](https://github.com/stan-dev/projpred), [`priorsense`](https://github.com/stan-dev/priorsense), [`rstantools`](https://github.com/stan-dev/rstantools)
- [`stan-dev/stan` Wiki: Developer Process Overview](https://github.com/stan-dev/stan/wiki/Developer-process-overview) and [Introduction to Stan for New Developers](https://github.com/stan-dev/stan/wiki/Introduction-to-Stan-for-New-Developers)
- [Open Source Guides — How to Contribute to Open Source](https://opensource.guide/how-to-contribute/) (GitHub)
- [GitHub Blog — New to open source? Here's everything you need to get started](https://github.blog/open-source/new-to-open-source-heres-everything-you-need-to-get-started/)
- General good-practice framing on collaborative code review from the research-software-engineering community (CodeRefinery-style "branch → pull request → review → merge" workflow; Carpentries-style framing of review as a learning practice)
- The [tidyverse style guide](https://style.tidyverse.org/), which most Stan R packages loosely follow for code style