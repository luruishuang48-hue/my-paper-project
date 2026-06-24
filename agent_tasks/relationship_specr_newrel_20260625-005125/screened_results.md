# Relationship-focused Specr screened results

Input file: `data/panel/specr_rel_clean.csv`.

This run screens relationship mechanisms under the new 8-dimension coding. It does not use old `output/data` files or historical result tables.

## Sample coverage

|variable              |  n_1| events_1| car20_nonmissing_1| intel_nonmissing_1| mean_car20_1| mean_car20_0|
|:---------------------|----:|--------:|------------------:|------------------:|------------:|------------:|
|any_relationship      | 5040|       60|               4953|               3948|    0.0008077|   -0.0470358|
|appropriable_any      | 3655|       60|               3618|               2864|    0.0050578|   -0.0132417|
|downstream_any        | 3417|       60|               3330|               2676|   -0.0048668|    0.0089979|
|downstream_integrator | 1797|       60|               1760|               1407|   -0.0001395|   -0.0001389|
|strategic_any         | 1503|       60|               1503|               1180|    0.0143710|   -0.0062824|
|upstream_any          | 1474|       60|               1474|               1157|    0.0148331|   -0.0063053|
|upstream_hardware     | 1200|       60|               1200|                940|    0.0167292|   -0.0053927|
|downstream_deployer   | 1140|       60|               1090|                893|   -0.0134540|    0.0035231|
|non_ai_deployer_only  | 1140|       60|               1090|                893|   -0.0134540|    0.0035231|
|competitor            |  511|       60|                511|                402|   -0.0002332|   -0.0001285|
|downstream_enabler    |  480|       60|                480|                376|   -0.0026999|    0.0001297|
|upstream_cloud        |  274|       60|                274|                217|    0.0065288|   -0.0005214|
|is_investor           |   39|       23|                 39|                 38|   -0.0018905|   -0.0001255|
|is_owner              |   29|       29|                 29|                 21|    0.0127604|   -0.0002136|

## Main and joint relationship effects

