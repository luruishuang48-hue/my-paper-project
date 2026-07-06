from pathlib import Path
import json
import math
import warnings

import numpy as np
import pandas as pd
from scipy import stats
import statsmodels.formula.api as smf
import matplotlib.pyplot as plt

warnings.filterwarnings('ignore')

ROOT = Path.cwd()
TASK = ROOT / 'agent_tasks' / 'analysis_report_20260521-133006'
DATA = ROOT / '事件集数据.csv'


def safe_name(x, fallback):
    if pd.isna(x):
        return fallback
    s = str(x).strip()
    if not s or s.lower() == 'nan':
        return fallback
    return s


def make_unique(cols):
    out, seen = [], {}
    for c in cols:
        base = str(c)
        if base not in seen:
            seen[base] = 0
            out.append(base)
        else:
            seen[base] += 1
            out.append(f'{base}_{seen[base]}')
    return out


def read_data():
    raw = pd.read_csv(DATA, encoding='gb18030', dtype=str)
    first = raw.iloc[0]
    cols = [safe_name(first.iloc[i], raw.columns[i]) for i in range(len(raw.columns))]
    cols = make_unique(cols)
    df = raw.iloc[1:].copy()
    df.columns = cols
    df = df.replace({'': np.nan, 'nan': np.nan, 'NaN': np.nan})
    for c in df.columns:
        if df[c].dtype == object:
            df[c] = df[c].str.strip()
    return raw, df

raw, df = read_data()

num_cols = [
    'release_year','trend_month_since_2022_11','size (log_assets)','BM_Ratio','volatility','Momentum',
    'car_1','car_2','car_3','car_5','car_10','car_15','car_20',
    'aa_intelligence_index','aa_coding_index','aa_math_index','mmlu_pro','gpqa','hle','livecodebench','scicode','math_500','aime',
    'price_1m_input_tokens','price_1m_output_tokens','price_1m_blended_3_to_1','median_output_tokens_per_second',
    'median_time_to_first_token_seconds','median_time_to_first_answer_token','aa_media_elo','aa_media_rank','aa_media_ci95','aa_media_appearances',
    'merged_model_count', 'media_sent_1_mean', 'media_sent_1_sd'
]
# Actual media columns after row-0 header normalization: some names are windows-N.
media_map = {
    'windows-2': 'media_sent_2_mean',
    'windows-2_1': 'media_sent_2_sd',
    'windows-3': 'media_sent_3_mean',
    'windows-3_1': 'media_sent_3_sd',
    'windows-5': 'media_sent_5_mean',
    'windows-5_1': 'media_sent_5_sd',
    'windows-10': 'media_sent_10_mean',
    'windows-10_1': 'media_sent_10_sd',
    'windows-15': 'media_sent_15_mean',
    'windows-15_1': 'media_sent_15_sd',
    'windows-20': 'media_sent_20_mean',
    'windows-20_1': 'media_sent_20_sd',
}
# The two first media columns did not receive English row-0 labels.
for col in df.columns:
    if col.startswith('媒体态度均值(1,1)'):
        media_map[col] = 'media_sent_1_mean'
    if col.startswith('媒体态度标准差') and col == '媒体态度标准差':
        media_map[col] = 'media_sent_1_sd'
for old, new in list(media_map.items()):
    if old in df.columns and new not in df.columns:
        df = df.rename(columns={old: new})

num_cols = list(dict.fromkeys(num_cols + list(media_map.values())))
for c in num_cols:
    if c in df.columns:
        df[c] = pd.to_numeric(df[c], errors='coerce')

binary_cols = [
    'is_cross_modality_release','is_model_family','is_multimodal','is_reasoning_model','is_coding_model',
    'is_media_generation_model','is_open_weight_or_open_source','is_chinese_model','needs_relationship_mapping',
    'llm_capability_sample_flag','media_capability_sample_flag'
]
for c in binary_cols:
    if c in df.columns:
        df[c] = pd.to_numeric(df[c], errors='coerce')

if 'release_date' in df.columns:
    df['release_date_parsed'] = pd.to_datetime(df['release_date'], errors='coerce')

# Convenience variables for formulas.
rename_for_formula = {
    'size (log_assets)': 'size_log_assets',
    'BM_Ratio': 'bm_ratio',
    'Momentum': 'momentum',
}
df = df.rename(columns=rename_for_formula)

# Data outputs.
df.to_csv(TASK / 'cleaned_event_company_sample.csv', index=False, encoding='utf-8-sig')

car_cols = [c for c in ['car_1','car_2','car_3','car_5','car_10','car_15','car_20'] if c in df.columns]
main_car = 'car_1'

