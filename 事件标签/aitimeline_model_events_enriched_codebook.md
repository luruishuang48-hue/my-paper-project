# Event-label codebook

## Scope

The coding unit is one day-verified model-release event. The final event table
contains 125 events. Multi-model announcements remain one event and are coded
using all released components.

## Fields

| Field | Definition |
|---|---|
| `model_modalities` | Semicolon-separated modalities represented in the event |
| `is_cross_modality_release` | Language and at least one media modality are released together |
| `is_model_family` | The event releases two or more variants from one model family |
| `is_multimodal` | The representative model supports multiple input or output modalities |
| `is_reasoning_model` | The representative model is presented as a reasoning model |
| `is_coding_model` | The representative model primarily targets coding tasks |
| `is_media_generation_model` | The event includes image, video, speech, or music generation |
| `is_open_weight_or_open_source` | A principal model released in the event has downloadable weights |
| `is_chinese_model` | The releasing developer belongs to the Chinese AI ecosystem |

The representative model is the event-level record selected in
`事件集筛选/processed/event_aa_metrics.csv`. Language-model events use the
highest Artificial Analysis Intelligence Index. Other events use the highest
available media Elo.

## Coding and adjudication

Coders A and B applied the same rules independently. Binary disagreements were
adjudicated individually. The original codings and discrepancy table are in
`事件标签/`, and the final table is
`事件集筛选/decisions/event_label_decisions.csv`.

Operational details and boundary cases are recorded in `labeling_rules.md`.