|family                   |spec_label           |term                 |x_var                |y_var  |controls        |estimate |std.error |  p.value|stars |    n| n_events| treated_n| treated_events| mean_y_treated| mean_y_untreated|
|:------------------------|:--------------------|:--------------------|:--------------------|:------|:---------------|:--------|:---------|--------:|:-----|----:|--------:|---------:|--------------:|--------------:|----------------:|
|joint_relationship_model |downstream_three_way |downstream_deployer  |NA                   |car_20 |firm_year_intel |-0.03801 |0.00782   | 1.40e-05|***   | 3780|       60|        NA|             NA|             NA|               NA|
|joint_relationship_model |downstream_three_way |downstream_deployer  |NA                   |car_15 |firm_year_intel |-0.03117 |0.00655   | 1.98e-05|***   | 3780|       60|        NA|             NA|             NA|               NA|
|joint_relationship_model |downstream_three_way |downstream_enabler   |NA                   |car_15 |firm_year_intel |-0.03563 |0.00751   | 2.04e-05|***   | 3780|       60|        NA|             NA|             NA|               NA|
|joint_relationship_model |downstream_three_way |downstream_deployer  |NA                   |car_10 |firm_year_intel |-0.02023 |0.00480   | 1.14e-04|***   | 3780|       60|        NA|             NA|             NA|               NA|
|main_effect_single       |single_flag          |downstream_any       |downstream_any       |car_15 |firm_year_intel |-0.02818 |0.00705   | 2.28e-04|***   | 3780|       60|      3330|             60|     -0.0043114|        0.0080280|
|main_effect_single       |single_flag          |downstream_deployer  |downstream_deployer  |car_20 |firm_year       |-0.01902 |0.00507   | 4.04e-04|***   | 4829|       60|      1090|             60|     -0.0134540|        0.0035231|
|main_effect_single       |single_flag          |non_ai_deployer_only |non_ai_deployer_only |car_20 |firm_year       |-0.01902 |0.00507   | 4.04e-04|***   | 4829|       60|      1090|             60|     -0.0134540|        0.0035231|
|main_effect_single       |single_flag          |downstream_deployer  |downstream_deployer  |car_20 |firm            |-0.01915 |0.00511   | 4.08e-04|***   | 4829|       60|      1090|             60|     -0.0134540|        0.0035231|
|main_effect_single       |single_flag          |non_ai_deployer_only |non_ai_deployer_only |car_20 |firm            |-0.01915 |0.00511   | 4.08e-04|***   | 4829|       60|      1090|             60|     -0.0134540|        0.0035231|
|main_effect_single       |single_flag          |downstream_any       |downstream_any       |car_20 |firm_year_intel |-0.03305 |0.00871   | 4.32e-04|***   | 3780|       60|      3330|             60|     -0.0048668|        0.0089979|
|main_effect_single       |single_flag          |downstream_deployer  |downstream_deployer  |car_20 |firm_year_intel |-0.02020 |0.00540   | 5.01e-04|***   | 3780|       60|      1090|             60|     -0.0134540|        0.0035231|
|main_effect_single       |single_flag          |non_ai_deployer_only |non_ai_deployer_only |car_20 |firm_year_intel |-0.02020 |0.00540   | 5.01e-04|***   | 3780|       60|      1090|             60|     -0.0134540|        0.0035231|
|joint_relationship_model |downstream_three_way |downstream_enabler   |NA                   |car_10 |firm_year_intel |-0.02428 |0.00678   | 8.18e-04|***   | 3780|       60|        NA|             NA|             NA|               NA|
|main_effect_single       |single_flag          |downstream_deployer  |downstream_deployer  |car_15 |firm_year       |-0.01429 |0.00431   | 1.56e-03|***   | 4829|       60|      1090|             60|     -0.0106312|        0.0027916|
|main_effect_single       |single_flag          |non_ai_deployer_only |non_ai_deployer_only |car_15 |firm_year       |-0.01429 |0.00431   | 1.56e-03|***   | 4829|       60|      1090|             60|     -0.0106312|        0.0027916|
|main_effect_single       |single_flag          |downstream_deployer  |downstream_deployer  |car_15 |firm            |-0.01434 |0.00435   | 1.64e-03|***   | 4829|       60|      1090|             60|     -0.0106312|        0.0027916|
|main_effect_single       |single_flag          |non_ai_deployer_only |non_ai_deployer_only |car_15 |firm            |-0.01434 |0.00435   | 1.64e-03|***   | 4829|       60|      1090|             60|     -0.0106312|        0.0027916|
|joint_relationship_model |downstream_three_way |downstream_enabler   |NA                   |car_20 |firm_year_intel |-0.03150 |0.00942   | 1.65e-03|***   | 3780|       60|        NA|             NA|             NA|               NA|
|main_effect_single       |single_flag          |downstream_any       |downstream_any       |car_15 |firm            |-0.02162 |0.00672   | 2.10e-03|***   | 4829|       60|      3330|             60|     -0.0043114|        0.0080280|
|main_effect_single       |single_flag          |downstream_any       |downstream_any       |car_10 |firm_year_intel |-0.01862 |0.00572   | 2.13e-03|***   | 3780|       60|      3330|             60|     -0.0032688|        0.0029584|

## Intelligence by relationship interactions

|family                        |term                      |x_var             |y_var  |controls  |estimate |std.error |  p.value|stars |    n| n_events| treated_n| treated_events|
|:-----------------------------|:-------------------------|:-----------------|:------|:---------|:--------|:---------|--------:|:-----|----:|--------:|---------:|--------------:|
|interaction_intel_by_relation |intel_c:is_investor       |is_investor       |car_15 |firm_year |-0.00253 |0.00052   | 1.23e-05|***   | 3780|       47|        38|             22|
|interaction_intel_by_relation |intel_c:is_investor       |is_investor       |car_15 |none      |-0.00320 |0.00081   | 2.74e-04|***   | 3955|       47|        38|             22|
|interaction_intel_by_relation |intel_c:is_investor       |is_investor       |car_10 |firm_year |-0.00251 |0.00068   | 6.15e-04|***   | 3780|       47|        38|             22|
|interaction_intel_by_relation |intel_c:is_investor       |is_investor       |car_10 |none      |-0.00291 |0.00084   | 1.13e-03|***   | 3955|       47|        38|             22|
|interaction_intel_by_relation |intel_c:is_investor       |is_investor       |car_20 |firm_year |-0.00262 |0.00089   | 5.16e-03|***   | 3780|       47|        38|             22|
|interaction_intel_by_relation |intel_c:is_investor       |is_investor       |car_20 |none      |-0.00319 |0.00117   | 8.86e-03|***   | 3955|       47|        38|             22|
|interaction_intel_by_relation |intel_c:competitor        |competitor        |car_15 |none      |-0.00107 |0.00058   | 7.03e-02|*     | 3955|       47|       402|             47|
|interaction_intel_by_relation |intel_c:upstream_hardware |upstream_hardware |car_10 |firm_year |0.00106  |0.00058   | 7.32e-02|*     | 3780|       47|       940|             47|
|interaction_intel_by_relation |intel_c:upstream_hardware |upstream_hardware |car_10 |none      |0.00090  |0.00050   | 7.92e-02|*     | 3955|       47|       940|             47|
|interaction_intel_by_relation |intel_c:competitor        |competitor        |car_15 |firm_year |-0.00092 |0.00052   | 8.36e-02|*     | 3780|       47|       402|             47|
|interaction_intel_by_relation |intel_c:is_owner          |is_owner          |car_15 |none      |0.00381  |0.00216   | 8.42e-02|*     | 3955|       47|        21|             21|
|interaction_intel_by_relation |intel_c:competitor        |competitor        |car_20 |none      |-0.00109 |0.00064   | 9.41e-02|*     | 3955|       47|       402|             47|
|interaction_intel_by_relation |intel_c:downstream_any    |downstream_any    |car_10 |firm_year |-0.00081 |0.00048   | 9.57e-02|*     | 3780|       47|      2605|             47|