summary = {
    'raw_rows_including_english_header': int(raw.shape[0]),
    'observations': int(df.shape[0]),
    'columns': int(df.shape[1]),
    'events': int(df['final_event_id'].nunique()) if 'final_event_id' in df else None,
    'companies': int(df['company_id'].nunique()) if 'company_id' in df else None,
    'creators': int(df['true_model_creator'].nunique()) if 'true_model_creator' in df else None,
    'date_min': str(df['release_date_parsed'].min().date()) if 'release_date_parsed' in df and df['release_date_parsed'].notna().any() else None,
    'date_max': str(df['release_date_parsed'].max().date()) if 'release_date_parsed' in df and df['release_date_parsed'].notna().any() else None,
}
(TASK / 'summary_overview.json').write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding='utf-8')

# Missingness.
key_cols = [
    'final_event_id','release_date','event_name','true_model_creator','creator_country','creator_type','model_names','company','company_id',
    'relationship','industry','industry_2','size_log_assets','bm_ratio','volatility','momentum',
] + car_cols + [
    'media_sent_1_mean','media_sent_1_sd','media_sent_3_mean','media_sent_3_sd',
    'model_modality','model_modalities','is_open_weight_or_open_source','is_chinese_model','candidate_tier',
    'llm_capability_sample_flag','media_capability_sample_flag','aa_intelligence_index','aa_coding_index','aa_math_index',
    'price_1m_blended_3_to_1','median_output_tokens_per_second','aa_media_elo'
]
key_cols = [c for c in key_cols if c in df.columns]
missing = pd.DataFrame({
    'variable': key_cols,
    'missing_n': [int(df[c].isna().sum()) for c in key_cols],
    'missing_pct': [float(df[c].isna().mean()) for c in key_cols],
    'nonmissing_n': [int(df[c].notna().sum()) for c in key_cols],
})
missing.to_csv(TASK / 'table_missingness.csv', index=False, encoding='utf-8-sig')

# Event and company distributions.
def top_counts(col, n=20):
    if col not in df:
        return pd.DataFrame()
    return df[col].value_counts(dropna=False).head(n).rename_axis(col).reset_index(name='n')

for col, fname in [
    ('true_model_creator','table_top_creators.csv'),('model_modality','table_modality_counts.csv'),
    ('candidate_tier','table_tier_counts.csv'),('creator_country','table_creator_country_counts.csv'),
    ('creator_type','table_creator_type_counts.csv'),('industry','table_industry_counts.csv'),('industry_2','table_industry2_counts.csv'),
    ('company_id','table_top_companies.csv'),('relationship','table_relationship_counts.csv')]:
    out = top_counts(col, 30)
    if not out.empty:
        out.to_csv(TASK / fname, index=False, encoding='utf-8-sig')

# CAR windows.
def ttest_row(series):
    x = pd.to_numeric(series, errors='coerce').dropna()
    if len(x) < 2:
        return {'n': len(x), 'mean': np.nan, 'median': np.nan, 'sd': np.nan, 't': np.nan, 'p': np.nan, 'positive_share': np.nan}
    t, p = stats.ttest_1samp(x, 0.0, nan_policy='omit')
    return {
        'n': int(len(x)), 'mean': float(x.mean()), 'median': float(x.median()), 'sd': float(x.std(ddof=1)),
        't': float(t), 'p': float(p), 'positive_share': float((x > 0).mean())
    }

car_summary = pd.DataFrame([{'window': c, **ttest_row(df[c])} for c in car_cols])
car_summary.to_csv(TASK / 'table_car_window_tests.csv', index=False, encoding='utf-8-sig')

# Group summaries for main CAR.
def group_summary(group_col, y=main_car, min_n=20):
    if group_col not in df or y not in df:
        return pd.DataFrame()
    rows = []
    for k, g in df.groupby(group_col, dropna=False):
        row = {'group_variable': group_col, 'group': str(k)}
        row.update(ttest_row(g[y]))
        rows.append(row)
    out = pd.DataFrame(rows)
    if out.empty:
        return out
    out = out[out['n'] >= min_n].sort_values('mean', ascending=False)
    return out

group_frames = []
for gc in ['model_modality','candidate_tier','creator_country','creator_type','industry','industry_2',
           'is_open_weight_or_open_source','is_chinese_model','is_model_family','is_reasoning_model',
           'is_coding_model','is_media_generation_model','llm_capability_sample_flag','media_capability_sample_flag']:
    gs = group_summary(gc)
    if not gs.empty:
        group_frames.append(gs)
if group_frames:
    group_table = pd.concat(group_frames, ignore_index=True)
    group_table.to_csv(TASK / 'table_group_car1_tests.csv', index=False, encoding='utf-8-sig')

