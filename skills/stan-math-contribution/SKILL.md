---
name: stan-math-contribution
description: Mentors a contributor step by step through a C++ code contribution to the Stan Math library (stan-dev/math) or the Stan core (stan-dev/stan), covering the GitFlow branch-from-develop process, where functions live across prim/rev/fwd/mix, the require_ type traits and Eigen expression pitfalls, expect_ad autodiff testing, and the required runTests.py, make cpplint and make doxygen checks before a pull request. Use when adding or changing a C++ function, distribution, gradient, or autodiff specialization in stan-dev/math or stan-dev/stan.
---

# Contributing to the Stan Math library

Authoritative sources — read these, do not rely on this skill alone:

- [Developer process overview](https://github.com/stan-dev/stan/wiki/Developer-process-overview)
  (the process, and the [code review guidelines](https://github.com/stan-dev/stan/wiki/Developer-process-overview#code-review-guidelines))
- [Math contributor help pages](https://github.com/stan-dev/math/tree/develop/doxygen/contributor_help_pages)
  — `getting_started.md`, `common_pitfalls.md`, `adding_new_distributions.md`,
  `autodiff_test_guide.md`, and others. (The repository's `CONTRIBUTING.md`
  links these as `https://mc-stan.org/math/developer_guide.html`, which is
  currently a 404; read them from the source tree instead.)
- [Math C++ API](https://mc-stan.org/math/)
- [`.github/CONTRIBUTING.md`](https://github.com/stan-dev/math/blob/develop/.github/CONTRIBUTING.md) in the repository
- [Coding style and idioms](https://github.com/stan-dev/stan/wiki/Coding-Style-and-Idioms)
- [AI Contribution Policy](https://github.com/stan-dev/stan/wiki/AI-Contribution-Policy) — all contributions must follow it

> **This process is not the R or Python one.** Branches come off `develop`, not
> `main`; every pull request must correspond to an issue; branch names are
> prescribed; and there is a fixed set of checks that must pass before review.
> Do not carry habits over from `stan-r-package-contribution`.

Requires: a C++14 toolchain (the library is moving to C++17), `make`, Python 3
for the test runner, and `doxygen` for the documentation check.

**Check the toolchain before step 1, not at step 7.** This is the one Stan
workflow where the platform changes the commands:

- **Windows.** Install [RTools](https://cran.r-project.org/bin/windows/Rtools/).
  It supplies the compiler and `make`, but the executable is called
  `mingw32-make`, not `make`. The test runner is `python runTests.py`; the
  `./runTests.py` form in this skill does not work on Windows.
- **macOS.** `xcode-select --install` for the compiler and `make`. `doxygen`
  comes from Homebrew.
- **Linux.** The distribution packages for `build-essential`, `python3`, and
  `doxygen`.

A contributor who reaches step 7 and finds no compiler has already written the
C++. Ask what they have at the start.

## Before you start

Tell new contributors that this is a demanding place to start. The library is
template-heavy C++ with hand-derived derivatives. Review is strict. If they want
a *first* contribution to Stan, and not to Math specifically, `stan-contributing`
lists easier entry points.

Background worth having first: the
[Stan Math paper](https://arxiv.org/abs/1509.07164), Bob Carpenter's
[AD Handbook](https://github.com/bob-carpenter/ad-handbook/blob/master/ad-handbook-draft.pdf),
and the `common_pitfalls` page of the contributor guide.

For general questions, use the
[Developers tag on Discourse](https://discourse.mc-stan.org/c/stan-dev), not the
issue tracker.

## How to work with the contributor

You are a mentor. You are not the contributor. This matters more here than in any
other Stan repository. Review is strict and the C++ is template-heavy. A
contributor who cannot explain their own gradient will fail the review. The
[AI Contribution Policy](https://github.com/stan-dev/stan/wiki/AI-Contribution-Policy)
makes them responsible for every line.

**Do not write the C++ for the contributor.** A hand-derived derivative that the
contributor did not derive is the worst thing to send to a Math reviewer. Work
through [references/writing-the-function.md](references/writing-the-function.md)
*with* them.

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
  the contribution, not the tool. Do not write "`git config merge.ff false` sets
  a git option". Write "it stops an accidental fast-forward, and `develop` must
  stay releasable". Each step below gives you that reason. Write your own reason
  for any other command. If you do not know the reason, say so. Then find it
  together. This repository has more steps with a non-obvious purpose than any
  other, so an invented reason does real damage here.
- **Give the command to the contributor.** Show the command. Ask *"Run this
  yourself, or shall I?"* Then stop and wait. An unanswered offer is not
  permission.
- **Read the output together.** Unexpected output is the lesson.
- **Run read-only commands without permission**: `grep`, `ls`, `git status`,
  `git log`, `gh issue view`. Say what you run and why. Show what it prints.
  Offer every other command first: git config, branches, file edits, builds,
  commits, pushes, the issue, and the pull request.
- **Do a step yourself if the contributor asks.** Then say what you did. Say what
  they must check. Then offer the next step again.

Write more than one sentence only if the contributor asks, or if the output is
unexpected. Full version: `stan-contributing/references/mentor-mode.md`.

## Where you are

Show this map at the start and name the stage each time you move. It is the
contributor's checklist, not yours.

    Orient    1. Open an issue (every PR corresponds to one; prefer small issues)
    Set up    2. Fork, add the upstream remote, configure git safety settings
              3. Branch from develop: feature/issue-<n>-description
              4. Find the right folder: prim / rev / fwd / mix / opencl
    Change    5. Write the function so it works for double, var, and fvar types
    Verify    6. Write the tests (failing test FIRST for a bug fix)
              7. Run all five required checks
    Submit    8. Fill in the PR template, including the copyright holder
    Review    9. Respond to review on the same branch

Every Stan code contribution has these five stages. **Almost none of the steps
match the R or Python workflow.** Branches come off `develop`, not `main`. An
issue is required, not recommended. Branch names are prescribed. There are five
checks, not one. Say this to any contributor who worked on an R package. Do not
let them find it at step 8.

---

## 1. Open an issue

*Stage: orient. **Why:** every Math pull request needs an issue. The issue
number goes into the branch name at step 3. The maintainers also agree the design
here, before anyone writes template C++.*

**The issue is theirs to write and open.** Draft it with them; do not post it.

Issues are for bugs and feature requests **that a developer can act on**.
Maintainers close vague requests and move them to the forums.

A bug report needs three parts: a description, a reproducible example, and the
expected outcome after a fix. A feature request needs a description, an example,
and the expected outcome if the feature existed.

Keep issues narrowly scoped. From the developer process: *"Did I mention we
prefer more smaller issues than fewer large issues?"*

For a new distribution, get it working as a
[user-defined function in the Stan language first](references/writing-the-function.md#adding-a-distribution)
and post it on Discourse before writing C++.

## 2. Fork and configure

*Stage: set up. **Why:** these settings and hooks stop an accidental push to
`develop` or `master`. Both branches are shared and must stay releasable.*

The fork is the contributor's copy on GitHub. The clone is their copy on disk.
The `upstream` remote keeps them up to date with `develop`. Math moves fast, and
a stale branch does not merge:

```bash
gh repo fork stan-dev/math --clone
cd math
git remote add upstream https://github.com/stan-dev/math.git
```

Two safety settings. `push.default simple` sends a bare `git push` only to the
matching branch on their fork. A mistyped command cannot reach another branch.
`merge.ff false` forces a merge commit instead of a quiet fast-forward, so the
history of `develop` records what merged and when:

```bash
git config push.default simple
git config merge.ff false
```

The repository also ships pre-push hooks in `hooks/` that block direct pushes to
`master` and `develop`. Install them.

## 3. Branch from `develop`

*Stage: set up. **Why:** R contributors get this step wrong. A branch off
`master` gives a pull request against the wrong base. The tooling also reads the
issue number out of the branch name.*

`develop` is the integration branch and must always be releasable; `master`
holds tagged releases only. Both change only through pull requests.

Three commands, in order. Switch to `develop`. Update it from the real
repository. Then branch from it. Skip the update, and the branch starts from old
code and gets conflicts:

```bash
git checkout develop
git pull upstream develop
git checkout -b feature/issue-1234-short-description
```

Naming is prescribed:

- `feature/issue-<number>-short-description` — new functionality, off `develop`
- `bugfix/issue-<number>-short-description` — fixes, off the latest hotfix

## 4. Find the right folder

*Stage: set up, and the first design decision. **Why:** the folder sets the
autodiff mode. A function in `rev` that belongs in `prim` works for one scalar
type and fails quietly for the others.*

The library splits by autodiff mode, then by role.

| Folder | Holds |
| :-- | :-- |
| `prim` | General `Scalar`, `Matrix`, and `std::vector<T>` implementations |
| `rev` | Reverse-mode autodiff specializations |
| `fwd` | Forward-mode autodiff specializations |
| `mix` | Mixed forward/reverse specializations |
| `opencl` | GPU implementations |

Within each:

| Subfolder | Holds |
| :-- | :-- |
| `core` | Scalar types, operators, allocator, threading setup |
| `err` | Check-and-throw functions |
| `fun` | The math functions exposed to the Stan language |
| `functor` | Functions taking other functions, e.g. `reduce_sum()` |
| `meta` | Type traits and internal helpers |

**A new function starts as a single implementation in `prim/fun`.** Write it
generically so it accepts `double`, reverse-mode
[`var`](https://mc-stan.org/math/), and forward-mode `fvar` scalars. Add
specializations in `rev`, `fwd`, `mix`, or `opencl` only when there is a reason
— an analytic gradient that beats the autodiff one, say.

Every function callable from the library, outside the `internal` namespace, is
expected to support **higher-order autodiff**.

## 5. Write the function

*Stage: change. **Why:** review is strictest here. A Math reviewer checks idiom
as well as correctness, and asks the author to justify each choice.*

**Do not write this for the contributor.** If they ask you to, go through the
result afterwards. Check that they can explain the type traits, the gradient, and
each specialization. If they cannot, the change is not ready. The tests do not
change that.

The library-specific patterns — `require_*` type traits, `to_ref()` for Eigen
expressions, `value_type_t`, `.coeff()`/`.coeffRef()` — are covered with a
worked example in
[references/writing-the-function.md](references/writing-the-function.md).
Read it before writing; these are the things a reviewer will send back.

Documentation is doxygen, and `make doxygen` must produce **zero warnings**.

## 6. Write the tests

*Stage: verify. **Why:** `expect_ad()` checks derivatives to third order against
finite differences. It is the evidence that a hand-derived gradient is correct.
For a bug fix, write the failing test first: a test nobody saw fail proves
nothing.*

The minimum the project states:

- **Bug fix**: at least one test that fails before the patch and passes after.
  Write and commit that test *first*.
- **New feature**: at least one test showing expected behaviour, **and** one
  showing the behaviour on error. Expect the reviewer to ask for more.

The `expect_ad()` framework verifies new functions. It checks values and
derivatives to third order against finite differences. It covers every
combination of primitive and autodiff argument types. Put the tests in
`test/unit/math/mix/fun/<name>_test.cpp`.

See [references/testing.md](references/testing.md) for how `expect_ad()` works,
the tolerance table, and the extra requirements for distributions.

## 7. Run the required checks

*Stage: verify. **Why:** R has one `devtools::check()`. Math has five gates, and
a pull request stalls if it fails any of them. Warn the contributor that
`runTests.py` is slow.*

All five must pass before you open the pull request. Run exactly these, from the
repository root:

```bash
./runTests.py test/unit          # unit tests
make test-headers                # every header compiles standalone
make test-math-dependencies      # no forbidden cross-folder includes
make doxygen                     # documentation builds, 0 warnings
make cpplint                     # style, 0 new errors
```

Each check stops one reason a Math pull request comes back. Code that compiles
only in one translation unit. An include that couples folders the library keeps
apart. An undocumented function. A style error that costs review time. Say which
check runs and what it tests.

> **Path note.** These are the paths in `stan-dev/math`. In `stan-dev/stan` the
> tests live under `src/`, so it is `./runTests.py src/test/unit` and
> `./runTests.py src/test/integration`. Check which repository you are in.

> **Windows.** Two of these five commands are spelled differently. The runner is
> `python runTests.py test/unit` — `./runTests.py` relies on a shebang, which
> Windows does not read. `make` is `mingw32-make`, from RTools:
>
> ```
> python runTests.py test/unit
> mingw32-make test-headers
> mingw32-make test-math-dependencies
> mingw32-make doxygen
> mingw32-make cpplint
> ```
>
> The five checks and what each one catches are the same. Give the contributor
> one set of commands, the set that matches their machine.

`./runTests.py test/unit` is slow. While iterating, run only the directory you
touched — for a change to `stan/math/prim/fun/foo.hpp`:

```bash
./runTests.py test/unit/math/prim/fun/foo_test.cpp
```

and run the full suite once before pushing.

To debug, add this to `make/local`. The library compiles at `-O3` by default.
That inlines and reorders the code, so a debugger shows very little. This setting
turns it off, and breakpoints work. Builds and tests get much slower:

```make
DEBUG = 1
```

which replaces `-O3` with `-g -O0` and enables the DEBUG macros.

Every commit should pass the tests, on the honour system. If your history has
broken intermediate commits, rebase to clean it before opening the pull request.

## 8. Open the pull request

*Stage: submit. **Why:** two fields here exist nowhere else in the ecosystem:
the copyright holder and the release note. Only the contributor can complete
them. The copyright holder is a licensing declaration.*

**Do not open the pull request for the contributor. Do not complete the
copyright holder field for them.** Ask them.

Base repository `stan-dev/math`, **base branch `develop`** — not `master`.

The template asks for **Summary**, **Tests**, **Side effects**, **Release
notes**, and a checklist. Two parts catch people out:

- **Copyright holder.** You must name it — yourself, or your university or
  employer. Submitting agrees to license the code under
  [BSD 3-clause](https://opensource.org/licenses/BSD-3-Clause) and the
  documentation under [CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/).
- **Release notes.** A short note on what changes if this is merged. It goes
  into the release notes, so write it for a user.

Report what the five checks actually printed. Never state that they passed
without having run them and read the output.

Load `stan-issue-and-pr` for the general structure of a good description, but
the template above takes precedence.

## 9. Review

*Stage: review. **Why:** the contribution finishes here. The contributor answers
for the change in their own words. Say this before they open the pull request.*

Reviewers wait for continuous integration. Then they check four things. Is the
functionality useful and correct? Are the tests adequate? Is the C++ idiomatic?
Is it documented?

**Anyone who reads C++ well can review.** You do not have to be an active
developer, and a review is a real contribution. Only development team members who
work on Math regularly can merge.

These stall or reject a pull request: failing CI, an incomplete checklist, thin
test coverage, undocumented code, new `cpplint` errors, unidiomatic C++, and
unrelated changes in the diff.

Fix review feedback **on the same branch**; do not open a replacement pull
request.

## Adding a dependency

This is rare. Justify the dependency against each of these: purpose, a
BSD-compatible licence, maturity and maintenance, build times, every supported
compiler, and the effect on developers and users. Open an issue first. Discuss it
before you do the work.
