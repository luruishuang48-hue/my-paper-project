from pathlib import Path

import pandas as pd


ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "agent_tasks/coder_ab_discrepancy_audit_20260624-211116"
A_PATH = ROOT / "data/relationships/coder_a_output.csv"
B_PATH = ROOT / "data/relationships/company_creator_relationships_coder_b.csv"
EVENT_PATH = ROOT / "data/relationships/6.21事件集数据.csv"

REL_COLS = [
    "upstream_hardware",
    "upstream_cloud",
    "downstream_integrator",
    "downstream_deployer",
    "downstream_enabler",
    "competitor",
    "is_investor",
    "is_owner",
]


def kappa(x, y):
    x = x.astype(int)
    y = y.astype(int)
    po = (x == y).mean()
    px = x.mean()
    py = y.mean()
    pe = px * py + (1 - px) * (1 - py)
    if pe == 1:
        return 1.0
    return (po - pe) / (1 - pe)


def note_for(row):
    company = row["company_id"]
    creator = row["creator"]
    dim = row["dimension"]
    if company == "AMZN" and creator == "Alibaba" and dim == "upstream_cloud":
        return "云服务宽窄口径分歧。按宽口径，AWS 是 AI cloud 基础设施，B=1。按实际托管口径，A=0。建议先固定 R2 口径。"
    if company == "GOOGL" and creator == "Google" and dim == "upstream_cloud":
        return "自有发布方事件是否仍标 upstream_cloud 的口径分歧。codebook 示例不完全一致，建议统一 self-cloud 规则。"
    if company == "MSFT" and creator == "Mistral AI" and dim == "downstream_integrator":
        return "Microsoft 是否对所有非自有发布方保持 R3 的一致性分歧。若 Copilot 暴露按 creator 通用处理，B=1。"
    if company == "QUBT" and dim == "downstream_integrator":
        return "低置信度 R3 边界。codebook 表中列为 L，A 按保守全 0，B 按 inclusive L=1。保守 H/M 样本中该差异消失。"
    if company == "WRD" and dim == "downstream_deployer":
        return "低置信度 R4 边界。codebook 表中列为 L，A 按保守全 0，B 按 inclusive L=1。保守 H/M 样本中该差异消失。"
    return "需人工复核。"


