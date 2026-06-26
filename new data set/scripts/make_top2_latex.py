#!/usr/bin/env python3
import csv
import re
from datetime import datetime
from pathlib import Path


BASE = Path(__file__).resolve().parents[1]
PROCESSED = BASE / "processed"
REPORTS = BASE / "reports"
REPORTS.mkdir(parents=True, exist_ok=True)

INPUT_CSV = PROCESSED / "ai_timeline_aa_top2_for_review.csv"
OUT_TEX = REPORTS / "ai_timeline_aa_top2_review_latex.tex"


def latex_escape(value):
    text = str(value or "")
    replacements = {
        "\\": r"\textbackslash{}",
        "&": r"\&",
        "%": r"\%",
        "$": r"\$",
        "#": r"\#",
        "_": r"\_",
        "{": r"\{",
        "}": r"\}",
        "~": r"\textasciitilde{}",
        "^": r"\textasciicircum{}",
    }
    return "".join(replacements.get(ch, ch) for ch in text)


def latex_text(value, strike=False):
    text = latex_escape(value)
    if not text:
        return ""
    if strike:
        return r"\sout{" + text + "}"
    return text


def compact_event(value):
    text = str(value or "")
    text = re.sub(r"\s+", " ", text).strip()
    return text


def load_rows():
    with INPUT_CSV.open(encoding="utf-8", newline="") as f:
        rows = list(csv.DictReader(f))
    for row in rows:
        row["AI Timeline event"] = compact_event(row["AI Timeline event"])
    return rows


def render_row(row):
    bad1 = row.get("Candidate 1 time mismatch") == "yes"
    bad2 = row.get("Candidate 2 time mismatch") == "yes"
    cells = [
        latex_text(row.get("AI Timeline event", "")),
        latex_text(row.get("AI Timeline date", "")),
        latex_text(row.get("AA most likely model", ""), bad1),
        latex_text(row.get("AA most likely release date", ""), bad1),
        latex_text(row.get("Confidence 1-10", ""), bad1),
        latex_text(row.get("AA second likely model", ""), bad2),
        latex_text(row.get("AA second release date", ""), bad2),
        latex_text(row.get("Confidence 2 1-10", ""), bad2),
    ]
    return " & ".join(cells) + r" \\ \hline"


def build_tex(rows):
    body = "\n".join(render_row(row) for row in rows)
    generated = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    return rf"""\documentclass[a4paper,landscape]{{article}}
\usepackage[a4paper,landscape,margin=0.45cm]{{geometry}}
\usepackage{{fontspec}}
\usepackage{{xeCJK}}
\usepackage{{array}}
\usepackage{{longtable}}
\usepackage[table]{{xcolor}}
\usepackage{{ragged2e}}
\usepackage[normalem]{{ulem}}
\usepackage{{booktabs}}
\usepackage{{caption}}
\usepackage{{hyperref}}

\setmainfont{{Arial Unicode MS}}
\setsansfont{{Arial Unicode MS}}
\setCJKmainfont{{Songti SC}}
\pagestyle{{empty}}
\setlength{{\parindent}}{{0pt}}
\setlength{{\tabcolsep}}{{2.2pt}}
\renewcommand{{\arraystretch}}{{1.03}}
\setlength{{\LTpre}}{{0pt}}
\setlength{{\LTpost}}{{0pt}}
\newcolumntype{{L}}[1]{{>{{\RaggedRight\arraybackslash}}p{{#1}}}}
\newcolumntype{{C}}[1]{{>{{\Centering\arraybackslash}}p{{#1}}}}

\begin{{document}}
\scriptsize
\textbf{{AI Timeline 与 AA 模型候选匹配表}}\hfill 生成时间 {latex_escape(generated)}

\vspace{{2pt}}
{{\footnotesize A4 横向。若 AA 发布时间与 AI Timeline 时间相差超过 12 个月，则对该候选加删除线。}}

\vspace{{3pt}}
\rowcolors{{2}}{{white}}{{gray!5}}
\begin{{longtable}}{{|L{{8.15cm}}|C{{1.85cm}}|L{{4.15cm}}|C{{1.75cm}}|C{{0.9cm}}|L{{4.15cm}}|C{{1.75cm}}|C{{0.9cm}}|}}
\hline
\rowcolor{{gray!85}}
\textcolor{{white}}{{\textbf{{AI Timeline 事件}}}} &
\textcolor{{white}}{{\textbf{{AI Timeline 时间}}}} &
\textcolor{{white}}{{\textbf{{AA 最可能模型}}}} &
\textcolor{{white}}{{\textbf{{发布时间}}}} &
\textcolor{{white}}{{\textbf{{可信度}}}} &
\textcolor{{white}}{{\textbf{{AA 第二可能模型}}}} &
\textcolor{{white}}{{\textbf{{发布时间}}}} &
\textcolor{{white}}{{\textbf{{可信度}}}} \\
\hline
\endfirsthead
\hline
\rowcolor{{gray!85}}
\textcolor{{white}}{{\textbf{{AI Timeline 事件}}}} &
\textcolor{{white}}{{\textbf{{AI Timeline 时间}}}} &
\textcolor{{white}}{{\textbf{{AA 最可能模型}}}} &
\textcolor{{white}}{{\textbf{{发布时间}}}} &
\textcolor{{white}}{{\textbf{{可信度}}}} &
\textcolor{{white}}{{\textbf{{AA 第二可能模型}}}} &
\textcolor{{white}}{{\textbf{{发布时间}}}} &
\textcolor{{white}}{{\textbf{{可信度}}}} \\
\hline
\endhead
{body}
\end{{longtable}}
\end{{document}}
"""


def main():
    rows = load_rows()
    OUT_TEX.write_text(build_tex(rows), encoding="utf-8")
    print(OUT_TEX)
    print(len(rows))


if __name__ == "__main__":
    main()
