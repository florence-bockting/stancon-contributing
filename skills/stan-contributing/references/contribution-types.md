# Ways to contribute to Stan

Code is the smallest of these categories, not the largest.

## Participate on Stan Discourse

[Stan Discourse](https://discourse.mc-stan.org) is the main forum for users and
developers to ask questions, discuss issues, and share ideas. Answering a
question you happen to know the answer to is a real contribution, and it is the
lowest-friction way to start.

The community is guided by the
[Code of Conduct](https://mc-stan.org/about/#code-of-conduct) and the
[Discourse guidelines](https://discourse.mc-stan.org/guidelines).

There is also a [Slack](https://join.slack.com/t/mc-stan/shared_invite/zt-1le4ebi4m-UMtiOkJb4gcS16qz2wIYCw)
used mainly for developer discussion, but prefer Discourse for questions: it is
open to everyone, so the answer helps the next person too.

## Report a problem

Anything that behaved differently from how it is documented, crashed, produced a
wrong number, or confused you enough to lose an afternoon. Documentation
problems count.

→ `stan-issue-and-pr` for how to write one that a maintainer can act on.

## Request a feature or improvement

Describe the problem or limitation first; a proposed solution is optional. Note
whether the request is small and self-contained or opens a design discussion —
the latter may belong on Discourse or in
[design-docs](https://github.com/stan-dev/design-docs) first.

→ `stan-issue-and-pr`.

## Improve documentation

Frequently the highest value-per-hour contribution available, and the easiest to
review:

- Clarifying confusing sections
- Adding examples or code snippets
- Fixing inaccuracies, including where current behaviour deviates from
  documented behaviour
- Flagging content that is missing or unclear
- Fixing typos, grammar, and broken links

A vignette change touches one file, needs no `NAMESPACE` entry and no unit test.
→ `stan-r-package-contribution`, `references/vignettes.md`.

## Write a case study or tutorial

A complete worked example in your own research domain. Published at
[mc-stan.org case studies](https://mc-stan.org/learn-stan/case-studies.html).

→ `stan-case-study`.

## Contribute code

New functions, bug fixes, tests, performance work. Start from an issue labelled
`good first issue` or `help wanted`, and avoid anything involving refactoring or
larger architectural change for a first contribution.

→ `stan-r-package-contribution`, `stan-python-package-contribution`, or
`stan-math-contribution`, depending on the target repository. These are three
different processes — see `stan-contributing` step 1.

## Review someone else's contribution

Reading an open pull request and saying what is unclear is useful even without
merge rights, and it is how you learn what maintainers look for.