# Correlations among key quantitative variables.
quant = [c for c in [main_car, 'car_3','car_5','media_sent_1_mean','media_sent_3_mean','aa_intelligence_index','aa_coding_index','aa_math_index',
                     'price_1m_blended_3_to_1','median_output_tokens_per_second','aa_media_elo','size_log_assets','bm_ratio','volatility','momentum',
                     'trend_month_since_2022_11'] if c in df.columns]
corr = df[quant].corr(min_periods=30) if quant else pd.DataFrame()
if not corr.empty:
    corr.to_csv(TASK / 'table_correlations.csv', encoding='utf-8-sig')

# Regressions.
reg_rows = []

def run_model(name, formula, data, cluster_col='final_event_id'):
    d = data.copy()
    try:
        model = smf.ols(formula, data=d, missing='drop').fit()
        nobs = int(model.nobs)
        if nobs < 30:
            return None
        if cluster_col in d.columns:
            used = d.loc[model.model.data.row_labels]
            clusters = used[cluster_col]
            if clusters.nunique() > 1:
                model = model.get_robustcov_results(cov_type='cluster', groups=clusters)
            else:
                model = model.get_robustcov_results(cov_type='HC1')
        else:
            model = model.get_robustcov_results(cov_type='HC1')
        names = list(model.model.exog_names)
        for term, coef, se, pval in zip(names, model.params, model.bse, model.pvalues):
            reg_rows.append({
                'model': name, 'term': term, 'coef': float(coef), 'std_err': float(se), 'p_value': float(pval),
                'nobs': nobs, 'r2': float(getattr(model, 'rsquared', np.nan)), 'formula': formula
            })
        return model
    except Exception as e:
        reg_rows.append({'model': name, 'term': '__ERROR__', 'coef': np.nan, 'std_err': np.nan, 'p_value': np.nan, 'nobs': np.nan, 'r2': np.nan, 'formula': formula, 'error': str(e)})
        return None

base_controls = 'size_log_assets + bm_ratio + volatility + momentum + trend_month_since_2022_11'
feature_terms = 'is_open_weight_or_open_source + is_chinese_model + is_model_family + is_reasoning_model + is_coding_model + is_media_generation_model'
run_model('M1_features_controls_car1', f'{main_car} ~ {feature_terms} + {base_controls}', df)
run_model('M2_features_industry_car1', f'{main_car} ~ {feature_terms} + {base_controls} + C(industry)', df)
if 'media_sent_3_mean' in df.columns:
    run_model('M3_media_sentiment_car1', f'{main_car} ~ media_sent_3_mean + media_sent_3_sd + {feature_terms} + {base_controls}', df)
if 'aa_intelligence_index' in df.columns:
    llm = df[df.get('llm_capability_sample_flag', 0).fillna(0) == 1].copy() if 'llm_capability_sample_flag' in df else df.copy()
    run_model('M4_llm_capability_car1', f'{main_car} ~ aa_intelligence_index + aa_coding_index + price_1m_blended_3_to_1 + median_output_tokens_per_second + {base_controls}', llm)
if 'aa_media_elo' in df.columns:
    media = df[df.get('media_capability_sample_flag', 0).fillna(0) == 1].copy() if 'media_capability_sample_flag' in df else df.copy()
    run_model('M5_media_capability_car1', f'{main_car} ~ aa_media_elo + aa_media_rank + {base_controls}', media)
run_model('M6_longer_window_car3', f'car_3 ~ {feature_terms} + {base_controls}', df)
run_model('M7_longer_window_car5', f'car_5 ~ {feature_terms} + {base_controls}', df)

reg_table = pd.DataFrame(reg_rows)
reg_table.to_csv(TASK / 'table_regressions_long.csv', index=False, encoding='utf-8-sig')

# A compact regression view containing terms of substantive interest.
if not reg_table.empty:
    keep_terms = ['Intercept','is_open_weight_or_open_source','is_chinese_model','is_model_family','is_reasoning_model','is_coding_model',
                  'is_media_generation_model','media_sent_3_mean','media_sent_3_sd','aa_intelligence_index','aa_coding_index',
                  'price_1m_blended_3_to_1','median_output_tokens_per_second','aa_media_elo','aa_media_rank',
                  'size_log_assets','bm_ratio','volatility','momentum','trend_month_since_2022_11']
    compact = reg_table[reg_table['term'].isin(keep_terms)].copy()
    compact.to_csv(TASK / 'table_regressions_compact.csv', index=False, encoding='utf-8-sig')

# Event-level table: one row per event for timeline and event characteristics.
event_cols = [c for c in ['final_event_id','release_date_parsed','release_date','event_name','true_model_creator','creator_country','creator_type',
                          'model_names','model_modality','model_modalities','candidate_tier','is_open_weight_or_open_source','is_chinese_model',
                          'llm_capability_sample_flag','media_capability_sample_flag','aa_intelligence_index','aa_media_elo'] if c in df.columns]
