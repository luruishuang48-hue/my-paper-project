# 媒体情绪管道（T7）

取代旧版 `爬虫抓取7.py` + `finbert情感分析2.py`（旧版问题见论文附录 D 与
本目录脚本头注释）。两步：

```bash
# 第 1 步：抓取（可断点续跑；每事件一个 CSV，已存在自动跳过）
python3 gdelt_fetch_news.py                 # 全部 124 个主样本事件
python3 gdelt_fetch_news.py --events AIT-2025-01-003   # 指定事件

# 第 2 步：情感（需 torch + transformers；首次运行自动下载 ProsusAI/finbert）
python3 finbert_sentiment.py --self-test    # 先自检（无需 torch）
python3 finbert_sentiment.py                # 正式运行
```

## 设计要点

- **事件与日期**从 `CAR/metadata/event_dates_with_trading_day.csv` 读取
  （核证日度日期），关键词由 model_names/aa_creators 程序化生成，
  泛词黑名单挡掉裸 "GPT"/"AI" 类查询；人工微调走
  `Media/metadata/event_keywords_override.csv`（event_id, add_keywords,
  drop_keywords，分号分隔）。
- **限流处理**：GDELT 限流返回 HTTP 200 + 纯文本，脚本以"响应不可 JSON 解析"
  识别并指数退避（15s→30s→60s...），单事件失败不影响已完成部分。
- **情感基于标题**（GDELT artlist 不含正文，旧版的 content 字段实为空转）。
  Tetlock 式标题情感 + GDELT ToneChart 的事件级语调
  （`processed/gdelt_event_tone.csv`）互为校验。
- **FinBERT 标签顺序按名称解析**：ProsusAI/finbert 是 (pos,neg,neu)=(0,1,2)，
  yiyanghkust/finbert-tone 是 (1,2,0)——已在线核对两个模型的 config.json。
  标签集合不符会直接报错，不会静默产出错误分数。
- **聚合窗口**（日历日，事件级输出 `processed/event_sentiment.csv`）：
  pre [-7,-1] / event [0,+1] / post [0,+3] / post [0,+7]。
  与 CAR 合并时按 event_id 连接即可。

## 实测状态（2026-07-13）

- 爬虫已实测跑通 2 个事件（R1：24 篇 + GDELT 语调 0.74；GPT-5：20 篇），
  退避机制经实弹验证。全量 124 事件约需 1–2 小时（限流节奏决定），
  可分多次跑，自动续接。
- FinBERT 脚本自检通过（标签映射/日期差/窗口聚合），前向传播需在装有
  torch 的机器上运行（GPU/Apple Silicon 均可，CPU 也行——只有标题，量小）。
