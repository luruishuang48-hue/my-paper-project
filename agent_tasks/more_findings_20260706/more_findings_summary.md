# Additional findings scan

Sample: 12112 firm-event observations, 124 events, 101 firms.

## Timing and attention

                 spec                    term          coef           se
        price_car_0_1   rel_upstream_hardware  0.0019951293 0.0020156284
        price_car_0_1      rel_upstream_cloud -0.0025989304 0.0025602910
        price_car_0_1 rel_downstream_deployer -0.0002499957 0.0007491699
        price_car_0_1          rel_competitor  0.0030564502 0.0021745877
 price_increment_2_20   rel_upstream_hardware  0.0145820010 0.0063173202
 price_increment_2_20      rel_upstream_cloud  0.0015429466 0.0079984683
 price_increment_2_20 rel_downstream_deployer -0.0004540905 0.0023338331
 price_increment_2_20          rel_competitor  0.0130115138 0.0062971694
           volume_0_1   rel_upstream_hardware  0.1204598296 0.0341113623
           volume_0_1      rel_upstream_cloud  0.2922119925 0.0523047760
           volume_0_1 rel_downstream_deployer  0.0062358134 0.0188710211
           volume_0_1          rel_competitor -0.0171784011 0.0427481290
    volume_pre_m10_m2   rel_upstream_hardware  0.0325552765 0.0263501235
    volume_pre_m10_m2      rel_upstream_cloud  0.2034934099 0.0410273789
    volume_pre_m10_m2 rel_downstream_deployer -0.0192406768 0.0151345693
    volume_pre_m10_m2          rel_competitor -0.0367456155 0.0294839609
            p     n events
 3.242321e-01 12112    124
 3.122408e-01 12112    124
 7.391807e-01 12112    124
 1.625243e-01 12112    124
 2.268215e-02 12112    124
 8.473811e-01 12112    124
 8.460541e-01 12112    124
 4.102158e-02 12112    124
 5.862113e-04 12072    124
 1.632511e-07 12072    124
 7.416310e-01 12072    124
 6.885299e-01 12072    124
 2.190466e-01 12072    124
 2.520243e-06 12072    124
 2.060364e-01 12072    124
 2.151588e-01 12072    124

## Hardware concentration

Baseline event-FE hardware coefficient: 0.0154 (se 0.0065, p 0.0206).
            term       coef          se           p     n events
    hardware_sox 0.01220284 0.006466131 0.061536198 12112    124
 hardware_nonsox 0.02749177 0.009393812 0.004094248 12112    124

Contrast:
                  contrast       coef          se         p     n events
 hardware_nonsox_minus_sox 0.01528893 0.007299799 0.0362425 12112    124

Leave-one-hardware-ticker-out range: 0.0118 to 0.0163; significant at 5% in 22 of 23 exclusions.

Lowest five after exclusions:
 dropped_ticker       coef          se          p
           SNDK 0.01182485 0.006350159 0.06502075
           LITE 0.01378691 0.006803539 0.04492306
             MU 0.01441496 0.006522817 0.02899442
            WDC 0.01492174 0.006543531 0.02434181
           AVGO 0.01496359 0.006555939 0.02421413

Highest five after exclusions:
 dropped_ticker       coef          se          p
           MCHP 0.01599003 0.006494471 0.01522225
           NXPI 0.01612301 0.006648506 0.01678639
           MPWR 0.01625893 0.006384554 0.01213304
           ALAB 0.01631339 0.006607263 0.01494830
           QCOM 0.01632801 0.006671683 0.01583038

## Cloud pre-event volume leave-one-out

Leave-one-cloud-ticker-out range: 0.1630 to 0.2339; significant at 1% in 6 of 6 exclusions.
 dropped_ticker      coef         se            p
           AMZN 0.2339239 0.04404982 5.790544e-07
           CRWV 0.1675656 0.04134278 9.199587e-05
           GOOG 0.2257687 0.03940472 8.772111e-08
          GOOGL 0.1992193 0.03976928 2.078944e-06
           MSFT 0.1992677 0.04621934 3.531562e-05
           NBIS 0.1629832 0.04245117 2.017387e-04

