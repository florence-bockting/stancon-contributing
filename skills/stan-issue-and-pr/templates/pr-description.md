<!--
Copy the content below into the pull request body and fill it in.
Delete this comment and any section that genuinely does not apply — but prefer
writing "None" over silently dropping "Breaking changes".

If the repository has .github/PULL_REQUEST_TEMPLATE.md, use that one instead and
treat this as a checklist of what to cover.

Title: one sentence, specific and searchable. In the ArviZ repositories the
title becomes the changelog entry, so write it as one.
  Good:  Add brms_summary_measures() helper for summarise_draws()
  Good:  Add Brier score to metrics()
  Avoid: Bug fix / update metrics

Not ready for review? Open it as a DRAFT pull request.

Keep it short. The reviewer reads the diff, not a retelling of it. The whole
description fits on one screen. Name identifiers, types, and functions exactly.
Do not explain what the code already shows.
-->

Closes #<ISSUE NUMBER>

## Description

<!-- What changed and why, in your own words. Three sentences, at most five.

     One sentence for the cause. One for the change. One for any decision a
     reader could question — a departure from a neighbouring function, or a
     design agreed in the issue thread. Name the functions and types involved.
     Do not restate the issue and do not walk through the diff. -->

## Breaking changes

<!-- Does this change existing behaviour, APIs, or output? If yes, name the
     input that behaves differently and the new behaviour, in one sentence. If
     no, write "None." Only claim a behaviour change you have run. -->

None.

## Tests

<!-- One sentence naming what the new tests cover, then the ACTUAL output of
     running the suite. Copy it from the terminal; do not estimate it, and do
     not claim a run you did not do. -->

```
[ FAIL 0 | WARN 0 | SKIP 11 | PASS 2040 ]
```

## Documentation

<!-- One line. What you documented and where. Whether the vignette or example
     renders. For R: whether NEWS.md was updated.
     For plots in bayesplot: confirm the new vdiffr snapshots are committed. -->

## Open questions

<!-- Genuine uncertainties, and anything you noticed along the way that might
     deserve its own issue. One line each, phrased as a question. Two or three
     at most; a longer list reads as an unfinished pull request. Delete the
     section only if you truly have none. -->

-

## TODOs

<!-- Anything still outstanding before this can be merged. If this list is
     non-empty, the pull request should be a draft. -->

- [ ]

## AI assistance

<!-- Name the tool and what it helped with. Delete this section if you used none.
     In the stan-dev repositories the Stan AI Contribution Policy requires this
     disclosure; in the ArviZ repositories there is no such policy and it is
     recommended practice instead.
     You are responsible for every line either way: you must be able to
     explain it, and the description must be in your own words. -->

<AI TOOL> helped with <WHAT IT HELPED WITH>. I reviewed every change and can
explain it.

## Copyright and Licensing

<!-- Name the copyright holder. This is you, unless your employer or your
     institution owns the work you do. Ask if you are not sure. Some Stan
     repositories, including stan-dev/math, require this field.

     NAME THE LICENSE THE TARGET REPOSITORY ACTUALLY USES. Licenses differ
     across the ecosystem: stan-dev/math is BSD 3-clause, arviz-stats is
     Apache 2.0. Read it from the checkout, do not copy the line below:

       head -3 LICENSE
       grep -n -i "license" pyproject.toml DESCRIPTION 2>/dev/null

     Then replace <LICENSE> with what you found, and delete the documentation
     line unless the repository licenses its docs separately. -->

Copyright holder: <NAME, OR THE EMPLOYER OR INSTITUTION THAT OWNS THE WORK>

By submitting this pull request, the copyright holder agrees to license the
submitted work under the repository's license:

- Code: <LICENSE OF THE TARGET REPOSITORY, e.g. Apache 2.0 for arviz-stats,
  BSD 3-clause for stan-dev/math>

<!-- If the repository ships its own licensing text, keep that text and add the
     copyright holder line to it. -->

## Checklist

- [ ] Style is consistent with the existing code and docs
- [ ] Documentation or vignette renders locally
- [ ] Tests pass, with the output pasted above
- [ ] Full check passes — `devtools::check()` / `tox -e check` / the five math
      `make` targets
- [ ] Changelog handled — `NEWS.md` entry added, OR the title is
      changelog-worthy where the changelog is generated, OR the release-note
      field is filled where the template has one
- [ ] Copyright holder named
- [ ] Every file in the diff is explainable
- [ ] AI assistance disclosed — required by the
      [AI Contribution Policy](https://github.com/stan-dev/stan/wiki/AI-Contribution-Policy)
      in stan-dev repositories, recommended elsewhere
