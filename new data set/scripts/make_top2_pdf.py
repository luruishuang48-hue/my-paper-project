#!/usr/bin/env python3
import csv
import html
import json
import re
from datetime import datetime
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.cidfonts import UnicodeCIDFont
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import PageBreak, Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle


BASE = Path(__file__).resolve().parents[1]
PROCESSED = BASE / "processed"
REPORTS = BASE / "reports"
REPORTS.mkdir(parents=True, exist_ok=True)

MATCHES_CSV = PROCESSED / "ai_timeline_aa_model_matches.csv"
AA_MODELS_CSV = PROCESSED / "aa_models.csv"
OUT_CSV = PROCESSED / "ai_timeline_aa_top2_for_review.csv"
OUT_PDF = REPORTS / "ai_timeline_aa_top2_review.pdf"

MONTHS = {
    "january": 1,
    "february": 2,
    "march": 3,
    "april": 4,
    "may": 5,
    "june": 6,
    "july": 7,
    "august": 8,
    "september": 9,
    "october": 10,
    "november": 11,
    "december": 12,
}


def load_csv(path):
    with path.open(encoding="utf-8", newline="") as f:
        return list(csv.DictReader(f))


def write_csv(path, rows, fieldnames):
    with path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)


def normalize(value):
    value = (value or "").lower()
    value = value.replace("‑", "-").replace("–", "-").replace("—", "-")
    value = re.sub(r"[^a-z0-9]+", " ", value)
    return re.sub(r"\s+", " ", value).strip()


def event_month_index(year, month_text):
    try:
        y = int(year)
    except Exception:
        return None
    token = str(month_text or "").replace("\xa0", " ").split()
    if not token:
        return None
    month = MONTHS.get(token[0].lower())
    if not month:
        return None
    return y * 12 + month


def release_month_index(value):
    value = str(value or "").strip()
    if not value:
        return None
    match = re.match(r"^(\d{4})-(\d{1,2})", value)
    if match:
        return int(match.group(1)) * 12 + int(match.group(2))
    match = re.match(r"^(\d{4})$", value)
    if match:
        return int(match.group(1)) * 12 + 6
    return None


def date_score(event_idx, release_idx):
    if event_idx is None or release_idx is None:
        return 0.55
    diff = abs(event_idx - release_idx)
    if diff <= 1:
        return 1.0
    if diff <= 3:
        return 0.85
    if diff <= 6:
        return 0.65
    if diff <= 12:
        return 0.40
    if diff <= 24:
        return 0.20
    return 0.05


def confidence_10(match_score, event_idx, release_idx):
    try:
        name_score = float(match_score)
    except Exception:
        name_score = 0.0
    d_score = date_score(event_idx, release_idx)
    score = 0.62 * name_score + 0.38 * d_score
    value = max(0.0, min(10.0, score * 10))
    if release_idx is None:
        value = min(value, 6.0 if name_score >= 0.85 else 5.0)
    elif event_idx is not None:
        diff = abs(event_idx - release_idx)
        if diff > 24:
            value = min(value, 5.5)
        elif diff > 12:
            value = min(value, 6.3)
        elif diff > 6:
            value = min(value, 7.2)
    if name_score < 0.60:
        value = min(value, 4.5)
    elif name_score < 0.75:
        value = min(value, 6.0)
    return round(value, 1)


def register_fonts():
    font_paths = [
        "/Library/Fonts/Arial Unicode.ttf",
        "/System/Library/Fonts/Supplemental/Arial Unicode.ttf",
    ]
    for p in font_paths:
        if Path(p).exists():
            pdfmetrics.registerFont(TTFont("DocFont", p))
            pdfmetrics.registerFont(TTFont("DocFont-Bold", p))
            return "DocFont", "DocFont-Bold"
    pdfmetrics.registerFont(UnicodeCIDFont("STSong-Light"))
    return "STSong-Light", "STSong-Light"


def esc(value):
    return html.escape(str(value or ""), quote=False)


def para(value, style, strike=False):
    text = esc(value).replace("\n", "<br/>")
    if strike and text:
        text = f"<strike>{text}</strike>"
    return Paragraph(text, style)


