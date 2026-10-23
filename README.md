# paper-forge

A Claude Code plugin for writing research papers in Markdown and publishing them as LaTeX PDFs in the format of IEEE, ACM, Springer, Elsevier, or a specific venue's own template.

The paper is written in Pandoc Markdown, converted to LaTeX fragments by Pandoc, and typeset with LaTeX inside the publisher's document class. Markdown is easy for people and AI assistants to write, review, and diff; LaTeX keeps full control of the final layout and the publisher's native bibliography style. Publisher-specific details live in three files per project: `latex/main.tex`, `paper/metadata.yaml` (reference prefixes), and `STYLE.md` (conventions the skills follow).

```text
paper/*.md ──pandoc + pandoc-crossref + tables.lua──▶ latex/generated/*.tex
                                                              │
references/references.bib, figures/*.pdf, latex/main.tex ────┴──latexmk──▶ build/paper.pdf
```

## Skills

| Skill | Purpose |
| --- | --- |
| `paper-init` | Create a paper project from a bundled template, or download and adapt a venue's official template |
| `paper-outline` | Plan contributions, sections, and needed evidence (`paper/outline.md`) |
| `paper-write` | Draft and revise sections in Pandoc Markdown, following the venue's `STYLE.md` |
| `paper-citations` | Import verified BibTeX by DOI/arXiv, normalize entries, check keys |
| `paper-figures` | Reproducible vector figures from Python scripts; sizing, captions, labels |
| `paper-tables` | Markdown tables for simple data, raw LaTeX `booktabs` for complex tables |
| `paper-convert` | Troubleshoot the Markdown→LaTeX stage; import existing LaTeX/Word papers |
| `paper-build` | Build the PDF and trace LaTeX/BibTeX errors back to the Markdown |
| `paper-review` | Peer-review-style critique of contributions, evidence, and writing |
| `paper-validate` | Pre-submission checks: citations, references, figures, logs, page limit, fonts, anonymity |

Skills are invoked automatically from the request ("start an ACM CCS paper", "set up a paper for Computers & Security", "add a citation for this DOI", "why does the build fail?") or explicitly, e.g. `/paper-forge:paper-init ieee-conference my-paper`.

Every skill follows the same rules: Markdown in `paper/` is the source of truth, files in `latex/generated/` are never edited, and references, results, and data are never fabricated. Gaps are marked `[TODO: ...]` or `[CITATION NEEDED]`.

## Templates

| Template | Class | Notes |
| --- | --- | --- |
| `ieee-conference` | `IEEEtran` `[conference]` | IEEE conferences |
| `ieee-journal` | `IEEEtran` `[journal]` | IEEE Transactions / IEEE Access style, with `\markboth` and `\IEEEmembership` |
| `acm` | `acmart` `[sigconf]` | ACM conferences; `acmsmall` for ACM journals. Adds `\Description` to figures automatically |
| `springer-lncs` | `llncs` | Springer LNCS / LNAI / CCIS proceedings |
| `elsevier` | `elsarticle` | Elsevier journals (preprint layout; `final,5p,twocolumn` for the journal look) |
| `generic-article` | `article` + `natbib` | Preprints (arXiv), reports, venues without a template |

**Venue templates.** For venues that distribute their own class (Springer Nature journals, MDPI, Wiley, USENIX, NeurIPS, ...), `paper-init` finds the official template, downloads it into a scratch directory, copies the class and bibliography style into `latex/`, writes `latex/main.tex` from the sample file, and writes `STYLE.md` from the author instructions. The original sample is kept in `latex/venue-template/`.

`templates/common/` holds the files shared by all templates; each template directory adds `latex/main.tex`, `paper/metadata.yaml`, `STYLE.md`, and optionally its own Pandoc filters in `latex/filters/`. A new project looks like this:

```text
my-paper/
├── AGENTS.md, CLAUDE.md     # authoring rules for AI assistants
├── STYLE.md                 # publisher conventions: citations, prefixes, widths, front matter
├── build.sh                 # setup | build | check | preview | snapshot (wraps the Makefile)
├── Makefile, requirements.txt, scripts/validate.py
├── paper/
│   ├── metadata.yaml        # pandoc-crossref prefixes ("Fig."/"Figure", "Sect."/"Section", ...)
│   ├── abstract.md
│   └── sections/01-introduction.md … 06-conclusion.md
├── references/references.bib
├── figures/                 # figures/src/<name>.py builds figures/<name>.pdf
├── latex/
│   ├── main.tex             # document class, title, authors, keywords
│   ├── tex-packages.txt     # TeX packages for a local TinyTeX
│   ├── pandoc-compat.tex    # macros Pandoc output needs; natbib→\cite mapping
│   ├── filters/*.lua        # Markdown tables → booktabs floats; template-specific filters
│   └── generated/           # Pandoc output (do not edit)
├── drafts/
│   ├── 00-raw/              # ideas, literature notes, preliminary results
│   └── NN-label/            # frozen milestone snapshots (01-outline, 02-first-draft, ...)
└── build/paper.pdf
```

