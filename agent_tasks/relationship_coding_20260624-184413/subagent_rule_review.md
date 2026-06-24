# 关系标注规则实现风险审阅

审阅角色为独立审阅子代理。审阅依据为 `data/relationships/gpt_coding_prompt.md`、`data/relationships/relationship_codebook.md` 和 `data/relationships/6.21事件集数据.csv`。本次审阅未修改主数据文件。

## 数据结构核对

- 事件表有两行表头。第 1 行为中文表头，第 2 行为英文表头。读取时应使用第 2 行英文表头。
- 文件编码为 GB18030。直接按 UTF-8 读取会导致中文乱码，也可能误判字段名。
- 正文记录为 5160 行，对应 60 个事件和 86 家公司。
- 样本包含 14 个 creator。事件分布为 Google 19 个、OpenAI 13 个、Anthropic 8 个、Alibaba 7 个、Meta 2 个、xAI 2 个、Mistral AI 2 个，其余 creator 各 1 个。
- 事件模态包括 text_llm、reasoning_llm、coding_llm、multimodal_llm、image_generation、image_editing、video_generation。扩展关系时不能只看 creator，还要保留模态字段供复核。

## 应生成的输出文件和列

最低交付应有一个事件－公司级关系文件。它对应 `relationship_codebook.md` 的编码单位。

建议文件名为 `data/relationships/event_company_relationships.csv`，或在主代理既有命名下保持一致。核心列应为：

```text
final_event_id,company_id,upstream_hardware,upstream_cloud,downstream_integrator,downstream_deployer,downstream_enabler,competitor,is_investor,is_owner,confidence,justification
```

如果需要保留可追溯信息，可追加这些辅助列：

```text
release_date,event_name,true_model_creator,model_names,model_modality,is_media_generation_model,is_reasoning_model,is_coding_model,is_open_weight_or_open_source
```

如果输出为合并后的主数据，则应保留原始事件表全部列，并追加二进制关系列。不要覆盖原有 `relationship` 文本列。建议把原列改名或复制为 `relationship_original`，再追加：

```text
rel_upstream_hardware,rel_upstream_cloud,rel_downstream_integrator,rel_downstream_deployer,rel_downstream_enabler,rel_competitor,rel_is_investor,rel_is_owner,rel_confidence,rel_justification
```

还应生成一个 creator 级中间矩阵，用来承接 `gpt_coding_prompt.md` 的任务设定。该文件应为 1204 行，等于 86 家公司乘 14 个 creator。核心列应为：

```text
company_id,creator,upstream_hardware,upstream_cloud,downstream_integrator,downstream_deployer,downstream_enabler,competitor,is_investor,is_owner,confidence,justification
```

建议另有一个审计文件，用于记录边界案例和低置信度判断。列可以为：

```text
scope_key,company_id,creator,final_event_id,relationship_dimension,provisional_value,confidence,rule_basis,risk_note,recommended_check
```

其中 `scope_key` 可取 `company_creator` 或 `event_company`。这能区分稳定关系和事件模态导致的例外。

## creator 级标注扩展到事件－公司标注的注意点