def build_aa_lookup(rows):
    by_slug = {}
    by_name_creator = {}
    by_name = {}
    for row in rows:
        slug = row.get("aa_slug", "")
        if slug:
            by_slug.setdefault(slug, row)
        key = (normalize(row.get("aa_name", "")), normalize(row.get("aa_creator", "")), row.get("aa_modality", ""))
        by_name_creator.setdefault(key, row)
        by_name.setdefault(normalize(row.get("aa_name", "")), row)
    return by_slug, by_name_creator, by_name


def find_aa_row(candidate, lookups):
    by_slug, by_name_creator, by_name = lookups
    slug = candidate.get("slug") or ""
    if slug in by_slug:
        return by_slug[slug]
    key = (normalize(candidate.get("name", "")), normalize(candidate.get("creator", "")), candidate.get("modality", ""))
    if key in by_name_creator:
        return by_name_creator[key]
    return by_name.get(normalize(candidate.get("name", "")), {})


def row_for_candidate(match_row, candidate, lookups):
    aa = find_aa_row(candidate, lookups)
    release = aa.get("release_date", "")
    score = candidate.get("score", "")
    event_idx = event_month_index(match_row.get("year"), match_row.get("month"))
    rel_idx = release_month_index(release)
    conf = confidence_10(score, event_idx, rel_idx)
    mismatch = is_large_time_mismatch(event_idx, rel_idx)
    name = candidate.get("name", "")
    creator = candidate.get("creator", "")
    if creator and creator not in name:
        display = f"{name} ({creator})"
    else:
        display = name
    return display, release, conf, mismatch


def is_large_time_mismatch(event_idx, release_idx):
    if event_idx is None or release_idx is None:
        return False
    return abs(event_idx - release_idx) > 12


def candidate_confidence(match_row, candidate, lookups):
    aa = find_aa_row(candidate, lookups)
    release = aa.get("release_date", "")
    return confidence_10(
        candidate.get("score", ""),
        event_month_index(match_row.get("year"), match_row.get("month")),
        release_month_index(release),
    )


def build_rows():
    matches = load_csv(MATCHES_CSV)
    aa_rows = load_csv(AA_MODELS_CSV)
    lookups = build_aa_lookup(aa_rows)
    out = []
    for row in matches:
        try:
            candidates = json.loads(row.get("top_candidates_json") or "[]")
        except Exception:
            candidates = []
        candidates = sorted(candidates, key=lambda c: candidate_confidence(row, c, lookups), reverse=True)
        c1 = candidates[0] if len(candidates) >= 1 else {}
        c2 = candidates[1] if len(candidates) >= 2 else {}
        m1, d1, s1, bad1 = row_for_candidate(row, c1, lookups) if c1 else ("", "", "", False)
        m2, d2, s2, bad2 = row_for_candidate(row, c2, lookups) if c2 else ("", "", "", False)
        event = f"{row.get('entity_name', '')} — {row.get('event_text', '')}"
        out.append(
            {
                "AI Timeline event": event,
                "AI Timeline date": f"{row.get('year', '')} {row.get('month', '')}".strip(),
                "AA most likely model": m1,
                "AA most likely release date": d1,
                "Confidence 1-10": s1,
                "Candidate 1 time mismatch": "yes" if bad1 else "",
                "AA second likely model": m2,
                "AA second release date": d2,
                "Confidence 2 1-10": s2,
                "Candidate 2 time mismatch": "yes" if bad2 else "",
                "match_level": row.get("match_level", ""),
                "entity_name": row.get("entity_name", ""),
            }
        )
    return out


