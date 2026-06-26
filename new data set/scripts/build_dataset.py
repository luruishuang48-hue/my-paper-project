#!/usr/bin/env python3
import csv
import html
import json
import re
from collections import Counter, defaultdict
from datetime import datetime
from difflib import SequenceMatcher
from pathlib import Path


BASE = Path(__file__).resolve().parents[1]
RAW = BASE / "raw"
PROCESSED = BASE / "processed"
REPORTS = BASE / "reports"
PROCESSED.mkdir(parents=True, exist_ok=True)
REPORTS.mkdir(parents=True, exist_ok=True)

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

COMPANIES = {
    "openai": "OpenAI",
    "google": "Google",
    "google deepmind": "Google",
    "anthropic": "Anthropic",
    "meta": "Meta",
    "microsoft": "Microsoft",
    "mistral": "Mistral",
    "mistral ai": "Mistral",
    "alibaba": "Alibaba",
    "deepseek": "DeepSeek",
    "deepseekai": "DeepSeek",
    "xai": "xAI",
    "x corporation": "xAI",
    "stability ai": "Stability AI",
    "black forest labs": "Black Forest Labs",
    "adobe": "Adobe",
    "suno": "Suno",
    "suno ai": "Suno",
    "runway": "Runway",
    "luma": "Luma",
    "pika": "Pika",
    "pika labs": "Pika",
    "midjourney": "Midjourney",
    "kling": "Kling",
    "z ai": "Z AI",
    "amazon": "Amazon",
    "apple": "Apple",
    "reka ai": "Reka AI",
    "rhymes ai": "Rhymes AI",
    "kyutai": "Kyutai",
    "udio": "Udio",
}

COMPANY_ONLY = {
    "openai",
    "google",
    "google deepmind",
    "anthropic",
    "meta",
    "microsoft",
    "mistral ai",
    "mistral",
    "alibaba",
    "deepseekai",
    "deepseek",
    "x corporation",
    "xai",
    "suno",
    "suno ai",
    "meta",
    "reka ai",
    "rhymes ai",
    "kyutai",
    "suno",
    "suno ai",
    "poetiq",
    "figure",
    "nvidia",
    "adobe",
    "black forest labs",
}

PRODUCT_NAMES = {
    "chatgpt",
    "bing ai",
    "bard",
    "grok ai",
    "ai overviews",
    "copilot+",
    "copilot",
    "apple intelligence",
    "notebooklm",
    "searchgpt",
    "search gpt",
    "operator",
    "deep research",
    "deepsearch",
    "chatgpt agent",
    "chatgpt atlas",
    "codex",
    "jules",
    "nova act",
    "alphavolve",
    "alphaevolve",
    "neo",
    "moltbook",
    "axiomprover",
    "advanced voice mode",
    "visual pdf analysis",
    "pika effects",
    "chatbot",
}

NON_MODEL_TERMS = {
    "arc agi",
    "arc agi 2",
    "arc 2",
    "frontier math benchmark",
    "international mathematical olympiad",
    "imo",
    "api",
    "json",
    "gold medal",
    "10 gigawatts",
    "putnam",
    "icpc",
}

MODEL_HINT_RE = re.compile(
    r"\b(model|models|llm|large language|language model|multimodal|text[- ]?to[- ]?image|generator|"
    r"image creation|image generation|video generation|video creation|music creation|"
    r"speech|voice|audio|weights|open[- ]?source|parameters|benchmark|reasoning model|"
    r"coding|vision model|SLM|MoE)\b",
    re.I,
)

