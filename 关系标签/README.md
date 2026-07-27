# 企业—开发者关系编码

编码单位是证券与模型开发者的组合。当前样本覆盖 45 只 NDXT 证券、25 个模型
开发者和 8 个关系维度，共 1,125 个组合、9,000 个二元编码单元。

## 权威文件

- `relationship_codebook.md` 定义 R1–R6、F1 和 F2。
- `coding_evidence/coder_A_ndxt45.csv` 是编码者 A 的独立结果。
- `coding_evidence/coder_B_ndxt45.csv` 是编码者 B 的独立结果。
- `coding_evidence/agreement_by_dimension.csv` 汇总逐维一致率和 Cohen's kappa。
- `事件集筛选/decisions/relationship_decisions.csv` 是仲裁后的分析输入。

R3、R4、R5 相互排斥，其余维度允许多标签。GOOGL 与 GOOG 分别编码。

校验脚本检查完整的 45×25 网格、键唯一性、两套编码的一致性统计以及定稿表的
覆盖范围。

```sh
python3 关系标签/validate_relationship_coding.py
```

当前校验结果为 133 个分歧单元，整体一致率为 98.5%。
