# REVIEW-CONTENT: Audit of `PAPER_B_WRITING_PLAN.md`

Reviewer: independent REVIEW-CONTENT agent. Did not author the document under review.

---

## 1. Numerical accuracy (8+ spot checks)

| # | Claim in PAPER_B_WRITING_PLAN.md | Source | Match? |
|---|---|---|---|
| 1 | R1 car_20: β_hardware=0.0237 (se=0.0086), β_cloud=0.0161 (se=0.0069), diff=0.0076, se_diff=0.0073, z=1.040, p=0.2984 (line 113) | `r1_hardware_vs_cloud_diff.md` row car_20 | Exact match |
| 2 | R1 car_10/car_15 diff p=0.58/0.776 (line 113) | r1 table: car_10 p=0.5800, car_15 p=0.7757 | Exact match (rounded) |
| 3 | R2 table car_1…car_20 beta/p_CR0/p_CR2/p_wild (lines 129-133) | `r2_downstream_deployer_robustness.md` results table | Exact match, all 5 rows checked |
| 4 | R3 DeepSeek exclusion: upstream_hardware 0.0228→0.0228 (0.2%), downstream_deployer −0.0190→−0.0186 (2.2%) (line 143) | `r3_sensitivity_summary.md` Check 1 | Exact match |
| 5 | R3 leave-one-event-out ranges [0.0203,0.0249] sd=0.00111 / [-0.0204,-0.0174] sd=0.00067, FMR-0056/FMR-0016 (line 144) | `r3_sensitivity_summary.md` Check 2 | Exact match |
| 6 | R3 leave-one-firm-out ranges, SMCI / 5803 JP (line 145) | `r3_sensitivity_summary.md` Check 3 | Exact match |
| 7 | R4 table: upstream_hardware MM 2.276/0.0090 vs FF3 0.145/0.8794; downstream_deployer MM −1.902/0.0004 vs FF3 −0.763/0.1334 (lines 157-158) | `r4_ff3_comparison.md` "Focused check" section | Exact match |
| 8 | R4 "27 matched rows, 6 sign flips" (line 162) | `r4_ff3_comparison.md` Overall summary: "27 matched variable x window rows... 6 row(s) show a sign flip" | Exact match |
| 9 | R5 joint-model table: upstream_hardware β=−0.0083, p_wild=0.64; downstream_deployer β=−0.0424, p_wild=0 (line 176) | `r5_wild_bootstrap_summary.md` §3 | Exact match |
| 10 | R5 open/closed interaction: hardware×open β=−0.0366, p_wild=0.04; deployer×open β=+0.0106, p_wild=0.30 (line 177) | `r5_wild_bootstrap_summary.md` §4 | Exact match |
| 11 | Table 1 numbers (upstream_hardware 2.28pp p=0.009 at car_20, downstream_deployer −1.90pp p=0.0004) (line 47, §3 intro) | `Tex/long.tex` line 67 (`2.28***`), line 90 (p=0.009), line 73 (`-1.90***`), line 90 (p=0.0004) | Exact match |
| 12 | Joint regression upstream_hardware −0.83 (line 179, "翻转为 −0.0083") | `Tex/long.tex` line 157 (`-0.83`) and R5 table (−0.0083) | Exact match (units consistent: pp vs decimal) |
| 13 | κ pooled = 0.986, all 8 dims > 0.96 (line 85) | `RELATIONSHIP_CODING_WORKFLOW_REPORT.md` line 104 pooled row, lines 96-103 per-dimension (min 0.967) | Exact match |
| 14 | Appendix line citations for Table 1-5 numbers ("第 67、73、121、125、157、163、199、201 行", line 241) | Verified directly: line 67=`2.28***`, 73=`-1.90***`, 121=`2.22***`, 125=`-1.90***` (Table 2/3 bundle/deployer rows), 157=`-0.83` (joint), 163=`-4.24***` (joint deployer), 199=`-3.66**` (interaction), 201=`1.06` (deployer interaction) | All 8 line citations verified correct |

**Verdict: PASS.** All 14 spot-checked numbers (exceeding the required minimum of 8) match their source files exactly, including decimal precision. No fabricated, rounded-beyond-source, or transposed figures found. The document's own "附录：数字核对来源" section is itself accurate — every line number cited there was independently verified against `Tex/long.tex`.

One very minor observation (not a numerical error in the writing plan, but worth flagging): R5's own source file (`r5_wild_bootstrap_summary.md`, lines 16/19) states "61 events" while R1/R2/R3 and `Tex/long.tex` consistently state 60 events / n=4,829. The writing plan correctly uses "60 事件" throughout (e.g., line 113) and does **not** propagate R5's "61" inconsistency. This is a latent data-correctness issue in R5's own output, out of scope for this content review (belongs to REVIEW-DATA), but noted here for completeness since it touches "numerical accuracy."

---

## 2. Critical-nuance preservation

