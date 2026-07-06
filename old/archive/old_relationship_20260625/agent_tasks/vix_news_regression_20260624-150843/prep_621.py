"""
prep_621.py: 预处理 data/relationships/6.21事件集数据.csv
输出: agent_tasks/vix_news_regression_20260624-150843/outputs/specr_621_clean.csv
"""
import pandas as pd
import numpy as np
import os

# ─── 读取文件 ─────────────────────────────────────────────────────────────────
raw = pd.read_csv(
    'data/relationships/6.21事件集数据.csv',
    dtype=str, encoding='gbk', header=None
)
print(f"Raw shape: {raw.shape}")

# Row 0: Chinese headers, Row 1: English headers, Row 2+: data
eng_headers_raw = raw.iloc[1, :].tolist()

# 处理重复列名
seen = {}
clean_headers = []
for h in eng_headers_raw:
    h = str(h).strip() if h and str(h) != 'nan' else ''
    if not h:
        h = f'_unnamed_{len(clean_headers)}'
    if h in seen:
        seen[h] += 1
        clean_headers.append(f'{h}_{seen[h]}')
    else:
        seen[h] = 0
        clean_headers.append(h)

df = raw.iloc[2:].copy()
df.columns = clean_headers
df = df.reset_index(drop=True)
print(f"Data shape: {df.shape}")

# ─── 重命名媒体情绪列（处理重复）───────────────────────────────────────────────
# 媒体情绪列有三个字段: 均值(sentiment), 标准差, 关注度(news count)
# 对应每个窗口 (1,2,3,5,10,15,20)
sentiment_windows = [1, 2, 3, 5, 10, 15, 20]

# 找到正确的媒体列 (知道它们按顺序: mean, sd, count * 7 windows)
# 原始中文标题: 媒体态度均值, 媒体态度标准差, 媒体关注度
# 英文标题因重复变成: windows_1, windows_1_1, attention rate_1, ...

# 检查实际列名
media_related = [(i, h) for i, h in enumerate(clean_headers) 
                 if 'windows' in h.lower() or 'attention' in h.lower()]
print(f"\nMedia columns ({len(media_related)}):")
for i, h in media_related:
    print(f"  [{i:3d}] {h}")

# ─── 重命名媒体情绪/新闻数量列 ────────────────────────────────────────────────
# 按窗口重新命名
window_labels = [1, 2, 3, 5, 10, 15, 20]
# 找到媒体态度均值(mean), 标准差(sd), 关注度(count) 各列
# 从原始CSV: 每组3列 (mean, sd, count) × 7 windows
media_triples = []
for i in range(0, len(media_related), 3):
    if i+2 < len(media_related):
        idx_mean, name_mean = media_related[i]
        idx_sd,   name_sd   = media_related[i+1]
        idx_cnt,  name_cnt  = media_related[i+2]
        media_triples.append((idx_mean, idx_sd, idx_cnt))

print(f"\nMedia triples found: {len(media_triples)}")

rename_map = {}
for j, (idx_mean, idx_sd, idx_cnt) in enumerate(media_triples):
    if j < len(window_labels):
        w = window_labels[j]
        old_mean = clean_headers[idx_mean]
        old_sd   = clean_headers[idx_sd]
        old_cnt  = clean_headers[idx_cnt]
        rename_map[old_mean] = f'sent_mean_w{w}'
        rename_map[old_sd]   = f'sent_sd_w{w}'
        rename_map[old_cnt]  = f'news_count_w{w}'

df = df.rename(columns=rename_map)

# ─── FF3 列重命名 ──────────────────────────────────────────────────────────────
# FF3列也是重复名: car_pre_1, car_1_1, car_2_1, car_3_1, car_5_1, car_10_1, car_15_1, car_20_1
ff3_rename = {
    'car_pre_1': 'ff3_car_pre',
    'car_1_1':   'ff3_car_1',
    'car_2_1':   'ff3_car_2',
    'car_3_1':   'ff3_car_3',
    'car_5_1':   'ff3_car_5',
    'car_10_1':  'ff3_car_10',
    'car_15_1':  'ff3_car_15',
    'car_20_1':  'ff3_car_20',
}
df = df.rename(columns={k: v for k, v in ff3_rename.items() if k in df.columns})

# ─── 标准化其他列名 ────────────────────────────────────────────────────────────
std_rename = {
    'size (log_assets)':           'size_log_assets',
    'BM_Ratio':                    'bm_ratio',
    'Momentum':                    'momentum',
    'trend_month_since_2022_11':   'trend_month',
    'is_open_weight_or_open_source': 'is_open_weight',
}
df = df.rename(columns={k: v for k, v in std_rename.items() if k in df.columns})

