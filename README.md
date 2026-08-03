# Contributing to Stan — StanCon 2026 Tutorial

Workshop materials for learning how to contribute to the Stan ecosystem. Content is written in [Quarto](https://quarto.org/) and can be rendered as either a full HTML book (notebook/handout) or RevealJS slide decks per section.

## Prerequisites

- [Quarto](https://quarto.org/docs/get-started/) 1.2 or later
- For the hands-on section: R with `devtools` (optional during render; required to run exercises)

Check your installation:

```bash
quarto --version
```

## Project structure

```
├── _quarto.yml              # Book config (default)
├── _quarto-slides.yml       # Slides profile (RevealJS)
├── index.qmd                # Welcome page
├── 01-what-is-stan.qmd      # Section 1
├── 02-ecosystem.qmd         # Section 2
├── 03-contributing.qmd      # Section 3
├── 04-hands-on.qmd          # Section 4
└── includes/                # Shared code for exercises
```

Each `0X-*.qmd` file is the single source for both that section's slides and its chapter in the book.

## Render the full book (notebook / handout)

From the repository root:

```bash
quarto render
```

Output: `_book/index.html` — open this in a browser for the full workshop handout with navigation between sections.

## Render slides

RevealJS slides must be rendered with the **slides profile**. The default book profile does not support slide output.

### One section

```bash
quarto render --profile slides 01-what-is-stan.qmd
quarto render --profile slides 02-ecosystem.qmd
quarto render --profile slides 03-contributing.qmd
quarto render --profile slides 04-hands-on.qmd
```

Output goes to `_slides/`:

| Section file | Slide deck |
|---|---|
| `01-what-is-stan.qmd` | `_slides/01-what-is-stan-slides.html` |
| `02-ecosystem.qmd` | `_slides/02-ecosystem-slides.html` |
| `03-contributing.qmd` | `_slides/03-contributing-slides.html` |
| `04-hands-on.qmd` | `_slides/04-hands-on-slides.html` |

Open the `.html` file in a browser to present. Use arrow keys to navigate; press `f` for fullscreen.

### All sections at once

```bash
quarto render --profile slides 01-what-is-stan.qmd \
               02-ecosystem.qmd \
               03-contributing.qmd \
               04-hands-on.qmd
```

## Preview while editing

Live preview of the book (default profile):

```bash
quarto preview
```

To preview slides for a section:

```bash
quarto preview --profile slides 02-ecosystem.qmd
```

## Optional: logo

Slide decks reference `img/stan_logo.png`. Add that file if you want the logo on each deck; rendering works without it.

## Reference guides

Longer background material lives in standalone Markdown files:

- [stan-ecosystem-guide.md](stan-ecosystem-guide.md)
- [how-to-contribute-stan-r-packages.md](how-to-contribute-stan-r-packages.md)

These are not part of the Quarto book render; the chapter `.qmd` files link to them for additional detail.
