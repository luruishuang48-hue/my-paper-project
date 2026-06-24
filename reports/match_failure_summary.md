# Match Failure Summary

## Inputs
- Source data: `data/events_with_aa_metrics.csv`
- AA cache: `data/cache/artificial_analysis_llms_models.json`
- No API request was made for this diagnostic pass.

## Outputs
- Diagnosed dataset: `data/events_match_diagnosed.csv`
- Manual review table: `reports/manual_match_review.csv`

## Match Status For Model-Labeled Events
| Value | Count |
|---|---:|
| `unmatched` | 31 |
| `matched_low_confidence` | 27 |
| `matched_confirmed` | 21 |

## Refined Event Type Counts
| Value | Count |
|---|---:|
| `text_llm` | 32 |
| `multimodal_model` | 18 |
| `image_model` | 8 |
| `product_integration` | 8 |
| `reasoning_llm` | 8 |
| `agent_product` | 6 |
| `video_model` | 6 |
| `research_system` | 4 |
| `audio_model` | 2 |
| `coding_llm` | 2 |

## Failure Reason Counts
| Value | Count |
|---|---:|
| `ambiguous_variant` | 15 |
| `non_llm_endpoint_mismatch` | 14 |
| `name_alias_issue` | 13 |
| `genuinely_missing_from_aa` | 6 |
| `model_family_not_specific` | 4 |
| `research_system_not_on_leaderboard` | 4 |
| `product_event_mislabeled_as_model` | 2 |

## Manual Review Queue
- Rows requiring manual review: 58
- Rows flagged for AA media endpoint instead of LLM endpoint: 16
- LLM benchmark metrics were blanked for media endpoint rows in the diagnosed output.

## Notes
- `matched_low_confidence` rows are not treated as confirmed; their metric fields remain blank unless already confirmed in the prior dataset.
- `candidate_1` to `candidate_3` are same-creator candidates from the cached AA LLM model list and are provided only for human review.
- Image, video, and audio events are marked `non_llm_endpoint_mismatch` because the cached payload is the AA LLM endpoint, not a media-model endpoint.
