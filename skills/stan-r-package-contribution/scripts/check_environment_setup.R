#!/usr/bin/env Rscript

# Checks that your environment is ready for a fresh pull request to an R package
# in the Stan ecosystem. Run from the root of your clone:
#
#   Rscript path/to/skills/stan-r-package-contribution/scripts/check_environment_setup.R
#
# It checks:
#   1. that you are in the root of an R package
#   2. that the repository has a contributing guide
#   3. that your roxygen2 version matches the one pinned in DESCRIPTION
#   4. that the development packages are installed
#   5. that no uncommitted change can leak into the pull request
#   6. that you are on the base branch, or on a branch you made for this change
#   7. that the gh CLI is authenticated
#
# It reports problems and exits non-zero if any would produce an unreviewable
# pull request. Nothing is installed or modified.
#
# Check 6 asks a question if you are on some other branch. Answer it, or pass
# --branch-ok to say that the branch belongs to this contribution.

args <- commandArgs(trailingOnly = TRUE)
branch_ok_flag <- "--branch-ok" %in% args

ok <- TRUE

say <- function(status, msg) {
  cat(sprintf("[%-4s] %s\n", status, msg))
  if (status == "FAIL") ok <<- FALSE
}

git <- function(...) {
  out <- suppressWarnings(
    system2("git", c(...), stdout = TRUE, stderr = FALSE)
  )
  status <- attr(out, "status")
  if (!is.null(status) && status != 0) return(character(0))
  out
}

ask_yes_no <- function(question) {
  cat(question)
  con <- file("stdin")
  on.exit(try(close(con), silent = TRUE))
  answer <- tryCatch(readLines(con, n = 1L), error = function(e) character(0))
  cat("\n")
  if (!length(answer)) return(NA)
  tolower(trimws(answer[1])) %in% c("y", "yes")
}

cat("\nEnvironment check for an R package contribution.\n")
cat("Reads DESCRIPTION, your R library, and your git state. Changes nothing.\n")
cat("FAIL blocks a reviewable pull request. WARN is worth a look.\n\n")

# --- 1. Are we in an R package? ----------------------------------------------

if (!file.exists("DESCRIPTION")) {
  say("FAIL", "No DESCRIPTION file. Run this from the root of the package clone.")
  quit(status = 1)
}

desc <- read.dcf("DESCRIPTION")
pkg <- if ("Package" %in% colnames(desc)) desc[1, "Package"] else "<unknown>"
say("OK", sprintf("Package: %s", pkg))

# --- 2. Contributing guide ---------------------------------------------------

guides <- c(".github/CONTRIBUTING.md", "CONTRIBUTING.md", "docs/CONTRIBUTING.md")
found <- guides[file.exists(guides)]
if (length(found)) {
  say("OK", sprintf("Contributing guide: %s -- read it before you start.", found[1]))
} else {
  say("WARN", "No CONTRIBUTING.md found. Check the repository wiki and website.")
}

# --- 3. roxygen2 pin ---------------------------------------------------------
# The single highest-value check here. roxygen2 8.x renamed the RoxygenNote
# field and changed how \link{} is written, so documenting with a mismatched
# version silently reformats every .Rd file in man/ and buries the real diff.

pin_field <- intersect(c("Config/roxygen2/version", "RoxygenNote"), colnames(desc))

if (!length(pin_field)) {
  say("WARN", "DESCRIPTION pins no roxygen2 version; skipping version check.")
} else {
  pinned <- unname(trimws(desc[1, pin_field[1]]))
  installed <- tryCatch(
    as.character(utils::packageVersion("roxygen2")),
    error = function(e) NA_character_
  )

  if (is.na(installed)) {
    say("FAIL", sprintf("roxygen2 is not installed; this package pins %s.", pinned))
    cat(sprintf('       remotes::install_version("roxygen2", version = "%s")\n', pinned))
  } else if (identical(installed, pinned)) {
    say("OK", sprintf("roxygen2 %s matches the pin in DESCRIPTION.", installed))
  } else {
    say("FAIL", sprintf(
      "roxygen2 mismatch: installed %s, DESCRIPTION pins %s.", installed, pinned
    ))
    cat("       Documenting now would rewrite every file in man/.\n")
    cat(sprintf('       remotes::install_version("roxygen2", version = "%s")\n', pinned))
  }
}