MODEL_FAMILY_RE = re.compile(
    r"(gpt|claude|gemini|llama|llama|mistral|mixtral|codestral|mathstral|pixtral|ministral|"
    r"qwen|qwq|qvq|deepseek|grok|phi|gemma|davinci|stable diffusion|stable audio|dall|dall-e|"
    r"midjourney|imagen|veo|sora|flux|firefly|suno|udio|runway|gen3|gen 3|kling|pika|"
    r"dream machine|ideogram|recraft|janus|nova|pali|openelm|chameleon|reka|moshi|"
    r"florence|alpha|o1|o3|o4|o5|r1|r1-zero|v\d|glm|kimi|minimax|nemotron|mimo|muse)",
    re.I,
)

MEDIA_HINTS = [
    ("text-to-image", re.compile(r"stable diffusion|dall|midjourney|imagen|flux|firefly|ideogram|recraft|text[- ]?to[- ]?image|image generation|image creation", re.I)),
    ("image-editing", re.compile(r"image editing|edit image", re.I)),
    ("text-to-video", re.compile(r"sora|veo|runway|gen3|gen 3|kling|pika|movie gen|dream machine|apollo|video", re.I)),
    ("text-to-speech", re.compile(r"text[- ]?to[- ]?speech|tts|voice|speech", re.I)),
    ("speech-to-speech", re.compile(r"speech[- ]?to[- ]?speech|voice[- ]?to[- ]?voice|moshi", re.I)),
    ("music", re.compile(r"music|suno|udio|stable audio", re.I)),
]


def read_json(path):
    return json.loads(path.read_text(encoding="utf-8"))


def write_csv(path, rows, fieldnames):
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)


def strip_tags(value):
    text = re.sub(r"<[^>]+>", " ", value or "")
    text = html.unescape(text)
    return re.sub(r"\s+", " ", text).strip()


def extract_bold(value):
    names = []
    for match in re.finditer(r"<b>(.*?)</b>", value or "", flags=re.I | re.S):
        item = strip_tags(match.group(1))
        item = re.sub(r"\s+", " ", item).strip()
        if item:
            names.append(item)
    return names


def normalize_text(value):
    value = html.unescape(value or "").lower()
    value = value.replace("‑", "-").replace("–", "-").replace("—", "-")
    value = value.replace("'", "")
    value = re.sub(r"\bmodel\b", " ", value)
    value = re.sub(r"\bmodels\b", " ", value)
    value = re.sub(r"\bai\b", " ", value)
    value = re.sub(r"\bnew\b", " ", value)
    value = re.sub(r"\bversion\b", " ", value)
    value = re.sub(r"\bthe\b", " ", value)
    value = re.sub(r"\bpreview\b", " preview ", value)
    value = re.sub(r"[^a-z0-9]+", " ", value)
    value = re.sub(r"\b0+([0-9])\b", r"\1", value)
    return re.sub(r"\s+", " ", value).strip()


def simple_norm(value):
    value = html.unescape(value or "").lower()
    value = value.replace("‑", "-").replace("–", "-").replace("—", "-")
    value = value.replace("'", "")
    value = re.sub(r"[^a-z0-9]+", " ", value)
    return re.sub(r"\s+", " ", value).strip()


PRODUCT_NORMS = {normalize_text(x) for x in PRODUCT_NAMES}
NON_MODEL_NORMS = {normalize_text(x) for x in NON_MODEL_TERMS}
COMPANY_ONLY_NORMS = {simple_norm(x) for x in COMPANY_ONLY}


def normalize_slug(value):
    return normalize_text((value or "").replace("-", " "))


def infer_creator(text):
    low = simple_norm(text)
    found = []
    for key, value in sorted(COMPANIES.items(), key=lambda item: len(simple_norm(item[0])), reverse=True):
        key_norm = simple_norm(key)
        if not key_norm:
            continue
        if re.search(rf"(^| ){re.escape(key_norm)}($| )", low):
            found.append(value)
    return found[0] if found else ""


def infer_modality(name, text):
    haystack = f"{name} {text}"
    for modality, pattern in MEDIA_HINTS:
        if pattern.search(haystack):
            return modality
    return "language"


