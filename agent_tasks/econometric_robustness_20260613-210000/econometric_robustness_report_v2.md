# Econometric Robustness Report (v2 — NEW relationship schema)

本报告由 `run_econometric_robustness_v2.R` 自动生成，使用新版8维度关系编码 (data/panel/specr_rel_clean.csv)。

## 样本摘要

# A tibble: 13 × 2
   metric                     value
   <chr>                      <dbl>
 1 raw_rows_specr_rel        5160  
 2 rows_after_blank_filter   5160  
 3 events_after_blank_filter   60  
 4 firms_after_blank_filter    86  
 5 main_regression_rows      3780  
 6 main_regression_events      47  
 7 closed_rows               2899  
 8 closed_events               36  
 9 open_rows                  881  
10 open_events                 11  
11 us_like_main_rows         2857  
12 us_like_main_firms          64  
13 intel_mean_for_centering    26.6

## 核心稳健性结果

# A tibble: 16 × 10
   spec                 cluster term  beta  se    p         n events firms r2   
   <chr>                <chr>   <chr> <chr> <chr> <chr> <int>  <int> <int> <chr>
 1 baseline_no_firm_fe… event   inte… 0.00… 0.00… 0.02…  3780     47    85 0.106
 2 firm_fe_all          event   inte… 0.00… 0.00… 0.02…  3780     47    85 0.166
 3 firm_fe_all          firm    inte… 0.00… 0.00… 0.00…  3780     47    85 0.166
 4 firm_fe_all          two_way inte… 0.00… 0.00… 0.05…  3780     47    85 0.166
 5 firm_fe_closed       event   inte… 0.00… 0.00… 0.00…  2899     36    85 0.173
 6 firm_fe_closed       firm    inte… 0.00… 0.00… 0.00…  2899     36    85 0.173
 7 firm_fe_closed       two_way inte… 0.00… 0.00… 0.01…  2899     36    85 0.173
 8 firm_fe_interaction… event   inte… 0.00… 0.00… 0.00…  3780     47    85 0.172
 9 firm_fe_interaction… event   inte… -0.0… 0.00… 0.00…  3780     47    85 0.172
10 firm_fe_interaction… two_way inte… -0.0… 0.00… 0.00…  3780     47    85 0.172
11 ff3_firm_fe_all      event   inte… 0.00… 0.00… 0.02…  3782     47    85 0.149
12 ff3_firm_fe_closed   event   inte… 0.00… 0.00… 0.02…  2901     36    85 0.152
13 pre_event_car_firm_… event   inte… 0.00… 0.00… 0.57…  3762     47    84 0.044
14 pre_event_car_firm_… event   inte… 0.00… 0.00… 0.11…  2884     36    84 0.060
15 us_like_tickers_fir… event   inte… 0.00… 0.00… 0.01…  2857     47    64 0.190
16 us_like_tickers_fir… event   inte… 0.00… 0.00… 0.00…  2191     36    64 0.191

## 事件层聚合结果

# A tibble: 4 × 10
  spec                  cluster term  beta  se    p         n events firms r2   
  <chr>                 <chr>   <chr> <chr> <chr> <chr> <int>  <int> <int> <chr>
1 event_level_all_firm… event_… inte… 0.00… 0.00… 0.11…    47     47    NA 0.453
2 event_level_all_firm… event_… inte… 0.00… 0.00… 0.01…    36     36    NA 0.455
3 event_level_related_… event_… inte… 0.00… 0.00… 0.12…    47     47    NA 0.360
4 event_level_related_… event_… inte… 0.00… 0.00… 0.03…    36     36    NA 0.514

## Leave-one-creator-out 结果

# A tibble: 20 × 10
   spec                 cluster term  beta  se    p         n events firms r2   
   <chr>                <chr>   <chr> <chr> <chr> <chr> <int>  <int> <int> <chr>
 1 closed_leave_out_Go… event   inte… 0.00… 0.00… 0.01…  1927     24    85 0.155
 2 all_leave_out_Google event   inte… 0.00… 0.00… 0.01…  2725     34    85 0.170
 3 closed_leave_out_Op… event   inte… 0.00… 0.00… 0.00…  2010     25    85 0.213
 4 all_leave_out_OpenAI event   inte… 0.00… 0.00… 0.07…  2808     35    85 0.207
 5 closed_leave_out_An… event   inte… 0.00… 0.00… 0.00…  2272     28    85 0.198
 6 all_leave_out_Anthr… event   inte… 0.00… 0.00… 0.06…  3153     39    85 0.179
 7 closed_leave_out_Al… event   inte… 0.00… 0.00… 0.00…  2820     35    85 0.202
 8 all_leave_out_Aliba… event   inte… 0.00… 0.00… 0.03…  3385     42    85 0.168
 9 closed_leave_out_Me… event   inte… 0.00… 0.00… 0.00…  2816     35    85 0.174
10 all_leave_out_Meta   event   inte… 0.00… 0.00… 0.02…  3614     45    85 0.169
11 closed_leave_out_xAI event   inte… 0.00… 0.00… 0.00…  2733     34    85 0.172
12 all_leave_out_xAI    event   inte… 0.00… 0.00… 0.02…  3614     45    85 0.169
13 closed_leave_out_Mi… event   inte… 0.00… 0.00… 0.00…  2899     36    85 0.173
14 all_leave_out_Mistr… event   inte… 0.00… 0.00… 0.02…  3622     45    85 0.175
15 closed_leave_out_Mi… event   inte… 0.00… 0.00… 0.00…  2816     35    85 0.155
16 all_leave_out_Micro… event   inte… 0.00… 0.00… 0.05…  3697     46    85 0.156
17 closed_leave_out_De… event   inte… 0.00… 0.00… 0.00…  2899     36    85 0.173
18 all_leave_out_DeepS… event   inte… 0.00… 0.00… 0.02…  3701     46    85 0.152
19 closed_leave_out_Zh… event   inte… 0.00… 0.00… 0.00…  2899     36    85 0.173
20 all_leave_out_Zhipu… event   inte… 0.00… 0.00… 0.02…  3701     46    85 0.167

## 窗口重叠诊断

   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
  0.000   2.000   3.000   2.681   4.000   6.000 

输出 CSV 已写入当前任务目录（均带 _v2 后缀）。
