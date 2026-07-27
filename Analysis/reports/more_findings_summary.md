# Additional findings scan

Sample: 5441 firm-event observations, 124 events, 45 firms.

## Timing and attention

                 spec                    term         coef          se
        price_car_0_1   rel_upstream_hardware  0.004205958 0.003144795
        price_car_0_1      rel_upstream_cloud  0.001403005 0.001989084
        price_car_0_1 rel_downstream_deployer  0.002699341 0.002421738
        price_car_0_1          rel_competitor  0.003613022 0.002782141
 price_increment_2_20   rel_upstream_hardware  0.030551629 0.010420350
 price_increment_2_20      rel_upstream_cloud  0.009097734 0.006293330
 price_increment_2_20 rel_downstream_deployer  0.009914716 0.007851284
 price_increment_2_20          rel_competitor  0.030240094 0.008235526
           volume_0_1   rel_upstream_hardware -0.007420100 0.049797410
           volume_0_1      rel_upstream_cloud  0.095087088 0.067489804
           volume_0_1 rel_downstream_deployer -0.170011117 0.057293817
           volume_0_1          rel_competitor  0.102551484 0.063260902
    volume_pre_m10_m2   rel_upstream_hardware -0.076536506 0.038818426
    volume_pre_m10_m2      rel_upstream_cloud  0.074450095 0.051148354
    volume_pre_m10_m2 rel_downstream_deployer -0.111615678 0.041407646
    volume_pre_m10_m2          rel_competitor  0.012380103 0.046744380
            p    n events
 0.1835847497 5441    124
 0.4819726364 5441    124
 0.2672033014 5441    124
 0.1966875953 5441    124
 0.0040281855 5441    124
 0.1509199725 5441    124
 0.2090676948 5441    124
 0.0003681077 5441    124
 0.8817967971 5441    124
 0.1614806147 5441    124
 0.0036167652 5441    124
 0.1077658518 5441    124
 0.0509276491 5441    124
 0.1481555532 5441    124
 0.0080215497 5441    124
 0.7916064413 5441    124

## Hardware concentration

Baseline event-FE hardware coefficient: 0.0336 (se 0.0108, p 0.0023).
            term       coef         se            p    n events
    hardware_sox 0.03675799 0.01021608 0.0004654222 5441    124
 hardware_nonsox 0.02271164 0.01493694 0.1310321233 5441    124

Contrast:
                  contrast        coef          se         p    n events
 hardware_nonsox_minus_sox -0.01404635 0.008923306 0.1155195 5441    124

Leave-one-hardware-ticker-out range: 0.0259 to 0.0369; significant at 5% in 20 of 20 exclusions.

Lowest five after exclusions:
 dropped_ticker       coef         se           p
           SNDK 0.02590486 0.01012578 0.011749497
             MU 0.03238112 0.01079574 0.003283464
           LRCX 0.03281786 0.01076261 0.002817982
           AVGO 0.03313891 0.01079806 0.002651059
           NVDA 0.03318575 0.01086792 0.002781135

Highest five after exclusions:
 dropped_ticker       coef         se            p
            STX 0.03459791 0.01078630 0.0017128424
           MPWR 0.03503579 0.01051377 0.0011425902
            WDC 0.03592044 0.01104906 0.0014901222
           INTC 0.03607652 0.01117645 0.0016042417
            ARM 0.03688828 0.01052844 0.0006438103

## Cloud pre-event volume leave-one-out

Leave-one-cloud-ticker-out range: 0.0208 to 0.1290; significant at 1% in 0 of 3 exclusions.
 dropped_ticker       coef         se          p
           GOOG 0.12899905 0.05022105 0.01145304
          GOOGL 0.06933382 0.05012735 0.16922035
           MSFT 0.02082007 0.06790945 0.75972640

