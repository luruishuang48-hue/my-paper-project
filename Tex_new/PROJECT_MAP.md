# 项目源码与数据地图（内部文件，不随论文发表）

论文唯一阅读入口：`Tex_new/gfj_main.tex`（正文 + 附录 A-E）。
本文件是它的配套索引：改哪个结果 → 跑哪个脚本 → 数据在哪。
路径均相对项目根目录。最后更新 2026-07-03。

## 一、流水线（按依赖顺序）

| 步骤 | 脚本 | 输入 → 输出 |
|---|---|---|
| 1. 事件集 | `new data set/scripts/build_dataset.py` → `resolve_entities.py` → `build_final_sample.py` | ATL+AA 原始数据 → `processed/final_event_sample.csv`（134 事件） |
| 2. 日期 | `new data set/scripts/build_event_dates.py` | + `decisions/date_decisions.csv` → `processed/final_event_sample_main.csv`（125；剔除 9 无日度日期） |
| 3. AA 指标 | `new data set/scripts/build_event_aa_metrics.py` | 旗舰代表规则 → `processed/event_aa_metrics.csv` |
| 4. 面板 | `Analysis/scripts/build_event_firm_panel.py` | CAR/财务/标签/关系全合并 → `Analysis/processed/event_firm_panel.csv`（13,500 行；含 D1 剔除标记 → 主样本 124 事件） |
| 5. 主回归 | `Analysis/scripts/t9_main_regressions.R` | → `Analysis/reports/t9_main_regressions.csv` |
| 6. 稳健性 | `Analysis/scripts/t9_robustness_matrix.R` | 20 设定 → `Analysis/reports/t9_robustness_matrix.csv` |
| 7. 能力定价 | `Analysis/scripts/frl_capability_pricing.R` | FRL 复刻 + 新角度网格 |
| 8. 异常量 | `Analysis/scripts/build_abnormal_volume.py` | → `Analysis/processed/event_firm_abnormal_volume.csv` |
| 9. 论文数字 | `Analysis/scripts/paper_numbers.R` | **论文全部表格数字的唯一来源** → `Analysis/reports/paper_numbers.csv` |
| 10. 图 1 | `Analysis/scripts/fig1_car_profile.R` | 读 paper_numbers.csv → `Tex_new/figures/fig1_car_profile.pdf` |

| 11. 媒体抓取 | `Media/scripts/gdelt_fetch_news.py` | 事件±7日 GDELT 标题+语调 → `Media/raw/gdelt/`、`Media/processed/` |
| 12. 媒体情感 | `Media/scripts/finbert_sentiment.py` | 需 torch；先 `--self-test` → `Media/processed/event_sentiment.csv` |
| 工具 | `tools/event_study.py` | 旧逐公司 Excel 工作流的修正版（MM+FF3；与面板 MM CAR 机器精度一致） |

改了任何 decisions 表 → 从对应步骤起往下重跑即可。
注意：估计窗为 **[-200,-11]**（2026-07-06 修订，右端点避开前窗 [-10,-2]）。

## 二、决策表（唯一真值，全在 `new data set/decisions/`）

- `entity_decisions.csv` —— 事件-AA 匹配终审（136 条）
- `date_decisions.csv` —— 134 事件官方日期 + 来源 + 置信度
- `firm_universe_decisions.csv` —— 108 公司池（纳指100+SOX，附来源指数）
- `relationship_decisions.csv` —— 2,700 对 ×8 维关系（双盲+仲裁定稿）
- `event_label_decisions.csv` —— 125 事件 ×9 标签（双盲+仲裁定稿）
- `analysis_design_decisions.md` —— P4/D1-D7 设计决策 + 旗舰规则

## 三、编码过程留痕（审稿人索要 κ 细节时用）

- `事件标签/` —— codebook、编码细则（含开源规则修订记录）、coder A/B 脚本与输出、分歧仲裁表
- `关系标签/` —— relationship codebook v1.0、coder A/B、分歧仲裁表、5 项 codebook 扩展说明（README）

## 四、市场与财务数据

- `CAR/processed/` —— `prices_daily_long.csv`、`returns_daily_long.csv`、`ff3_daily.csv`、基准指数
- `CAR/metadata/event_dates_with_trading_day.csv` —— 事件交易日映射（滚动规则）
- `Fundamentals/processed/fundamentals_quarterly_wide.csv` —— 季度财务（ADR 股数已核）
- `Analysis/processed/` 其余：`event_firm_abnormal_volume.csv`（异常量）、`event_firm_car_shifted.csv`（t+1 平移 CAR）、`event_release_time_meta.csv` / `_wayback.csv`（时点考证）

## 五、分析备忘录（附录 A-E 的底稿，读附录即可，这些仅作溯源）

`Analysis/reports/`：
- `frl_capability_pricing_review_20260703.md` —— 测量法医学全记录（附录 D 底稿）
- `vshape_timing_20260703.md` —— V 型排查 + 时点敏感性（附录 E.8 底稿）
- `volume_portfolio_tests_20260703.md` —— 量价与组合（附录 E.3/E.6 底稿）
- `codex_specr_reconciliation_20260703.md` —— 独立规格搜索对账（附录 E.7 底稿）
- `agent_tasks/more_findings_20260706/` —— Codex 二轮补充挖掘（LOO/SOX 对比/云前窗放量；口径正确，已核实并入正文与附录 E）
- `paper_rewrite_draft_20260703.md` —— 叙事重构方案（已被英文稿吸收）
- `两篇分工与结构_20260703.md` —— FRL/长文双轨分工（若回退 FRL 用）
- 根目录 `数据问题与欠缺清单_20260703.md` —— 历史问题清单（全部闭环，存档）

## 六、旧版遗产（只读，勿用于新分析）

- `data/panel/clean_event_firm_panel.csv` + `specr_input_clean.csv` —— 旧 60 事件面板（CAR 不可复现，仅供附录 D 的对照复算）
- `data/relationships/adjudicated_company_creator.csv` —— 旧关系仲裁（新编码的仲裁锚）
- `Tex/long_new.tex` —— 中文会议版长文（叙事已过时，数字为旧样本）

## 七、待办（截至 2026-07-03）

1. 媒体情绪（GDELT+FinBERT，用户生产）→ 到位后插入长文"注意力通道"节 + 面板加列
2. 用户审稿 `gfj_main.tex`（标题三候选已选 1；H2 按"检验并拒绝"呈现）
3. GFJ 投稿配件：highlights 文件、cover letter、title page（Elsevier 要求分文件）
4. 可选补强：历史成分股名单（幸存者偏差）、中概/港股子样本