def main():
    a = pd.read_csv(A_PATH, dtype=str).fillna("")
    b = pd.read_csv(B_PATH, dtype=str).fillna("")
    events = pd.read_csv(EVENT_PATH, encoding="gb18030", skiprows=1, dtype=str)
    events = events[events["final_event_id"].astype(str).str.match(r"^FMR-\d{4}$", na=False)].copy()
    event_weights = events.drop_duplicates(["final_event_id", "true_model_creator"])[
        "true_model_creator"
    ].value_counts()

    m = a.merge(b, on=["company_id", "creator"], suffixes=("_a", "_b"), how="outer", indicator=True)

    rows = []
    for _, r in m.iterrows():
        for dim in REL_COLS:
            av = r[f"{dim}_a"]
            bv = r[f"{dim}_b"]
            if av != bv:
                rows.append(
                    {
                        "company_id": r["company_id"],
                        "creator": r["creator"],
                        "dimension": dim,
                        "coder_a": av,
                        "coder_b": bv,
                        "confidence_a": r["confidence_a"],
                        "confidence_b": r["confidence_b"],
                        "justification_a": r["justification_a"],
                        "justification_b": r["justification_b"],
                        "creator_event_count": int(event_weights.get(r["creator"], 0)),
                    }
                )
    diffs = pd.DataFrame(rows)
    if not diffs.empty:
        diffs["event_rows_affected"] = diffs["creator_event_count"]
        diffs["audit_note"] = diffs.apply(note_for, axis=1)
    diffs.to_csv(OUT / "binary_disagreements_company_creator.csv", index=False, encoding="utf-8-sig")

    event_diff_rows = []
    for _, r in diffs.iterrows():
        matched = events[
            (events["true_model_creator"] == r["creator"])
            & (events["company_id"] == r["company_id"])
        ]
        for _, ev in matched.iterrows():
            event_diff_rows.append(
                {
                    "final_event_id": ev["final_event_id"],
                    "event_name": ev["event_name"],
                    "creator": r["creator"],
                    "company_id": r["company_id"],
                    "dimension": r["dimension"],
                    "coder_a": r["coder_a"],
                    "coder_b": r["coder_b"],
                    "confidence_a": r["confidence_a"],
                    "confidence_b": r["confidence_b"],
                    "audit_note": r["audit_note"],
                }
            )
    pd.DataFrame(event_diff_rows).to_csv(
        OUT / "binary_disagreements_event_weighted.csv", index=False, encoding="utf-8-sig"
    )

    summary_rows = []
    for dim in REL_COLS:
        x = m[f"{dim}_a"].astype(int)
        y = m[f"{dim}_b"].astype(int)
        summary_rows.append(
            {
                "dimension": dim,
                "n_pairs": len(m),
                "coder_a_ones": int(x.sum()),
                "coder_b_ones": int(y.sum()),
                "agreements": int((x == y).sum()),
                "disagreements": int((x != y).sum()),
                "a1_b0": int(((x == 1) & (y == 0)).sum()),
                "a0_b1": int(((x == 0) & (y == 1)).sum()),
                "agreement_rate": round(float((x == y).mean()), 6),
                "cohen_kappa": round(float(kappa(x, y)), 6),
            }
        )
    kappa_df = pd.DataFrame(summary_rows)
    kappa_df.to_csv(OUT / "kappa_summary_company_creator.csv", index=False, encoding="utf-8-sig")

    hm = m.copy()
    for suffix in ["a", "b"]:
        lmask = hm[f"confidence_{suffix}"] == "L"
        for dim in REL_COLS:
            hm.loc[lmask, f"{dim}_{suffix}"] = "0"
    hm_rows = []
    for dim in REL_COLS:
        x = hm[f"{dim}_a"].astype(int)
        y = hm[f"{dim}_b"].astype(int)
        hm_rows.append(
            {
                "dimension": dim,
                "n_pairs": len(hm),
                "coder_a_ones_hm": int(x.sum()),
                "coder_b_ones_hm": int(y.sum()),
                "agreements_hm": int((x == y).sum()),
                "disagreements_hm": int((x != y).sum()),
                "a1_b0_hm": int(((x == 1) & (y == 0)).sum()),
                "a0_b1_hm": int(((x == 0) & (y == 1)).sum()),
                "agreement_rate_hm": round(float((x == y).mean()), 6),
                "cohen_kappa_hm": round(float(kappa(x, y)), 6),
            }
        )
    hm_kappa_df = pd.DataFrame(hm_rows)
    hm_kappa_df.to_csv(
        OUT / "kappa_summary_company_creator_hm_conservative.csv",
        index=False,
        encoding="utf-8-sig",
    )

    any_binary = pd.Series(False, index=m.index)
    for dim in REL_COLS:
        any_binary |= m[f"{dim}_a"] != m[f"{dim}_b"]
    conf_only = m[(~any_binary) & (m["confidence_a"] != m["confidence_b"])].copy()
    conf_only["creator_event_count"] = conf_only["creator"].map(event_weights).fillna(0).astype(int)
    conf_only.to_csv(OUT / "confidence_only_disagreements.csv", index=False, encoding="utf-8-sig")

    a_rel_sum = a[REL_COLS].astype(int).sum(axis=1)
    b_rel_sum = b[REL_COLS].astype(int).sum(axis=1)
    quality_rows = [
        {
            "coder": "A",
            "rows": len(a),
            "duplicate_keys": int(a.duplicated(["company_id", "creator"]).sum()),
            "zero_relation_rows": int((a_rel_sum == 0).sum()),
            "zero_relation_rows_with_confidence": int(((a_rel_sum == 0) & (a["confidence"] != "")).sum()),
            "zero_relation_rows_with_justification": int(((a_rel_sum == 0) & (a["justification"] != "")).sum()),
        },
        {
            "coder": "B",
            "rows": len(b),
            "duplicate_keys": int(b.duplicated(["company_id", "creator"]).sum()),
            "zero_relation_rows": int((b_rel_sum == 0).sum()),
            "zero_relation_rows_with_confidence": int(((b_rel_sum == 0) & (b["confidence"] != "")).sum()),
            "zero_relation_rows_with_justification": int(((b_rel_sum == 0) & (b["justification"] != "")).sum()),
        },
    ]
    pd.DataFrame(quality_rows).to_csv(OUT / "input_quality_summary.csv", index=False, encoding="utf-8-sig")

    by_dim = diffs.groupby("dimension").size().reindex(REL_COLS, fill_value=0)
    by_company = diffs.groupby("company_id").size().sort_values(ascending=False)
    by_creator = diffs.groupby("creator").size().sort_values(ascending=False)

    event_diff_count = len(event_diff_rows)
    total_cells = len(m) * len(REL_COLS)
    total_diff = len(diffs)
    conf_only_weighted = int(conf_only["creator_event_count"].sum())
    hm_any = pd.Series(False, index=hm.index)
    for dim in REL_COLS:
        hm_any |= hm[f"{dim}_a"] != hm[f"{dim}_b"]
    hm_total_diff = int(
        sum((hm[f"{dim}_a"] != hm[f"{dim}_b"]).sum() for dim in REL_COLS)
    )
    hm_pair_diff = int(hm_any.sum())
    hm_event_rows = 0
    for _, r in hm[hm_any].iterrows():
        hm_event_rows += int(event_weights.get(r["creator"], 0))

    report = f"""# Coder A 与 Coder B 差异审计

审计对象为 `data/relationships/coder_a_output.csv` 和 `data/relationships/company_creator_relationships_coder_b.csv`。二者都是公司－发布方层面的 1,204 行矩阵。

## 总览

- 两份文件键完全一致，均无重复 `company_id, creator`。
- 8 个二进制字段共有 {total_cells} 个可比单元格。
- 二进制差异为 {total_diff} 个，整体一致率为 {1 - total_diff / total_cells:.4%}。
- 有任一二进制差异的公司－发布方行为 {int(any_binary.sum())} 行，占 1,204 行的 {any_binary.mean():.2%}。
- 扩展到 60 个事件后，受影响事件－公司行为 {event_diff_count} 行，占 5,160 行的 {event_diff_count / 5160:.2%}。
- 置信度单独不同但二进制完全一致的行为 {len(conf_only)} 行，按事件权重展开为 {conf_only_weighted} 行。
- 保守 H/M 口径下，二进制差异降至 {hm_total_diff} 个，公司－发布方行为 {hm_pair_diff} 行，事件－公司行为 {hm_event_rows} 行。

## κ 统计

{kappa_df.to_markdown(index=False)}

## 保守 H/M 口径

先把 `confidence=L` 的正关系重置为 0 后，κ 统计如下。

{hm_kappa_df.to_markdown(index=False)}

## 二进制差异分布

按关系字段统计。

{by_dim.to_frame('disagreements').to_markdown()}

按公司统计。

{by_company.to_frame('disagreements').to_markdown()}

按发布方统计。

{by_creator.to_frame('disagreements').to_markdown()}

## 主要分歧

1. `upstream_cloud` 有 2 个差异。AMZN－Alibaba 是 R2 宽窄口径分歧。GOOGL－Google 是自有发布方事件是否仍标 cloud 的口径分歧。
2. `downstream_integrator` 有 15 个差异。其中 QUBT 对全部 14 个 creator 为低置信度边界。MSFT－Mistral AI 是 Microsoft R3 是否对所有非自有 creator 一致适用。
3. `downstream_deployer` 有 14 个差异，全部来自 WRD 对 14 个 creator 的低置信度 R4 边界。
4. 其他 5 个字段完全一致，包括 hardware、enabler、competitor、investor 和 owner。

## 数据质量问题

Coder A 有 28 行全 0 关系却保留 `confidence=L` 和 justification，均来自 QUBT 与 WRD。按 prompt 的输出规范，全 0 行应把这两个字段留空。若后续只看二进制关系，这不影响 κ。若要比较 confidence，需要先统一这个格式。

## 建议裁决

- 先固定 R2 cloud 口径。若采用宽口径，AMZN－Alibaba 应取 B。若采用实际托管口径，取 A。
- 对 self-cloud 单独定规。若 owner 事件不再标 R2，GOOGL－Google 应取 A，并同步检查 BABA－Alibaba、MSFT－Microsoft。
- QUBT 和 WRD 的差异是 L 级边界。保守 H/M 版本可直接归 0，inclusive 版本可保留 B。
- MSFT－Mistral AI 建议取 B，前提是 Microsoft Copilot 的 R3 暴露按所有非自有 creator 稳定处理。
- confidence 字段建议按 codebook 的最低置信度规则重算。AMZN、IBM、CRM 的 B 口径更符合“最低置信度”。
"""
    (OUT / "coder_ab_discrepancy_report.md").write_text(report, encoding="utf-8")


if __name__ == "__main__":
    main()
