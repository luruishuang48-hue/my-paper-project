# SPECR three-star scan

This is an exploratory specification scan. It is meant to find candidate patterns, not to replace the pre-specified main tables.

- Total tested coefficients: 7,458
- Raw p < 0.01 coefficients: 390
- BH-adjusted p < 0.05 coefficients: 14
- BH-adjusted p < 0.01 coefficients: 0

## Most frequent three-star patterns

spec_type | x | x_label | moderator | n_specs | n_three_star | share_three_star | n_positive | n_negative | sign_stability | n_bh_5pct | median_est_pp | min_p
--- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | ---
main_effect | downstream_deployer | Downstream deployer | NA | 672 | 70 | 0.104 |  46 | 626 | 0.932 | 3 | -0.559 | 1.65e-05
main_effect | upstream_any | Any upstream | NA | 672 | 42 | 0.062 | 342 | 330 | 0.509 | 0 |  0.014 | 4.80e-04
main_effect | upstream_cloud | Upstream cloud | NA | 672 | 41 | 0.061 | 534 | 138 | 0.795 | 0 |  0.494 | 4.43e-04
main_effect | strategic_any | Strategic/upstream | NA | 672 | 40 | 0.060 | 337 | 335 | 0.501 | 0 |  0.000 | 5.67e-04
main_effect | z_intelligence | AA Intelligence Index (z) | NA | 560 | 38 | 0.068 | 309 | 251 | 0.552 | 3 |  0.056 | 4.95e-05
main_effect | downstream_any | Any downstream | NA | 672 | 35 | 0.052 | 215 | 457 | 0.680 | 0 | -0.248 | 1.12e-04
main_effect | upstream_hardware | Upstream hardware | NA | 672 | 35 | 0.052 | 312 | 360 | 0.536 | 0 | -0.074 | 5.75e-04
interaction | upstream_hardware | Upstream hardware | is_open_weight |  30 | 22 | 0.733 |   0 |  30 | 1.000 | 1 | -3.434 | 3.40e-05
interaction | upstream_any | Any upstream | is_open_weight |  30 | 15 | 0.500 |   0 |  30 | 1.000 | 1 | -3.312 | 2.73e-05
interaction | upstream_cloud | Upstream cloud | z_media_sentiment |  30 | 11 | 0.367 |  30 |   0 | 1.000 | 4 |  1.006 | 7.68e-06
main_effect | competitor | Direct competitor | NA | 672 | 11 | 0.016 | 327 | 345 | 0.513 | 0 | -0.011 | 2.20e-04
main_effect | downstream_enabler | Downstream enabler | NA | 672 | 10 | 0.015 | 277 | 395 | 0.588 | 0 | -0.087 | 3.10e-03
main_effect | downstream_integrator | Downstream integrator | NA | 672 |  7 | 0.010 | 391 | 281 | 0.582 | 0 |  0.136 | 1.13e-03
interaction | upstream_hardware | Upstream hardware | is_chinese_model |  20 |  6 | 0.300 |   0 |  20 | 1.000 | 2 | -2.747 | 2.99e-05
interaction | downstream_deployer | Downstream deployer | is_chinese_model |  20 |  3 | 0.150 |   1 |  19 | 0.950 | 0 | -0.960 | 1.36e-03
interaction | upstream_any | Any upstream | is_chinese_model |  20 |  2 | 0.100 |   1 |  19 | 0.950 | 0 | -2.001 | 9.67e-04
interaction | downstream_any | Any downstream | is_reasoning_model |  30 |  1 | 0.033 |   0 |  30 | 1.000 | 0 | -1.605 | 8.06e-03
interaction | downstream_any | Any downstream | is_open_weight |  30 |  1 | 0.033 |  29 |   1 | 0.967 | 0 |  1.645 | 7.68e-03

## Strongest BH-adjusted candidates

spec_type | x_label | moderator | y_var | outcome_family | control_set | sample | term | estimate_pp | se_pp | p.value | p_bh_all | n | n_events
--- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | ---
interaction | Upstream cloud | z_media_sentiment | car_20 | market | firm_year | all | upstream_cloud:z_media_sentiment |  2.502 | 0.505 | 7.68e-06 | 0.0341 | 4198 | 60
interaction | Upstream cloud | z_media_sentiment | car_15 | market | firm_year | all | upstream_cloud:z_media_sentiment |  2.061 | 0.433 | 1.56e-05 | 0.0341 | 4198 | 60
main_effect | Downstream deployer | NA | car_3 | market | firm_year_pre | chinese_origin | downstream_deployer | -1.207 | 0.175 | 1.65e-05 | 0.0341 | 1028 | 13
interaction | Any upstream | is_open_weight | car_5 | market | firm_year | text_or_reason | upstream_any:is_open_weight | -4.452 | 0.958 | 2.73e-05 | 0.0341 | 3861 | 48
interaction | Upstream hardware | is_chinese_model | car_15 | market | firm_year | all | upstream_hardware:is_chinese_model | -5.930 | 1.311 | 2.99e-05 | 0.0341 | 4829 | 60
main_effect | Downstream deployer | NA | car_3 | market | firm_year | chinese_origin | downstream_deployer | -1.225 | 0.189 | 3.08e-05 | 0.0341 | 1029 | 13
interaction | Upstream hardware | is_open_weight | car_5 | market | firm_year | text_or_reason | upstream_hardware:is_open_weight | -4.777 | 1.042 | 3.40e-05 | 0.0341 | 3861 | 48
main_effect | Downstream deployer | NA | car_3 | market | firm | chinese_origin | downstream_deployer | -1.235 | 0.194 | 3.66e-05 | 0.0341 | 1029 | 13
interaction | Upstream cloud | z_media_sentiment | car_20 | market | firm_year | text_or_reason | upstream_cloud:z_media_sentiment |  2.618 | 0.574 | 4.17e-05 | 0.0346 | 3468 | 48
main_effect | AA Intelligence Index (z) | NA | ff3_car_1 | ff3 | firm_year_pre | listed_creator | z_intelligence |  0.831 | 0.162 | 4.95e-05 | 0.0369 | 1694 | 21
interaction | Upstream hardware | is_chinese_model | car_10 | market | firm_year | all | upstream_hardware:is_chinese_model | -4.572 | 1.051 | 5.48e-05 | 0.0372 | 4829 | 60
main_effect | AA Intelligence Index (z) | NA | ff3_car_1 | ff3 | firm_year | listed_creator | z_intelligence |  0.837 | 0.171 | 8.71e-05 | 0.0499 | 1694 | 21
interaction | Upstream cloud | z_media_sentiment | car_10 | market | firm_year | all | upstream_cloud:z_media_sentiment |  1.735 | 0.410 | 9.37e-05 | 0.0499 | 4198 | 60
main_effect | AA Intelligence Index (z) | NA | ff3_car_3 | ff3 | firm_year_pre | listed_creator | z_intelligence |  0.905 | 0.186 | 9.38e-05 | 0.0499 | 1697 | 21

## Files

- `all_specr_results.csv`
- `three_star_results_p001.csv`
- `three_star_summary_by_pattern.csv`
- `three_star_summary_by_x.csv`
