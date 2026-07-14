#!/usr/bin/env python3
"""FinBERT 标题情感分析（媒体情绪管道第 2 步）。取代旧版 finbert情感分析2.py。

相对旧版修复的问题：
  1. 标签顺序不再假设 [positive, negative, neutral]，而是从模型
     config.id2label 按名称建立映射——ProsusAI/finbert 与
     yiyanghkust/finbert-tone 的顺序不同，旧版若装的是后者则所有分数错误。
     标签集合非 {positive, negative, neutral} 时直接报错退出；
  2. 情感分数按位置写回（reset_index 后逐列赋值），消灭旧版
     "过滤后 index 不连续 + concat(axis=1) 按索引对齐" 造成的错位与 NaN 膨胀；
  3. 聚合窗口非对称且标签如实：pre [-7,-1]、event [0,+1]、post3 [0,+3]、
     post7 [0,+7]（日历日，新闻场景合理），不再有 (-2,-10) 这类空集窗口；
  4. 无交互式文件对话框；参数化 CLI；设备自动选择 cuda > mps > cpu。

用法：
  python3 finbert_sentiment.py --input ../processed/gdelt_articles_all.csv
  python3 finbert_sentiment.py --input ... --model /path/to/local/finbert
  python3 finbert_sentiment.py --self-test        # 无需 torch，验证管道逻辑
"""
import argparse
import csv
import re
import sys
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parent
DEFAULT_INPUT = ROOT / "Media/processed/gdelt_articles_all.csv"
OUT_DETAIL = ROOT / "Media/processed/article_sentiment.csv"
OUT_EVENT = ROOT / "Media/processed/event_sentiment.csv"

WINDOWS = {"pre_m7_m1": (-7, -1), "event_0_1": (0, 1),
           "post_0_3": (0, 3), "post_0_7": (0, 7)}
REQUIRED_LABELS = {"positive", "negative", "neutral"}


# ---------------- 通用逻辑（自检与正式运行共用） ----------------

def clean_text(t: str) -> str:
    t = re.sub(r"http\S+|www\S+", "", t or "")
    t = re.sub(r"\s+", " ", t).strip()
    return t


def days_from_event(seendate: str, event_date: str):
    """GDELT seendate 形如 20250121T143000Z；按 UTC 日历日差。"""
    try:
        d1 = datetime.strptime(seendate[:8], "%Y%m%d").date()
        d0 = datetime.strptime(event_date[:10], "%Y-%m-%d").date()
        return (d1 - d0).days
    except (ValueError, TypeError):
        return None


def aggregate(rows):
    """rows: 含 event_id, days_from_event, sentiment_score 的字典列表。"""
    by_event = {}
    for r in rows:
        by_event.setdefault(r["event_id"], []).append(r)
    out = []
    for eid, group in sorted(by_event.items()):
        rec = {"event_id": eid}
        for wname, (lo, hi) in WINDOWS.items():
            sel = [g["sentiment_score"] for g in group
                   if g["days_from_event"] is not None and lo <= g["days_from_event"] <= hi]
            n = len(sel)
            rec[f"{wname}_n"] = n
            rec[f"{wname}_mean"] = round(sum(sel) / n, 4) if n else ""
            rec[f"{wname}_pos_share"] = round(sum(1 for s in sel if s > 0.05) / n, 4) if n else ""
            rec[f"{wname}_neg_share"] = round(sum(1 for s in sel if s < -0.05) / n, 4) if n else ""
        out.append(rec)
    return out


def resolve_label_indices(id2label: dict):
    """按名称解析标签下标；集合不符则报错。返回 (i_pos, i_neg, i_neu)。"""
    norm = {int(k): str(v).strip().lower() for k, v in id2label.items()}
    labels = set(norm.values())
    if labels != REQUIRED_LABELS:
        raise SystemExit(
            f"模型标签为 {sorted(labels)}，不是 {sorted(REQUIRED_LABELS)}。\n"
            "请确认这是三分类金融情感模型（如 ProsusAI/finbert 或 "
            "yiyanghkust/finbert-tone），不要盲跑。")
    inv = {v: k for k, v in norm.items()}
    return inv["positive"], inv["negative"], inv["neutral"]


# ---------------- 正式运行 ----------------

