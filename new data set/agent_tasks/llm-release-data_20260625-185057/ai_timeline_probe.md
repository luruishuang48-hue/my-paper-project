# AI Timeline 数据源探查

记录时间 2026-06-25 18:56:43 CST

## 结论

`https://nhlocal.github.io/AiTimeline/#2026` 的 `#2026` 是页内锚点。服务器返回的内容与 `https://nhlocal.github.io/AiTimeline/` 相同，浏览器只滚动到 2026 年 section。

事件数据不是前端运行时再请求 JSON、CSV 或 API。该站点是 Jekyll 静态站，构建时用 `site.data.timeline` 把 `_data/timeline.yml` 渲染进首页 HTML。前端 `assets/js/script.js` 只负责搜索、筛选、排序、深色模式和锚点交互，未发现 `fetch`、`XMLHttpRequest`、`axios` 或动态 `import`。

仓库 README 明确写明 `_data/timeline.md` 是时间线的 single source of truth，`_data/timeline.yml` 由脚本自动生成，供 Jekyll 构建页面使用。因此主代理应优先下载 `_data/timeline.md`，同时下载 `_data/timeline.yml` 作为机器可读版本。

## 数据加载链路

1. 维护者编辑 `_data/timeline.md`。
2. GitHub Actions 运行 `scripts/convert_timeline_events.py _data/timeline.md`。
3. 脚本生成 `_data/timeline.yml`。
4. Jekyll 读取 `site.data.timeline`。
5. `index.md` 按年份和月份循环渲染 HTML。
6. 浏览器打开首页后，事件已在 HTML 中。`#2026` 只定位到对应年份。

## 已验证 URL

| URL | 验证结果 | 用途判断 |
| --- | --- | --- |
| `https://nhlocal.github.io/AiTimeline/#2026` | HTTP 200。返回完整静态 HTML，hash 不参与服务端请求 | 页面入口，可用于核对渲染结果 |
| `https://nhlocal.github.io/AiTimeline/` | HTTP 200。HTML 中含 5 个年份、43 个 month article、235 条 info item、59 条 special item | 可直接从渲染页抽取，但不是最干净的数据源 |
| `https://github.com/NHLOCAL/AiTimeline` | 仓库存在，默认分支 `main`。API 显示最近 push 时间为 2026-06-10T07:49:46Z | 一手仓库入口 |
| `https://api.github.com/repos/NHLOCAL/AiTimeline/contents/_data?ref=main` | HTTP 200。列出 `links.yml`、`timeline.md`、`timeline.yml` | 定位数据文件 |
| `https://raw.githubusercontent.com/NHLOCAL/AiTimeline/main/_data/timeline.md` | HTTP 200，`text/plain`，32,885 bytes。Git blob sha `2f44f933daf9632566d19b486c1993af96f04c3a`。内容 SHA-256 `f1b8fb62938ba006a560a95a3c3ac8f65b636a3bdab62b746a9cac5cd7e209e8` | 首选下载文件 |
| `https://raw.githubusercontent.com/NHLOCAL/AiTimeline/main/_data/timeline.yml` | HTTP 200，`text/plain`，37,320 bytes。Git blob sha `da817bd0304d90fbd6fcf5ebe5c4ef933fe4a2d0`。内容 SHA-256 `fb454f9d21e77631680e05e019f9a286a4b81167f2bb24193400ad58a3e78419` | 首选机器可读文件 |
| `https://nhlocal.github.io/AiTimeline/_data/timeline.yml` | HTTP 404 | GitHub Pages 不直接暴露 `_data` |
| `https://nhlocal.github.io/AiTimeline/_data/timeline.md` | HTTP 404 | GitHub Pages 不直接暴露 `_data` |
| `https://raw.githubusercontent.com/NHLOCAL/AiTimeline/main/index.md` | HTTP 200。发现 `site.data.timeline` 和 `site.data.links` | 证明 Jekyll 数据来源 |
| `https://raw.githubusercontent.com/NHLOCAL/AiTimeline/main/assets/js/script.js` | HTTP 200。未发现网络取数关键词 | 证明前端不动态加载事件 |
| `https://raw.githubusercontent.com/NHLOCAL/AiTimeline/main/scripts/convert_timeline_events.py` | HTTP 200。脚本把 Markdown 年份、月份、bullet 和 `(*special*)` 转为 YAML | 证明生成规则 |
| `https://raw.githubusercontent.com/NHLOCAL/AiTimeline/main/.github/workflows/deploy.yml` | HTTP 200。workflow 安装 PyYAML 后转换 timeline，再构建 Jekyll | 证明自动化链路 |
| `https://nhlocal.github.io/AiTimeline/feed.xml` | HTTP 200。渲染后 RSS 有 43 个 item，按月份聚合 | 可辅助核对月份，不适合作为 item-level 事件源 |

## 可获得字段

### `_data/timeline.yml`