`drafts/00-raw/` collects unverified raw material that the outline and writing skills draw on. `make snapshot NAME=02-first-draft` freezes `paper/`, `references/`, `figures/`, and the PDF into `drafts/02-first-draft/`. The skills offer snapshots at milestones and compare against them during review.

Implementation choices beyond the basic Pandoc pipeline:

- Citations go through `--natbib`; for classes without natbib (IEEEtran, llncs), `pandoc-compat.tex` maps `\citep`/`\citet` to `\cite`, so BibTeX with the publisher's `.bst` formats the bibliography.
- Pandoc's `longtable` output fails in two-column layouts; `tables.lua` emits `table` + `tabular` with the caption above, as all four publishers require.
- Figure and `\input` paths are relative to the project root.
- Computer Modern templates load `lmodern`, so PDFs contain no bitmap (Type 3) fonts; the validator checks for them.
- A fresh project builds before any citation exists.

## Building

Each project has a `build.sh` in its root; the skills only run it and act on its last line.

```bash
./build.sh setup     # once per project: local toolchain in .tools/ and .venv/
./build.sh           # BUILD OK: build/paper.pdf, N page(s); check: ...  |  FAILED <stage>: ... at: paper/sections/x.md:12
./build.sh check     # all findings: citations, references, figures, fonts, page limit (--max-pages, --anonymous)
./build.sh preview   # pages as PNGs in build/preview/
./build.sh snapshot 02-first-draft
```

`setup` installs Pandoc and pandoc-crossref (pinned, matching versions), TinyTeX with the template's packages if no system TeX provides the document class, and a Python virtual environment for figure scripts. Packages missing during a build are installed into the local TinyTeX automatically. Set `PAPER_FORGE_TOOLS` and `PAPER_FORGE_VENV` to share one installation between projects.

Platforms: macOS (Apple Silicon, Intel) and Linux (x86_64, arm64, including WSL on Windows). Prerequisites: `bash`, `curl`, `make`, `perl`, `xz`, and `python3` — on Debian/Ubuntu `sudo apt install curl make perl xz-utils python3`, on macOS `xcode-select --install`.

## Usage

### Install from GitHub

The repository is also a plugin marketplace (`.claude-plugin/marketplace.json`). Add it and install the plugin from your shell:

```bash
claude plugin marketplace add rysavy-ondrej/paper-forge
claude plugin install paper-forge@paper-forge
```

or inside a Claude Code session:

```text
/plugin marketplace add rysavy-ondrej/paper-forge
/plugin install paper-forge@paper-forge
```

Check it with `claude plugin list`. To get new versions later, run `claude plugin marketplace update paper-forge`, or `/plugin` in a session and update from the marketplace's page. To remove it: `claude plugin uninstall paper-forge@paper-forge`.

### Use a local checkout

For development, load the plugin from a clone for one session:

```bash
git clone https://github.com/rysavy-ondrej/paper-forge.git
claude --plugin-dir ./paper-forge
```

### Working with the skills

Ask in plain language, for example: "Create an IEEE conference paper project in `~/papers/triage`", "Set up a paper for the Springer journal Cybersecurity using their template", "Outline the paper from my notes", "Write the related work section", "Build the paper and fix the errors", "Validate the paper for a 6-page double-blind submission".

## Tests

`tests/demo-paper/` is a complete example project (synthetic data, real references). `tests/run-tests.sh` builds every template from scratch and the demo content with every template through `./build.sh`, and tests checks, snapshots, and failure reports; CI runs it on Linux and macOS; see [tests/README.md](tests/README.md).

## Repository layout

```text
.claude-plugin/plugin.json   # plugin manifest
.claude-plugin/marketplace.json  # marketplace listing for GitHub installs
skills/<name>/SKILL.md       # one directory per skill
templates/{common,ieee-conference,ieee-journal,acm,springer-lncs,elsevier,generic-article}/
tests/                       # run-tests.sh, demo-paper/
.github/workflows/tests.yml  # CI on Linux and macOS
```
