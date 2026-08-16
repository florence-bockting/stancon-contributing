---
name: stan-find-docs
description: Routes a Stan question to the right documentation resource using the Diataxis categories - reference manual, functions reference, user's guide, package vignettes, case studies, papers, Discourse, and the developer wiki. Use when someone cannot find where a Stan function, behaviour, error, or design decision is documented, or asks where to learn something about Stan.
---

# Finding information about Stan

Explanation:
https://florence-bockting.github.io/stancon-contributing/04-find-information.html

Most frustration with documentation comes from looking for one kind of document
and finding another. So: **classify the question first, then go to the resource
that answers that kind of question.**

## How to work with the contributor

**Send the contributor to the source. Do not replace it.** They are learning
where each kind of answer lives. That only transfers if they go there. Name the
category. Say why the answer belongs in that kind of document. Give the link. A
summary teaches nothing and can paraphrase the page wrongly.

**Do not answer from memory.** Signatures, argument names, and defaults change
between versions. Quote the documentation or the checkout. Say which one you
used.

**Write in simplified technical English.** Use short sentences. Use the active
voice. Keep each answer below 100 words.

This skill is **orient**, the first of the five stages in `stan-contributing`.
People are often here before they know they have a contribution to make. If
nothing documents the answer, that is a finding. See the last section.

## Classify the question

| The question is really | Category | Go to |
| :-- | :-- | :-- |
| "What is this? What arguments does it take?" | Reference | Reference manual, functions reference, package API index |
| "How do I solve this specific task?" | How-to | Vignettes, user's guide, case studies |
| "I'm new — where do I start?" | Tutorial | Tutorials, example models, user's guide walkthroughs |
| "Why is it like this?" | Explanation | Papers, wiki, Discourse, design-docs |

The four are not a ranking, and no single document has to serve all of them.

## Reference — "What is this?"

Dry, complete, factual. Structured for lookup, not for reading front to back.

- **The Stan language itself** — blocks, types, constraints, what makes a valid
  program → [Stan reference manual](https://mc-stan.org/docs/reference-manual/).
  The grammar book.
- **A built-in Stan function** — what `normal_lpdf` does, what types it expects
  → [Functions reference](https://mc-stan.org/docs/functions-reference/).
  The dictionary.
- **A function in an R or Python package** — what `loo()` does and what
  arguments it takes → that package's API index, e.g.
  [loo](https://mc-stan.org/loo/reference/index.html),
  [posterior](https://mc-stan.org/posterior/reference/index.html),
  [bayesplot](https://mc-stan.org/bayesplot/reference/index.html),
  [ArviZ](https://python.arviz.org/). The manual for one specific tool.

In a checkout, the source is the fastest reference. It is also the only one
that matches the installed version. Published documentation can describe another
release. Say this when you suggest the command:

```bash
grep -rn "<FUNCTION NAME>" R/ man/     # R
grep -rn "<FUNCTION NAME>" src/        # Python
```

## How-to — "How do I solve this?"

Recipes for a specific task, for someone who already knows the basics.

- **Modelling techniques in Stan** — reparameterisation, missing data, ragged
  arrays, efficiency → [Stan user's guide](https://mc-stan.org/docs/stan-users-guide/)
- **Using a package for something** → that package's vignettes/articles, e.g.
  [plotting MCMC draws with bayesplot](https://mc-stan.org/bayesplot/articles/plotting-mcmc-draws.html),
  [LOO cross-validation with loo](https://mc-stan.org/loo/articles/loo2-example.html),
  [multivariate models in brms](https://paulbuerkner.com/brms/articles/brms_multivariate.html)

## Tutorial — "How do I get started?"

Guided lessons through a complete working example. The goal is familiarity, not
solving your particular problem; the path is chosen for you and is meant to
succeed.

- [Tutorials](https://mc-stan.org/learn-stan/tutorials.html#tutorials)
- [Case studies](https://mc-stan.org/learn-stan/case-studies.html)
- [Bayesian Workflow book](https://avehtari.github.io/Bayesian-Workflow/casestudies.html)
  and [Aki Vehtari's case studies](https://users.aalto.fi/~ave/casestudies.html),
  for how the pieces fit into a full workflow

## Explanation — "Why is it like this?"

Context, design decisions, alternatives considered. Read away from the keyboard.
The only category where opinion and history belong.

- **The reasoning behind a method, and how it was validated** → the paper
  accompanying the package:
  [posterior](https://joss.theoj.org/papers/10.21105/joss.10526),
  [brms](https://www.jstatsoft.org/article/view/v080i01),
  [bayesplot](https://rss.onlinelibrary.wiley.com/doi/full/10.1111/rssa.12378),
  [ArviZ](https://joss.theoj.org/papers/10.21105/joss.09889)
- **Why Stan is designed a particular way** →
  [Discourse](https://discourse.mc-stan.org) and the
  [Developer Wiki](https://github.com/stan-dev/stan/wiki)
- **A proposed or past design change** →
  [design-docs](https://github.com/stan-dev/design-docs)

## When the answer is not written down anywhere

That is itself a finding. Two useful responses:

- **Ask on [Discourse](https://discourse.mc-stan.org)**, then, once you have the
  answer, consider whether it belongs in the documentation.
- **Open a documentation issue** saying what you looked for, where you looked,
  and what you expected to find. "I expected this in the functions reference and
  it is only on Discourse" is an actionable report. Load `stan-issue-and-pr`.

Documentation gaps are among the most valuable things a newcomer can report,
because only a newcomer notices them.