## Capability slopes within relationship subsamples

|family                                 |term                  |x_var                 |y_var  |controls  |estimate |std.error | p.value|stars |    n| n_events| treated_n| treated_events|
|:--------------------------------------|:---------------------|:---------------------|:------|:---------|:--------|:---------|-------:|:-----|----:|--------:|---------:|--------------:|
|capability_slope_in_relation_subsample |aa_intelligence_index |is_investor           |car_10 |none      |-0.00317 |0.00090   | 0.00199|***   |   38|       22|        38|             22|
|capability_slope_in_relation_subsample |aa_intelligence_index |is_investor           |car_15 |none      |-0.00311 |0.00098   | 0.00460|***   |   38|       22|        38|             22|
|capability_slope_in_relation_subsample |aa_intelligence_index |appropriable_any      |car_20 |firm_year |0.00132  |0.00056   | 0.02210|**    | 2793|       47|      2834|             47|
|capability_slope_in_relation_subsample |aa_intelligence_index |any_relationship      |car_20 |firm_year |0.00116  |0.00051   | 0.02720|**    | 3729|       47|      3877|             47|
|capability_slope_in_relation_subsample |aa_intelligence_index |competitor            |car_10 |none      |-0.00091 |0.00042   | 0.03410|**    |  402|       47|       402|             47|
|capability_slope_in_relation_subsample |aa_intelligence_index |is_investor           |car_20 |none      |-0.00273 |0.00132   | 0.05150|*     |   38|       22|        38|             22|
|capability_slope_in_relation_subsample |aa_intelligence_index |downstream_any        |car_20 |firm_year |0.00139  |0.00073   | 0.06350|*     | 2490|       47|      2605|             47|
|capability_slope_in_relation_subsample |aa_intelligence_index |competitor            |car_15 |none      |-0.00090 |0.00048   | 0.06650|*     |  402|       47|       402|             47|
|capability_slope_in_relation_subsample |aa_intelligence_index |downstream_integrator |car_20 |firm_year |0.00184  |0.00098   | 0.06750|*     | 1373|       47|      1377|             47|
|capability_slope_in_relation_subsample |aa_intelligence_index |downstream_enabler    |car_10 |none      |-0.00110 |0.00059   | 0.06820|*     |  376|       47|       376|             47|
|capability_slope_in_relation_subsample |aa_intelligence_index |upstream_hardware     |car_15 |firm_year |0.00116  |0.00063   | 0.07190|*     |  907|       47|       940|             47|
|capability_slope_in_relation_subsample |aa_intelligence_index |strategic_any         |car_15 |firm_year |0.00094  |0.00052   | 0.07730|*     | 1147|       47|      1180|             47|
|capability_slope_in_relation_subsample |aa_intelligence_index |upstream_any          |car_15 |firm_year |0.00095  |0.00053   | 0.07750|*     | 1124|       47|      1157|             47|
|capability_slope_in_relation_subsample |aa_intelligence_index |is_owner              |car_15 |none      |0.00387  |0.00208   | 0.07750|*     |   21|       21|        21|             21|
|capability_slope_in_relation_subsample |aa_intelligence_index |appropriable_any      |car_15 |firm_year |0.00088  |0.00051   | 0.09090|*     | 2793|       47|      2834|             47|

