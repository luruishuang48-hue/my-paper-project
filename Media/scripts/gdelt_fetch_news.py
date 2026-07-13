#!/usr/bin/env python3
"""GDELT 新闻抓取（媒体情绪管道第 1 步）。

对主样本每个事件，按核证事件日 ±N 日历日抓取 GDELT DOC 2.0 的英文报道列表，
并另取 GDELT ToneChart 得到事件级语调分布。取代旧版 爬虫抓取7.py。

相对旧版修复的问题：
  1. 事件与日期从流水线决策表读取（CAR/metadata/event_dates_with_trading_day.csv），
     不再手工硬编码；
  2. 彻底移除"示例/假数据模式"；
  3. 关键词由 model_names/aa_creators 程序化生成 + 泛词黑名单（杜绝裸 "GPT"
     和少逗号隐式拼接一类错误）；可用 Media/metadata/event_keywords_override.csv
     人工增删（event_id, add_keywords, drop_keywords，分号分隔）；
  4. GDELT 限流实际返回 HTTP 200 + 纯文本提示——旧版只查 429 捕不到；
     本版把"非 JSON 响应"识别为限流并指数退避；
  5. 断点续跑：每事件一个 CSV，已存在即跳过（--force 重抓）；
  6. artlist 模式不返回正文/snippet（旧版的 content 字段实为空转）——本版如实
     只存标题与元数据，情感分析明确基于标题（Tetlock 式）；事件级语调另由
     ToneChart 端点直接提供。

用法：
  python3 gdelt_fetch_news.py               # 全部主样本事件
  python3 gdelt_fetch_news.py --events AIT-2025-01-003 AIT-2025-08-005
  python3 gdelt_fetch_news.py --window 7 --max-records 75 --force
"""
import argparse
import csv
import json
import re
import subprocess
import sys
import time
import urllib.parse
from datetime import datetime, timedelta
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EVENTS_FILE = ROOT / "CAR/metadata/event_dates_with_trading_day.csv"
MAIN_FILE = ROOT / "new data set/processed/final_event_sample_main.csv"
OVERRIDE_FILE = ROOT / "Media/metadata/event_keywords_override.csv"
RAW_DIR = ROOT / "Media/raw/gdelt"
OUT_FILE = ROOT / "Media/processed/gdelt_articles_all.csv"
TONE_FILE = ROOT / "Media/processed/gdelt_event_tone.csv"

API = "https://api.gdeltproject.org/api/v2/doc/doc"
MIN_INTERVAL = 6.0          # GDELT 要求 >=5s/请求
GENERIC_BLACKLIST = {"gpt", "ai", "llm", "model", "chat", "pro", "max", "mini",
                     "nano", "flash", "turbo", "plus", "beta", "preview", "r1", "o1", "o3", "v3"}

FIELDS = ["event_id", "event_date", "query", "title", "url", "domain",
          "language", "sourcecountry", "seendate", "socialimage"]

_last_request = [0.0]


def http_get_json(url: str, timeout: int = 40, max_retries: int = 5):
    """带限流退避的 GET。GDELT 限流返回 200+纯文本，故以 JSON 可解析为准。
    requests 优先，失败回落 curl（部分环境 python TLS 受限）。"""
    for attempt in range(max_retries):
        wait = MIN_INTERVAL - (time.time() - _last_request[0])
        if wait > 0:
            time.sleep(wait)
        body = None
        try:
            import requests
            r = requests.get(url, timeout=timeout,
                             headers={"User-Agent": "media-sentiment-pipeline/1.0"})
            body = r.text
        except Exception:
            p = subprocess.run(["curl", "-s", "--max-time", str(timeout),
                                "-A", "media-sentiment-pipeline/1.0", url],
                               capture_output=True, text=True)
            body = p.stdout
        _last_request[0] = time.time()
        try:
            return json.loads(body)
        except (json.JSONDecodeError, TypeError):
            backoff = 15 * (2 ** attempt)
            snippet = (body or "")[:80].replace("\n", " ")
            print(f"    非 JSON 响应（疑似限流），{backoff}s 后重试: {snippet}",
                  file=sys.stderr)
            time.sleep(backoff)
    raise RuntimeError("GDELT 连续限流/失败，中止。稍后用 --force 之外的默认模式续跑即可。")


def load_events(only_ids=None):
    with MAIN_FILE.open(newline="", encoding="utf-8") as f:
        main_ids = {r["event_id"] for r in csv.DictReader(f)}
    events = []
    with EVENTS_FILE.open(newline="", encoding="utf-8") as f:
        for r in csv.DictReader(f):
            if r["event_id"] not in main_ids:
                continue
            if only_ids and r["event_id"] not in only_ids:
                continue
            events.append(r)
    return events


def load_overrides():
    add, drop = {}, {}
    if OVERRIDE_FILE.exists():
        with OVERRIDE_FILE.open(newline="", encoding="utf-8") as f:
            for r in csv.DictReader(f):
                eid = r["event_id"].strip()
                add[eid] = [k.strip() for k in (r.get("add_keywords") or "").split(";") if k.strip()]
                drop[eid] = {k.strip().lower() for k in (r.get("drop_keywords") or "").split(";") if k.strip()}
    return add, drop


