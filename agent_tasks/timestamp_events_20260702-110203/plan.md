# Multi-agent execution plan

Task timestamp: 20260702-110203, Asia/Shanghai.

Goal: rename `传递` to `事件集筛选`, create a root timestamped working folder, copy the necessary event-set file into it, then enrich the 134-event final sample with event dates from official vendor technical blogs or equivalent first-party technical announcement pages.

## Phase 1. Planning and intake

- Confirm current event-set folder and final sample location.
- Create a timestamped root work folder.
- Copy `final_event_sample.csv` as the starting point.
- Read creators and events from the sample, then partition events by vendor.
- Use official vendor technical blogs as primary sources. If no technical blog post exists, use a first-party announcement, release note, developer page, or model page and mark the source type.

## Phase 2. Execution and integration

- Main agent handles filesystem changes and creates the integrated dated sample.
- Subagents, when available, handle independent vendor groups and write results into local CSV/Markdown files under this task folder.
- Each evidence row should include event_id, model names, vendor, official date, source URL, source title, and confidence.
- The integration output should preserve all 134 events.

## Phase 3. Review

- Check row count remains 134.
- Check that every inserted date has a first-party URL where possible.
- Flag unresolved or low-confidence rows rather than inventing dates.
- Spot-check vendor groups with known ambiguous announcement versus release timing.

## Phase 4. Revision

- Revise dates where review identifies a better official source.
- Produce final dated CSV plus a concise coverage report.
- Keep all intermediate evidence files in the timestamped folder.
