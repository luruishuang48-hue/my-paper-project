# 关系编码切换 — 最终总结

完成时间: 2026-06-25

## 数据切换（Phase 1，已审阅 PASS）
- 根目录 `relationship_data_final.csv` 已产出：5160 行，60 事件，新 8 维列，旧 8 列已删除。
- `data/panel/specr_rel_clean.csv` 已切换为新口径；旧版本备份在 `data/panel/specr_rel_clean_OLD_BACKUP.csv`。
- 独立审阅 agent 跑了 7 项检查，全部通过：行数、唯一键、旧列删除确认、新列计数与 `adjudicated_event_level.csv` 逐行核对（5160/5160 完全匹配）、零缺失值、零重复键。唯一发现的异常是备份文件里有 1 行迁移前就存在的空 key 占位行，不影响结果，无需处理。

## 回归重跑（Phase 2，7 个脚本逐一判断+迁移）
- 6 个脚本确认为真正的关系回归，已建 `_v2` 版本迁移列名语义、跑通、产出对比说明（原文件/原结果全部保留未覆盖）：
  `run_relation_subsample_regressions`、`run_econometric_robustness`、`run_proposal_gap_supplement`、`run_missing_analyses`、`relonly_regression`、`run_relationship_specr`
- 1 个脚本（`vix_news_regression.R`）判定为不适用——它走的是另一条独立管线（直接从原始中文 `relationship` 文本列解析，不经过 `specr_rel_clean.csv`），已另开 follow-up 任务处理。

## 关键发现（Phase 3 综合审阅）

**最值得写进论文的新发现：** `downstream_deployer`（AI 作为工具被非 AI 原生企业部署）呈现负向公告效应，在 3 个独立迁移的脚本中方向一致地浮现（`run_relationship_specr`: coef -0.019, p=0.0004；`relonly_regression`: 同向但样本小未显著；`run_proposal_gap_supplement`: broad_downstream 翻转为显著负 -0.0425, p=0.0051）。这是旧编码的粗粒度 business/real downstream 分类完全掩盖不了的模式，三个脚本独立收敛指向同一结论，是这次重新编码最有价值的产出。

另一个稳健发现：upstream 效应几乎全部由 `upstream_hardware` 驱动，`upstream_cloud` 弱且不显著——旧版合并的 "upstream" 指标掩盖了这个异质性，在 `relonly_regression` 和 `run_relationship_specr` 中独立得到验证。

**需要谨慎对待、建议先做稳健性检查的结果：**
1. `run_econometric_robustness` 的"相关公司"子样本过滤器，在新口径下覆盖率从 40.2% 飙升到 97.7%，已经失去区分能力——这个稳健性检验当前设计的目的已经失效，需要收紧过滤条件或换用别的限制方式。
2. `run_missing_analyses` 的 `positive_exposure` 在 CAR[0,+1] 上从完全不显著（p=0.978）变为高度显著（p=0.0031），但样本量扩大了13倍，点估计本身变化超过一个数量级——更像是样本构成变化而非纯粹的统计功效提升，需要拆解验证。
3. `run_proposal_gap_supplement` 的联合模型里，upstream 效应消失、downstream 效应同时翻转为显著负——两个核心系数在同一模型里同时大幅变动，需要拆开成独立模型分别估计以排除互相干扰。

## 完整产出清单
- `/relationship_data_final.csv`（根目录）
- `data/panel/specr_rel_clean.csv`（已切换）+ `specr_rel_clean_OLD_BACKUP.csv`（备份）
- 6 组 `*_v2.R` + outputs（`_v2` 后缀）+ `*_v2_comparison.md`，分布在各自原 `agent_tasks/` 子目录下
- `agent_tasks/vix_news_regression_20260624-150843/vix_news_regression_NOTE.md`（说明为何跳过）
- `agent_tasks/relationship_recode_switch_2026062500/review_data.md`（数据完整性审阅）
- `agent_tasks/relationship_recode_switch_2026062500/review_regressions_summary.md`（回归结果综合审阅，含完整数字和 6 条行动建议）
- 仓库已完成首次 git commit（`a77bad4`），覆盖以上所有改动

## 未在本轮处理（已记录为独立 follow-up）
- `vix_news_regression.R` 及其依赖的 `prep_621.py` 管线，仍用旧口径解析原始文本列，需要单独迁移到 `adjudicated_event_level.csv`。已生成任务卡片 `task_d625672e`。