| 层级 | 字段 | 说明 |
| --- | --- | --- |
| year | `year` | 年份，整数 |
| year | `events` | 月份事件数组 |
| event | `date` | 月份名，如 `March` |
| event | `info` | 该月份下的事件数组 |
| info | `text` | 事件文本，模型或产品名通常在 `<b>...</b>` 中 |
| info | `special` | 可选布尔值。出现 59 次，未出现时可视为 false |

### `_data/timeline.md`

| 结构 | 说明 |
| --- | --- |
| `# Year: 2025` | 年份 |
| `## March` | 月份 |
| `- ...` | 单条事件 |
| `**...**` | 加粗文本，通常是模型、产品、公司或项目名 |
| `(*special*)` | 重要事件标记 |

### 首页 HTML

| 字段或结构 | 说明 |
| --- | --- |
| `<section class="year" id="2026">` | 年份区块 |
| `<article id="2026-March-2026" class="event" data-date="March 2026">` | 月份区块。id 是模板生成值，不在原始数据中 |
| `<div class="info" data-special="false">` | 单条事件 |
| `<div class="info special" data-special="true">` | special 事件 |

## 事件量级

统计口径为 `_data/timeline.yml` 的 `info` 条目，结果与首页 HTML 和 `_data/timeline.md` 一致。

| 年份 | 月份数 | 事件条数 | special 条数 |
| --- | ---: | ---: | ---: |
| 2022 | 8 | 11 | 3 |
| 2023 | 9 | 18 | 2 |
| 2024 | 11 | 94 | 17 |
| 2025 | 12 | 95 | 33 |
| 2026 | 3 | 17 | 4 |
| 合计 | 43 | 235 | 59 |

年份范围为 2022 到 2026。

## 静态下载判断

可以静态下载原始数据，但下载入口应走 GitHub raw 或 GitHub API，而不是 GitHub Pages 的 `_data` 路径。

推荐下载顺序如下。

| 优先级 | 文件 | 原因 |
| --- | --- | --- |
| 1 | `_data/timeline.md` | README 指定的权威源。文本最接近人工维护版本，便于审阅 |
| 2 | `_data/timeline.yml` | Jekyll 实际读取的数据。结构化，便于程序处理 |
| 3 | `scripts/convert_timeline_events.py` | 可复现 Markdown 到 YAML 的转换 |
| 4 | `index.md` | 可复现页面渲染字段和排序方式 |
| 5 | `.github/workflows/deploy.yml` | 可复现线上构建流程 |
| 6 | `assets/js/script.js` | 可证明前端没有另行拉取事件数据 |

不建议把 `feed.xml` 作为主数据源。线上 RSS 只有 43 个月份级 item，不能直接保留 235 条 item-level 事件的原始结构。仓库 raw 里的 `feed.xml` 是模板，不是渲染后的数据。

## 对后续匹配任务的影响

源数据没有直接区分模型、产品、公司、功能、研究成果或基准事件。`<b>...</b>` 只是强调文本，不能等同于模型名。例如有些加粗内容是公司、产品、榜单、功能或研究项目。后续模型与产品分类需要单独做规则和人工审核。

源数据只有月份，没有精确日期。做金融市场事件研究时，不能直接拿这些记录作为交易日事件，需要为每条事件补充公告日或发布日期。

源数据没有每条事件的引用链接。若要进入正式样本，应为候选模型发布事件补一手来源，至少补公司公告、博客、论文、模型卡或可信平台链接。

## 主代理建议

主代理应下载 `timeline.md` 和 `timeline.yml`。解析时以 YAML 为主，保留 Markdown 原文用于人工审核。候选名称可以先从 `<b>...</b>` 或 Markdown `**...**` 抽取，但只作为候选，不作为模型名真值。

后续分类建议先给每条 `info` 生成这些中间字段。

| 字段 | 建议生成方式 |
| --- | --- |
| `year` | 来自 year |
| `month` | 来自 event.date |
| `event_text_html` | 来自 YAML info.text |
| `event_text_plain` | 去掉 HTML 标签 |
| `bold_terms` | 提取 `<b>...</b>` 或 `**...**` |
| `is_special` | YAML 的 special，缺失填 false |
| `candidate_type` | 人工或模型规则标记为 model、product、feature、company、research、benchmark、other |
| `needs_exact_date` | 默认 true |
| `needs_source_url` | 默认 true |

最小下载清单如下。

```text
https://raw.githubusercontent.com/NHLOCAL/AiTimeline/main/_data/timeline.md
https://raw.githubusercontent.com/NHLOCAL/AiTimeline/main/_data/timeline.yml
https://raw.githubusercontent.com/NHLOCAL/AiTimeline/main/scripts/convert_timeline_events.py
https://raw.githubusercontent.com/NHLOCAL/AiTimeline/main/index.md
https://raw.githubusercontent.com/NHLOCAL/AiTimeline/main/.github/workflows/deploy.yml
```

## 限制

web-access 的 CDP 前置检查未通过。Node.js 可用，但 Chrome remote debugging 未连接，因此本次没有使用浏览器 CDP。由于目标页面和仓库文件均可通过静态请求验证，这一限制不影响本次数据源定位结论。