## Relationship contrast models

|family                   |spec_label                 |term                  |y_var  |controls        |estimate |std.error |  p.value|stars |    n| n_events|
|:------------------------|:--------------------------|:---------------------|:------|:---------------|:--------|:---------|--------:|:-----|----:|--------:|
|joint_relationship_model |downstream_three_way       |downstream_deployer   |car_20 |firm_year_intel |-0.03801 |0.00782   | 1.40e-05|***   | 3780|       60|
|joint_relationship_model |downstream_three_way       |downstream_deployer   |car_15 |firm_year_intel |-0.03117 |0.00655   | 1.98e-05|***   | 3780|       60|
|joint_relationship_model |downstream_three_way       |downstream_enabler    |car_15 |firm_year_intel |-0.03563 |0.00751   | 2.04e-05|***   | 3780|       60|
|joint_relationship_model |downstream_three_way       |downstream_deployer   |car_10 |firm_year_intel |-0.02023 |0.00480   | 1.14e-04|***   | 3780|       60|
|joint_relationship_model |downstream_three_way       |downstream_enabler    |car_10 |firm_year_intel |-0.02428 |0.00678   | 8.18e-04|***   | 3780|       60|
|joint_relationship_model |downstream_three_way       |downstream_enabler    |car_20 |firm_year_intel |-0.03150 |0.00942   | 1.65e-03|***   | 3780|       60|
|joint_relationship_model |joint_all_eight            |downstream_enabler    |car_15 |firm_year_intel |-0.04197 |0.01291   | 2.16e-03|***   | 3780|       60|
|joint_relationship_model |upstream_hardware_vs_cloud |upstream_hardware     |car_20 |firm_year_intel |0.03149  |0.00993   | 2.70e-03|***   | 3780|       60|
|joint_relationship_model |joint_bundles              |downstream_any        |car_20 |firm_year_intel |-0.03874 |0.01225   | 2.76e-03|***   | 3780|       60|
|joint_relationship_model |joint_all_eight            |downstream_enabler    |car_10 |firm_year_intel |-0.03588 |0.01164   | 3.46e-03|***   | 3780|       60|
|joint_relationship_model |downstream_three_way       |downstream_deployer   |car_20 |none            |-0.02245 |0.00738   | 3.52e-03|***   | 5053|       60|
|joint_relationship_model |upstream_hardware_vs_cloud |upstream_cloud        |car_15 |firm_year_intel |0.01997  |0.00685   | 5.46e-03|***   | 3780|       60|
|joint_relationship_model |downstream_three_way       |downstream_deployer   |car_15 |none            |-0.01866 |0.00654   | 5.99e-03|***   | 5053|       60|
|joint_relationship_model |upstream_hardware_vs_cloud |upstream_hardware     |car_20 |none            |0.02303  |0.00810   | 6.14e-03|***   | 5053|       60|
|joint_relationship_model |downstream_three_way       |downstream_integrator |car_20 |firm_year_intel |-0.03062 |0.01095   | 7.49e-03|***   | 3780|       60|
|joint_relationship_model |joint_all_eight            |downstream_enabler    |car_20 |firm_year_intel |-0.03973 |0.01424   | 7.66e-03|***   | 3780|       60|
|joint_relationship_model |joint_bundles              |downstream_any        |car_15 |firm_year_intel |-0.03208 |0.01151   | 7.70e-03|***   | 3780|       60|
|joint_relationship_model |upstream_hardware_vs_cloud |upstream_hardware     |car_15 |firm_year_intel |0.02375  |0.00874   | 9.21e-03|***   | 3780|       60|
|joint_relationship_model |joint_all_eight            |downstream_deployer   |car_20 |firm_year_intel |-0.04991 |0.01893   | 1.14e-02|**    | 3780|       60|
|joint_relationship_model |joint_all_eight            |downstream_integrator |car_20 |firm_year_intel |-0.04160 |0.01584   | 1.17e-02|**    | 3780|       60|

## Files

- `relationship_specr_newrel_all.csv`
- `relationship_specr_newrel_summary.csv`
- `relationship_main_effect_screen.csv`
- `relationship_interaction_screen.csv`
- `relationship_subsample_screen.csv`
- `relationship_contrast_screen.csv`
- `sample_overlap_report.csv`
