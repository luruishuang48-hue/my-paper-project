# 事件标签编码（125 事件主样本）

对应 to_do T8 后半：为 `new data set/processed/final_event_sample_main.csv` 的
125 个事件重打事件级标签，供回归使用（开源调节效应、异质性分析）。

## 规则来源（只放规则，不放旧结果）

- `aitimeline_model_events_enriched_codebook.md`：标签字段定义（第 41-48 字段），
  来自旧数据集 codebook，本轮沿用同一定义。
- `labeling_rules.md`：本轮编码细则——把 codebook 定义具体化成可执行判据，
  含边界情形处理，coder A/B 共同遵守。

## 编码协议

沿用关系编码的双盲流程：

1. **Coder A**：Claude（2026-07-03 本轮），独立编码，产出
   `coder_A_event_labels_20260703.csv`，逐事件附判断依据。
2. **Coder B**：待安排（另开会话或用户本人），不得参考 coder A 结果。
3. **仲裁**：A/B 分歧行列分歧表，由用户仲裁定稿；计算各维度 Cohen's κ。
4. 定稿后落 `new data set/decisions/event_label_decisions.csv`，
   由面板构建脚本合并。

## 标签字段（沿用旧面板列名）

| 字段 | 类型 | 定义摘要 |
|---|---|---|
| model_modalities | 文本 | 事件内所有身份匹配模型的模态集合（分号分隔） |
| is_cross_modality_release | 0/1 | 同一事件同时发布语言与媒体（图/视频/音频）模型 |
| is_model_family | 0/1 | 家族/多尺寸发布（≥2 个同系列变体），非单一模型 |
| is_multimodal | 0/1 | 代表模型支持多模态输入或输出 |
| is_reasoning_model | 0/1 | 代表模型为推理模型或事件明确主打 reasoning |
| is_coding_model | 0/1 | 代表模型主打编程/代码任务 |
| is_media_generation_model | 0/1 | 事件含图像/视频/语音/音乐生成模型 |
| is_open_weight_or_open_source | 0/1 | 事件发布的模型公开权重（以旗舰代表模型为准） |
| is_chinese_model | 0/1 | 发布方属中国生态 |