def run(args):
    import pandas as pd
    import torch
    from transformers import AutoModelForSequenceClassification, AutoTokenizer

    device = ("cuda" if torch.cuda.is_available()
              else "mps" if torch.backends.mps.is_available() else "cpu")
    print(f"设备: {device} | 模型: {args.model}")
    tok = AutoTokenizer.from_pretrained(args.model)
    model = AutoModelForSequenceClassification.from_pretrained(args.model)
    i_pos, i_neg, i_neu = resolve_label_indices(model.config.id2label)
    print(f"标签映射（来自 config.id2label）: pos={i_pos} neg={i_neg} neu={i_neu}")
    model.to(device).eval()

    df = pd.read_csv(args.input)
    df["cleaned"] = df[args.text_col].astype(str).map(clean_text)
    df = df[df["cleaned"].str.len() >= 15].reset_index(drop=True)   # 关键：重置索引
    print(f"有效文本: {len(df)}")
    if df.empty:
        raise SystemExit("无有效文本。")

    scores, pos_p, neg_p, neu_p = [], [], [], []
    texts = df["cleaned"].tolist()
    with torch.no_grad():
        for i in range(0, len(texts), args.batch_size):
            batch = texts[i:i + args.batch_size]
            enc = tok(batch, truncation=True, padding=True, max_length=128,
                      return_tensors="pt").to(device)
            probs = torch.softmax(model(**enc).logits, dim=-1).cpu().numpy()
            pos_p.extend(probs[:, i_pos]); neg_p.extend(probs[:, i_neg])
            neu_p.extend(probs[:, i_neu])
            scores.extend(probs[:, i_pos] - probs[:, i_neg])
            if (i // args.batch_size) % 20 == 0:
                print(f"  {min(i+args.batch_size, len(texts))}/{len(texts)}")

    # 按位置逐列赋值（与 df 行序一一对应），而非 concat-on-index
    df["sentiment_score"] = scores
    df["p_positive"], df["p_negative"], df["p_neutral"] = pos_p, neg_p, neu_p
    df["days_from_event"] = [days_from_event(s, e) for s, e in
                             zip(df["seendate"].astype(str), df["event_date"].astype(str))]

    df.to_csv(OUT_DETAIL, index=False)
    rows = df[["event_id", "days_from_event", "sentiment_score"]].to_dict("records")
    ev = aggregate(rows)
    with OUT_EVENT.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(ev[0].keys()))
        w.writeheader(); w.writerows(ev)
    print(f"逐文章: {OUT_DETAIL.relative_to(ROOT)} ({len(df)} 行)")
    print(f"事件级: {OUT_EVENT.relative_to(ROOT)} ({len(ev)} 事件)")


# ---------------- 自检（无需 torch；不写生产输出） ----------------

def self_test():
    # 1. 标签映射：两种真实模型的顺序都必须解析正确
    assert resolve_label_indices({0: "positive", 1: "negative", 2: "neutral"}) == (0, 1, 2)
    assert resolve_label_indices({0: "Neutral", 1: "Positive", 2: "Negative"}) == (1, 2, 0)
    try:
        resolve_label_indices({0: "LABEL_0", 1: "LABEL_1"}); raise AssertionError("应当报错")
    except SystemExit:
        pass
    # 2. 日期差
    assert days_from_event("20250124T120000Z", "2025-01-21") == 3
    assert days_from_event("20250118T000000Z", "2025-01-21") == -3
    assert days_from_event("bad", "2025-01-21") is None
    # 3. 窗口聚合：分数与文章绑定关系可追溯（每篇分数=其天数编码，错位即失败）
    rows = [{"event_id": "E1", "days_from_event": d, "sentiment_score": d / 10}
            for d in (-8, -3, -1, 0, 1, 3, 7, 9)]
    ev = aggregate(rows)[0]
    assert ev["pre_m7_m1_n"] == 2 and abs(ev["pre_m7_m1_mean"] - (-0.2)) < 1e-9
    assert ev["event_0_1_n"] == 2 and abs(ev["event_0_1_mean"] - 0.05) < 1e-9
    assert ev["post_0_7_n"] == 4          # 0,1,3,7；9 在窗外
    print("SELF-TEST PASS：标签映射 / 日期差 / 窗口聚合 全部正确")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--input", default=str(DEFAULT_INPUT))
    ap.add_argument("--model", default="ProsusAI/finbert",
                    help="HF 模型名或本地目录（须为三分类金融情感模型）")
    ap.add_argument("--text-col", default="title")
    ap.add_argument("--batch-size", type=int, default=32)
    ap.add_argument("--self-test", action="store_true")
    a = ap.parse_args()
    if a.self_test:
        self_test()
    else:
        run(a)