def classify_entity(name, event_text):
    n = normalize_text(name)
    n_simple = simple_norm(name)
    t = normalize_text(event_text)
    if not n:
        return "other", "empty normalized entity"
    if n in NON_MODEL_NORMS:
        return "other", "benchmark or technical term"
    if n_simple in COMPANY_ONLY_NORMS:
        return "other", "company name"
    if n in PRODUCT_NORMS:
        return "product", "known product or feature name"
    if re.search(r"\b(mode|overview|search|copilot|notebook|operator|chatbot|assistant|product|feature)\b", n):
        return "product", "product or feature wording"
    if MODEL_FAMILY_RE.search(name) or MODEL_HINT_RE.search(event_text):
        if "chatbot" in t and not MODEL_FAMILY_RE.search(name):
            return "product", "chatbot wording without model-family clue"
        return "model", "model-family or model-context clue"
    if re.search(r"\bv\d+(\.\d+)?\b", n) and infer_creator(event_text):
        return "model", "version token with creator context"
    return "other", "no model or product clue"


def build_ai_timeline():
    timeline = read_json(RAW / "ai_timeline_timeline.json")
    events = []
    entities = []
    seq = 0
    for year_block in timeline:
        year = int(year_block["year"])
        for month_block in year_block.get("events", []):
            raw_month = str(month_block.get("date", "")).replace("\xa0", " ").strip()
            month_name = raw_month.split()[0].lower()
            month_num = MONTHS.get(month_name)
            for item_idx, item in enumerate(month_block.get("info", []), start=1):
                seq += 1
                raw_text = item.get("text", "")
                clean_text = strip_tags(raw_text)
                bold_names = extract_bold(raw_text)
                event_id = f"AIT-{year}-{month_num or 0:02d}-{item_idx:03d}"
                creator = infer_creator(clean_text)
                entity_types = []
                for entity_idx, name in enumerate(bold_names, start=1):
                    entity_type, reason = classify_entity(name, clean_text)
                    entity_types.append(entity_type)
                    entities.append(
                        {
                            "entity_id": f"{event_id}-E{entity_idx:02d}",
                            "event_id": event_id,
                            "year": year,
                            "month": raw_month,
                            "month_num": month_num or "",
                            "event_order": seq,
                            "entity_order": entity_idx,
                            "entity_name": name,
                            "entity_type": entity_type,
                            "entity_classification_reason": reason,
                            "inferred_creator": creator,
                            "inferred_modality": infer_modality(name, clean_text),
                            "event_text": clean_text,
                            "is_special": bool(item.get("special", False)),
                            "source": "AI Timeline _data/timeline.yml",
                        }
                    )
                has_model = "model" in entity_types
                has_product = "product" in entity_types
                if has_model and has_product:
                    event_type = "mixed"
                elif has_model:
                    event_type = "model"
                elif has_product:
                    event_type = "product"
                elif MODEL_HINT_RE.search(clean_text):
                    event_type = "model_context_without_bold_entity"
                else:
                    event_type = "other"
                events.append(
                    {
                        "event_id": event_id,
                        "year": year,
                        "month": raw_month,
                        "month_num": month_num or "",
                        "event_order": seq,
                        "event_text": clean_text,
                        "raw_html": raw_text,
                        "bold_entities": "; ".join(bold_names),
                        "event_type": event_type,
                        "inferred_creator": creator,
                        "is_special": bool(item.get("special", False)),
                        "source": "AI Timeline _data/timeline.yml",
                    }
                )
    return events, entities


def creator_name(record):
    creator = record.get("model_creator") or record.get("creator") or {}
    if isinstance(creator, dict):
        return creator.get("name") or creator.get("slug") or ""
    return str(creator or "")


def creator_slug(record):
    creator = record.get("model_creator") or record.get("creator") or {}
    if isinstance(creator, dict):
        return creator.get("slug") or normalize_text(creator.get("name") or "")
    return normalize_text(str(creator or ""))