**(a) R1 null result on hardware-vs-cloud difference (p≈0.298):**
Lines 109-119, §3 R1 section, explicitly states: "本次正式 Wald 检验**未能在统计上确认这一差异**"; "不应在论文正文中把'硬件驱动、云弱'作为一个经过统计检验确认的发现来写"; "这是一个真实的零结果（null finding），应在稳健性章节中坦诚报告，而非淡化或省略。" Also reiterated in §5 exclusion table (line 211): "Wald 检验确认'硬件驱动、云服务弱'的因果叙事 | 不应写入任何版本 | R1 已正式检验并得到 p=0.298 的不显著结果。" **Preserved, not softened.**

**(b) R4: both headline findings lose significance under FF3 at car_20:**
Lines 149-164 (§3 R4) labeled "必须突出报告的重要警示" (must be prominently flagged warning). Explicit statement (line 162): "**两个headline 发现都保留了符号方向，但都在 car_20 窗口失去统计显著性**（upstream_hardware p=0.879；downstream_deployer p=0.133）." Followed by an instruction that this "不能只在附录脚注中一笔带过" and must appear in both Main Results and Robustness sections (line 164, line 198). **Preserved, in fact elevated to a structural requirement (§4 table, row 5/6) rather than buried.**

**(c) R5: upstream_hardware sign-flips/loses significance in joint model; downstream_deployer survives everywhere — not equal strength:**
The opening summary box of §3 (line 107) states this asymmetry as the lead finding before any individual R-item discussion: "downstream_deployer...是本文最稳健、最可辩护的核心发现...upstream_hardware...统计上更脆弱...这一不对称性必须在论文中如实呈现，不能把两个发现写成同等强度。" §3 R5 section (lines 166-181) gives the full per-context breakdown and directly quotes R5's own recommendation verbatim (line 181). This nuance is also pushed into §4 (Main Results row, line 193: "前瞻性对冲段落"; Conclusion row, line 196: "新增第四点关于证据强度分级的诚实陈述") and into §6 effort estimate (line 224: dedicated 0.25-day line item for "Conclusion 章节的证据强度分级陈述"). **Preserved and structurally reinforced across multiple sections — this is the strongest-handled of the three checks.**

**Verdict: PASS.** All three critical nuances are not only present but are foregrounded (lead bullet of §3, dedicated table rows in §4, dedicated exclusion-list entry in §5, dedicated line items in §6). No instance found where any of the three is contradicted, softened, or omitted elsewhere in the document.

---

## 3. Completeness vs requested scope (plan.md DOC spec)

`plan.md` (lines 212-220) requires six elements in the DOC deliverable:

| Required element | Found in PAPER_B_WRITING_PLAN.md | Status |
|---|---|---|
| 1. 定位（标题、目标期刊、核心命题） | §1 (lines 13-38), includes three-paper comparison table, target journals (JFE/RFS/JBF/JFQA), core propositions | Present |
| 2. 现有素材盘点表（标注完成/需新写，引用文件路径） | §2 (lines 41-101): long.tex structure table, figures table, scripts table, methodology materials, R1-R5 file list — all with explicit file paths and 已完成/[待补充] status tags | Present |
| 3. 5 项稳健性回归结果汇总（嵌入关键数字，标注产出文件路径） | §3 (lines 105-181), one subsection per R1-R5, each citing its source `.md`/`.csv` path | Present |
| 4. 论文结构 8 节表（节名、内容、对应表图、状态） | §4 (lines 185-198), exactly 8 rows (Introduction through Conclusion), each with content/materials/status columns | Present |
| 5. 不在本论文范围内的内容清单（注明应归属哪篇论文） | §5 (lines 202-211), 6-row table, each row has an "应归属" (belongs-to) column | Present |
| 6. 工作量估计表（更新后剩余工作量） | §6 (lines 215-233), itemized table with 9 line items + two grand totals (with/without spec curve) | Present |

All six required elements are present, and the document additionally includes a numbers-provenance appendix (§237-248) that was not explicitly required but directly supports verifiability — a reasonable value-add, not scope creep.

**Verdict: PASS.** No required section missing.

---

## 4. Effort estimate sanity check

Original baseline cited: 5-7 days "before R1-R5 were completed" (line 217). Updated estimate: 5-6.5 days (without spec curve) / 6-8.5 days (with spec curve) (lines 230-231).

Checking whether the estimate correctly treats Main Results hedging/rewriting as separate, additional work rather than folding it into Robustness:

- Line 221: Robustness section writing — 0.5-1 day (separate line item)
- Line 222: New table formatting for R1-R5 — 0.5 day (separate line item)
- Line 223: **"Main Results 章节的对冲性措辞修订（插入 R5 联合模型警示段落）" — 0.25 day**, explicitly described as inserting 2-3 sentences into the existing §1.5 joint-regression paragraph, citing R5 numbers
- Line 224: **"Conclusion 章节的证据强度分级陈述" — 0.25 day**, a new paragraph distinguishing downstream_deployer (robust) from upstream_hardware (fragile)
- Line 228: Cross-section consistency check (0.5-1 day) explicitly calls out checking "upstream_hardware 的强度描述要前后一致" between §5 Main Results and §6 Robustness

