# R 回归实现复核与稳健性脚本注意事项

复核时间 20260613-210131，北京时间。

本次只复核代码和输出表，没有修改项目主脚本、数据和结果文件。重点文件包括 `scripts/analysis/core_table.R`、`scripts/analysis/main_regression.R`、`scripts/analysis/main_regression_rel.R`、`scripts/prep/specr_rel_prep.py` 和 `output/tables/core_table_results.csv`。

## 总体判断

当前核心回归思路基本合理。`aa_intelligence_index` 是事件层变量，CAR 是公司 × 事件层结果，因此按 `final_event_id` 聚类是必要的。`core_table.R` 已经把 CR0、CR2 和 wild cluster bootstrap 并列报告，这比早期只报告 CR0 更稳。

最大的计量风险不在估计器本身，而在有效识别单位。结果表显示主规格有 3780 个 firm-event 观测，但真正提供能力指数变化的是 47 个事件。闭源样本只有 36 个事件，开源事件约 11 个。后续稳健性脚本要把“事件层识别”作为主线，避免让审稿人觉得面板观测数夸大了统计精度。

## 现有 CR0、CR2 和 wild bootstrap

### CR0

CR0 按 `final_event_id` 聚类是正确方向。因为同一模型发布日下的公司收益共同受同一事件冲击影响，普通异方差稳健标准误会明显过度乐观。

但 CR0 不应作为最终主推断。当前事件数 47，闭源样本 36，部分异质性样本更少。CR0 在小聚类数下容易过拒绝。建议主文表可以保留 CR0，但把 CR2 或 wild p-value 作为更可信的判断依据。

对应代码位置包括 `main_regression.R` 第 39 至 42 行，`main_regression_rel.R` 第 46 至 48 行，`core_table.R` 第 147 至 151 行。

### CR2

CR2 合理，而且很适合当前小聚类数环境。`core_table.R` 第 62 至 66 行用 `lm_robust(..., se_type = "CR2")` 重新估计 p 值，这是正确做法。结果表也显示全样本主效应从 CR0 的 0.0271 变为 CR2 的 0.0541，说明小样本修正对结论有实质影响。

建议新增脚本把 CR2 的自由度也输出。只给 p 值不够透明，最好同时保存 estimate、SE、df、p。若某些交互或子样本的 CR2 自由度很低，应在附录中说明。

### wild cluster bootstrap

wild cluster bootstrap 作为小聚类稳健推断是合理的。`core_table.R` 第 70 至 110 行采用 Rademacher 权重，按事件簇重抽残差，并对目标系数施加零假设。对 36 至 47 个事件的主规格，这个设计可用。

需要注意几个实现问题。

第一，当前 p 值写法是 `mean(abs(t_star) >= abs(t_obs))`。更稳妥的是有限样本写法 `(1 + sum(abs(t_star) >= abs(t_obs))) / (B + 1)`，避免极端情况下出现 0。

第二，当前所有规格使用同一个 seed 42。复现没有问题，但建议每个规格用稳定但不同的 seed，例如由模型标签生成。这样可以避免多个 p 值之间出现完全相同的随机序列。

第三，受限模型和完整模型必须使用完全相同的样本。当前 `wild_boot_p()` 只先删了缺失因变量，后面由 `lm()` 和 `lm_robust()` 自动删 RHS 缺失。现有核心变量大体完整，所以问题不大。新增控制变量、firm FE 或事件层聚合后，应先显式 `drop_na(all model variables)`，再送入完整模型和受限模型。

第四，交互模型中的“主斜率”wild 检验有一个需要修正的地方。以 open-weight 交互为例，完整模型是 `intel_c + is_open_weight + intel_c:is_open_weight`。如果检验 `intel_c`，当前受限模型在 `core_table.R` 第 194 至 195 行只保留 `is_open_weight`，这相当于同时删掉了 `intel_c` 和交互项。更严格地说，这不是单独检验闭源斜率为零。若要只检验 `intel_c = 0`，受限模型应保留 `is_open_weight` 和 `intel_c:is_open_weight`。investor、cloud 主斜率的 wild 检验也有同样问题。交互项本身的受限模型写法是合理的。

第五，open-weight 子样本只有约 11 个事件，Rademacher wild bootstrap 仍可能不稳定。若后续单独跑开源样本，建议只作为描述性稳健性，不要做强结论。

## 新增 firm FE 的实现

firm FE 是很有价值的稳健性。它吸收公司长期 AI 暴露、规模层级、商业模式、估值风格和交易市场差异。不能加入 event FE，因为 `aa_intelligence_index` 是事件层变量，会被 event FE 完全吸收。

推荐设定如下。

```r
fixest::feols(
  car_20 ~ intel_c + size_log_assets + bm_ratio + volatility + momentum + i(release_year) | company_id,
  data = df_base,
  vcov = ~ final_event_id
)
```

如果继续用 `estimatr`，也可以把 `factor(company_id)` 放进 RHS，但 `fixest::feols()` 更适合 FE 和多维聚类。

