import pandas as pd
import numpy as np
import statsmodels.api as sm
from datetime import datetime

# ================== 用户需要配置的部分 ==================

# 1. 公司代码
company_id = 'INX Gn'

# 2. 从你原始脚本中完整提取的事件日期清单（共 60 多个事件）
event_dates = [
    '2024-04-18', '2024-05-14', '2024-05-30', '2024-06-12', '2024-08-08',
    '2024-08-13', '2024-08-28', '2024-09-12', '2024-09-12', '2024-09-24',
    '2024-10-03', '2024-10-03', '2024-10-22', '2024-11-12', '2024-12-06',
    '2024-12-09', '2024-12-11', '2024-12-17', '2024-12-17', '2024-12-20',
    '2025-01-22', '2025-01-28', '2025-01-31', '2025-02-05', '2025-02-17',
    '2025-02-18', '2025-02-25', '2025-02-26', '2025-03-12', '2025-03-31',
    '2025-04-15', '2025-04-15', '2025-04-16', '2025-04-16', '2025-04-21',
    '2025-05-06', '2025-05-20', '2025-05-21', '2025-05-21', '2025-05-22',
    '2025-06-17', '2025-06-17', '2025-07-21', '2025-07-22', '2025-07-28',
    '2025-08-05', '2025-08-26', '2025-09-05', '2025-09-25', '2025-10-14',
    '2025-12-02', '2025-12-09', '2025-12-18', '2025-12-18', '2025-12-31',
    '2026-02-05', '2026-02-12', '2026-02-16', '2026-02-26', '2026-03-17',
]

# 3. 完全读取你原脚本的核心窗口参数
est_start = -130      # 估计窗口开始
est_end   = -11       # 估计窗口结束

# 完全保留你的 8 个标准事件窗口
windows = {
    'car_minus10_minus2': (-10, -2),
    'car1': (-1, 1),
    'car2': (-2, 2),
    'car3': (-3, 3),
    'car5': (-5, 5),
    'car10': (-10, 10),
    'car15': (-15, 15),
    'car20': (-20, 20),
}

# ================== FF3三因子计算核心逻辑 ==================

print("正在读取日度数据并匹配三因子 ...")
daily = pd.read_excel(r"D:\组会内容\数据2026\ADBE.xlsx")

# 列名规范化映射 (请务必确保你的表格里有 'smb', 'hml', 'rf' 列)
daily.rename(columns={
    'code': 'company_id',
}, inplace=True)

# 日期类型转换
if not pd.api.types.is_datetime64_any_dtype(daily['date']):
    daily['date'] = pd.to_datetime(daily['date'], origin='1960-01-01', unit='D')
else:
    daily['date'] = pd.to_datetime(daily['date'])

# 筛选目标公司数据并排序
comp_data = daily[daily['company_id'] == company_id].copy()
if comp_data.empty:
    raise ValueError(f"公司代码 {company_id} 在数据中不存在，请检查数据内容。")
print(f"公司 {company_id} 共有 {len(comp_data)} 条日度记录。")
comp_data.sort_values('date', inplace=True)

# 【重要重构】：根据FF3模型规范，计算超额收益率作为回归基础
# Ri_RF = 个股收益率 - 无风险利率； Mkt_RF = 市场收益率 - 无风险利率
comp_data['Ri_RF'] = comp_data['share_earn'] - comp_data['rf']
comp_data['Mkt_RF'] = comp_data['market_earn'] - comp_data['rf']

results = []

# 循环每个事件日期
for i, event_date_str in enumerate(event_dates, 1):
    event_date = pd.to_datetime(event_date_str)
    print(f"处理事件 {i}/{len(event_dates)}: {event_date.date()}")
    
    # 使用你原本的交易日相对日期逻辑
    comp_data['rel_date'] = (comp_data['date'] - event_date).dt.days
    
    # 提取估计窗口数据并剔除缺失值
    in_est = comp_data['rel_date'].between(est_start, est_end)
    est_data = comp_data[in_est].dropna(subset=['Ri_RF', 'Mkt_RF', 'smb', 'hml'])
    
    if len(est_data) < 30:
        print(f"  警告：估计窗口有效数据仅 {len(est_data)} 天，样本量较小可能影响回归稳健性。")
    
    # ---- 核心重构：将 OLS 回归从单变量升级为 Fama-French 三因子回归 ----
    X_est = est_data[['Mkt_RF', 'smb', 'hml']]
    X_est = sm.add_constant(X_est)  # 自动引入常数项 Alpha
    y_est = est_data['Ri_RF']
    
    # 拟合 FF3 估计方程
    model = sm.OLS(y_est, X_est).fit()
    
    # 循环各个事件窗口计算 CAR
    car_vals = {}
    for win_name, (start, end) in windows.items():
        in_win = comp_data['rel_date'].between(start, end)
        win_data = comp_data[in_win].copy()
        if win_data.empty:
            car_vals[win_name] = np.nan
            continue
        
        # 构造用于预测期望收益的自变量矩阵（必须包含 const、Mkt_RF、smb、hml）
        X_win = pd.DataFrame({
            'const': 1,
            'Mkt_RF': win_data['Mkt_RF'],
            'smb': win_data['smb'],
            'hml': win_data['hml']
        })
        
        # 预测预期的个股超额收益率 E(Ri - Rf)
        win_data['expected_Ri_RF'] = model.predict(X_win)
        
        # 计算三因子模型下的异常收益率：
        # AR = 实际个股超额收益率 - 预期个股超额收益率
        win_data['ar'] = win_data['Ri_RF'] - win_data['expected_Ri_RF']
        
        # 对窗口期内的 AR 进行加总得到该窗口的 CAR
        car_vals[win_name] = win_data['ar'].sum()
    
    # 收集当前事件的一系列 CAR 结果
    results.append({
        'event_date': event_date,
        **car_vals
    })

# 转换为 DataFrame 并导出结果
result_df = pd.DataFrame(results)
result_df.insert(0, 'event_id', range(1, len(result_df)+1))

print("\nFF3三因子计算结果预览：")
print(result_df.head(10))

result_df.to_excel('car_ff3_results.xlsx', index=False)
print("\n更准确的 FF3 结果已保存至 car_ff3_results.xlsx")