## Event attribute moderators

                                    spec
            moderator_is_reasoning_model
               moderator_is_coding_model
               moderator_is_model_family
            moderator_is_reasoning_model
               moderator_is_model_family
 moderator_is_open_weight_or_open_source
 moderator_is_open_weight_or_open_source
     moderator_is_cross_modality_release
     moderator_is_media_generation_model
              moderator_is_chinese_model
     moderator_is_cross_modality_release
              moderator_is_chinese_model
               moderator_is_model_family
     moderator_is_cross_modality_release
            moderator_is_reasoning_model
     moderator_is_media_generation_model
                 moderator_is_multimodal
              moderator_is_chinese_model
 moderator_is_open_weight_or_open_source
                 moderator_is_multimodal
               moderator_is_coding_model
               moderator_is_coding_model
     moderator_is_media_generation_model
                 moderator_is_multimodal
                                                  term          coef
              rel_upstream_hardware:is_reasoning_model  0.0434163803
               rel_downstream_deployer:is_coding_model -0.0591621436
                 rel_upstream_hardware:is_model_family -0.0341537823
                     rel_competitor:is_reasoning_model  0.0213468561
                        rel_competitor:is_model_family -0.0227560358
          rel_competitor:is_open_weight_or_open_source  0.0187262556
 rel_downstream_deployer:is_open_weight_or_open_source  0.0195802633
       rel_upstream_hardware:is_cross_modality_release  0.0730095643
     rel_downstream_deployer:is_media_generation_model -0.0178209141
                       rel_competitor:is_chinese_model  0.0188168792
     rel_downstream_deployer:is_cross_modality_release  0.0140875705
                rel_upstream_hardware:is_chinese_model  0.0259132883
               rel_downstream_deployer:is_model_family  0.0175127421
              rel_competitor:is_cross_modality_release  0.0195783305
            rel_downstream_deployer:is_reasoning_model  0.0140367947
              rel_competitor:is_media_generation_model -0.0107501928
                   rel_upstream_hardware:is_multimodal  0.0143333149
              rel_downstream_deployer:is_chinese_model  0.0076915369
   rel_upstream_hardware:is_open_weight_or_open_source  0.0075215430
                          rel_competitor:is_multimodal  0.0048365692
                 rel_upstream_hardware:is_coding_model -0.0379300000
                        rel_competitor:is_coding_model -0.0152908661
       rel_upstream_hardware:is_media_generation_model -0.0026883626
                 rel_downstream_deployer:is_multimodal  0.0003641923
          se          p      q_bh    n events
 0.016732032 0.01123702 0.2696884 5441    124
 0.017224742 0.03735596 0.4158730 5441    124
 0.017497386 0.05698133 0.4158730 5441    124
 0.013010452 0.10477783 0.4158730 5441    124
 0.014449379 0.12217729 0.4158730 5441    124
 0.012256248 0.12982732 0.4158730 5441    124
 0.013040912 0.13646594 0.4158730 5441    124
 0.040355319 0.16168073 0.4158730 5441    124
 0.013742547 0.19856033 0.4158730 5441    124
 0.014971077 0.21634004 0.4158730 5441    124
 0.009527986 0.23010804 0.4158730 5441    124
 0.021402018 0.23345852 0.4158730 5441    124
 0.014608493 0.23666444 0.4158730 5441    124
 0.013707636 0.24408641 0.4158730 5441    124
 0.012371500 0.25992063 0.4158730 5441    124
 0.011201064 0.34007897 0.5101185 5441    124
 0.016549026 0.38834758 0.5482554 5441    124
 0.016066470 0.63491755 0.7866316 5441    124
 0.017823461 0.67395005 0.7866316 5441    124
 0.011556966 0.67644493 0.7866316 5441    124
 0.086367007 0.68830268 0.7866316 5441    124
 0.047100810 0.76551216 0.8351042 5441    124
 0.018921028 0.88738109 0.9259629 5441    124
 0.012553385 0.97690911 0.9769091 5441    124

