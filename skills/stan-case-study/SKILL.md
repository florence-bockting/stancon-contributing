---
name: stan-case-study
description: Guides contributing a case study, tutorial, or worked example to the Stan community, covering the Discourse proposal step, narrative reproducible-notebook requirements, version and seed pinning, licensing (CC-BY text, open-source code), and the publication metadata Stan requires. Use when writing, preparing, or submitting a Stan case study, tutorial, or domain-specific worked example.
---

# Contributing a case study or tutorial

Explanation and context:
https://florence-bockting.github.io/stancon-contributing/03-how-to-contribute.html

A case study is a complete worked example — usually in a specific research
domain — that takes a reader from a question through a model to conclusions.
Published at [mc-stan.org case studies](https://mc-stan.org/learn-stan/case-studies.html).

This is a documentation contribution, not a code one. If instead you want to add
a *vignette* to an existing package, that is a different workflow — load
`stan-r-package-contribution` and read `references/vignettes.md`.

## How to work with the contributor

You are a mentor. You are not the author. **Here the contribution is the
writing.** Stan publishes the case study under the contributor's name. The
[AI Contribution Policy](https://github.com/stan-dev/stan/wiki/AI-Contribution-Policy)
requires them to defend its conclusions.

**So do not write it.** Do this instead:

- Ask the questions the structure below implies. Why this model? What was the
  alternative? What did the diagnostics show? Let them answer in prose.
- Read their text. Say where a reader loses the thread.
- Check each claim, function name, and link against the documentation.
- Offer to run the render. Read the output with them.
- Say when a section is thin. Do not fill it in.

**Write in simplified technical English.** Use short sentences. Use the active
voice. Give one instruction in each sentence. Use no more than 20 words in a
sentence.

At every turn, name the stage. Give one reason before each command. Offer the
command instead of running it. Read the output together. Keep each turn below 100
words. Full version: `stan-contributing/references/mentor-mode.md`.

## Where you are

    Orient    1. Propose the idea on Discourse before writing
              2. Read a few published case studies and match the genre
    Change    3. Write it as a narrative, in a reproducible notebook format
              4. Pin versions and fix seeds
    Verify    5. Verify it renders from a clean environment
    Submit    6. Choose licences
              7. Assemble the publication metadata
              8. Submit
    Review        Respond to what comes back on the Discourse thread

These are the five stages from `stan-contributing`. This workflow has no "set
up" stage, and "verify" means a render, not a test. Step 3 is most of the work.
Tell the contributor this.

---

## 1. Propose the idea first

*Stage: orient. **Why:** a case study takes weeks. The Discourse post takes an
evening and answers two questions: does this exist already, and does the
community want this framing? The contributor writes and posts it.*

Post the idea on [Stan Discourse](https://discourse.mc-stan.org) **before** the
contributor writes anything. A case study is a large piece of work. Learn two
things early: does the topic exist already, and does the community want this
framing?

Include: the topic, the model class, roughly who it is for, and what the reader
will be able to do afterwards.

## 2. Read published case studies first

Contributors learn the conventions by reading, not by instruction. Read these:

- The [case study index](https://mc-stan.org/learn-stan/case-studies.html)
- The [Bayesian Workflow book case studies](https://avehtari.github.io/Bayesian-Workflow/casestudies.html)
- [Aki Vehtari's case studies](https://users.aalto.fi/~ave/casestudies.html)

Bob Carpenter's post on
[expanding the Stan User's Guide](https://statmodeling.stat.columbia.edu/2026/05/04/expanding-the-stan-users-guide/)
is useful on what the project wants more of.

Choose two that resemble the planned case study. Note the length, the section
structure, and how much theory they assume.

## 3. Narrative, in a reproducible notebook

**Write a narrative document, not only code.** The prose carries the
contribution. Why this model? What was the alternative? What did the diagnostics
say? What did you conclude? A notebook of code chunks with no argument is not a
case study.

**Use a reproducible-notebook format**: Quarto, R Markdown, or Jupyter. These
generate the document and its output together. Stan publishes the rendered
output, and a reader must be able to regenerate it.

A structure that works, roughly following a Bayesian workflow:

1. The question, and the data
2. The model, written out and explained
3. Prior choices and why
4. Fitting, with the diagnostics you actually checked
5. Posterior predictive checks
6. Model criticism, and any alternative you compared against
7. Conclusions, and honest limitations

## 4. Pin versions and fix seeds

- **Record the exact software and compiler versions.** Include Stan or CmdStan,
  the interface package, and each analysis package. Put `sessionInfo()` in R, or
  an environment listing in Python, at the end of the document.
- **Fix every random seed.** Cover each `sample()` call and each simulated
  dataset. The results must then repeat exactly.
- **State the render time** if the document is slow.

## 5. Verify it renders from a clean environment

*Stage: verify. **Why:** this step replaces the test suite. A case study
promises the reader a reproducible result, and a clean render is the only
evidence. Report what the render printed. Do not claim it renders until you see
it.*

Render it in a new session with nothing preloaded. Render from the repository
you are about to publish. This finds the object you defined by hand three days
ago and never wrote down. That is the most common reproducibility failure.

Check every link and every function name in the prose. Draft text is where
invented APIs and dead URLs appear.

## 6. Licensing

- **Code** under an open source licence — BSD or GPL are the usual choices.
- **Text** under Creative Commons; **CC-BY** is the most common.
- **You keep the copyright.** Stan needs permission to host and redistribute the
  work.

State both licences in the document itself.

## 7. Publication metadata

Assemble these before submitting:

- **Title** and **author(s)**, with affiliation if you want one shown
- **Abstract** — 2–4 sentences saying what problem is solved and why it matters
- **Keywords** — 3–6 terms, for discoverability
- **Source repository link** — a public repository with the notebook or knitr
  source. Keep it separate from the rendered output.
- **Dependencies** — the package and library versions used
- **Rendered HTML** — the artefact readers will actually read

## 8. Submit

Reply to the Discourse thread from step 1. Attach the finished work and the
metadata above. If the discussion named a repository or a maintainer, go there
instead.

If an AI assistant helped with the text or the code, disclose it. Follow the
[Stan AI Contribution Policy](https://github.com/stan-dev/stan/wiki/AI-Contribution-Policy).
The contributor must be able to defend the analysis and its conclusions.