def flatten_aa_record(record, modality, source_file):
    evaluations = record.get("evaluations") or {}
    pricing = record.get("pricing") or {}
    performance = record.get("performance") or {}
    perf_p50 = performance.get("p50") if isinstance(performance, dict) else {}
    if not isinstance(perf_p50, dict):
        perf_p50 = {}
    return {
        "aa_record_key": f"{modality}:{record.get('id') or record.get('slug') or record.get('name')}",
        "aa_id": record.get("id", ""),
        "aa_name": record.get("name", ""),
        "aa_slug": record.get("slug", ""),
        "aa_modality": modality,
        "aa_creator": creator_name(record),
        "aa_creator_slug": creator_slug(record),
        "release_date": record.get("release_date", ""),
        "source_file": source_file,
        "aa_intelligence_index": evaluations.get("artificial_analysis_intelligence_index", record.get("artificial_analysis_intelligence_index", "")),
        "aa_coding_index": evaluations.get("artificial_analysis_coding_index", record.get("artificial_analysis_coding_index", "")),
        "aa_math_index": evaluations.get("artificial_analysis_math_index", record.get("artificial_analysis_math_index", "")),
        "mmlu_pro": evaluations.get("mmlu_pro", record.get("mmlu_pro", "")),
        "gpqa": evaluations.get("gpqa", record.get("gpqa", "")),
        "livecodebench": evaluations.get("livecodebench", record.get("livecodebench", "")),
        "aime": evaluations.get("aime", record.get("aime", "")),
        "elo": record.get("elo", ""),
        "rank": record.get("rank", ""),
        "ci95": record.get("ci95", record.get("ci_95", "")),
        "appearances": record.get("appearances", ""),
        "aa_wer_index": record.get("aa_wer_index", ""),
        "bba_score": record.get("bba_score", ""),
        "fdb_score": record.get("fdb_score", ""),
        "tau_voice_score": record.get("tau_voice_score", ""),
        "price_1m_blended_3_to_1": pricing.get("price_1m_blended_3_to_1", record.get("price_1m_blended_3_to_1", "")),
        "price_1m_input_tokens": pricing.get("price_1m_input_tokens", record.get("price_1m_input_tokens", "")),
        "price_1m_output_tokens": pricing.get("price_1m_output_tokens", record.get("price_1m_output_tokens", "")),
        "median_output_tokens_per_second": record.get("median_output_tokens_per_second", perf_p50.get("median_output_tokens_per_second", "")),
        "median_time_to_first_token_seconds": record.get("median_time_to_first_token_seconds", perf_p50.get("median_time_to_first_token_seconds", "")),
        "median_time_to_first_answer_token": record.get("median_time_to_first_answer_token", perf_p50.get("median_time_to_first_answer_token", "")),
        "aa_url": f"https://artificialanalysis.ai/models/{record.get('slug')}" if record.get("slug") else "",
    }


def load_list_from_json(path):
    obj = read_json(path)
    if isinstance(obj, dict):
        data = obj.get("data")
        if isinstance(data, list):
            return data
        if all(k in obj for k in ["id", "name"]):
            return [obj]
        return []
    return obj if isinstance(obj, list) else []


def build_aa_models():
    sources = [
        ("data_llms_models.json", "language"),
        ("data_media_text-to-image.json", "text-to-image"),
        ("data_media_image-editing.json", "image-editing"),
        ("data_media_text-to-video.json", "text-to-video"),
        ("data_media_image-to-video.json", "image-to-video"),
        ("data_media_text-to-speech.json", "text-to-speech"),
        ("media_text-to-video-audio_models_free.json", "text-to-video-audio"),
        ("media_image-to-video-audio_models_free.json", "image-to-video-audio"),
        ("media_speech-to-speech_models_free.json", "speech-to-speech"),
        ("media_speech-to-text_models_free.json", "speech-to-text"),
        ("media_music_instrumental_models_free.json", "music-instrumental"),
        ("media_music_with-vocals_models_free.json", "music-with-vocals"),
    ]
    rows = []
    seen = set()
    for filename, modality in sources:
        path = RAW / "aa_api_v2" / filename
        if not path.exists():
            continue
        for record in load_list_from_json(path):
            row = flatten_aa_record(record, modality, filename)
            key = (row["aa_modality"], row["aa_id"] or row["aa_slug"] or row["aa_name"], row["aa_creator"])
            if key in seen:
                continue
            seen.add(key)
            rows.append(row)
    return rows