## Cost, speed, and benchmark metrics

                             metric
                      livecodebench
                      livecodebench
    median_output_tokens_per_second
                               aime
                      aa_math_index
                               gpqa
                      aa_math_index
    median_output_tokens_per_second
                               aime
              aa_intelligence_index
                    aa_coding_index
                           mmlu_pro
                               gpqa
                      aa_math_index
                           mmlu_pro
            price_1m_blended_3_to_1
             price_1m_output_tokens
    median_output_tokens_per_second
 median_time_to_first_token_seconds
                               aime
              aa_intelligence_index
                      livecodebench
              aa_intelligence_index
            price_1m_blended_3_to_1
 median_time_to_first_token_seconds
             price_1m_output_tokens
             price_1m_output_tokens
 median_time_to_first_token_seconds
                               gpqa
            price_1m_blended_3_to_1
                           mmlu_pro
                    aa_coding_index
                    aa_coding_index
                                                         term          coef
                               rel_competitor:z_livecodebench  0.0198756418
                        rel_upstream_hardware:z_livecodebench  0.0275653665
      rel_upstream_hardware:z_median_output_tokens_per_second  0.0263525390
                                 rel_upstream_hardware:z_aime  0.0245459271
                               rel_competitor:z_aa_math_index  0.0223804067
                                 rel_upstream_hardware:z_gpqa  0.0236197946
                        rel_upstream_hardware:z_aa_math_index  0.0242475905
             rel_competitor:z_median_output_tokens_per_second  0.0125970221
                                        rel_competitor:z_aime  0.0153190724
                rel_upstream_hardware:z_aa_intelligence_index  0.0200133688
                             rel_competitor:z_aa_coding_index -0.0309767890
                             rel_upstream_hardware:z_mmlu_pro  0.0153074826
                                        rel_competitor:z_gpqa  0.0095385714
                      rel_downstream_deployer:z_aa_math_index -0.0104981543
                                    rel_competitor:z_mmlu_pro  0.0073215071
                     rel_competitor:z_price_1m_blended_3_to_1  0.0078872116
                      rel_competitor:z_price_1m_output_tokens  0.0072094889
    rel_downstream_deployer:z_median_output_tokens_per_second  0.0049460407
          rel_competitor:z_median_time_to_first_token_seconds -0.0073608769
                               rel_downstream_deployer:z_aime  0.0057848229
                       rel_competitor:z_aa_intelligence_index  0.0049973859
                      rel_downstream_deployer:z_livecodebench -0.0030784016
              rel_downstream_deployer:z_aa_intelligence_index -0.0024494391
              rel_upstream_hardware:z_price_1m_blended_3_to_1 -0.0021475675
   rel_upstream_hardware:z_median_time_to_first_token_seconds  0.0022293397
             rel_downstream_deployer:z_price_1m_output_tokens  0.0018278897
               rel_upstream_hardware:z_price_1m_output_tokens -0.0013920650
 rel_downstream_deployer:z_median_time_to_first_token_seconds -0.0010653196
                               rel_downstream_deployer:z_gpqa -0.0005787907
            rel_downstream_deployer:z_price_1m_blended_3_to_1 -0.0003558898
                           rel_downstream_deployer:z_mmlu_pro -0.0001454385
                    rel_downstream_deployer:z_aa_coding_index  0.0003622516
                      rel_upstream_hardware:z_aa_coding_index  0.0003049042
          se           p       q_bh    n events
 0.006327247 0.002930711 0.08071341 3222    124
 0.009308582 0.004891722 0.08071341 3222    124
 0.009219893 0.010120603 0.10425255 3842    124
 0.009268441 0.012636673 0.10425255 2459    124
 0.009428217 0.025153972 0.14909198 2127    124
 0.010292067 0.027107633 0.14909198 3580    124
 0.011961961 0.052545749 0.24054563 2127    124
 0.006541903 0.070537057 0.24054563 3842    124
 0.008219830 0.072271037 0.24054563 2459    124
 0.010844910 0.072892615 0.24054563 3842    124
 0.014318001 0.090411113 0.27123334  924    124
 0.009162780 0.121054840 0.33290081 3222    124
 0.007490461 0.209970004 0.52388477 3580    124
 0.008401669 0.222254145 0.52388477 2127    124
 0.006628371 0.289709477 0.63736085 3222    124
 0.007359530 0.316398748 0.65257242 3842    124
 0.007181511 0.343091479 0.66600111 3842    124
 0.006645345 0.465903784 0.83286584 3842    124
 0.009805845 0.479528816 0.83286584 3842    124
 0.008758522 0.514020650 0.84813407 2459    124
 0.008701794 0.569506062 0.89493810 3842    124
 0.006636749 0.644989732 0.96748460 3222    124
 0.006470567 0.707269220 0.98875653 3842    124
 0.007584940 0.784391177 0.98875653 3842    124
 0.010422811 0.837149425 0.98875653 3842    124
 0.009172298 0.846865235 0.98875653 3842    124
 0.007689216 0.860715780 0.98875653 3842    124
 0.006136937 0.867598575 0.98875653 3842    124
 0.006592503 0.930482006 0.98875653 3580    124
 0.011351575 0.975780150 0.98875653 3842    124
 0.005981016 0.981010535 0.98875653 3222    124
 0.014568109 0.981225164 0.98875653  924    124
 0.020579014 0.988756530 0.98875653  924    124

## Release-calendar crowding

                   spec                                   term         coef
 calendar_isolated_pm10    rel_upstream_hardware:isolated_pm10  0.028659772
 calendar_isolated_pm10           rel_competitor:isolated_pm10  0.023458213
 calendar_isolated_pm10  rel_downstream_deployer:isolated_pm10 -0.003349082
  calendar_density_pm10   rel_upstream_hardware:z_density_pm10 -0.005257152
  calendar_density_pm10          rel_competitor:z_density_pm10 -0.014157235
  calendar_density_pm10 rel_downstream_deployer:z_density_pm10  0.010980902
          se           p    n events
 0.019587565 0.167193639 5441    124
 0.017312029 0.200325224 5441    124
 0.025969773 0.899505272 5441    124
 0.006656818 0.432717471 5441    124
 0.005054945 0.006917566 5441    124
 0.005978236 0.071220531 5441    124

Event density within +/-10 calendar days:
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
  0.000   2.000   3.000   3.081   5.000   7.000 
Isolated events (+/-10 days): 12 of 124.
