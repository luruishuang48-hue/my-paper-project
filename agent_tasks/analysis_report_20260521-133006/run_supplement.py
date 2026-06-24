from pathlib import Path
import re
import numpy as np
import pandas as pd
from scipy import stats
import statsmodels.formula.api as smf

TASK = Path('agent_tasks/analysis_report_20260521-133006')
df = pd.read_csv(TASK / 'cleaned_event_company_sample.csv')

suffix_re = re.compile(r'\s(KS|HK|TT|JP|GR|LN|SW|NA|FH|IM)$')
def market_bucket(ticker):
    if pd.isna(ticker):
        return 'unknown'
    s = str(ticker).strip()
    if suffix_re.search(s):
        return 'non_us_exchange_code'
    return 'us_or_adr_like'

df['market_bucket'] = df['company_id'].map(market_bucket)
df.to_csv(TASK / 'cleaned_event_company_sample.csv', index=False, encoding='utf-8-sig')

market_counts = df.groupby('market_bucket').agg(rows=('company_id','size'), companies=('company_id','nunique'), events=('final_event_id','nunique')).reset_index()
market_counts.to_csv(TASK / 'table_market_bucket_counts.csv', index=False, encoding='utf-8-sig')

# T-tests by market bucket and CAR window.
rows=[]
for bucket,g in df.groupby('market_bucket'):
    for y in ['car_1','car_3','car_5']:
        x = pd.to_numeric(g[y], errors='coerce').dropna()
        if len(x)>1:
            t,p=stats.ttest_1samp(x,0)
            rows.append({'market_bucket':bucket,'window':y,'n':len(x),'mean':x.mean(),'median':x.median(),'sd':x.std(ddof=1),'t':t,'p':p,'positive_share':(x>0).mean()})
market_car=pd.DataFrame(rows)
market_car.to_csv(TASK/'table_market_bucket_car_tests.csv',index=False,encoding='utf-8-sig')

# Event-level average CAR removes duplicated event-level regressors.
agg_vars = ['car_1','car_3','car_5']
first_vars = ['release_date','event_name','true_model_creator','creator_country','creator_type','model_modality','candidate_tier',
              'is_open_weight_or_open_source','is_chinese_model','is_model_family','is_reasoning_model','is_coding_model','is_media_generation_model',
              'llm_capability_sample_flag','media_capability_sample_flag','aa_intelligence_index','aa_coding_index','price_1m_blended_3_to_1','median_output_tokens_per_second','aa_media_elo','aa_media_rank','trend_month_since_2022_11']
agg = df.groupby('final_event_id').agg(**{f'mean_{v}':(v,'mean') for v in agg_vars}, n_company=('company_id','nunique'))
first = df.sort_values('final_event_id').drop_duplicates('final_event_id').set_index('final_event_id')[[v for v in first_vars if v in df.columns]]
event = first.join(agg).reset_index()
event.to_csv(TASK/'table_event_level_dataset.csv',index=False,encoding='utf-8-sig')

reg_rows=[]
def run(name, formula, data):
    try:
        m=smf.ols(formula,data=data,missing='drop').fit(cov_type='HC1')
        for term, coef, se, p in zip(m.model.exog_names,m.params,m.bse,m.pvalues):
            reg_rows.append({'model':name,'term':term,'coef':coef,'std_err':se,'p_value':p,'nobs':int(m.nobs),'r2':m.rsquared,'formula':formula})
    except Exception as e:
        reg_rows.append({'model':name,'term':'__ERROR__','coef':np.nan,'std_err':np.nan,'p_value':np.nan,'nobs':np.nan,'r2':np.nan,'formula':formula,'error':str(e)})

run('E1_event_features_mean_car1','mean_car_1 ~ is_open_weight_or_open_source + is_chinese_model + is_model_family + is_reasoning_model + is_coding_model + is_media_generation_model + trend_month_since_2022_11', event)
run('E2_event_features_mean_car3','mean_car_3 ~ is_open_weight_or_open_source + is_chinese_model + is_model_family + is_reasoning_model + is_coding_model + is_media_generation_model + trend_month_since_2022_11', event)
llm = event[event.get('llm_capability_sample_flag',0)==1].copy()
run('E3_event_llm_capability_mean_car1','mean_car_1 ~ aa_intelligence_index + aa_coding_index + price_1m_blended_3_to_1 + median_output_tokens_per_second + trend_month_since_2022_11', llm)
media = event[event.get('media_capability_sample_flag',0)==1].copy()
run('E4_event_media_capability_mean_car1','mean_car_1 ~ aa_media_elo + aa_media_rank + trend_month_since_2022_11', media)
ereg=pd.DataFrame(reg_rows)
ereg.to_csv(TASK/'table_event_level_regressions.csv',index=False,encoding='utf-8-sig')

# Markdown helper.
def simple_markdown(d, max_rows=None):
    d = d.head(max_rows).copy() if max_rows else d.copy()
    d = d.fillna('')
    for c in d.columns:
        if pd.api.types.is_float_dtype(d[c]):
            d[c] = d[c].map(lambda x: '' if x=='' else f'{x:.4f}')
    headers = list(d.columns)
    lines = ['| ' + ' | '.join(headers) + ' |', '| ' + ' | '.join(['---']*len(headers)) + ' |']
    for _, r in d.iterrows():
        lines.append('| ' + ' | '.join(str(r[c]) for c in headers) + ' |')
    return '\n'.join(lines)

(TASK/'table_market_bucket_counts.md').write_text(simple_markdown(market_counts),encoding='utf-8')
(TASK/'table_market_bucket_car_tests.md').write_text(simple_markdown(market_car),encoding='utf-8')
(TASK/'table_event_level_regressions.md').write_text(simple_markdown(ereg[ereg['term'].isin(['Intercept','is_open_weight_or_open_source','is_chinese_model','is_model_family','is_reasoning_model','is_coding_model','is_media_generation_model','trend_month_since_2022_11','aa_intelligence_index','aa_coding_index','price_1m_blended_3_to_1','median_output_tokens_per_second','aa_media_elo','aa_media_rank'])],120),encoding='utf-8')
print(market_counts.to_string(index=False))
print(event[['final_event_id','mean_car_1']].describe().to_string())
