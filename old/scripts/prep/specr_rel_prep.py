"""
预处理：task/事件集数据-relationships.csv → specr_rel_clean.csv (UTF-8)
"""
import pandas as pd
import numpy as np

df = pd.read_csv('task/事件集数据-relationships.csv', encoding='utf-8', dtype=str)

# ── 列名映射 ──────────────────────────────────────────────────────────────────
rename = {
    '事件 ID':                          'final_event_id',
    '日级发布日期':                      'release_date',
    '发布年份':                          'release_year',
    '发布月份':                          'release_month',
    '发布季度':                          'release_quarter',
    '从2022-11 起算的月度趋势变量':       'trend_month',
    '事件名称':                          'event_name',
    '模型发布者':                        'true_model_creator',
    '模型发布者国家':                    'creator_country',
    '发布者类型':                        'creator_type',
    '模型名称':                          'model_names',
    '公司':                             'company',
    '公司编码':                          'company_id',
    '与模型发布者的关系':                'relationship_old',
    '行业板块':                          'industry',
    '行业分组':                          'industry_2',
    '规模（亿美元）（ln）':              'size_log_assets',
    '账面市值比':                        'bm_ratio',
    '前期波动率':                        'volatility',
    '累计涨幅':                          'momentum',
    '市场模型异常收益[-10,-2]':           'car_pre',
    '市场模型异常收益时间窗口1':          'car_1',
    '市场模型异常收益2':                  'car_2',
    '市场模型异常收益3':                  'car_3',
    '市场模型异常收益5':                  'car_5',
    '市场模型异常收益10':                 'car_10',
    '市场模型异常收益15':                 'car_15',
    '市场模型异常收益20':                 'car_20',
    'FF3异常收益时间窗口1':              'ff3_car_1',
    'FF3异常收益2':                      'ff3_car_2',
    'FF3异常收益3':                      'ff3_car_3',
    'FF3异常收益5':                      'ff3_car_5',
    'FF3异常收益10':                     'ff3_car_10',
    'FF3异常收益15':                     'ff3_car_15',
    'FF3异常收益20':                     'ff3_car_20',
    '模型的模态':                        'model_modality',
    '是否开源或开放权重':                'is_open_weight',
    '是否为中国发布者或中国模型体系':    'is_chinese_model',
    '候选事件重要性分层，Tier 1 最高':   'candidate_tier',
    'LLM 模型的 AA 指标':               'aa_intelligence_index',
}

df = df.rename(columns={k: v for k, v in rename.items() if k in df.columns})

# Relationship columns stay as-is: owner, investor, cloud,
# business_upstream, real_upstream, business_downstream, real_downstream, competitor

df = df.replace({'': np.nan, 'nan': np.nan, 'NaN': np.nan})
for c in df.select_dtypes('object').columns:
    df[c] = df[c].str.strip()

# ── 数值化 ────────────────────────────────────────────────────────────────────
num_cols = [
    'release_year', 'trend_month',
    'car_1','car_2','car_3','car_5','car_10','car_15','car_20',
    'ff3_car_1','ff3_car_2','ff3_car_3','ff3_car_5','ff3_car_10','ff3_car_15','ff3_car_20',
    'size_log_assets','bm_ratio','volatility','momentum',
    'aa_intelligence_index',
    'is_open_weight','is_chinese_model',
    'owner','investor','cloud',
    'business_upstream','real_upstream',
    'business_downstream','real_downstream',
    'competitor',
]
for c in num_cols:
    if c in df.columns:
        df[c] = pd.to_numeric(df[c], errors='coerce')

df.to_csv('specr_rel_clean.csv', index=False, encoding='utf-8')
print(f"Saved: {len(df)} rows x {len(df.columns)} cols")
print(f"Events: {df['final_event_id'].nunique()}")
print(f"\nRelationship counts (=1):")
for c in ['owner','investor','cloud','business_upstream','real_upstream',
          'business_downstream','real_downstream','competitor']:
    n = int(df[c].sum()) if c in df.columns else 'N/A'
    print(f"  {c}: {n}")

print(f"\naa_intelligence_index non-missing: {df['aa_intelligence_index'].notna().sum()}")
for c in ['car_1','car_5','car_20']:
    print(f"  {c} non-missing: {df[c].notna().sum()}")
print(f"\ncreator_type:\n{df['creator_type'].value_counts().to_string()}")
print(f"\nmodel_modality:\n{df['model_modality'].value_counts().to_string()}")