## Event attribute moderators

                                    spec
            moderator_is_reasoning_model
                 moderator_is_multimodal
     moderator_is_media_generation_model
            moderator_is_reasoning_model
            moderator_is_reasoning_model
 moderator_is_open_weight_or_open_source
     moderator_is_cross_modality_release
               moderator_is_model_family
                 moderator_is_multimodal
               moderator_is_model_family
     moderator_is_cross_modality_release
              moderator_is_chinese_model
 moderator_is_open_weight_or_open_source
               moderator_is_coding_model
     moderator_is_media_generation_model
              moderator_is_chinese_model
               moderator_is_coding_model
               moderator_is_coding_model
     moderator_is_media_generation_model
              moderator_is_chinese_model
               moderator_is_model_family
                 moderator_is_multimodal
     moderator_is_cross_modality_release
 moderator_is_open_weight_or_open_source
                                                  term         coef          se
              rel_upstream_hardware:is_reasoning_model  0.032315738 0.012209675
                 rel_downstream_deployer:is_multimodal  0.006280245 0.003925142
              rel_competitor:is_media_generation_model -0.012720452 0.008650681
                     rel_competitor:is_reasoning_model  0.013388294 0.009871256
            rel_downstream_deployer:is_reasoning_model  0.005425027 0.004246480
          rel_competitor:is_open_weight_or_open_source  0.011406540 0.009326928
       rel_upstream_hardware:is_cross_modality_release  0.046729412 0.031403082
               rel_downstream_deployer:is_model_family  0.005141775 0.004508283
                   rel_upstream_hardware:is_multimodal  0.013105856 0.012244941
                 rel_upstream_hardware:is_model_family -0.014092537 0.013495353
     rel_downstream_deployer:is_cross_modality_release  0.009749759 0.010763033
              rel_downstream_deployer:is_chinese_model -0.003556933 0.004824684
 rel_downstream_deployer:is_open_weight_or_open_source -0.002853209 0.003909519
               rel_downstream_deployer:is_coding_model -0.006501025 0.008199746
     rel_downstream_deployer:is_media_generation_model -0.002587202 0.003878330
                       rel_competitor:is_chinese_model  0.007064179 0.011497377
                 rel_upstream_hardware:is_coding_model -0.034096061 0.052118023
                        rel_competitor:is_coding_model -0.022638725 0.036293848
       rel_upstream_hardware:is_media_generation_model -0.006059268 0.013020687
                rel_upstream_hardware:is_chinese_model  0.006780982 0.014797430
                        rel_competitor:is_model_family -0.003795511 0.010259039
                          rel_competitor:is_multimodal  0.002880166 0.008513512
              rel_competitor:is_cross_modality_release  0.008903674 0.029498337
   rel_upstream_hardware:is_open_weight_or_open_source  0.001649767 0.012930543
           p      q_bh     n events
 0.009755951 0.2341428 12112    124
 0.112520695 0.7242699 12112    124
 0.145364065 0.7242699 12112    124
 0.178832916 0.7242699 12112    124
 0.205092338 0.7242699 12112    124
 0.224311442 0.7242699 12112    124
 0.227302453 0.7242699 12112    124
 0.259897817 0.7242699 12112    124
 0.286865798 0.7242699 12112    124
 0.301779106 0.7242699 12112    124
 0.427840590 0.7658881 12112    124
 0.465590522 0.7658881 12112    124
 0.467253515 0.7658881 12112    124
 0.482358281 0.7658881 12112    124
 0.506694638 0.7658881 12112    124
 0.542555812 0.7658881 12112    124
 0.556709872 0.7658881 12112    124
 0.574416077 0.7658881 12112    124
 0.642975885 0.7792807 12112    124
 0.649400567 0.7792807 12112    124
 0.713114801 0.8027105 12112    124
 0.735817959 0.8027105 12112    124
 0.781539925 0.8155199 12112    124
 0.898739022 0.8987390 12112    124

