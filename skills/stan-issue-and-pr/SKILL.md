---
name: stan-issue-and-pr
description: Helps a contributor write GitHub bug reports, feature requests, and pull request descriptions that meet Stan project norms, drafting with them rather than for them, covering minimal reproducible examples, issue-linking keywords, breaking-change and test sections, draft pull requests, and AI-assistance disclosure. Use when opening or drafting an issue or pull request for stan-dev, arviz-devs, brms, or another Stan ecosystem repository.
---

# Writing issues and pull requests for Stan projects

Explanation and examples:
https://florence-bockting.github.io/stancon-contributing/03-how-to-contribute.html

## How to work with the contributor

**Stage: submit, then review.** These are the last two of the five stages in
`stan-contributing`. Say so. Here the work becomes public in the contributor's
name.

**A pull request description is the contributor speaking to the maintainers.**
Reviewers answer a person. The
[AI Contribution Policy](https://github.com/stan-dev/stan/wiki/AI-Contribution-Policy)
asks for their words.

**So draft it with them, section by section. Let them post it.**

- Ask the questions in the template, one at a time. Write down their answers.
  What broke? What did you expect? What did the suite print?
- Offer structure, order, and the parts they forgot. Do not offer finished
  sentences to approve.
- Mark any wording you suggest as a suggestion. Expect them to rewrite it.
  Reviewers ask about text the contributor did not write.
- Do not run `gh issue create` or `gh pr create` without permission. Offer first.
- Do not fill an empty section with a plausible answer. Put an unknown in "Open
  questions".

**Write in simplified technical English.** Use short sentences. Use the active
voice. Give one instruction in each sentence. Use no more than 20 words in a
sentence. Keep each turn below 100 words.

Full version: `stan-contributing/references/mentor-mode.md`.

Templates to copy and fill in:

- [templates/bug-report.md](templates/bug-report.md)
- [templates/feature-request.md](templates/feature-request.md)
- [templates/pr-description.md](templates/pr-description.md)

Check the repository first. Some projects ship their own templates, and those
take precedence over this skill. A maintainer asks for specific sections for a
reason. A description that ignores them looks careless:

```bash
ls .github/ISSUE_TEMPLATE/ .github/PULL_REQUEST_TEMPLATE.md 2>/dev/null
```

## Honesty rules

These come first. Breaking them damages trust.

- **Never record that a test suite, check, lint, or render passed before you read
  the output.** If nobody ran it, write that. An invented green check is worse
  than no description.
- **Report the numbers you saw.** Copy "0 failures, 2040 passing" from the
  terminal. Do not estimate it.
- **Say what you are unsure about.** An "Open questions" section costs the
  reviewer nothing and saves a round trip.
- **Write in your own words.** Reviewers answer a person, and in stan-dev
  repositories the
  [Stan AI Contribution Policy](https://github.com/stan-dev/stan/wiki/AI-Contribution-Policy)
  requires it. If an AI assistant helped, disclose it — required there,
  recommended in the ArviZ repositories. Review every change first.
  Is it correct? Is it needed? Is it in scope? You must be able to explain every
  line.

## Before opening anything

**Search for duplicates.** This is the single most common wasted issue. `--state
all` is the part that matters: an issue closed two years ago with the reasoning
for *why* it was closed is the most useful thing the contributor can find, and a
default search would hide it:

```bash
gh issue list --repo <OWNER/REPO> --search "<KEYWORDS>" --state all
```

**Decide if this is an issue at all.** Some questions are not yet concrete.
"Would something like this be useful?" and "am I doing this wrong?" belong on
[Stan Discourse](https://discourse.mc-stan.org) first. A design change to the
Stan language may belong in
[design-docs](https://github.com/stan-dev/design-docs).

## Titles

One sentence: specific and searchable. The title is what someone finds in two
years, and in the ArviZ repositories it *becomes the changelog entry*.

- Good: `Fix incorrect ESS calculation for thinned chains`
- Good: `Add Brier score to metrics()`
- Avoid: `Bug fix`, `update metrics`, `question about loo`

## Bug reports

Full template: [templates/bug-report.md](templates/bug-report.md).

The parts that decide whether it gets acted on:

- **What happened vs. what you expected.** Both, explicitly.
- **A minimal reproducible example.** Give the smallest model, script, and data
  that triggers the bug. Minimal matters. Nobody reads a 200-line model with a
  bug somewhere inside it. In R, [`reprex`](https://reprex.tidyverse.org/) runs
  the code and formats it for pasting.
- **Exact steps to reproduce.**
- **Put logs and error output in a code block as text. Never use a screenshot.**
  Search engines find text. The next person with this error then finds the
  issue.
- **Environment** where relevant: OS, package and compiler versions, hardware if
  it could matter.

Further reading on writing these well:
[Mozilla's bug writing guidelines](https://bugzilla.mozilla.org/page.cgi?id=bug-writing.html),
Simon Tatham's ["How to Report Bugs Effectively"](https://www.chiark.greenend.org.uk/~sgtatham/bugs.html).

## Feature requests

Full template: [templates/feature-request.md](templates/feature-request.md).

- **Describe the problem or limitation first.** What can you not currently do?
- **A proposed solution is optional**, and holding it loosely is usually better —
  maintainers often know a cheaper way.
- **Note the scope**: is this small and self-contained, or does it open a design
  discussion? Saying so helps a maintainer triage it.

## Pull requests

Full template: [templates/pr-description.md](templates/pr-description.md).

### Before you open it

- Read the repository's contributing guidelines and the AI Contribution Policy.
- **Check for a pull request template in the repository. It takes precedence
  over everything below.** `stan-dev/math` requires sections this skill does not
  cover, such as a named copyright holder and a release note. Load
  `stan-math-contribution`.
- Is it small and focused on **one logical change**? If not, split it.
- Not ready for review? Open it as a **draft** so reviewers know to hold off.

### Structure

**Link the issue** with a
[GitHub keyword](https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue#linking-a-pull-request-to-an-issue-using-a-keyword)
so it closes automatically: `Fixes #123` or `Closes #123`.

Then:

- **Description** — what changed, and why. Three sentences, at most five. One for
  the cause, one for the change, one for any design decision a reader could
  question. This matters most where you left the conventions of a neighbouring
  function.
- **Breaking changes** — does this change existing behaviour, APIs, or output? If
  yes, name the input that behaves differently and the new behaviour. If no, say
  "None" rather than omitting the section.
- **Tests** — one sentence on what the new tests cover, then the actual result of
  running the suite.
- **Documentation** — what you documented and where; whether the vignette renders.
  One line.
- **Open questions** — genuine uncertainties, and anything you noticed that might
  deserve its own issue. One line each, two or three at most.
- **TODOs** — anything still outstanding before it can be merged. If this list is
  non-empty, the pull request should be a draft.
- **AI assistance** — name the tool and what it helped with. The
  [AI Contribution Policy](https://github.com/stan-dev/stan/wiki/AI-Contribution-Policy)
  requires this in stan-dev repositories; in ArviZ it is recommended practice.
  Include the section by default. The contributor deletes it if they used none.
- **Checklist** — copy it from the template into the description. Tick only the
  items the contributor confirms.
- **Copyright and Licensing** — name the copyright holder, then agree to the
  project's license. The holder is the contributor, unless an employer or an
  institution owns the work. Ask the contributor; do not fill this in for them.
  `stan-dev/math` requires the field. Where the repository ships its own
  licensing text, keep that text and add the copyright holder line to it.

  **Read the license out of the target repository. Never carry one over from
  another repository or from this skill.** Licenses differ across the
  ecosystem: `stan-dev/math` is BSD 3-clause, `arviz-stats` is Apache 2.0.
  Naming the wrong one in a pull request is a legal statement that is false:

  ```bash
  head -3 LICENSE
  grep -n -i "license" pyproject.toml DESCRIPTION 2>/dev/null
  ```

  Both are read-only, so run them and show the contributor the output.

### Length

**A long description hides the change.** The reviewer reads the diff. The
description says what the diff cannot: the cause, the decision, and the result of
running the checks. The whole thing fits on one screen.

- **Write precise technical language.** Name the functions, types, arguments, and
  files exactly. `vctrs::vec_c()` binds the columns, not "the values are combined
  in a type-safe way".
- **Do not narrate the diff.** A reader who wants the line-by-line opens the
  Files tab. Do not name every helper you added.
- **Cut every sentence that carries no fact.** Restating the issue, praising the
  approach, and explaining why tests matter all belong in this category.
- **One fact per sentence. No sentence over 20 words.**
- **Prefer a list to a paragraph** where the content is a list.

A pull request description over about 300 words needs a reason. Split the change
instead, or move the reasoning into a comment on the issue.

### The pre-submission checklist

Go through this **with** the contributor. Ask, do not assert. "Did the check
pass?" gets an answer. "The checks pass" gets a nod. Do not tick an item they
cannot confirm.

```
- [ ] Style is consistent with the existing code and docs
- [ ] Documentation renders / builds without warnings
- [ ] Tests pass (paste the actual output)
- [ ] Full check passes: devtools::check() / tox -e check / the five math make
      targets
- [ ] Changelog handled: NEWS.md entry, OR a changelog-worthy PR title where it
      is generated, OR the release-note field where the template has one
- [ ] Copyright holder named where the repository asks for it
- [ ] Diff contains only explainable changes
- [ ] AI assistance disclosed if used
```

The language-specific detail behind each of these lives in
`stan-r-package-contribution`, `stan-python-package-contribution`, and
`stan-math-contribution`. They differ more than the shared checklist suggests —
follow the one for your target repository.

## During review

*Stage: review. Contributors do not expect this stage. Say early that a pull
request starts a conversation. A first review that asks for changes is the normal
result, not a rejection.*

- Respond to every comment, even if only to say you disagree and why.
- Push follow-up commits rather than force-pushing over the reviewed history,
  unless the project asks otherwise.
- Write review responses in your own words. When in doubt about something, ask
  the Stan developers rather than an AI assistant.
