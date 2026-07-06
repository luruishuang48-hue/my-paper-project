# CAR_pre control rerun

All regressions keep the current manuscript outcome construction and add market-model `car_pre` as an extra control.
Controls are `size_log_assets`, `bm_ratio`, `volatility`, `momentum`, `car_pre`, and release-year fixed effects unless otherwise stated.
Standard errors are CR0 clustered by `final_event_id`, matching the existing table scripts.

- Input rows: 5,160
- Nonmissing `car_pre`: 5,029
- Nonmissing `car_20` with all baseline controls plus `car_pre`: 4,805
- Media sentiment coverage: 54 events

## Headline Results

| Section | Variable | Term | Estimate pp | SE pp | p | n |
|---|---|---:|---:|---:|---:|---:|
| baseline | Downstream deployer | downstream_deployer | -1.65 | 0.46 | <0.001 | 4,805 |
| baseline | Upstream hardware | upstream_hardware | 1.67 | 0.68 | 0.016 | 4,805 |
| bundle | Any downstream | downstream_any | -1.80 | 0.71 | 0.014 | 4,805 |
| bundle | Any upstream | upstream_any | 1.62 | 0.63 | 0.013 | 4,805 |
| open_closed | Upstream hardware | Closed/proprietary | 2.12 | 0.80 | 0.008 | 4,805 |
| open_closed | Upstream hardware | Open-weight | 0.06 | 1.03 | 0.952 | 4,805 |
| open_closed | Upstream hardware | Open minus closed | -2.06 | 1.31 | 0.116 | 4,805 |
| open_closed | Downstream deployer | Closed/proprietary | -2.00 | 0.49 | <0.001 | 4,805 |
| open_closed | Downstream deployer | Open-weight | -0.38 | 0.93 | 0.682 | 4,805 |
| open_closed | Downstream deployer | Open minus closed | 1.61 | 1.03 | 0.116 | 4,805 |
| aa_control | Downstream deployer | downstream_deployer | -1.56 | 0.49 | 0.003 | 3,762 |
| aa_control | Upstream hardware | upstream_hardware | 2.20 | 0.79 | 0.007 | 3,762 |
| reasoning | Upstream hardware | Baseline (mod=0) | 1.11 | 0.77 | 0.151 | 4,805 |
| reasoning | Upstream hardware | Mod=1 | 3.11 | 1.27 | 0.014 | 4,805 |
| reasoning | Upstream hardware | Interaction (mod=1 minus mod=0) | 2.00 | 1.47 | 0.173 | 4,805 |
| reasoning | Downstream deployer | Baseline (mod=0) | -1.38 | 0.52 | 0.008 | 4,805 |
| reasoning | Downstream deployer | Mod=1 | -2.31 | 0.88 | 0.008 | 4,805 |
| reasoning | Downstream deployer | Interaction (mod=1 minus mod=0) | -0.93 | 1.02 | 0.358 | 4,805 |
| code | Upstream hardware | Baseline (mod=0) | 1.90 | 0.80 | 0.017 | 4,805 |
| code | Upstream hardware | Mod=1 | 1.04 | 1.36 | 0.444 | 4,805 |
| code | Upstream hardware | Interaction (mod=1 minus mod=0) | -0.86 | 1.59 | 0.589 | 4,805 |
| code | Downstream deployer | Baseline (mod=0) | -1.70 | 0.57 | 0.003 | 4,805 |
| code | Downstream deployer | Mod=1 | -1.50 | 0.57 | 0.009 | 4,805 |
| code | Downstream deployer | Interaction (mod=1 minus mod=0) | 0.20 | 0.77 | 0.796 | 4,805 |
| chinese_origin | Upstream hardware | Baseline (mod=0) | 2.17 | 0.82 | 0.008 | 4,805 |
| chinese_origin | Upstream hardware | Mod=1 | -0.15 | 1.05 | 0.887 | 4,805 |
| chinese_origin | Upstream hardware | Interaction (mod=1 minus mod=0) | -2.32 | 1.35 | 0.086 | 4,805 |
| chinese_origin | Any upstream | Baseline (mod=0) | 1.97 | 0.77 | 0.011 | 4,805 |
| chinese_origin | Any upstream | Mod=1 | 0.33 | 1.04 | 0.749 | 4,805 |
| chinese_origin | Any upstream | Interaction (mod=1 minus mod=0) | -1.64 | 1.35 | 0.226 | 4,805 |
| media | Upstream hardware | Position main effect (at mean sentiment) | 1.99 | 0.74 | 0.007 | 4,174 |
| media | Upstream hardware | Sentiment main effect | -1.25 | 0.43 | 0.004 | 4,174 |
| media | Upstream hardware | Interaction (position x sentiment) | 0.55 | 0.59 | 0.353 | 4,174 |
| media | Upstream hardware | Position effect at -1 SD sentiment | 1.44 | 0.89 | 0.108 | 4,174 |
| media | Upstream hardware | Position effect at +1 SD sentiment | 2.54 | 1.00 | 0.011 | 4,174 |
| media | Downstream deployer | Position main effect (at mean sentiment) | -1.56 | 0.50 | 0.002 | 4,174 |
| media | Downstream deployer | Sentiment main effect | -1.26 | 0.39 | 0.001 | 4,174 |
| media | Downstream deployer | Interaction (position x sentiment) | 0.79 | 0.30 | 0.010 | 4,174 |
| media | Downstream deployer | Position effect at -1 SD sentiment | -2.35 | 0.58 | <0.001 | 4,174 |
| media | Downstream deployer | Position effect at +1 SD sentiment | -0.77 | 0.59 | 0.189 | 4,174 |

## Output Files

- `table_baseline_position_with_car_pre.csv`
- `table_bundle_positions_with_car_pre.csv`
- `table_joint_positions_with_car_pre.csv`
- `table_open_closed_with_car_pre.csv`
- `table_aa_control_with_car_pre.csv`
- `table_reasoning_interaction_with_car_pre.csv`
- `table_code_interaction_with_car_pre.csv`
- `table_chinese_origin_with_car_pre.csv`
- `table_creator_listing_with_car_pre.csv`
- `table_joint_open_origin_with_car_pre.csv`
- `table_media_sentiment_with_car_pre.csv`
