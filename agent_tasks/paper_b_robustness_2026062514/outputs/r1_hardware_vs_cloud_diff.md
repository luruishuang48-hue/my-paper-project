# R1: upstream_hardware vs upstream_cloud — formal difference test

At the primary window **car_20**, the joint regression (both `upstream_hardware` and `upstream_cloud` entered simultaneously, controls + year FE, CR0 clustered by `final_event_id`) gives beta_hardware = 0.0237 (SE = 0.0086) vs. beta_cloud = 0.0161 (SE = 0.0069); the difference is 0.0076 with SE 0.0073, z = 1.040, **p = 0.2984** (n = 4829, 60 event clusters). This difference is NOT statistically significant at the 5% level.

This does NOT formally confirm the claim in `agent_tasks/relationship_recode_switch_2026062500/review_regressions_summary.md` (line 28, `relonly_regression` discussion), which claims the upstream effect is "driven almost entirely by hardware (cloud weak/n.s.)" based on eyeballing point estimates from separate single-variable regressions: the joint-model point estimates point the same direction at car_20 (hardware > cloud), but the formal difference test does not reach conventional significance, so the qualitative claim is not confirmed (only descriptively, not statistically, supported) by this stricter test.

Full results across car_10 / car_15 / car_20:

| outcome | beta_hardware | se_hardware | beta_cloud | se_cloud | diff | se_diff | z | p_value | n | n_events |
|---|---|---|---|---|---|---|---|---|---|---|
| car_10 | 0.0075 | 0.0060 | 0.0112 | 0.0055 | -0.0037 | 0.0067 | -0.553 | 0.5800 | 4829 | 60 |
| car_15 | 0.0176 | 0.0075 | 0.0197 | 0.0059 | -0.0020 | 0.0071 | -0.285 | 0.7757 | 4829 | 60 |
| car_20 | 0.0237 | 0.0086 | 0.0161 | 0.0069 | 0.0076 | 0.0073 | 1.040 | 0.2984 | 4829 | 60 |