events = df.sort_values(event_cols[1] if 'release_date_parsed' in event_cols else event_cols[0]).drop_duplicates('final_event_id')[event_cols] if 'final_event_id' in df else pd.DataFrame()
if not events.empty:
    events.to_csv(TASK / 'table_events_unique.csv', index=False, encoding='utf-8-sig')

# Figures.
plt.style.use('ggplot')
if 'release_date_parsed' in df and 'final_event_id' in df:
    ev = df.drop_duplicates('final_event_id').dropna(subset=['release_date_parsed']).copy()
    if not ev.empty:
        monthly = ev.set_index('release_date_parsed').resample('ME').size()
        fig, ax = plt.subplots(figsize=(10, 4))
        monthly.plot(kind='bar', ax=ax, color='#356859')
        ax.set_title('Model Release Events by Month')
        ax.set_xlabel('Month')
        ax.set_ylabel('Events')
        ticks = ax.get_xticks()
        labels = [monthly.index[int(i)].strftime('%Y-%m') if int(i) < len(monthly) else '' for i in ticks]
        ax.set_xticklabels(labels, rotation=70, ha='right', fontsize=7)
        fig.tight_layout()
        fig.savefig(TASK / 'figure_event_timeline.png', dpi=180)
        plt.close(fig)

if not car_summary.empty:
    fig, ax = plt.subplots(figsize=(8, 4))
    ax.bar(car_summary['window'], car_summary['mean'], color='#b35c44')
    ax.axhline(0, color='black', linewidth=0.8)
    ax.set_title('Mean CAR by Event Window')
    ax.set_xlabel('CAR Window Variable')
    ax.set_ylabel('Mean CAR')
    fig.tight_layout()
    fig.savefig(TASK / 'figure_car_window_means.png', dpi=180)
    plt.close(fig)

if 'model_modality' in df and main_car in df:
    mod = group_summary('model_modality', min_n=30).head(12)
    if not mod.empty:
        fig, ax = plt.subplots(figsize=(9, 4.5))
        ax.barh(mod['group'], mod['mean'], color='#3d5a80')
        ax.axvline(0, color='black', linewidth=0.8)
        ax.set_title('Mean CAR[Main] by Model Modality')
        ax.set_xlabel('Mean CAR')
        ax.set_ylabel('Modality')
        fig.tight_layout()
        fig.savefig(TASK / 'figure_car1_by_modality.png', dpi=180)
        plt.close(fig)

# Markdown tables for report embedding.
def fmt_pct(x):
    if pd.isna(x):
        return ''
    return f'{x*100:.2f}%'

def fmt_num(x, digits=4):
    if pd.isna(x):
        return ''
    return f'{x:.{digits}f}'

def md_table(dataframe, cols=None, max_rows=None):
    d = dataframe.copy()
    if cols:
        d = d[cols]
    if max_rows:
        d = d.head(max_rows)
    return d.to_markdown(index=False)

# pandas to_markdown requires tabulate; if missing, use simple fallback.
def simple_markdown(df_in, max_rows=None):
    d = df_in.head(max_rows).copy() if max_rows else df_in.copy()
    d = d.fillna('')
    headers = list(d.columns)
    lines = ['| ' + ' | '.join(headers) + ' |', '| ' + ' | '.join(['---']*len(headers)) + ' |']
    for _, r in d.iterrows():
        lines.append('| ' + ' | '.join(str(r[c]) for c in headers) + ' |')
    return '\n'.join(lines)

car_md = car_summary.copy()
for c in ['mean','median','sd','t','p','positive_share']:
    if c in car_md:
        car_md[c] = car_md[c].map(lambda x: fmt_num(x, 4) if c != 'positive_share' else fmt_pct(x))
car_md_path = TASK / 'table_car_window_tests.md'
car_md_path.write_text(simple_markdown(car_md), encoding='utf-8')

if group_frames:
    gmd = group_table.copy()
    for c in ['mean','median','sd','t','p']:
        if c in gmd:
            gmd[c] = gmd[c].map(lambda x: fmt_num(x, 4))
    if 'positive_share' in gmd:
        gmd['positive_share'] = gmd['positive_share'].map(fmt_pct)
    (TASK / 'table_group_car1_tests.md').write_text(simple_markdown(gmd, 80), encoding='utf-8')

if not reg_table.empty:
    rmd = compact.copy() if 'compact' in locals() else reg_table.copy()
    for c in ['coef','std_err','p_value','r2']:
        if c in rmd:
            rmd[c] = rmd[c].map(lambda x: fmt_num(x, 4))
    (TASK / 'table_regressions_compact.md').write_text(simple_markdown(rmd, 120), encoding='utf-8')

print(json.dumps(summary, ensure_ascii=False, indent=2))
print('outputs', TASK)