def make_pdf(rows):
    font, bold = register_fonts()
    page_size = landscape(A4)
    doc = SimpleDocTemplate(
        str(OUT_PDF),
        pagesize=page_size,
        leftMargin=0.45 * cm,
        rightMargin=0.45 * cm,
        topMargin=0.45 * cm,
        bottomMargin=0.45 * cm,
    )
    styles = getSampleStyleSheet()
    title_style = ParagraphStyle(
        "TitleCN",
        parent=styles["Title"],
        fontName=bold,
        fontSize=11,
        leading=13,
        alignment=TA_LEFT,
        spaceAfter=6,
    )
    note_style = ParagraphStyle(
        "NoteCN",
        parent=styles["Normal"],
        fontName=font,
        fontSize=5.8,
        leading=7,
        alignment=TA_LEFT,
        textColor=colors.HexColor("#333333"),
    )
    cell_style = ParagraphStyle(
        "CellCN",
        parent=styles["Normal"],
        fontName=font,
        fontSize=4.65,
        leading=5.55,
        alignment=TA_LEFT,
        wordWrap="CJK",
    )
    head_style = ParagraphStyle(
        "HeadCN",
        parent=cell_style,
        fontName=bold,
        fontSize=4.9,
        leading=5.7,
        alignment=TA_CENTER,
        textColor=colors.white,
    )
    story = [
        Paragraph("AI Timeline 与 AA 模型候选匹配表", title_style),
        Paragraph(
            f"生成时间 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}。A4 横向。可信度为 10 分制，名称相似度占 62%，发布时间接近程度占 38%。候选发布时间来自 AA 字段 release_date。若 AA 发布时间与 AI Timeline 时间相差超过 12 个月，则用删除线标注该候选。",
            note_style,
        ),
        Spacer(1, 0.12 * cm),
    ]

    headers = [
        "AI Timeline 事件",
        "AI Timeline 时间",
        "AA 最可能模型",
        "模型发布时间",
        "可信度",
        "AA 第二可能模型",
        "模型发布时间",
        "可信度",
    ]
    col_widths = [8.6 * cm, 2.0 * cm, 4.6 * cm, 2.0 * cm, 1.15 * cm, 4.6 * cm, 2.0 * cm, 1.15 * cm]
    chunk_size = 18
    total = len(rows)
    for start in range(0, total, chunk_size):
        if start:
            story.append(PageBreak())
        chunk = rows[start : start + chunk_size]
        data = [[para(h, head_style) for h in headers]]
        for item in chunk:
            bad1 = item.get("Candidate 1 time mismatch") == "yes"
            bad2 = item.get("Candidate 2 time mismatch") == "yes"
            data.append(
                [
                    para(item["AI Timeline event"], cell_style),
                    para(item["AI Timeline date"], cell_style),
                    para(item["AA most likely model"], cell_style, bad1),
                    para(item["AA most likely release date"], cell_style, bad1),
                    para(item["Confidence 1-10"], cell_style, bad1),
                    para(item["AA second likely model"], cell_style, bad2),
                    para(item["AA second release date"], cell_style, bad2),
                    para(item["Confidence 2 1-10"], cell_style, bad2),
                ]
            )
        table = Table(data, colWidths=col_widths, repeatRows=1)
        table.setStyle(
            TableStyle(
                [
                    ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#1F2937")),
                    ("GRID", (0, 0), (-1, -1), 0.25, colors.HexColor("#D1D5DB")),
                    ("VALIGN", (0, 0), (-1, -1), "TOP"),
                    ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#F8FAFC")]),
                    ("LEFTPADDING", (0, 0), (-1, -1), 3),
                    ("RIGHTPADDING", (0, 0), (-1, -1), 3),
                    ("TOPPADDING", (0, 0), (-1, -1), 2),
                    ("BOTTOMPADDING", (0, 0), (-1, -1), 2),
                ]
            )
        )
        story.append(table)
    doc.build(story)


def main():
    rows = build_rows()
    fieldnames = [
        "AI Timeline event",
        "AI Timeline date",
        "AA most likely model",
        "AA most likely release date",
        "Confidence 1-10",
        "Candidate 1 time mismatch",
        "AA second likely model",
        "AA second release date",
        "Confidence 2 1-10",
        "Candidate 2 time mismatch",
        "match_level",
        "entity_name",
    ]
    write_csv(OUT_CSV, rows, fieldnames)
    make_pdf(rows)
    print(json.dumps({"rows": len(rows), "csv": str(OUT_CSV), "pdf": str(OUT_PDF)}, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
