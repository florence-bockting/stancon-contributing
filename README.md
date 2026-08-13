# Contributing to Stan — StanCon 2026 Tutorial

Workshop materials for learning how to contribute to the Stan ecosystem. Content is written in [Quarto](https://quarto.org/) and can be rendered as either a full HTML book (notebook/handout) or RevealJS slide decks per section.

## Prerequisites

- [Quarto](https://quarto.org/docs/get-started/) 1.2 or later
- R (optional for render; useful when following the R-package contribution checklist with `devtools`)

Check your installation:

```bash
quarto --version
```

## Project structure

```
├── _quarto.yml                 # Book config (default)
├── _quarto-slides.yml          # Slides profile (RevealJS)
├── index.qmd                   # Welcome page
├── 01-what-is-stan.qmd         # What is Stan?
├── 02-stan-ecosystem.qmd       # The Stan ecosystem
├── 03-how-to-contribute.qmd    # How to contribute
├── 04-find-information.qmd     # Where to find information
├── 05-checklist.qmd            # Contribution checklist
├── book.css / slides.css       # Styling
├── img/                        # Logos and figures
└── includes/                   # Shared slide/setup helpers
```

Each `0X-*.qmd` file is the single source for both that section's slides and its chapter in the book.

## Render the full book (notebook / handout)

From the repository root:

```bash
quarto render
```

Output: `_book/index.html` — open this in a browser for the full workshop handout with navigation between sections.

This also builds `_book/Contributing-to-Stan.pdf`, and the HTML book shows a **Download PDF** link in the sidebar.

### PDF requirements

The PDF is built with LaTeX. If you don't have a TeX installation, install Quarto's bundled one once:

```bash
quarto install tinytex
```

To skip the PDF while drafting (it adds a few LaTeX passes to every render):

```bash
quarto render --to html
```

## Render slides

RevealJS slides must be rendered with the **slides profile**. The default book profile does not support slide output.

### One section

```bash
quarto render --profile slides 00-intro.qmd
quarto render --profile slides 01-what-is-stan.qmd
quarto render --profile slides 02-stan-ecosystem.qmd
quarto render --profile slides 03-how-to-contribute.qmd
quarto render --profile slides 04-find-information.qmd
quarto render --profile slides 05-checklist.qmd
```

Output goes to `_slides/`:

| Section file | Slide deck |
|---|---|
| `01-what-is-stan.qmd` | `_slides/01-what-is-stan-slides.html` |
| `02-stan-ecosystem.qmd` | `_slides/02-stan-ecosystem-slides.html` |
| `03-how-to-contribute.qmd` | `_slides/03-how-to-contribute-slides.html` |
| `04-find-information.qmd` | `_slides/04-find-information-slides.html` |
| `05-checklist.qmd` | `_slides/05-checklist-slides.html` |

Open the `.html` file in a browser to present. Use arrow keys to navigate; press `f` for fullscreen.

### All sections at once

```bash
quarto render --profile slides 01-what-is-stan.qmd \
               02-stan-ecosystem.qmd \
               03-how-to-contribute.qmd \
               04-find-information.qmd \
               05-checklist.qmd
```

### The slides deck for the tutorial
```bash
quarto render --profile slides tutorial_presi.qmd --output tutorial_presi.html
```

Then open `tutorial_presi.html`.

## Preview while editing

Live preview of the book (default profile):

```bash
quarto preview
```

To preview slides for a section:

```bash
quarto preview --profile slides 02-stan-ecosystem.qmd
```

## Logo

Slide decks use `img/stan_logo.png`. Rendering works without it, but the logo is included in this repository.
