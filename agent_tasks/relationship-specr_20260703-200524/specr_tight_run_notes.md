# Tight Relationship SPECR Run Notes

本次是按子代理审阅意见收紧后的探索性 SPECR。宽网格版本因事件固定效应和大量共线组合过慢而中止，没有用于结论。

- Input panel: `/Users/chenzhuo/Library/Mobile Documents/com~apple~CloudDocs/Documents/Manuscript/在研项目/大语言模型发布行为对金融市场的影响 - 来自美股市场的证据/Analysis/processed/event_firm_panel.csv`
- Successful specs: 3200
- Candidate groups: 15
- Full results: `/Users/chenzhuo/Library/Mobile Documents/com~apple~CloudDocs/Documents/Manuscript/在研项目/大语言模型发布行为对金融市场的影响 - 来自美股市场的证据/agent_tasks/relationship-specr_20260703-200524/specr_tight_all_results.csv`
- Candidate summary: `/Users/chenzhuo/Library/Mobile Documents/com~apple~CloudDocs/Documents/Manuscript/在研项目/大语言模型发布行为对金融市场的影响 - 来自美股市场的证据/agent_tasks/relationship-specr_20260703-200524/specr_tight_candidate_summary.csv`
- Validation: `/Users/chenzhuo/Library/Mobile Documents/com~apple~CloudDocs/Documents/Manuscript/在研项目/大语言模型发布行为对金融市场的影响 - 来自美股市场的证据/agent_tasks/relationship-specr_20260703-200524/specr_tight_validation.csv`

设计边界：主关系采用事件固定效应和完整控制组；R5 下游赋能全零，未纳入；owner/investor 低支持度，自动标风险；coding 和 cross-modality 事件数过少，未进入交互搜索。

判读规则：优先看同族 BH q 值、方向一致率、处理组公司数/事件数和 leave-one-year / leave-one-ticker 核验。