def token_score(a, b):
    ta = normalize_text(a).split()
    tb = normalize_text(b).split()
    if not ta or not tb:
        return 0.0
    sa, sb = set(ta), set(tb)
    inter = sa & sb
    overlap = (2 * len(inter)) / (len(sa) + len(sb))
    sort_ratio = SequenceMatcher(None, " ".join(sorted(ta)), " ".join(sorted(tb))).ratio()
    seq_ratio = SequenceMatcher(None, normalize_text(a), normalize_text(b)).ratio()
    containment = 0.0
    na, nb = normalize_text(a), normalize_text(b)
    if na and nb and (na in nb or nb in na):
        small = min(len(ta), len(tb))
        containment = 0.92 if small >= 2 else 0.78
    return max(overlap, sort_ratio, seq_ratio, containment)


def candidate_names(row):
    names = {row["aa_name"], row["aa_slug"].replace("-", " ")}
    if row["aa_creator"]:
        names.add(f"{row['aa_creator']} {row['aa_name']}")
    cleaned = re.sub(r"\([^)]*\)", " ", row["aa_name"])
    names.add(cleaned)
    return [x for x in names if x.strip()]


def match_one(entity, aa_rows):
    name = entity["entity_name"]
    creator = entity.get("inferred_creator", "")
    modality = entity.get("inferred_modality", "")
    query_names = [name]
    if creator and len(normalize_text(name).split()) <= 2:
        query_names.append(f"{creator} {name}")
    scored = []
    for aa in aa_rows:
        base = max(token_score(q, cand) for q in query_names for cand in candidate_names(aa))
        if creator and aa["aa_creator"] and normalize_text(creator) == normalize_text(aa["aa_creator"]):
            base = min(1.0, base + 0.06)
        if modality and modality != "language" and modality in aa["aa_modality"]:
            base = min(1.0, base + 0.04)
        if len(normalize_text(name).split()) == 1 and not creator and base < 0.96:
            base = min(base, 0.55)
        scored.append((base, aa))
    scored.sort(key=lambda x: x[0], reverse=True)
    best_score, best = scored[0] if scored else (0.0, {})
    if best_score >= 0.96:
        level = "exact_or_near_exact"
    elif best_score >= 0.88:
        level = "high"
    elif best_score >= 0.75:
        level = "medium"
    elif best_score >= 0.62:
        level = "low"
    else:
        level = "unmatched"
    top = [
        {
            "score": round(score, 4),
            "name": row["aa_name"],
            "creator": row["aa_creator"],
            "modality": row["aa_modality"],
            "slug": row["aa_slug"],
        }
        for score, row in scored[:5]
    ]
    out = dict(entity)
    out.update(
        {
            "match_level": level,
            "match_score": round(best_score, 4),
            "aa_record_key": best.get("aa_record_key", "") if level != "unmatched" else "",
            "aa_name": best.get("aa_name", "") if level != "unmatched" else "",
            "aa_slug": best.get("aa_slug", "") if level != "unmatched" else "",
            "aa_creator": best.get("aa_creator", "") if level != "unmatched" else "",
            "aa_modality": best.get("aa_modality", "") if level != "unmatched" else "",
            "aa_release_date": best.get("release_date", "") if level != "unmatched" else "",
            "aa_url": best.get("aa_url", "") if level != "unmatched" else "",
            "top_candidates_json": json.dumps(top, ensure_ascii=False),
            "needs_review": level in {"medium", "low", "unmatched"},
        }
    )
    return out