容易出错的地方有三点。

第一，firm FE 下不要再把样本解释成 3780 个独立观测。推断仍主要依赖事件数。

第二，加入 firm FE 后，部分公司层变量如果几乎不随事件变化，解释力会被 FE 吸收。保留这些控制变量可以，但要检查是否被自动删除。

第三，若做 open-weight 交互，`intel_c` 的中心化应固定使用全样本均值，不要在每个子样本或每次 leave-one-out 中重新中心化，否则主效应含义会变。

## 新增 event-level aggregation 的实现

这是最值得补的稳健性。目的不是替代 firm-event 面板，而是证明结论不是靠公司层重复观测堆出来的。

建议构造一行一个事件的数据。

```r
event_df <- df_base |>
  dplyr::filter(!is.na(car_20), !is.na(aa_intelligence_index)) |>
  dplyr::group_by(final_event_id) |>
  dplyr::summarise(
    car20_mean = mean(car_20, na.rm = TRUE),
    car20_median = median(car_20, na.rm = TRUE),
    n_firms = dplyr::n(),
    aa_intelligence_index = dplyr::first(aa_intelligence_index),
    is_open_weight = dplyr::first(is_open_weight),
    release_year = dplyr::first(release_year),
    true_model_creator = dplyr::first(true_model_creator),
    .groups = "drop"
  )
```

主规格可以是 `car20_mean ~ aa_intelligence_index + factor(release_year)`，闭源样本单独跑。由于只有 47 个事件，不宜放太多控制变量。HC2 或 HC3 比普通 OLS 标准误更合适。

更强的版本是固定公司集合后再聚合。当前 `output/data/specr_rel_clean.csv` 中总样本有 61 个事件、87 家公司，但主回归完整样本的每个事件只有 76 至 83 家公司。若直接求事件均值，事件之间的公司构成变化会进入被解释变量。可以先取在所有 47 个核心事件中都可用的公司，再算事件均值。另一种做法是同时报告 equal-weighted mean、median 和关系暴露组均值。

不要在事件层回归里机械加入 firm-level 平均控制变量。平均规模、平均 BM、平均波动率更多是样本构成控制，不是清晰的事件控制。可以作为附录规格，但主文应保持简洁。

## 新增 pre-event CAR 的实现

`specr_rel_prep.py` 第 31 行已经把“市场模型异常收益[-10,-2]”映射为 `car_pre`。这是很好的提前定价或安慰剂检验。

建议用同一核心公式，把因变量替换为 `car_pre`。

```r
car_pre ~ intel_c + size_log_assets + bm_ratio + volatility + momentum + factor(release_year)
```

需要注意两点。

第一，`specr_rel_prep.py` 的数值化列表第 63 至 74 行没有包含 `car_pre`，`core_table.R` 第 17 至 22 行也没有包含 `car_pre`。虽然 R 读 CSV 时可能自动识别为数值，但稳健性脚本应显式 `as.numeric(car_pre)`。

第二，`momentum` 如果和 `car_pre` 的计算窗口重叠，pre-event 检验会被机械相关污染。建议报告两列，一列保留 momentum，一列去掉 momentum。若 `car_pre` 对 intelligence 显著，主文应谨慎解释 CAR[0,+20]，因为这可能是提前预期、信息泄露或事件前趋势。

## 新增 leave-one-creator-out 的实现

这个检验很关键，因为事件高度集中。核心完整样本中 Google 约 13 个事件，OpenAI 约 12 个事件，Anthropic 约 8 个事件，Alibaba 约 5 个事件。逐一剔除主要 creator 后再跑核心规格，可以判断闭源结论是否只是某一发布者驱动。

建议按事件发布者剔除，而不是按行剔除。

```r
creators <- c("Google", "OpenAI", "Anthropic", "Alibaba")
loo <- purrr::map_dfr(creators, function(cr) {
  d <- df_base |> dplyr::filter(true_model_creator != cr)
  fit <- lm_robust(fml, data = d, clusters = d$final_event_id, se_type = "CR2")
  # 保存 beta、se、p、事件数、公司数
})
```

容易出错的地方有四点。

第一，不要在每次剔除后重新计算 `intel_c`，否则系数可比性变差。用全样本均值中心化。

第二，剔除 Google 或 OpenAI 后，年份分布和能力指数分布都会变化。输出中应同时保存剩余事件数、剩余 creator 数、`aa_intelligence_index` 均值和范围。

第三，CR2 或 wild bootstrap 可能在某些剔除样本中变得不稳定。脚本要捕获错误并记录失败原因，而不是静默输出 NA。

第四，若同一天有两个同一 creator 事件，例如 2024/9/12、2024/10/3、2024/12/17、2025/4/16、2025/6/17，leave-one-creator-out 比 leave-one-event-out 更有意义。单独剔除一个事件会留下同日近似重复冲击。

## 新增 two-way clustering 的实现