# --- 4. Development dependencies ---------------------------------------------

for (p in c("devtools", "usethis", "testthat")) {
  if (requireNamespace(p, quietly = TRUE)) {
    say("OK", sprintf("%s installed.", p))
  } else {
    say("FAIL", sprintf('%s not installed: install.packages("%s")', p, p))
  }
}

if (dir.exists("tests/testthat/_snaps")) {
  if (requireNamespace("vdiffr", quietly = TRUE)) {
    say("OK", "vdiffr installed (this package uses snapshot tests).")
  } else {
    say("FAIL", 'This package has snapshot tests: install.packages("vdiffr")')
  }
}

# --- 5. A clean working tree -------------------------------------------------
# Changes that are already in the tree end up in the pull request. A fresh
# contribution starts from a tree that holds nothing else.

in_git <- length(git("rev-parse", "--is-inside-work-tree")) > 0L

if (!in_git) {
  say("WARN", "Not a git repository. Skipping the branch checks.")
} else {
  changes <- git("status", "--porcelain")
  untracked <- grepl("^\\?\\?", changes)
  modified <- changes[!untracked]

  if (!length(changes)) {
    say("OK", "Working tree clean.")
  } else {
    if (length(modified)) {
      say("WARN", sprintf(
        "%d tracked file(s) already changed. They land in your pull request.",
        length(modified)
      ))
      for (line in utils::head(modified, 5L)) cat(sprintf("       %s\n", line))
      cat("       Commit, stash, or discard them before you start.\n")
    }
    if (any(untracked)) {
      say("WARN", sprintf(
        "%d untracked file(s). Keep them out of git add.", sum(untracked)
      ))
    }
  }

  # --- 6. Branch -------------------------------------------------------------
  # This check runs before you create the contribution branch. So you are
  # normally on the base branch of the repository. The Stan R packages use
  # main or master. The C++ repositories (stan, math) use develop.

  base_branches <- c("main", "master", "develop")
  branch <- git("rev-parse", "--abbrev-ref", "HEAD")
  branch <- if (length(branch)) branch[1] else NA_character_

  ref_exists <- function(ref) {
    length(git("rev-parse", "--verify", "--quiet", ref)) > 0L
  }
  has_develop <- ref_exists("develop") || ref_exists("origin/develop")

  if (is.na(branch)) {
    say("WARN", "Cannot read the current branch.")
  } else if (branch %in% base_branches) {
    say("OK", sprintf(
      "On base branch '%s'. Step 4 creates your branch from it.", branch
    ))
    if (has_develop && branch != "develop") {
      say("WARN", "This repository also has 'develop'. Check which one it merges into.")
    }
  } else {
    question <- sprintf(
      paste0(
        "       Branch '%s' is not a base branch.\n",
        "       Did you create it for this contribution? [y/N] "
      ),
      branch
    )
    answer <- if (branch_ok_flag) TRUE else ask_yes_no(question)

    if (isTRUE(answer)) {
      say("OK", sprintf("On '%s', your branch for this change. Commit here.", branch))
    } else if (isFALSE(answer)) {
      say("FAIL", sprintf("Branch '%s' is not for this contribution.", branch))
      cat("       Your change would start from somebody else's work.\n")
      cat("       git checkout main   # or master, or develop\n")
      cat('       usethis::pr_init("123-short-description")\n')
    } else {
      say("FAIL", sprintf("Branch '%s' is not a base branch. No answer.", branch))
      cat("       Run this script in a terminal and answer the question.\n")
      cat("       Or pass --branch-ok if the branch is for this change.\n")
    }
  }
}

# --- 7. gh CLI ---------------------------------------------------------------
# Used to read issue threads and check whether a maintainer's branch is stale.

gh <- suppressWarnings(system2("gh", c("auth", "status"), stdout = FALSE, stderr = FALSE))
if (identical(gh, 0L)) {
  say("OK", "gh CLI authenticated.")
} else {
  say("WARN", "gh CLI missing or not authenticated (gh auth login). Optional but useful.")
}

# --- Summary -----------------------------------------------------------------

cat("\n")
if (ok) {
  cat("Environment ready. Next: create a branch, then write the code.\n")
} else {
  cat("Fix every FAIL above before you start the change.\n")
  quit(status = 1)
}