def build_matches(entities, aa_rows):
    model_entities = [row for row in entities if row["entity_type"] == "model"]
    return [match_one(entity, aa_rows) for entity in model_entities]


def summarize_json_file(path):
    try:
        obj = read_json(path)
    except Exception:
        return {"file": path.name, "status": "bad_json", "records": ""}
    if isinstance(obj, dict):
        data = obj.get("data")
        records = len(data) if isinstance(data, list) else len(obj.get("hostModels", [])) if isinstance(obj.get("hostModels"), list) else ""
        status = obj.get("status", "")
    elif isinstance(obj, list):
        records = len(obj)
        status = ""
    else:
        records = ""
        status = ""
    return {"file": path.name, "status": status, "records": records, "bytes": path.stat().st_size}


def build_report(events, entities, aa_rows, matches):
    event_counts = Counter(row["event_type"] for row in events)
    entity_counts = Counter(row["entity_type"] for row in entities)
    match_counts = Counter(row["match_level"] for row in matches)
    aa_counts = Counter(row["aa_modality"] for row in aa_rows)
    year_counts = Counter(row["year"] for row in events)
    website_rows = []
    for p in sorted((RAW / "aa_website_api").glob("host_models_performance_*.json")):
        website_rows.append(summarize_json_file(p))
    api_manifest = (RAW / "aa_api_v2_fetch_manifest.tsv").read_text(encoding="utf-8") if (RAW / "aa_api_v2_fetch_manifest.tsv").exists() else ""
    legacy_manifest = (RAW / "aa_api_v2_legacy_fetch_manifest.tsv").read_text(encoding="utf-8") if (RAW / "aa_api_v2_legacy_fetch_manifest.tsv").exists() else ""
    review_sample = [m for m in matches if m["needs_review"]][:30]

    lines = []
    lines.append("# AI Timeline 与 Artificial Analysis 数据重建报告")
    lines.append("")
    lines.append(f"生成时间 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append("")
    lines.append("## 文件清单")
    lines.append("")
    lines.append("- 原始 AI Timeline 数据 `new data set/raw/ai_timeline_timeline.yml` 和 `new data set/raw/ai_timeline_timeline.json`")
    lines.append("- 原始 AA API 数据 `new data set/raw/aa_api_v2/`")
    lines.append("- 原始 AA 网页排行榜数据 `new data set/raw/aa_website_api/`")
    lines.append("- 清洗后事件表 `new data set/processed/ai_timeline_events.csv`")
    lines.append("- 清洗后实体表 `new data set/processed/ai_timeline_entities.csv`")
    lines.append("- AA 合并模型表 `new data set/processed/aa_models.csv`")
    lines.append("- 匹配结果 `new data set/processed/ai_timeline_aa_model_matches.csv`")
    lines.append("- 需人工审核匹配 `new data set/processed/ai_timeline_aa_model_matches_review.csv`")
    lines.append("")
    lines.append("## 数据来源")
    lines.append("")
    lines.append("- AI Timeline 来自 `https://github.com/NHLOCAL/AiTimeline/blob/main/_data/timeline.yml`")
    lines.append("- AA 正式 API 文档来自 `https://artificialanalysis.ai/data-api/docs`")
    lines.append("- AA 免费 API 使用 `x-api-key` 请求，报告不保存也不展示密钥")
    lines.append("- AA 官方文档说明 API 基址为 `https://artificialanalysis.ai/api/v2`，认证头为 `x-api-key`")
    lines.append("")
    lines.append("## AI Timeline 概况")
    lines.append("")
    lines.append(f"- 事件总数 {len(events)}")
    lines.append("- 年份分布 " + ", ".join(f"{year} 年 {year_counts[year]} 条" for year in sorted(year_counts)))
    lines.append("- 事件类型 " + ", ".join(f"{k} {v}" for k, v in sorted(event_counts.items())))
    lines.append(f"- 加粗实体总数 {len(entities)}")
    lines.append("- 实体类型 " + ", ".join(f"{k} {v}" for k, v in sorted(entity_counts.items())))
    lines.append("")
    lines.append("## AA 数据概况")
    lines.append("")
    lines.append(f"- 合并模型记录 {len(aa_rows)} 条")
    lines.append("- 模态分布 " + ", ".join(f"{k} {v}" for k, v in sorted(aa_counts.items())))
    lines.append("- 旧版 LLM 端点 `/api/v2/data/llms/models` 返回 542 条，是本次语言模型匹配主表")
    lines.append("- 新版 `/api/v2/language/models/free` 返回 200 条，Pro 端点在当前 key 下返回 403")
    lines.append("")
    lines.append("### AA API 抓取状态")
    lines.append("")
    lines.append("```text")
    lines.append((api_manifest + legacy_manifest).strip())
    lines.append("```")
    lines.append("")
    lines.append("### AA 网页排行榜补充数据")
    lines.append("")
    lines.append("| 文件 | 状态 | 记录数 | 字节数 |")
    lines.append("|---|---:|---:|---:|")
    for row in website_rows:
        lines.append(f"| {row['file']} | {row.get('status','')} | {row.get('records','')} | {row.get('bytes','')} |")
    lines.append("")
    lines.append("## 分类规则")
    lines.append("")
    lines.append("- 先读取事件中的 `<b>...</b>` 加粗实体")
    lines.append("- 公司名被标为 `other`，例如 OpenAI、Google、Meta")
    lines.append("- ChatGPT、Bard、Copilot+、AI Overviews、Operator 等被标为 `product`")
    lines.append("- 出现 GPT、Claude、Gemini、Llama、Mistral、Qwen、DeepSeek、Grok、Phi、Gemma、Stable Diffusion、DALL-E、Midjourney、Imagen、Veo、Sora、Flux 等模型族，或上下文明确写有 model、language model、open-source、parameters、video generation、music creation 等词时，标为 `model`")
    lines.append("- 同一事件同时包含模型和产品实体时，事件类型标为 `mixed`")
    lines.append("")
    lines.append("## 匹配规则")
    lines.append("")
    lines.append("- 对实体名和 AA 模型名做规范化，统一大小写、连字符、括号和 `model/models` 等泛词")
    lines.append("- 短名称会结合事件上下文推断创建方，例如 DeepSeek 的 R1、Suno 的 v4")
    lines.append("- 匹配分数综合字符相似度、词集合相似度、包含关系、创建方一致和模态一致")
    lines.append("- `exact_or_near_exact` 和 `high` 通常可直接使用，`medium`、`low`、`unmatched` 已标记为需审核")
    lines.append("")
    lines.append("## 匹配结果概况")
    lines.append("")
    lines.append(f"- 待匹配 AI Timeline 模型实体 {len(matches)} 个")
    lines.append("- 匹配等级 " + ", ".join(f"{k} {v}" for k, v in sorted(match_counts.items())))
    matched = len([m for m in matches if m["match_level"] != "unmatched"])
    lines.append(f"- 非 unmatched 记录 {matched} 个")
    lines.append(f"- 需人工审核记录 {len([m for m in matches if m['needs_review']])} 个")
    lines.append("")
    lines.append("## 需优先审核样本")
    lines.append("")
    lines.append("| AI Timeline 实体 | 年月 | 匹配等级 | 分数 | AA 候选 | 事件文本 |")
    lines.append("|---|---:|---:|---:|---|---|")
    for m in review_sample:
        text = m["event_text"].replace("|", " ").replace("\n", " ")
        if len(text) > 120:
            text = text[:117] + "..."
        lines.append(
            f"| {m['entity_name']} | {m['year']} {m['month']} | {m['match_level']} | {m['match_score']} | {m['aa_name']} | {text} |"
        )
    lines.append("")
    lines.append("## 使用建议")
    lines.append("")
    lines.append("- 先审核 `ai_timeline_aa_model_matches_review.csv`")
    lines.append("- 对 `medium` 和 `low` 记录，优先看 `top_candidates_json` 中前 5 个候选")
    lines.append("- 对 `unmatched` 记录，判断是 AA 未覆盖、AI Timeline 实体不是模型，还是名称需要手工别名")
    lines.append("- 人工确认后，可增加别名表再重跑脚本")
    lines.append("")
    return "\n".join(lines)


def main():
    events, entities = build_ai_timeline()
    aa_rows = build_aa_models()
    matches = build_matches(entities, aa_rows)

    event_fields = [
        "event_id",
        "year",
        "month",
        "month_num",
        "event_order",
        "event_text",
        "raw_html",
        "bold_entities",
        "event_type",
        "inferred_creator",
        "is_special",
        "source",
    ]
    entity_fields = [
        "entity_id",
        "event_id",
        "year",
        "month",
        "month_num",
        "event_order",
        "entity_order",
        "entity_name",
        "entity_type",
        "entity_classification_reason",
        "inferred_creator",
        "inferred_modality",
        "event_text",
        "is_special",
        "source",
    ]
    aa_fields = [
        "aa_record_key",
        "aa_id",
        "aa_name",
        "aa_slug",
        "aa_modality",
        "aa_creator",
        "aa_creator_slug",
        "release_date",
        "source_file",
        "aa_intelligence_index",
        "aa_coding_index",
        "aa_math_index",
        "mmlu_pro",
        "gpqa",
        "livecodebench",
        "aime",
        "elo",
        "rank",
        "ci95",
        "appearances",
        "aa_wer_index",
        "bba_score",
        "fdb_score",
        "tau_voice_score",
        "price_1m_blended_3_to_1",
        "price_1m_input_tokens",
        "price_1m_output_tokens",
        "median_output_tokens_per_second",
        "median_time_to_first_token_seconds",
        "median_time_to_first_answer_token",
        "aa_url",
    ]
    match_fields = entity_fields + [
        "match_level",
        "match_score",
        "aa_record_key",
        "aa_name",
        "aa_slug",
        "aa_creator",
        "aa_modality",
        "aa_release_date",
        "aa_url",
        "top_candidates_json",
        "needs_review",
    ]

    write_csv(PROCESSED / "ai_timeline_events.csv", events, event_fields)
    write_csv(PROCESSED / "ai_timeline_events_classified.csv", events, event_fields)
    write_csv(PROCESSED / "ai_timeline_entities.csv", entities, entity_fields)
    write_csv(PROCESSED / "ai_timeline_model_entities.csv", [e for e in entities if e["entity_type"] == "model"], entity_fields)
    write_csv(PROCESSED / "aa_models.csv", aa_rows, aa_fields)
    write_csv(PROCESSED / "ai_timeline_aa_model_matches.csv", matches, match_fields)
    write_csv(PROCESSED / "ai_timeline_aa_model_matches_review.csv", [m for m in matches if m["needs_review"]], match_fields)

    report = build_report(events, entities, aa_rows, matches)
    (REPORTS / "data_rebuild_report.md").write_text(report, encoding="utf-8")

    summary = {
        "events": len(events),
        "entities": len(entities),
        "aa_models": len(aa_rows),
        "matches": len(matches),
        "needs_review": len([m for m in matches if m["needs_review"]]),
        "match_counts": dict(Counter(m["match_level"] for m in matches)),
        "event_counts": dict(Counter(e["event_type"] for e in events)),
    }
    (PROCESSED / "run_summary.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(summary, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