- 扩展键应使用 `company_id` 和 `true_model_creator`。不要用中文公司名，也不要用 `event_name` 或 `model_names` 进行关系合并。
- creator 名称必须先规范化。`Mistral AI`、`ShengShu Technology`、`Stability AI`、`Zhipu AI`、`xAI` 不能被截断或合并到相近公司。
- creator 级矩阵是稳定底稿，事件级结果还要按 `final_event_id` 展开。每个事件应有 86 行，最终应有 5160 行，不能只输出 1204 行。
- `is_owner` 只能按 codebook 映射。Google 对应 GOOGL，Meta 对应 META，Microsoft 对应 MSFT，Alibaba 对应 BABA。OpenAI、Anthropic、xAI、DeepSeek、Mistral AI、Stability AI、Runway、Kuaishou、ShengShu Technology、Zhipu AI 在样本公司中没有 listed owner。
- Microsoft 对 OpenAI 是 investor，不是 owner。Microsoft 只有在 Phi 事件中才是 owner。
- Kuaishou 虽然是上市公司，但样本公司没有快手 ticker。不能把 Kuaishou 事件映射给 Tencent、BABA 或其他中国互联网公司作为 owner。
- `is_investor` 要求投资发生在事件日之前。已知投资关系包括 MSFT 对 OpenAI、AMZN 对 Anthropic、GOOGL 对 Anthropic、CRM 对 Anthropic、MSFT 对 Mistral AI。
- `competitor` 不能对本公司自己的 creator 事件置 1。owner 事件通常是 `is_owner=1`，不是 `competitor=1`。
- 大型 AI labs 可跨模态视为竞争者。Google、OpenAI、Meta、Anthropic、Alibaba 通常覆盖 text、reasoning、image、video 或多模态的广义竞争。较小或垂直公司只在同模态、同能力空间内标 competitor。
- NVIDIA 是最重要的单独规则。所有 creator 事件中 `upstream_hardware=1`，LLM 事件中 `competitor=0`。不要因为 NeMo、DGX Cloud 或 AI Enterprise 把它标成模型竞争者。
- 下游三类 R3、R4、R5 大多数情况下互斥。公司若已标 R3，通常不再标 R4 或 R5。若确有双重身份，应在 justification 说明主次，而不是无说明地多标。
- R3 和 R4 的核心测试是公司主业离开 AI 后是否仍可识别。Netflix、Uber、Tesla 这类应偏 R4。Palantir、C3.ai、SoundHound、Adobe、ServiceNow、Salesforce 这类应偏 R3。
- R3 和 R5 的核心测试是服务自己产品还是帮助客户部署。Accenture、DXC、Genpact、Fujitsu、NEC、Tietoevry 应偏 R5。Thomson Reuters、Wolters Kluwer、Experian 更接近自有数据和产品嵌入，按 codebook 应优先考虑 R3。
- 云服务 R2 存在规则口径风险。prompt 倾向把大型 AI cloud 能力视为 creator 级结构关系，codebook 示例却对部分 creator 使用更窄的实际托管关系。实现前应固定口径。若采用宽口径，AMZN、GOOGL、MSFT、ORCL、BABA 可能对多 creator 事件均为 R2。若采用窄口径，只能在有托管、服务或平台关系时标 1。
- Oracle 不应被标为 competitor。OCI 是 cloud，不是自研 foundation model 竞争者。
- IBM 是混合案例。codebook 明确要求非 IBM 事件可同时标 downstream_enabler 和 competitor，不能因为 R5 已为 1 就跳过 R6。
- 事件模态可能改变下游暴露。纯视频或图像事件对纯文本下游产品的关系较弱，但 codebook 允许把广义 AI 能力信号计入。实现上应保留模态审计，避免机械复制所有 R3。
- `confidence` 应取所有为 1 指标中的最低置信度。全 0 行如何处理有轻微分歧。prompt 要求空值，codebook 6.1 建议写无关系说明。为和输出规范一致，建议全 0 行 `confidence` 为空，`justification` 为空，同时在审计文件记录无关系说明。
- `justification` 应只解释为 1 的指标。不要给 0 指标写理由，也不要把旧的单一关系文本直接塞入该列。
- 旧的 `relationship` 字段中有 `business_downstream_vs_real_downstream`、`business_downstream`、`real_upstream` 等旧标签。这些不是新 codebook 的合法输出值，不能直接作为最终关系列使用。

## 最容易出错的 20 个公司或 creator 关系

1. MSFT－OpenAI  
   应为 investor，不是 owner。还可能同时有 Azure cloud、Copilot downstream integrator 和 Phi competitor。

2. MSFT－Microsoft  
   Phi 事件中应为 owner。不能再把 Microsoft 标成自身 competitor。是否保留 upstream_cloud 需按统一 R2 口径处理。

3. MSFT－Mistral AI  
   已知有小额投资，应标 investor。不要因为投资额小而漏掉，也不要误标 owner。

4. GOOGL－Google  
   Google 事件中应为 owner，不是 competitor。自有事件中的 upstream_cloud 是否为 1 需要和全局 R2 口径一致。

5. GOOGL－Anthropic  
   既是 investor，又可能是 upstream_cloud 和 competitor。漏标 investor 或把 investor 扩展到非 Anthropic 事件都是高风险错误。

6. AMZN－Anthropic  
   应标 investor。AWS cloud 和 Titan、Nova competitor 也可能同时为 1。不要把 investor 扩展到 OpenAI 或 Google。

7. CRM－Anthropic  
   Salesforce Ventures 投资 Anthropic，应标 investor。CRM 自身也常为 downstream_integrator。不要把投资关系误解成 owner。

8. BABA－Alibaba  
   Alibaba 事件中 BABA 是 owner，不是 competitor。Qwen image 和 text 事件都应统一 owner 处理。

9. META－Meta  
   Meta 事件中 META 是 owner，不是 competitor。Llama 事件的开放权重不改变 owner 标注。

10. Kuaishou 事件  
    样本中没有快手上市 ticker。不能把 700 HK Tencent 或 BABA 误标为 owner。

11. ShengShu Technology、Zhipu AI、DeepSeek、Runway、Stability AI 事件  
    这些 creator 在样本公司中没有 listed owner。不要因为同属中国或同属媒体生成领域而推断 owner。

12. NVDA－所有 creator  
    应稳定标 upstream_hardware。LLM 事件中 competitor 应为 0，这是 codebook 的关键识别约束。

13. ORCL－所有 creator  
    Oracle 是 upstream_cloud 候选，不是 competitor。OCI 托管第三方模型不等于自研 foundation model。

