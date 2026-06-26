# relonly_regression.R → v2 迁移说明与 OLD vs NEW 关系系数对比

## 1. 脚本性质与迁移范围

`relonly_regression.R` 的核心目的是关系变量回归：剔除无关系标签行后，PART R1
做主回归基准对比（不涉及具体关系维度），**PART R2 是真正的关系子样本回归**——
对每个旧关系维度取子样本（该维度=1的行），再跑 `aa_intelligence_index → CAR`
回归，比较不同关系角色公司的市场反应是否不同。这是本脚本里唯一直接消费旧
8 维关系编码的部分。

旧维度使用方式：全部是 **子样本筛选**（不是交互项、不是连续控制变量）：
`competitor`、`downstream`（=business_downstream|real_downstream）、
`biz_down`（business_downstream）、`real_down`（real_downstream）、
`upstream`（=business_upstream|real_upstream）、
`owner_invest`（=owner|investor）。

## 2. 关键迁移决策（语义重导，非字符串替换）

数据源也变更：v1 的 `outputs/specr_621_clean.csv` 里的旧关系列是
`prep_621.py` 从一个独立的 `relationship` 字符串列派生的；v2 改为直接从新
schema 权威源 `data/panel/specr_rel_clean.csv` 按 `(final_event_id,
company_id)` merge 进新的 8 列，5160 行全部匹配，不再用旧派生逻辑。

| 旧变量 | 新映射 | 理由 |
|---|---|---|
| `competitor` | `competitor`（同名） | 新版定义略宽，旧 1 全部保留为新 1，直接替换 |
| `owner` \| `investor` (并集) | `is_owner` \| `is_investor`（并集） | 角色定义近 1:1，直接替换，新版 investor 略宽 |
| `upstream` (= biz_up\|real_up) | `upstream_any` = `upstream_hardware` \| `upstream_cloud` | 经验交叉表显示旧 upstream=1 的 128 行中 100% 落入新 `upstream_hardware`，新增了 `upstream_cloud`（不重叠的 235 行，云厂商此前未被旧 upstream 捕捉） |
| `downstream` (= biz_down\|real_down) | `downstream_any` = `integrator`\|`deployer`\|`enabler` | 同理，三个新维度的并集对应旧 downstream 角色 |
| `biz_down` / `real_down` | **不再保留**，改为三个独立维度：`downstream_integrator`、`downstream_deployer`、`downstream_enabler` | 这是任务里说明的"genuinely new"情形：旧 schema 的 business/real（经济活动属性轴）与新 schema 的 integrator/deployer/enabler（AI 角色轴）是**不同的分类维度**。经验交叉表显示 real_downstream=1 的行里 deployer 重叠为 0、business_downstream=1 的行里也只有 10% 落入 deployer——二者没有清晰的一一对应，强行映射会引入语义噪音。因此放弃 biz_down/real_down 子样本，替换为三个新维度各自的独立子样本，这才是新 schema 下真正可解释、可复现的关系角色划分 |
| （新增）`upstream_hardware`、`upstream_cloud` 单独子样本 | — | 新 schema 把旧 upstream 拆细，单独看更有信息量（如 NVIDIA 类硬件 vs AWS/Azure 类云） |

输出路径：所有 `outputs/r_0X_*.csv` 均加 `_v2` 后缀，v1 结果未被覆盖。脚本
增加了基于脚本自身路径的自动定位逻辑，可从仓库根目录或脚本所在目录调用。

## 3. 运行结果

`Rscript relonly_regression_v2.R` 运行成功，exit code 0，无报错无警告。
样本量与 v1 完全一致：全样本 5160 行 → 有关系标签 3143 行（61%）→
有 AA 指数 2418 行。PART R1（主回归基准，不涉及关系维度）系数与 v1 逐位
相同，符合预期（该部分未使用任何关系列，只是样本筛选）。

