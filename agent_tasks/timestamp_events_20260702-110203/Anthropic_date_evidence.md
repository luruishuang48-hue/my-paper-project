# Anthropic date evidence

Input file: `Anthropic_events.csv`

Method: official first-party Anthropic pages were used where available. The preferred source class was Anthropic News. Product pages were accepted when they are first-party technical/product announcements. When one event combines two models with separate official posts, both dates are retained rather than collapsed.

| event_id | model_names | official_date | source_type | confidence | source |
|---|---|---:|---|---|---|
| AIT-2023-07-002 | Claude 2 | 2023-07-11 | official_news | high | [Claude 2](https://www.anthropic.com/news/claude-2) |
| AIT-2024-03-002 | Claude 3 | 2024-03-04 | official_news | high | [Introducing the next generation of Claude](https://www.anthropic.com/news/claude-3-family) |
| AIT-2024-06-005 | Claude Sonnet 3.5 | 2024-06-21 | official_news | high | [Claude 3.5 Sonnet](https://www.anthropic.com/news/claude-3-5-sonnet) |
| AIT-2024-10-011 | Claude 3.5 Sonnet New | 2024-10-22 | official_news | high | [Introducing computer use, a new Claude 3.5 Sonnet, and Claude 3.5 Haiku](https://www.anthropic.com/news/3-5-models-and-computer-use) |
| AIT-2024-11-007 | Claude 3.5 Haiku | 2024-10-22 | official_news | medium | [Introducing computer use, a new Claude 3.5 Sonnet, and Claude 3.5 Haiku](https://www.anthropic.com/news/3-5-models-and-computer-use) |
| AIT-2025-02-002 | Claude 3.7 | 2025-02-24 | official_news | high | [Claude 3.7 Sonnet and Claude Code](https://www.anthropic.com/news/claude-3-7-sonnet) |
| AIT-2025-05-003 | Claude 4 Opus; Claude Sonnet 4 | 2025-05-22 | official_news | high | [Introducing Claude 4](https://www.anthropic.com/news/claude-4) |
| AIT-2025-08-002 | Claude Opus 4.1 | 2025-08-05 | official_news | high | [Claude Opus 4.1](https://www.anthropic.com/news/claude-opus-4-1) |
| AIT-2025-09-007 | Claude Sonnet 4.5 | 2025-09-29 | official_news | high | [Introducing Claude Sonnet 4.5](https://www.anthropic.com/news/claude-sonnet-4-5) |
| AIT-2025-10-003 | Claude 4.5 Haiku | 2025-10-15 | official_product | high | [Introducing Claude Haiku 4.5](https://www.anthropic.com/news/claude-haiku-4-5) |
| AIT-2025-11-007 | Claude Opus 4.5 | 2025-11-24 | official_news | high | [Introducing Claude Opus 4.5](https://www.anthropic.com/news/claude-opus-4-5) |
| AIT-2026-02-001 | Claude Opus 4.6; Claude Sonnet 4.6 | 2026-02-05; 2026-02-17 | official_news; official_product | high | [Introducing Claude Opus 4.6](https://www.anthropic.com/news/claude-opus-4-6); [Introducing Claude Sonnet 4.6](https://www.anthropic.com/news/claude-sonnet-4-6) |

## Notes

- `AIT-2024-06-005`: the Anthropic page date is June 21, 2024, so the output uses 2024-06-21 even though some secondary sources cite June 20.
- `AIT-2024-11-007`: the official Anthropic page announced Claude 3.5 Haiku on October 22, 2024 and stated that Haiku would be released later that month. I did not find a separate first-party technical post for Visual PDF Analysis during this pass, so confidence is medium.
- `AIT-2026-02-001`: this row combines two models with separate first-party pages and separate dates. I retained both dates. A later event-level rule should either split this event or choose a deterministic rule such as earliest official date.
