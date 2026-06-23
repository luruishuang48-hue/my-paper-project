"""
预处理：将事件集数据-new.csv（GB18030）转为 UTF-8，供 R specr 脚本读取。
输出：specr_input_clean.csv（UTF-8，单行英文表头，数据从第2行起）
"""
import pandas as pd
import numpy as np

raw = pd.read_csv('事件集数据-new.csv', encoding='gb18030', dtype=str)

# 第0行是英文列名，第1行起是数据
first = raw.iloc[0]
cols = []
seen = {}
for i in range(len(raw.columns)):
    name = str(first.iloc[i]).strip()
    if not name or name.lower() == 'nan':
        name = str(raw.columns[i]).strip()
    if name in seen:
        seen[name] += 1
        name = f'{name}_{seen[name]}'
    else:
        seen[name] = 0
    cols.append(name)

df = raw.iloc[1:].copy()
df.columns = cols
df = df.replace({'': np.nan, 'nan': np.nan, 'NaN': np.nan})
for c in df.columns:
    if df[c].dtype == object:
        df[c] = df[c].str.strip()

# 重命名含空格/特殊字符的列，方便 R 公式使用
df = df.rename(columns={
    'size (log_assets)': 'size_log_assets',
    'BM_Ratio': 'bm_ratio',
    'Momentum': 'momentum',
})

df.to_csv('specr_input_clean.csv', index=False, encoding='utf-8')

print(f"Saved: {len(df)} rows x {len(df.columns)} cols")
print(f"Events (final_event_id): {df['final_event_id'].nunique()}")
print(f"Company-event obs:       {len(df)}")
print(f"\nKey numeric check:")
for col in ['car_1','car_5','aa_intelligence_index','aa_coding_index','aa_math_index','aa_media_elo']:
    n_valid = pd.to_numeric(df[col], errors='coerce').notna().sum()
    print(f"  {col}: {n_valid} non-missing")
print(f"\nRelationship value counts:")
print(df['relationship'].value_counts().to_string())
print(f"\nCreator type value counts:")
print(df['creator_type'].value_counts().to_string())
print(f"\nModel modality value counts:")
print(df['model_modality'].value_counts().to_string())