## 4. OLD vs NEW 关系子样本系数对比（car_5, base+VIX+news spec 为主，节选关键窗口）

| 维度 | 旧/新 | n (events) | car_1 coef (p) | car_5 coef (p) | car_20 coef (p) |
|---|---|---|---|---|---|
| competitor | OLD `competitor` | 454 (47) | 0.00016 (0.138) | 0.00039 (0.116) | 0.00057 (0.249) |
| competitor | NEW `competitor` | 401 (47) | 0.00014 (0.266) | 0.00025 (0.368) | 0.00059 (0.188) |
| upstream（合并） | OLD `upstream` | 100 (47) | 0.00023 (0.587) | **0.00138** (**0.021**\*\*) | **0.00224** (**0.052**\*) |
| upstream（合并） | NEW `upstream_any` | 404 (47) | 0.00015 (0.557) | **0.00084** (**0.0036**\*\*\*) | 0.00092 (0.129) |
| — | NEW `upstream_hardware` | 169 (47) | 0.00035 (0.422) | **0.00133** (**0.0085**\*\*\*) | 0.00166 (0.131) |
| — | NEW `upstream_cloud` | 235 (47) | -0.00002 (0.909) | 0.00040 (0.232) | 0.00036 (0.439) |
| downstream（合并） | OLD `downstream` | 1849 (47) | 0.00012 (0.470) | -0.00020 (0.607) | 0.00126 (0.126) |
| downstream（合并） | NEW `downstream_any` | 1912 (47) | 0.00013 (0.443) | -0.00019 (0.615) | 0.00127 (0.117) |
| — | NEW `downstream_integrator` | 1356 (47) | 0.00011 (0.607) | -0.00027 (0.548) | 0.00162 (0.110) |
| — | NEW `downstream_deployer` | 184 (47) | 0.00009 (0.724) | 0.00030 (0.434) | -0.00059 (0.488) |
| — | NEW `downstream_enabler` | 372 (47) | 0.00017 (0.295) | -0.00022 (0.507) | 0.00065 (0.394) |
| biz_down (旧，无新对应) | OLD `biz_down` | 1819 (47) | 0.00013 (0.445) | -0.00014 (0.715) | 0.00133 (0.102) |
| real_down (旧，无新对应) | OLD `real_down` | 1052 (47) | 0.00015 (0.397) | -0.00023 (0.584) | **0.00174** (**0.073**\*) |
| owner_invest | OLD `owner` \| `investor` | NA (NA) | N/A — 模型未收敛/聚类不足 | N/A | N/A |
| owner_invest | NEW `is_owner` \| `is_investor` | 59 (43) | 0.00004 (0.930) | -0.00010 (0.882) | 0.00127 (0.340) |

注：以上为 `base+VIX+news` spec 下 `aa_intelligence_index` 系数；完整 8 个新维度 × 3 个窗口 × 2 个 spec 详见
`outputs/r_02_relationship_subsamples_v2.csv`，旧版对照见 `outputs/r_02_relationship_subsamples.csv`。

## 5. 逐维度发现（8 个新维度 vs 旧对应项）

1. **competitor（同名维度）**：方向不变（始终正），三个窗口下系数从 OLD 略微下移到 NEW（car_5: 0.00039→0.00025；car_20: 0.00057→0.00059，基本持平），显著性始终未达 10% 门槛，结论稳定——竞争对手公司对 AI 智能指数变化的市场反应在新旧编码下都不显著，方向一致。样本量从 454 降到 401（新版 competitor 定义虽然"略宽"，但具体到这批已有 AA 指数的有关系行上，net 反而略减，说明部分旧 competitor=1 行在新 schema 下未保留该标签，同时有新纳入的行）。

