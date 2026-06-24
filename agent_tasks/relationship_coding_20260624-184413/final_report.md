# 关系标注交付报告

本次任务按 `gpt_coding_prompt.md` 先构造公司－发布方矩阵，再按 `relationship_codebook.md` 扩展到事件－公司层面。

## 输出文件

- `data/relationships/company_creator_relationships_coder_b.csv`
  - 1,204 行
  - 86 家公司乘 14 个发布方
  - 字段为 `company_id, creator` 加 8 个二进制关系列、`confidence`、`justification`
- `data/relationships/event_company_relationships_coder_b.csv`
  - 5,160 行
  - 60 个事件乘 86 家公司
  - 字段为 `final_event_id, company_id` 加 8 个二进制关系列、`confidence`、`justification`
- `data/relationships/6.21事件集数据_relationships_coder_b.csv`
  - 5,160 行
  - 基于最新版 `6.21事件集数据.csv`
  - 原始事件数据后追加 `rel_` 前缀的关系字段
- `agent_tasks/relationship_coding_20260624-184413/relationship_audit_cases.csv`
  - 20 个高风险审计案例
- `agent_tasks/relationship_coding_20260624-184413/subagent_rule_review.md`
  - 子代理独立规则审阅

## 关键口径

- 云服务采用宽口径。AMZN、GOOGL、MSFT、ORCL、BABA 作为 AI cloud 基础设施提供方，对各发布方事件标记 `upstream_cloud=1`。自有发布方事件中仍保留 cloud 关系，但 `competitor=0`。
- `is_owner` 只映射 BABA－Alibaba、GOOGL－Google、META－Meta、MSFT－Microsoft。
- `is_investor` 只映射 MSFT－OpenAI、AMZN－Anthropic、GOOGL－Anthropic、CRM－Anthropic、MSFT－Mistral AI。
- NVIDIA 按 codebook 规则在全部事件中标记 `upstream_hardware=1`，不标记 competitor。
- 专业信息服务公司 EXPN LN、TRI、WKL NA 按 codebook 的边界规则归入 R3，而不是 R5。
- 下游三类 R3、R4、R5 在每一行中保持互斥。

## 验证结果

- 公司－发布方文件为 1,204 行，无重复 `company_id, creator`。
- 事件－公司文件为 5,160 行，无重复 `final_event_id, company_id`。
- 完整合并文件为 5,160 行，覆盖 60 个事件和 86 家公司。
- 8 个关系列均为 0 或 1。
- 正关系行均有 `confidence` 和 `justification`。
- `confidence` 仅包含 H、M、L。
- 下游三类没有多重标记。
- owner 行只有 4 个 creator 映射，且 owner 行没有 competitor 标记。

## 关系计数

公司－发布方矩阵计数如下。

| 字段 | 计数 |
| --- | ---: |
| upstream_hardware | 280 |
| upstream_cloud | 70 |
| downstream_integrator | 433 |
| downstream_deployer | 280 |
| downstream_enabler | 112 |
| competitor | 122 |
| is_investor | 5 |
| is_owner | 4 |

事件－公司矩阵计数如下。

| 字段 | 计数 |
| --- | ---: |
| upstream_hardware | 1200 |
| upstream_cloud | 300 |
| downstream_integrator | 1859 |
| downstream_deployer | 1200 |
| downstream_enabler | 480 |
| competitor | 511 |
| is_investor | 39 |
| is_owner | 29 |