two-way clustering 可以作为附录稳健性。一个自然选择是按事件和公司双向聚类。

```r
fixest::feols(
  car_20 ~ intel_c + size_log_assets + bm_ratio + volatility + momentum + i(release_year),
  data = df_base,
  vcov = ~ final_event_id + company_id
)
```

如果同时加 firm FE，可以写成。

```r
fixest::feols(
  car_20 ~ intel_c + size_log_assets + bm_ratio + volatility + momentum + i(release_year) | company_id,
  data = df_base,
  vcov = ~ final_event_id + company_id
)
```

需要谨慎解读。`aa_intelligence_index` 在事件层变化，事件聚类仍是最关键维度。公司聚类只能处理同一公司跨事件的残差相关，不能替代事件聚类。

另一个更贴近数据的问题是同日多事件。当前核心样本 47 个事件中有 43 个唯一发布日期，5 个日期各有两个事件。按 `final_event_id` 聚类不会把同一天的两个事件合并为同一冲击。建议额外报告按 `release_date` 聚类，或用 `creator_date = paste(true_model_creator, release_date)` 聚类。若按发布日期聚类后结果明显变弱，说明同日重复事件对显著性贡献较大。

two-way clustering 常见坑包括非正定协方差、少数簇导致 p 值跳动、以及 `estimatr::lm_robust()` 不适合直接做多维聚类。建议用 `fixest`，并保存 warning。

## 其他实现风险

第一，输入路径不稳。几个脚本用 `read.csv("specr_rel_clean.csv")` 或 `read.csv("specr_input_clean.csv")`，但当前工作目录根部没有这两个文件，实际数据在 `output/data/`。如果脚本必须从特定目录运行，应在脚本开头固定路径，或把数据路径作为参数传入。否则很容易复现出错。

第二，变量名存在双轨。`main_regression.R` 使用 `is_open_weight_or_open_source`，关系版脚本使用 `is_open_weight`。新增稳健性脚本应统一使用关系数据的 `is_open_weight`，并在输出中记录数据来源。

第三，样本计数和实际估计样本可能不一致。`main_regression.R` 第 26 至 32 行和 `main_regression_rel.R` 第 28 至 38 行在估计前打印样本数，但 `lm_robust()` 会因为控制变量或因变量缺失再删行。建议新增脚本先显式生成 `model_df`，然后所有样本数都从 `model_df` 来。

第四，`core_table.R` 第 17 至 22 行没有把 `car_2` 放入数值化列表，但第 264 行使用了 `car_2`。R 读入时可能已经是数值，所以当前结果未必错，但新增脚本应把所有使用到的 CAR 窗口统一数值化。

第五，`specr_rel_prep.py` 第 79 行输出到当前目录，而不是 `output/data/`。这和现有结果目录不一致。稳健性脚本若要复现，应明确读取 `output/data/specr_rel_clean.csv`，并把新表写入任务目录或 `output/tables`，不要混写。

第六，多重检验风险仍然存在。`core_table.R` 已经收窄为 10 个核心行，但 owner、investor、cloud、open-weight、不同窗口和不同子样本仍较多。新增稳健性脚本应把四个优先检验固定为 firm FE、事件层聚合、pre-event CAR、leave-one-creator-out，不要继续扩散到大量异质性。

## 建议的稳健性脚本顺序

第一步，建立唯一的 `model_df`。读取 `output/data/specr_rel_clean.csv`，数值化所有回归变量，过滤 `aa_intelligence_index`、控制变量、`car_20`、`final_event_id`、`company_id` 非缺失，生成 `intel_c`。保存样本诊断表，包含观测数、事件数、公司数、creator 分布、open/closed 分布、同日多事件数量。

第二步，复现核心表。先跑当前公式，输出 CR0、CR2、wild p。这个步骤用于确认新脚本和 `output/tables/core_table_results.csv` 一致。

第三步，跑 firm FE。主列用事件聚类 CR2，附列用 event × firm two-way clustering。

第四步，跑 event-level aggregation。至少报告 equal-weighted mean CAR 和固定公司集合 mean CAR 两种。

第五步，跑 pre-event CAR。报告含 momentum 和不含 momentum 两列。

第六步，跑 leave-one-creator-out。至少剔除 Google、OpenAI、Anthropic、Alibaba。输出每次剩余事件数和系数区间。

第七步，跑同日和窗口重叠诊断。按发布日期聚类，或把同日同 creator 多事件合并为一个事件后重跑。

## 最终建议

现有 CR0、CR2、wild bootstrap 的方向是对的。主文最应依赖 CR2 和 wild，而不是 CR0。新增稳健性最应优先做事件层聚合、firm FE、pre-event CAR 和 leave-one-creator-out。two-way clustering 可以补，但它不是核心识别修复。最容易出错的地方是相对路径、有效样本口径、交互模型 wild bootstrap 的受限模型、同日多事件聚类，以及在 leave-one-out 中重新中心化 intelligence。
