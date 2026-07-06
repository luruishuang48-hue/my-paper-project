# Coder A 与 Coder B 差异审计

审计对象为 `data/relationships/coder_a_output.csv` 和 `data/relationships/company_creator_relationships_coder_b.csv`。二者都是公司－发布方层面的 1,204 行矩阵。

## 总览

- 两份文件键完全一致，均无重复 `company_id, creator`。
- 8 个二进制字段共有 9632 个可比单元格。
- 二进制差异为 31 个，整体一致率为 99.6782%。
- 有任一二进制差异的公司－发布方行为 31 行，占 1,204 行的 2.57%。
- 扩展到 60 个事件后，受影响事件－公司行为 148 行，占 5,160 行的 2.87%。
- 置信度单独不同但二进制完全一致的行为 42 行，按事件权重展开为 181 行。
- 保守 H/M 口径下，二进制差异降至 3 个，公司－发布方行为 3 行，事件－公司行为 28 行。

## κ 统计

| dimension             |   n_pairs |   coder_a_ones |   coder_b_ones |   agreements |   disagreements |   a1_b0 |   a0_b1 |   agreement_rate |   cohen_kappa |
|:----------------------|----------:|---------------:|---------------:|-------------:|----------------:|--------:|--------:|-----------------:|--------------:|
| upstream_hardware     |      1204 |            280 |            280 |         1204 |               0 |       0 |       0 |         1        |      1        |
| upstream_cloud        |      1204 |             68 |             70 |         1202 |               2 |       0 |       2 |         0.998339 |      0.984626 |
| downstream_integrator |      1204 |            418 |            433 |         1189 |              15 |       0 |      15 |         0.987542 |      0.972744 |
| downstream_deployer   |      1204 |            266 |            280 |         1190 |              14 |       0 |      14 |         0.988372 |      0.966847 |
| downstream_enabler    |      1204 |            112 |            112 |         1204 |               0 |       0 |       0 |         1        |      1        |
| competitor            |      1204 |            122 |            122 |         1204 |               0 |       0 |       0 |         1        |      1        |
| is_investor           |      1204 |              5 |              5 |         1204 |               0 |       0 |       0 |         1        |      1        |
| is_owner              |      1204 |              4 |              4 |         1204 |               0 |       0 |       0 |         1        |      1        |

## 保守 H/M 口径

先把 `confidence=L` 的正关系重置为 0 后，κ 统计如下。

| dimension             |   n_pairs |   coder_a_ones_hm |   coder_b_ones_hm |   agreements_hm |   disagreements_hm |   a1_b0_hm |   a0_b1_hm |   agreement_rate_hm |   cohen_kappa_hm |
|:----------------------|----------:|------------------:|------------------:|----------------:|-------------------:|-----------:|-----------:|--------------------:|-----------------:|
| upstream_hardware     |      1204 |               196 |               196 |            1204 |                  0 |          0 |          0 |            1        |         1        |
| upstream_cloud        |      1204 |                68 |                70 |            1202 |                  2 |          0 |          2 |            0.998339 |         0.984626 |
| downstream_integrator |      1204 |               418 |               419 |            1203 |                  1 |          0 |          1 |            0.999169 |         0.998169 |
| downstream_deployer   |      1204 |               210 |               210 |            1204 |                  0 |          0 |          0 |            1        |         1        |
| downstream_enabler    |      1204 |               112 |               112 |            1204 |                  0 |          0 |          0 |            1        |         1        |
| competitor            |      1204 |               122 |               122 |            1204 |                  0 |          0 |          0 |            1        |         1        |
| is_investor           |      1204 |                 5 |                 5 |            1204 |                  0 |          0 |          0 |            1        |         1        |
| is_owner              |      1204 |                 4 |                 4 |            1204 |                  0 |          0 |          0 |            1        |         1        |

## 二进制差异分布

按关系字段统计。

| dimension             |   disagreements |
|:----------------------|----------------:|
| upstream_hardware     |               0 |
| upstream_cloud        |               2 |
| downstream_integrator |              15 |
| downstream_deployer   |              14 |
| downstream_enabler    |               0 |
| competitor            |               0 |
| is_investor           |               0 |
| is_owner              |               0 |

按公司统计。

| company_id   |   disagreements |
|:-------------|----------------:|
| QUBT         |              14 |
| WRD          |              14 |
| AMZN         |               1 |
| GOOGL        |               1 |
| MSFT         |               1 |

按发布方统计。

| creator             |   disagreements |
|:--------------------|----------------:|
| Alibaba             |               3 |
| Google              |               3 |
| Mistral AI          |               3 |
| Anthropic           |               2 |
| DeepSeek            |               2 |
| Kuaishou            |               2 |
| Meta                |               2 |
| Microsoft           |               2 |
| OpenAI              |               2 |
| Runway              |               2 |
| ShengShu Technology |               2 |
| Stability AI        |               2 |
| Zhipu AI            |               2 |
| xAI                 |               2 |

## 主要分歧

1. `upstream_cloud` 有 2 个差异。AMZN－Alibaba 是 R2 宽窄口径分歧。GOOGL－Google 是自有发布方事件是否仍标 cloud 的口径分歧。
2. `downstream_integrator` 有 15 个差异。其中 QUBT 对全部 14 个 creator 为低置信度边界。MSFT－Mistral AI 是 Microsoft R3 是否对所有非自有 creator 一致适用。
3. `downstream_deployer` 有 14 个差异，全部来自 WRD 对 14 个 creator 的低置信度 R4 边界。
4. 其他 5 个字段完全一致，包括 hardware、enabler、competitor、investor 和 owner。

## 数据质量问题

Coder A 有 28 行全 0 关系却保留 `confidence=L` 和 justification，均来自 QUBT 与 WRD。按 prompt 的输出规范，全 0 行应把这两个字段留空。若后续只看二进制关系，这不影响 κ。若要比较 confidence，需要先统一这个格式。

## 建议裁决

- 先固定 R2 cloud 口径。若采用宽口径，AMZN－Alibaba 应取 B。若采用实际托管口径，取 A。
- 对 self-cloud 单独定规。若 owner 事件不再标 R2，GOOGL－Google 应取 A，并同步检查 BABA－Alibaba、MSFT－Microsoft。
- QUBT 和 WRD 的差异是 L 级边界。保守 H/M 版本可直接归 0，inclusive 版本可保留 B。
- MSFT－Mistral AI 建议取 B，前提是 Microsoft Copilot 的 R3 暴露按所有非自有 creator 稳定处理。
- confidence 字段建议按 codebook 的最低置信度规则重算。AMZN、IBM、CRM 的 B 口径更符合“最低置信度”。
