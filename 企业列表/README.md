# 企业样本

主样本采用 Nasdaq-100 Technology Sector Index 在 2026-05-01 的官方快照。
样本包含 45 只证券和 44 家发行人。GOOGL 与 GOOG 是两类独立证券，均按指数
成分保留。

## 文件

- `ndxt45_constituents_20260501.csv` 保存官方顺序、公司名、来源日期和
  SOX/SOXX 子样本标记。
- `build_firm_universe.py` 校验快照并生成
  `事件集筛选/decisions/firm_universe_decisions.csv`。
- `firm_universe_manifest.json` 记录输入和输出的 SHA-256、样本规模及来源。

运行方式如下。

```sh
python3 企业列表/build_firm_universe.py
```