14. IBM－非 IBM creator  
    IBM 可同时为 downstream_enabler 和 competitor。不要因为 downstream 类互斥而误删 R6。

15. HPE－所有 creator  
    HPE 可能同时是 AI hardware 和 enterprise AI enabler。置信度通常不应过高，且不应直接等同 hyperscaler cloud。

16. HUT－所有 creator  
    Hut 8 从 crypto mining 转向 AI/HPC hosting，事件日期和收入确认很重要。它在 R2 upstream_cloud 与 R4 deployer 之间最易摇摆。

17. EXPN LN、TRI、WKL NA  
    这些专业信息服务公司容易被标成 R5。codebook 更倾向把自有数据加 AI 产品视为 R3，除非证据显示主要是客户 AI 部署服务。

18. ACN、DXC、G、6701 JP、6702 JP、TIETO FH  
    这些是 downstream_enabler，不是 downstream_integrator。其价值在帮助客户采用 AI，而不是把 foundation model 作为自有产品核心。

19. AAPL－非 Apple creator  
    Apple 的 on-device foundation models 可作为 competitor，通常置信度为 M。不要把硬件业务自动标成 upstream_hardware，因为它不是 LLM 训练基础设施供应商。

20. 媒体生成 creator 关系  
    Runway、Kuaishou、ShengShu、Stability AI、Google Veo、OpenAI SORA、Alibaba image 事件涉及 image 或 video。主要 AI labs 可跨模态竞争，垂直或文本公司应按同模态能力谨慎判断。

## 验证清单

- 读取 `6.21事件集数据.csv` 时使用 GB18030，并以第 2 行英文表头为字段名。
- 最终事件－公司文件为 5160 行正文，且每个 `final_event_id` 恰有 86 行。
- creator 级中间矩阵为 1204 行正文，且每个 `creator` 恰有 86 行。
- 事件级唯一键为 `final_event_id` 加 `company_id`，无重复，无缺失。
- creator 级唯一键为 `creator` 加 `company_id`，无重复，无缺失。
- 8 个关系列只允许 0 或 1。
- `confidence` 只允许 H、M、L 或空值。
- 全 0 行的 `confidence` 和 `justification` 处理方式与输出规范一致。建议为空。
- 任一行为 1 的关系必须在 `justification` 中有对应简短说明。
- 下游三类 R3、R4、R5 每行最多一个为 1，除非审计文件明确列出例外。
- `is_owner=1` 的行只出现在 GOOGL－Google、META－Meta、MSFT－Microsoft、BABA－Alibaba。
- MSFT－OpenAI 的 `is_owner` 必须为 0，`is_investor` 必须为 1。
- AMZN－Anthropic、GOOGL－Anthropic、CRM－Anthropic、MSFT－Mistral AI 的 `is_investor` 应为 1。
- 其他 creator 的 investor 标注不得从相近关系或合作关系推断。
- NVDA 的 `upstream_hardware` 应对全部 60 个事件为 1，`competitor` 应为 0。
- ORCL 的 `competitor` 应为 0。
- owner 事件中，同一公司不能同时因为自有模型发布被标为 competitor。
- major AI labs 的 competitor 标注应排除自有 creator，并按模态和 codebook 规则扩展到其他 creator。
- 纯 image、video、coding、reasoning 事件应保留模态复核字段，避免把 text-only 关系无条件复制。
- 旧 `relationship` 文本列不应直接映射为最终单一标签。新输出应使用 8 个二进制列。
- 输出排序应固定。creator 级按 `company_id`、`creator` 排序。事件级按 `final_event_id`、`company_id` 排序，或按研究团队指定顺序排序。
- 输出文件建议使用 UTF-8 with BOM 或明确记录编码，避免中文公司名在 Excel 中乱码。
- 对 20 个高风险案例做定向抽查，并保存抽查结果到审计文件。
- 对每个关系维度做汇总计数。若某一维度全为 0，或 owner、investor 数量明显偏离已知映射，应停止交付并复查。

## 总体风险判断

本次规则实现的主要风险不是行数或基础字段，而是两个规则文件的粒度差异。`gpt_coding_prompt.md` 要求公司－creator 矩阵，`relationship_codebook.md` 要求事件－公司矩阵。正确做法是先生成 creator 级底稿，再按事件表展开，并保留事件模态、事件日期和 creator 名称用于复核。

第二个核心风险是 R2 upstream_cloud 的口径不够完全一致。实现前需要固定宽口径或窄口径，并在输出说明里记录。否则 Microsoft、Amazon、Google、Oracle、Alibaba 的 cloud 标注会出现系统性分歧，直接影响 inter-coder reliability。

第三个核心风险是把旧 `relationship` 文本类别当作新标签使用。新 codebook 要求 8 个二进制字段加 confidence 和 justification。旧标签只能作为参考，不能作为最终输出结构。
