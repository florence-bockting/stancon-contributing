# Stan contributor skills

Agent Skills that walk a new contributor through making a contribution to the
Stan ecosystem. They are the operational companion to the workshop book at
<https://florence-bockting.github.io/stancon-contributing/>: the book explains
*why*, the skills carry the commands, the order, and the traps.

Skills follow the [Agent Skills](https://agentskills.io/) open standard, so they
work in Claude Code and other agents that implement it.

## The seven skills

| Skill | Use it when you want to |
| :-- | :-- |
| [`stan-contributing`](stan-contributing/) | Start somewhere — pick a contribution path and the right repository |
| [`stan-r-package-contribution`](stan-r-package-contribution/) | Change an R package: posterior, bayesplot, loo, cmdstanr, brms, … |
| [`stan-python-package-contribution`](stan-python-package-contribution/) | Change a Python package: arviz-base, arviz-stats, arviz-plots, cmdstanpy |
| [`stan-math-contribution`](stan-math-contribution/) | Change C++ in stan-dev/math or stan-dev/stan |
| [`stan-issue-and-pr`](stan-issue-and-pr/) | Write a bug report, feature request, or pull request description |
| [`stan-case-study`](stan-case-study/) | Write and submit a case study or tutorial |
| [`stan-find-docs`](stan-find-docs/) | Find where something about Stan is documented |

`stan-contributing` is the entry point and routes to the others. The rest also
fire on their own when you describe what you are doing.

## How they behave

**These skills make the agent a mentor, not a contributor.** That is a deliberate
design choice and the thing that most distinguishes them from a generic "help me
with this repository" prompt. In practice you should see:

- **A map, and where you are on it.** Every contribution passes through five
  stages — *orient, set up, change, verify, submit* — then review. Only the
  contents differ between R, Python, and C++. Each workflow skill opens with that
  map and names the stage as you move.
- **Never a command without a reason.** Every command is introduced by one
  sentence on what it does *for the contribution* — what a reviewer would see, or
  fail to see, if it were skipped — not by what it does to your filesystem. This
  holds for one-liners, for obvious commands, and for the read-only lookups the
  agent runs itself. If you get a bare command, or a block of five, that is the
  skill not being followed: ask why, and expect an answer about the pull request
  rather than about the tool.
- **Short turns.** One stage, one reason, one command block, one offer — under
  100 words, no recap of what you just did, no preview of what comes later. The
  skills ask for
  [simplified technical English](https://en.wikipedia.org/wiki/Simplified_Technical_English):
  short sentences, active voice, one instruction per sentence, the same word for
  the same thing every time. If a turn does not fit on a screen, the agent is
  lecturing rather than mentoring.
- **Commands handed to you, not run at you.** You get the command to copy, and an
  offer: run it yourself, or have the agent run it. Read-only lookups (`grep`,
  `git status`, `gh issue view`) it may run unasked; anything that installs,
  edits, commits, pushes, or posts is offered every time.
- **Output read together.** A version mismatch or a failing test is the most
  useful thing that can happen; it should be shown to you, not quietly fixed.

If you already know a step, say so and it will move on — and if you want the
agent to take one over, ask and it will, then tell you what to check. What it
should not do is take over your understanding: the pull request goes out under
your name, and you have to be able to explain every line of it. In the stan-dev
repositories the
[AI Contribution Policy](https://github.com/stan-dev/stan/wiki/AI-Contribution-Policy)
states this outright; the ArviZ repositories have no equivalent policy, but the
same expectation holds in practice.

The full statement of this, which every skill points at, is
[`stan-contributing/references/mentor-mode.md`](stan-contributing/references/mentor-mode.md).

**The three code workflows are separate processes, not variations on one.** The
R packages, the ArviZ packages, and the Math library differ in base branch,
whether an issue is required, branch naming, test runner, documentation
toolchain, changelog handling, and licensing steps. There is a comparison table
at the end of
[`stan-python-package-contribution`](stan-python-package-contribution/SKILL.md).

**Not covered:** [`stanc3`](https://github.com/stan-dev/stanc3), the OCaml
compiler. That workflow has not been validated here — see the
[Developer Wiki](https://github.com/stan-dev/stan/wiki).

## Install

You will use these while working inside a clone of *another* repository — your
fork of `posterior`, say — so install them for your user, not for a project.

macOS and Linux:

```bash
git clone https://github.com/florence-bockting/stancon-contributing.git
mkdir -p ~/.claude/skills
cp -r stancon-contributing/skills/stan-* ~/.claude/skills/
```

Windows, in PowerShell:

```powershell
git clone https://github.com/florence-bockting/stancon-contributing.git
New-Item -ItemType Directory -Force -Path "$HOME\.claude\skills"
Copy-Item -Recurse stancon-contributing\skills\stan-* "$HOME\.claude\skills\"
```

Then **restart your agent session**. Skills are discovered at session start;
editing or adding one mid-session has no effect until you restart.

Verify they loaded by asking: *"which skills do you have for contributing to
Stan?"*

For other agents implementing the Agent Skills standard, copy the same
directories into that tool's skills location.

## Shell and platform

**The `bash` blocks in these skills assume a POSIX shell.** That is Terminal on
macOS and Linux, and **Git Bash** on Windows — the shell that ships with
[Git for Windows](https://gitforwindows.org/). PowerShell and `cmd.exe` do not
understand `2>/dev/null`, and neither has `grep` or `head`.

Everything the skills run on macOS works unchanged from what is written. Windows
differs in four places, and each is marked where it appears:

| Written | On Windows |
| :-- | :-- |
| `source .venv/bin/activate` | `.venv\Scripts\Activate.ps1`, or `source .venv/Scripts/activate` in Git Bash |
| `python3` | `python`, or `py -3` |
| `./runTests.py …` | `python runTests.py …` |
| `make …` (Stan Math) | `mingw32-make …`, from [RTools](https://cran.r-project.org/bin/windows/Rtools/) |

Two toolchain requirements catch people on every platform, before any skill
command runs:

- **R.** `devtools::check()` compiles the package. That needs
  [RTools](https://cran.r-project.org/bin/windows/Rtools/) on Windows and the
  Xcode command line tools (`xcode-select --install`) on macOS. On Windows, the R
  installer also does **not** put `Rscript` on the `PATH` by default — if
  `Rscript` is not found, either add `R\bin` to the `PATH` or run the checks by
  hand from the R console.
- **Stan Math.** A C++14 toolchain, `make`, Python 3, and `doxygen`. On Windows
  all of these come from RTools rather than from the system.

Agents: state the platform difference **once, when the contributor first reaches
the command**, and use the form that matches their machine. Ask which platform
they are on if you do not know. Do not print all three variants of every
command.

## Use

Just describe what you are doing. The skills are triggered by their descriptions,
so no special syntax is needed:

- *"I'd like to contribute to Stan but I don't know where to start"* →
  `stan-contributing`
- *"I want to add a function to posterior — issue #238"* →
  `stan-r-package-contribution`
- *"help me write the PR description"* → `stan-issue-and-pr`

In Claude Code you can also invoke one by name with `/stan-contributing`.

## A note on trusting them

These skills tell an agent to **verify against the repository rather than trust
what is written here** — pinned tool versions, file locations, and available
functions differ between repositories and change over time.

They also say, repeatedly, never to claim that a test suite or check passed
without having run it. Hold the agent to that: if a pull request description
says the tests pass, ask to see the output. See the
[Stan AI Contribution Policy](https://github.com/stan-dev/stan/wiki/AI-Contribution-Policy).

One limitation worth knowing: a skill is guidance, not enforcement. An agent
running in an autonomous mode can still work ahead of you, and a sufficiently
insistent "just do the whole thing" will get you a contribution you did not
write. The skills are arranged to make the mentoring stance the default and to
say what it costs you to drop it — they cannot prevent you from dropping it.

## Layout

```
skills/
├── stan-contributing/
│   ├── SKILL.md
│   └── references/       mentor-mode.md, ecosystem-map.md, contribution-types.md
├── stan-r-package-contribution/
│   ├── SKILL.md
│   ├── references/       worked-example.md, plots-and-vdiffr.md, vignettes.md
│   └── scripts/          check_environment_setup.R
├── stan-python-package-contribution/
│   └── SKILL.md
├── stan-math-contribution/
│   ├── SKILL.md
│   └── references/       writing-the-function.md, testing.md
├── stan-issue-and-pr/
│   ├── SKILL.md
│   └── templates/        bug-report.md, feature-request.md, pr-description.md
├── stan-case-study/
│   └── SKILL.md
└── stan-find-docs/
    └── SKILL.md
```

`references/` are read for context. `templates/` are copied out and filled in.
`scripts/` are run.

## Maintaining

The skills overlap with the checklist and walkthrough chapters by design — the
book keeps the prose and the reasoning, the skills keep the procedure. **When a
command, version pin, or repository convention changes, update both.** The
overlapping pairs are:

| Book chapter | Skill |
| :-- | :-- |
| `02-stan-ecosystem.qmd` | `stan-contributing/references/ecosystem-map.md` |
| `03-how-to-contribute.qmd` | `stan-issue-and-pr`, `stan-case-study` |
| `04-find-information.qmd` | `stan-find-docs` |
| `05-checklist.qmd` | `stan-r-package-contribution/SKILL.md` |
| `06-skills.qmd` | this README, and `stan-contributing/references/mentor-mode.md` |
| `07-walkthrough-R.qmd` | `stan-r-package-contribution/SKILL.md`, `.../references/` |
| `08-walkthrough-Py.qmd` | `stan-python-package-contribution/SKILL.md` |
| *(no chapter yet)* | `stan-math-contribution` |

The two walkthrough chapters are transcripts of the skills being used. They
reproduce the **Where you are** map and several command blocks verbatim, so a
change to a step in a workflow skill needs the matching chapter updated in the
same commit.

**The platform differences are stated twice.** The agent-facing version is
`stan-contributing/references/mentor-mode.md` ("The contributor's platform"),
because the install step copies only the `stan-*` directories and an agent never
reads this README. The table above is the human-facing copy. The individual
commands that differ carry their own note where they appear — the venv
activation in `stan-python-package-contribution`, the five checks in
`stan-math-contribution`, `Rscript` and `devtools::check()` in
`stan-r-package-contribution`. Change one, change the others.

**The mentoring stance is stated in seven places on purpose.** The canonical text
is `stan-contributing/references/mentor-mode.md`; each `SKILL.md` carries a short
form at the top, because a skill only fires when its own description matches and
each directory has to work when copied on its own. Change the canonical file and
the short forms together, or the skills will disagree about how to behave. The
five-stage map is duplicated the same way, once per workflow skill with its own
steps filled in.

`stan-math-contribution` has no counterpart in the book: the walkthrough
chapters cover the R packages and ArviZ. Its content is sourced from the
[developer process overview](https://github.com/stan-dev/stan/wiki/Developer-process-overview),
the [Math contributor help pages](https://github.com/stan-dev/math/tree/develop/doxygen/contributor_help_pages), and
the repository's own `CONTRIBUTING.md` and pull request template — not from a
contribution that was actually carried out, unlike the other workflows. Treat it
as accurate to the documentation and unverified in practice.