# ─── 构造关系二值变量 (从 relationship 字符串列) ─────────────────────────────
rel_col = 'relationship'
if rel_col in df.columns:
    df['rel_str'] = df[rel_col].fillna('').str.strip().str.lower()
    
    df['owner']              = (df['rel_str'] == 'owner').astype(int)
    df['investor']           = (df['rel_str'] == 'investor').astype(int)
    df['competitor']         = (df['rel_str'] == 'competitor').astype(int)
    df['business_upstream']  = df['rel_str'].str.contains('business_upstream').astype(int)
    df['real_upstream']      = df['rel_str'].str.contains('real_upstream').astype(int)
    df['business_downstream']= df['rel_str'].str.contains('business_downstream').astype(int)
    df['real_downstream']    = df['rel_str'].str.contains('real_downstream').astype(int)
    df['upstream']           = (df['business_upstream'] | df['real_upstream']).astype(int)
    df['downstream']         = (df['business_downstream'] | df['real_downstream']).astype(int)
    
    print("\nRelationship dummy counts:")
    for c in ['owner','investor','competitor','upstream','downstream',
              'business_upstream','real_upstream','business_downstream','real_downstream']:
        print(f"  {c}: {df[c].sum()}")
else:
    print("WARNING: 'relationship' column not found!")

# ─── 数值化 ────────────────────────────────────────────────────────────────────
num_cols = [
    'release_year', 'trend_month', 'VIX',
    'car_pre', 'car_1', 'car_2', 'car_3', 'car_5', 'car_10', 'car_15', 'car_20',
    'ff3_car_pre', 'ff3_car_1', 'ff3_car_2', 'ff3_car_3', 'ff3_car_5',
    'ff3_car_10', 'ff3_car_15', 'ff3_car_20',
    'size_log_assets', 'bm_ratio', 'volatility', 'momentum',
    'aa_intelligence_index', 'aa_coding_index', 'aa_math_index',
    'aa_media_elo', 'price_1m_blended_3_to_1',
    'is_open_weight', 'is_chinese_model', 'is_reasoning_model',
    'is_coding_model', 'is_multimodal', 'is_media_generation_model',
    'owner', 'investor', 'competitor',
    'upstream', 'downstream',
    'business_upstream', 'real_upstream', 'business_downstream', 'real_downstream',
]
# Add news count and sentiment cols
for w in [1, 2, 3, 5, 10, 15, 20]:
    num_cols += [f'sent_mean_w{w}', f'sent_sd_w{w}', f'news_count_w{w}']

for c in num_cols:
    if c in df.columns:
        df[c] = pd.to_numeric(df[c], errors='coerce')

# ─── 构造 log(news+1) ────────────────────────────────────────────────────────
for w in [1, 2, 3, 5, 10, 15, 20]:
    nc = f'news_count_w{w}'
    if nc in df.columns:
        df[f'log_news_w{w}'] = np.log1p(df[nc].fillna(0))

# ─── 描述统计 ──────────────────────────────────────────────────────────────────
print("\n=== Key Variable Summary ===")
key_vars = ['VIX', 'news_count_w1', 'news_count_w5', 'log_news_w1', 'log_news_w5',
            'aa_intelligence_index', 'car_1', 'car_20', 'ff3_car_1', 'ff3_car_20']
for v in key_vars:
    if v in df.columns and df[v].notna().sum() > 0:
        s = df[v].describe()
        print(f"  {v}: n={int(s['count'])}, mean={s['mean']:.3f}, "
              f"sd={s['std']:.3f}, min={s['min']:.3f}, max={s['max']:.3f}")

# ─── 保存 ──────────────────────────────────────────────────────────────────────
out_dir = 'agent_tasks/vix_news_regression_20260624-150843/outputs'
os.makedirs(out_dir, exist_ok=True)
out_path = f'{out_dir}/specr_621_clean.csv'
df.to_csv(out_path, index=False, encoding='utf-8')
print(f"\nSaved: {out_path}")
print(f"  Rows: {len(df)}, Cols: {len(df.columns)}")
print(f"  Events: {df['final_event_id'].nunique()}")
print(f"  aa_intelligence non-null: {df['aa_intelligence_index'].notna().sum()}")
print(f"  car_1 non-null: {df['car_1'].notna().sum()}")
print(f"  VIX non-null: {df['VIX'].notna().sum()}")
print(f"  news_count_w1 non-null: {df['news_count_w1'].notna().sum()}")