## Cost, speed, and benchmark metrics

                             metric
    median_output_tokens_per_second
    median_output_tokens_per_second
                      livecodebench
                               gpqa
                               aime
                           mmlu_pro
              aa_intelligence_index
                               aime
                      livecodebench
                           mmlu_pro
    median_output_tokens_per_second
                      livecodebench
            price_1m_blended_3_to_1
                    aa_coding_index
             price_1m_output_tokens
                      aa_math_index
                               gpqa
 median_time_to_first_token_seconds
                      aa_math_index
                    aa_coding_index
              aa_intelligence_index
 median_time_to_first_token_seconds
 median_time_to_first_token_seconds
            price_1m_blended_3_to_1
                      aa_math_index
                               aime
              aa_intelligence_index
             price_1m_output_tokens
            price_1m_blended_3_to_1
                           mmlu_pro
                               gpqa
                    aa_coding_index
             price_1m_output_tokens
                                                         term          coef
      rel_upstream_hardware:z_median_output_tokens_per_second  1.960073e-02
    rel_downstream_deployer:z_median_output_tokens_per_second  5.543514e-03
                        rel_upstream_hardware:z_livecodebench  1.449533e-02
                                 rel_upstream_hardware:z_gpqa  1.489482e-02
                                 rel_upstream_hardware:z_aime  1.524724e-02
                           rel_downstream_deployer:z_mmlu_pro  3.714312e-03
                rel_upstream_hardware:z_aa_intelligence_index  1.282151e-02
                                        rel_competitor:z_aime  9.555530e-03
                      rel_downstream_deployer:z_livecodebench  3.459651e-03
                             rel_upstream_hardware:z_mmlu_pro  9.024962e-03
             rel_competitor:z_median_output_tokens_per_second  7.314802e-03
                               rel_competitor:z_livecodebench  5.895794e-03
                     rel_competitor:z_price_1m_blended_3_to_1  5.752146e-03
                             rel_competitor:z_aa_coding_index -1.692270e-02
                      rel_competitor:z_price_1m_output_tokens  5.477335e-03
                        rel_upstream_hardware:z_aa_math_index  1.092558e-02
                               rel_downstream_deployer:z_gpqa  2.009049e-03
          rel_competitor:z_median_time_to_first_token_seconds -6.024044e-03
                               rel_competitor:z_aa_math_index  5.644273e-03
                      rel_upstream_hardware:z_aa_coding_index  1.527719e-02
                       rel_competitor:z_aa_intelligence_index -3.474552e-03
   rel_upstream_hardware:z_median_time_to_first_token_seconds  4.102132e-03
 rel_downstream_deployer:z_median_time_to_first_token_seconds  1.136256e-03
              rel_upstream_hardware:z_price_1m_blended_3_to_1 -3.029709e-03
                      rel_downstream_deployer:z_aa_math_index  1.228300e-03
                               rel_downstream_deployer:z_aime  1.226258e-03
              rel_downstream_deployer:z_aa_intelligence_index  7.804136e-04
               rel_upstream_hardware:z_price_1m_output_tokens -2.055338e-03
            rel_downstream_deployer:z_price_1m_blended_3_to_1 -6.733381e-04
                                    rel_competitor:z_mmlu_pro  1.055317e-03
                                        rel_competitor:z_gpqa  5.746487e-04
                    rel_downstream_deployer:z_aa_coding_index  3.691163e-04
             rel_downstream_deployer:z_price_1m_output_tokens  7.269232e-06
          se          p      q_bh    n events
 0.006753112 0.00922089 0.3042894 8562    124
 0.002192892 0.02054764 0.3305881 8562    124
 0.006911955 0.04163510 0.3305881 7180    124
 0.007318305 0.04857293 0.3305881 7982    124
 0.007474539 0.05008911 0.3305881 5469    124
 0.002031311 0.09341543 0.5102015 7180    124
 0.007789282 0.10822457 0.5102015 8562    124
 0.006125917 0.12935805 0.5155190 5469    124
 0.002306371 0.14059609 0.5155190 7180    124
 0.006516581 0.19146894 0.6312751 7180    124
 0.005626865 0.21042503 0.6312751 8562    124
 0.005192738 0.26208831 0.6494185 7180    124
 0.004852033 0.27135374 0.6494185 8562    124
 0.014220325 0.29474951 0.6494185 2056    124
 0.005047579 0.30743636 0.6494185 8562    124
 0.010668265 0.31486959 0.6494185 4751    124
 0.002263142 0.38009119 0.7356792 7982    124
 0.006698930 0.40127955 0.7356792 8562    124
 0.008156525 0.49492583 0.8581653 4751    124
 0.022079655 0.52010016 0.8581653 2056    124
 0.005719842 0.54753718 0.8604156 8562    124
 0.008202404 0.63344612 0.8788848 8562    124
 0.002316051 0.64023298 0.8788848 8562    124
 0.006591776 0.65823963 0.8788848 8562    124
 0.002812724 0.66582181 0.8788848 4751    124
 0.003449934 0.72475958 0.8896628 5469    124
 0.002225582 0.72790590 0.8896628 8562    124
 0.006436848 0.75746160 0.8927226 8562    124
 0.002687057 0.80860085 0.9080529 8562    124
 0.004687875 0.82550266 0.9080529 7180    124
 0.005476418 0.91694254 0.9761001 7982    124
 0.005254758 0.94701332 0.9766075 2056    124
 0.002319787 0.99757470 0.9975747 8562    124

## Release-calendar crowding

                   spec                                   term         coef
 calendar_isolated_pm10    rel_upstream_hardware:isolated_pm10  0.017628875
 calendar_isolated_pm10           rel_competitor:isolated_pm10  0.009834308
 calendar_isolated_pm10  rel_downstream_deployer:isolated_pm10 -0.001471372
  calendar_density_pm10   rel_upstream_hardware:z_density_pm10 -0.005255406
  calendar_density_pm10          rel_competitor:z_density_pm10 -0.010336392
  calendar_density_pm10 rel_downstream_deployer:z_density_pm10  0.003628026
          se          p     n events
 0.016766470 0.31291314 12112    124
 0.018164588 0.59816131 12112    124
 0.006752086 0.83106947 12112    124
 0.005728771 0.36258998 12112    124
 0.004410167 0.02254732 12112    124
 0.001733505 0.04058966 12112    124

Event density within +/-10 calendar days:
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
  0.000   2.000   3.000   3.081   5.000   7.000 
Isolated events (+/-10 days): 12 of 124.