2. **upstream_hardware（对应旧 upstream 的绝大部分）**：car_5 在 OLD `upstream`（0.00138, p=0.021\*\*）与 NEW `upstream_hardware`（0.00133, p=0.0085\*\*\*）高度一致，系数几乎不变，**显著性从 5% 提升到 1% 门槛**（n 从100增至169，统计效力提升）。这是符合预期的：经验交叉表显示旧 upstream=1 的行 100% 落在新 upstream_hardware 里，二者本质是同一关系的更精细测量。car_20 从边缘显著（p=0.052\*）变为不显著（p=0.131），系数方向不变但 SE 增大，可能因新版把部分弱信号行剔出该子样本所致。

3. **upstream_cloud（新拆分出的维度，无旧对照）**：系数全程很小且不显著（car_5: 0.00040, p=0.232；car_20: 0.00036, p=0.439），方向为正但弱。这是真正的新发现——云厂商（AWS/Azure/GCP/Alibaba Cloud/Oracle）作为 upstream 角色，其股价对 AI 能力指数变化的敏感度明显弱于硬件供应商（NVIDIA 等），说明旧版"upstream"合并掩盖了硬件与云两个子渠道效应强度的差异：硬件渠道驱动了几乎全部旧 upstream 的显著性。

4. **downstream 三分裂（integrator / deployer / enabler，无旧 1:1 对照）**：合并后的 `downstream_any`（0.00013/-0.00019/0.00127，三窗口均不显著）与旧 `downstream`（0.00012/-0.00020/0.00126）几乎完全一致，因为新三维度的并集样本与旧并集样本高度重叠（1912 vs 1849 行）。拆开看：`downstream_integrator`（n=1356，AI 核心产品公司，如 Palantir/Salesforce）car_20 系数最大（0.00162）但仍不显著（p=0.110）；`downstream_deployer`（n=184，如 Tesla/Uber，AI 是工具而非核心）car_20 系数为**负**（-0.00059, p=0.488）——方向与其他两类相反，提示"AI 仅作为工具"的公司可能对 AI 能力提升的边际反应较弱甚至轻微负向；`downstream_enabler`（n=372，IT咨询/外包，如 Accenture/IBM consulting）系数与 integrator 同向但更弱（0.00065 vs 0.00162）。旧的 biz_down/real_down 拆分中，real_down 子样本（n=1052）在 car_20 曾达到边缘显著（0.00174, p=0.073\*），但这一显著性在新分类下没有直接对应项保留——这恰好印证了 biz/real 轴与 integrator/deployer/enabler 轴是不同维度，旧的 real_down 显著性更可能来自"real economy downstream"这一特定属性组合，而非单纯的 AI 角色分类，新 schema 下没有再现。

5. **owner_invest（is_owner ∪ is_investor）**：这是本次迁移中最实质的改进——旧版 `owner|investor` 子样本因聚类数不足（可能 < 3 个事件或 n < 20）导致模型完全无法估计（全部 NA）；新版因 `is_investor` 定义略宽、且合并逻辑更稳健，子样本扩大到 n=59（43 个事件），三个窗口均可估计，尽管全部不显著（p 在 0.34–0.93 之间），但至少恢复了该维度的可分析性，为后续稳健性检验提供了基础。

## 6. 结论要点

- 主回归（PART R1，不涉及具体关系维度）完全不受 schema 切换影响，系数逐位相同，确认迁移未引入数据泄漏或样本变化。
- `upstream` 渠道的显著性主要由 `upstream_hardware` 驱动，`upstream_cloud` 信号很弱——新 schema 的拆分揭示了旧版合并指标掩盖的异质性。
- `downstream` 内部的 integrator/deployer/enabler 三分也显示出方向性差异（deployer 为负，integrator/enabler 为正），但样本量较小、均未达统计显著，需要更大样本或更长窗口验证。
- `competitor` 和合并后的 `upstream_any`/`downstream_any` 在新旧编码下保持方向与显著性模式的总体稳定，说明新 schema 是旧 schema 的合理细化而非颠覆性改变。
- `owner_invest` 子样本从无法估计变为可估计，是新 schema 在样本量上的直接增益。