def build_keywords(event, add, drop):
    """模型名短语 + 厂商×首模型组合；过滤泛词。全部为完整短语，杜绝裸词。"""
    names = [n.strip() for n in (event.get("model_names") or "").split(";") if n.strip()]
    creators = [c.strip() for c in (event.get("aa_creators") or "").split(";") if c.strip()]
    kws = []
    for n in names:
        if n.lower() in GENERIC_BLACKLIST or len(n) < 4:
            continue
        kws.append(n)
    if creators and names:
        kws.append(f"{creators[0]} {names[0]}")
    kws.extend(add.get(event["event_id"], []))
    kws = [k for k in kws if k.lower() not in drop.get(event["event_id"], set())]
    # 去重保序
    seen, out = set(), []
    for k in kws:
        if k.lower() not in seen:
            seen.add(k.lower())
            out.append(k)
    return out[:4]     # 每事件最多 4 个查询，控制请求量


def date_range(event_date: str, window: int):
    d0 = datetime.strptime(event_date[:10], "%Y-%m-%d")
    return ((d0 - timedelta(days=window)).strftime("%Y%m%d%H%M%S"),
            (d0 + timedelta(days=window)).strftime("%Y%m%d235959"))


def fetch_event(event, window, max_records):
    eid = event["event_id"]
    edate = event["official_date"][:10]
    start, end = date_range(edate, window)
    add, drop = fetch_event.overrides
    kws = build_keywords(event, add, drop)
    if not kws:
        print(f"  {eid}: 无可用关键词（全被黑名单/override 过滤），跳过", file=sys.stderr)
        return [], None

    articles, seen_urls = [], set()
    for kw in kws:
        q = urllib.parse.quote(f'"{kw}" sourcelang:english')
        url = (f"{API}?query={q}&mode=artlist&format=json&maxrecords={max_records}"
               f"&startdatetime={start}&enddatetime={end}")
        data = http_get_json(url)
        for a in data.get("articles", []):
            u = a.get("url", "")
            title = (a.get("title") or "").strip()
            if not u or u in seen_urls or len(title) < 15:
                continue
            # 相关性：关键词首个词元须出现在标题（大小写不敏感）
            if kw.split()[0].lower() not in title.lower():
                continue
            seen_urls.add(u)
            articles.append({
                "event_id": eid, "event_date": edate, "query": kw,
                "title": title, "url": u, "domain": a.get("domain", ""),
                "language": a.get("language", ""),
                "sourcecountry": a.get("sourcecountry", ""),
                "seendate": a.get("seendate", ""),
                "socialimage": a.get("socialimage", ""),
            })

    # 事件级 ToneChart（用首个关键词）
    tone_row = None
    q = urllib.parse.quote(f'"{kws[0]}" sourcelang:english')
    url = (f"{API}?query={q}&mode=tonechart&format=json"
           f"&startdatetime={start}&enddatetime={end}")
    try:
        data = http_get_json(url, max_retries=3)
        bins = data.get("tonechart", [])
        total = sum(b.get("count", 0) for b in bins)
        if total > 0:
            mean_tone = sum(b.get("bin", 0) * b.get("count", 0) for b in bins) / total
            tone_row = {"event_id": eid, "event_date": edate, "keyword": kws[0],
                        "gdelt_article_count": total,
                        "gdelt_mean_tone": round(mean_tone, 4)}
    except RuntimeError:
        print(f"  {eid}: tonechart 取失败（限流），文章列表已保留", file=sys.stderr)
    return articles, tone_row


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--events", nargs="*", help="只抓这些 event_id")
    ap.add_argument("--window", type=int, default=7, help="事件日 ± 日历日（默认 7）")
    ap.add_argument("--max-records", type=int, default=75)
    ap.add_argument("--force", action="store_true", help="重抓已存在的事件")
    args = ap.parse_args()

    RAW_DIR.mkdir(parents=True, exist_ok=True)
    OUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    fetch_event.overrides = load_overrides()

    events = load_events(set(args.events) if args.events else None)
    print(f"待处理事件: {len(events)}")

    tone_rows = []
    for i, ev in enumerate(events, 1):
        eid = ev["event_id"]
        per_event = RAW_DIR / f"{eid}.csv"
        if per_event.exists() and not args.force:
            print(f"[{i}/{len(events)}] {eid}: 已存在，跳过")
            continue
        print(f"[{i}/{len(events)}] {eid} ({ev['official_date'][:10]}) ...")
        arts, tone = fetch_event(ev, args.window, args.max_records)
        with per_event.open("w", newline="", encoding="utf-8") as f:
            w = csv.DictWriter(f, fieldnames=FIELDS)
            w.writeheader()
            w.writerows(arts)
        if tone:
            tone_rows.append(tone)
        print(f"    文章 {len(arts)} 篇" + (f"；GDELT 平均语调 {tone['gdelt_mean_tone']}" if tone else ""))

    # 汇总全部逐事件文件
    all_rows = []
    for p in sorted(RAW_DIR.glob("AIT-*.csv")):
        with p.open(newline="", encoding="utf-8") as f:
            all_rows.extend(csv.DictReader(f))
    with OUT_FILE.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=FIELDS)
        w.writeheader()
        w.writerows(all_rows)
    if tone_rows:
        exists = TONE_FILE.exists()
        with TONE_FILE.open("a", newline="", encoding="utf-8") as f:
            w = csv.DictWriter(f, fieldnames=list(tone_rows[0].keys()))
            if not exists:
                w.writeheader()
            w.writerows(tone_rows)
    print(f"\n汇总: {len(all_rows)} 篇 -> {OUT_FILE.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
