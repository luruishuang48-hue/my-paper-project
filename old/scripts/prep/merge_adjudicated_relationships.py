"""
合并仲裁后的 8 维关系编码到关系数据源头文件。

输入:
  task/事件集数据-relationships.csv          (UTF-8, 5161 行, 含旧 8 列关系编码)
  data/relationships/adjudicated_event_level.csv (UTF-8, 5160 行, 新 8 维仲裁结果)
输出:
  task/事件集数据-relationships_v2.csv        (UTF-8, 新旧两套关系列并存)
"""
import sys
import pandas as pd
import numpy as np

SRC_PATH = 'task/事件集数据-relationships.csv'
ADJ_PATH = 'data/relationships/adjudicated_event_level.csv'
OUT_PATH = 'task/事件集数据-relationships_v2.csv'

NEW_REL_COLS = [
    'upstream_hardware', 'upstream_cloud', 'downstream_integrator',
    'downstream_deployer', 'downstream_enabler', 'competitor',
    'is_investor', 'is_owner',
]
NEW_COL_RENAME = {
    'competitor': 'competitor_new',
    'confidence': 'relationship_confidence',
    'justification': 'relationship_justification',
}

src = pd.read_csv(SRC_PATH, encoding='utf-8', dtype=str)
adj = pd.read_csv(ADJ_PATH, encoding='utf-8', dtype=str)

src_n_before = len(src)

# 源头文件末尾有一行 key 全为 NaN 的空行，丢弃后再校验
src = src.dropna(subset=['事件 ID', '公司编码'], how='all')
assert src.duplicated(['事件 ID', '公司编码']).sum() == 0, '源头文件存在重复 key'
assert adj.duplicated(['final_event_id', 'company_id']).sum() == 0, 'adjudicated 文件存在重复 key'

src_keys = set(zip(src['事件 ID'], src['公司编码']))
adj_keys = set(zip(adj['final_event_id'], adj['company_id']))
missing_in_adj = src_keys - adj_keys
missing_in_src = adj_keys - src_keys
if missing_in_adj or missing_in_src:
    print(f'ERROR: key 不对齐。src-only: {len(missing_in_adj)}, adj-only: {len(missing_in_src)}', file=sys.stderr)
    sys.exit(1)

adj_renamed = adj.rename(columns=NEW_COL_RENAME)
new_cols_final = [NEW_COL_RENAME.get(c, c) for c in NEW_REL_COLS] + ['relationship_confidence', 'relationship_justification']

merged = src.merge(
    adj_renamed[['final_event_id', 'company_id'] + new_cols_final],
    left_on=['事件 ID', '公司编码'],
    right_on=['final_event_id', 'company_id'],
    how='left',
    validate='one_to_one',
)
merged = merged.drop(columns=['final_event_id', 'company_id'])

assert len(merged) == len(src), f'合并后行数变化: {len(src)} -> {len(merged)}'
binary_new = [c for c in new_cols_final if c not in ('relationship_confidence', 'relationship_justification')]
n_missing = merged[binary_new].isna().any(axis=1).sum()
assert n_missing == 0, f'新关系列存在缺失值: {n_missing} 行'

merged.to_csv(OUT_PATH, index=False, encoding='utf-8')

print(f'源头文件行数（去空行前/后）: {src_n_before} / {len(src)}')
print(f'合并输出行数: {len(merged)}')
print(f'输出文件: {OUT_PATH}')
print()
print('新关系列计数 (=1):')
for c in binary_new:
    print(f'  {c}: {int(pd.to_numeric(merged[c]).sum())}')

print()
print('与 adjudicated_event_level.csv 直接统计对比:')
for c in NEW_REL_COLS:
    final_name = NEW_COL_RENAME.get(c, c)
    direct_count = int(pd.to_numeric(adj[c]).sum())
    merged_count = int(pd.to_numeric(merged[final_name]).sum())
    status = 'OK' if direct_count == merged_count else 'MISMATCH'
    print(f'  {c} -> {final_name}: direct={direct_count}, merged={merged_count} [{status}]')
