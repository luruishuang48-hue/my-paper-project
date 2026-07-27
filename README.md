# Generative AI Model Releases and Technology-Stock Returns

This repository reproduces the manuscript
`Tex_new/frl_three_results.tex` and its online appendix.

The analysis links 125 day-verified generative-AI model releases to 45
securities in the Nasdaq-100 Technology Sector Index. One event with a
contested identity remains in the balanced panel and is excluded from the
regression sample, leaving 124 events in the reported estimates.

The paper reports three results.

1. Positive twenty-day abnormal returns are concentrated among hardware
   suppliers and rival model developers.
2. Both responses emerge after 2025, with a larger increase among hardware
   suppliers.
3. Model capability is positively associated with the hardware response.

## One-command reproduction

Install Python 3.11 or later, R 4.3 or later, and a LaTeX distribution with
`latexmk`. Then run:

```sh
python3 -m pip install -r requirements.txt
Rscript install_r_packages.R
./run_reproduction.sh
```

The repository contains the source snapshots needed for an offline rerun.
Download steps read these caches first and contact the original source only
when a required cache file is absent.

Successful completion produces:

- `Analysis/reproduction/validation.json` with `"passed": true`
- `Tex_new/frl_three_results.pdf`
- `Tex_new/frl_three_results_online_appendix.pdf`

## Public project structure

- `事件集筛选/` builds the event sample and merges Artificial Analysis metrics.
- `事件标签/` contains the two event codings, adjudication evidence, and validator.
- `企业列表/` contains the official May 1, 2026 NDXT snapshot and its builder.
- `关系标签/` contains the two firm-developer codings, codebook, and validator.
- `CAR/` contains cached daily prices, factors, market benchmarks, and builders.
- `Fundamentals/` contains cached accounting inputs and the quarterly-data builder.
- `Analysis/` builds the event-firm panel and reproduces every reported estimate.
- `Tex_new/` contains the current manuscript, online appendix, and figure.

The hand-verified decision tables in `事件集筛选/decisions/` are versioned
research inputs. Scripts rebuild all derived files from those decisions and
the archived source snapshots.

## Archive boundary

The local `history/` directory contains superseded manuscripts, old samples,
exploratory analyses, and internal review files. It is excluded by
`.gitignore` and is not part of the replication package.