This confirms the estimate does NOT just account for the Robustness section — it carries four distinct line items (lines 221-224 plus 228) that specifically address the Main Results hedging, the Conclusion's asymmetric framing, and the cross-section consistency check made necessary by the upstream_hardware fragility finding. This is the correct allocation: the fragility finding genuinely creates work beyond "write up R1-R5," and the document accounts for it explicitly rather than implicitly.

Total of 5-6.5 days (excluding optional spec curve) is plausible: the largest single item is literature-review depth (2-3 days, line 225), which is realistic for a short-paper → full-length-journal upgrade and is appropriately flagged as the dominant remaining cost driver, separate from the now-completed statistical work.

**Verdict: PASS.** The estimate correctly decomposes hedging/rewriting work as distinct from, and additive to, the Robustness section write-up, and the total is plausible given the completed empirical work.

---

## 5. Scope discipline (Paper A / Paper C content check)

Searched the full document for Paper-A-specific content (AA Intelligence Index as a pricing variable, continuous capability measure as the dependent construct) and Paper-C content (media sentiment, news text mechanism tests):

- AA Intelligence appears only twice: (1) §1.1 comparison table (line 22) correctly listing it as Paper A's core independent variable, explicitly contrasted with Paper B's relationship variables; (2) §1.7/Table 5 reference (line 55) and §5 exclusion table (line 206) where it is explicitly scoped as "论文 B 仅在 Table 5 中把它作为控制变量使用，不展开讨论能力指标本身的构造或定价含义" (used only as a control variable in Paper B, not discussed as a pricing construct). This is correct scope discipline — using a variable as a control is legitimately part of Paper B and is clearly distinguished from claiming Paper A's research question.
- Media sentiment / text analysis appears only in §1.1 table (line 22, listed as Paper C's variable) and §5 exclusion table (line 207, explicitly excluded with reasoning "完全不同的识别策略和数据源"). No media-sentiment mechanism content is discussed substantively anywhere else.
- No instance found where Paper A's capability-pricing narrative or Paper C's sentiment-channel narrative is presented as if it were a Paper B finding.

**Verdict: PASS.** Scope boundaries are explicit and consistently maintained; no bleed-in from Paper A or Paper C.

---

## 6. Internal consistency

Checked specifically for the failure mode of describing upstream_hardware as "fully robust" in one place while flagging its joint-model fragility elsewhere:

- §1 (line 33): describes the upstream/downstream relationship as "互补品/替代品" framework — a directional/qualitative claim, not a robustness claim. Does not overclaim statistical strength.
- §2.1 table (line 58): marks §3 robustness (long.tex) as "[待补充]" — consistent with not yet claiming completion.
- §3 opening box (line 107) and R5 subsection (lines 166-181) consistently describe upstream_hardware as directionally robust but statistically fragile in the joint model — never described as "fully robust" anywhere.
- §4 row for Main Results (line 193) and row for Conclusion (line 196) both correctly carry forward the same asymmetric characterization (robust deployer vs. fragile-in-joint-model hardware) rather than contradicting it.
- §6 effort table (line 228) explicitly flags the cross-section consistency risk as a to-do item ("尤其 upstream_hardware 的强度描述要前后一致"), which is itself evidence the document's authors were aware of this failure mode and built in a safeguard — appropriate given this is a forward-looking planning document, not the final paper text.

No section was found that asserts upstream_hardware is "fully robust" or omits the joint-model caveat when discussing it. The qualifier ("方向稳健，统计上更脆弱" / "统计上对设定敏感") is attached consistently every time the variable's robustness is characterized.

**Verdict: PASS.**

---

## Overall verdict

**PASS — no FAILs found across all 6 checks.**

Summary: `PAPER_B_WRITING_PLAN.md` is numerically accurate (14/14 spot-checked figures match source files exactly, including the appendix's own line-number citations), faithfully preserves and in fact foregrounds all three required critical nuances (R1 null result, R4 FF3 significance loss, R5 joint-model asymmetry between the two headline findings), is complete against the plan.md DOC task spec (all 6 required elements present), provides a plausible and correctly-decomposed effort estimate that accounts for Main-Results hedging as additive work, maintains clean scope boundaries against Paper A and Paper C, and is internally consistent in how it characterizes upstream_hardware's fragility throughout.

One non-blocking observation for the record (not a writing-plan defect): R5's own source file states "61 events" in two places while all other sources (R1/R2/R3, `Tex/long.tex`) state 60 events/n=4,829; the writing plan correctly used "60" throughout and did not inherit this inconsistency. Recommend flagging this to REVIEW-DATA / the R5 script author for correction at the source, but it requires no change to `PAPER_B_WRITING_PLAN.md` itself.
