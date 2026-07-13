import pandas as pd
import numpy as np
import statsmodels.api as sm
from datetime import datetime

# ================== 用户需要配置的部分 ==================

# 1. 公司代码（例如三星电子为 '005930 KS'）
company_id = 'INX Gn'

# 2.94 个事件日期，请按实际日期填写（格式为 'YYYY-MM-DD' 的字符串）
event_dates = [
    '2024-04-18',   # ⭐ 示例事件日1，请修改为您的实际事件日期
    '2024-05-14',
    '2024-05-30',
    '2024-06-12',  
    '2024-08-08',
    '2024-08-13',  
    '2024-08-28',
    '2024-09-12',
    '2024-09-12',
    '2024-09-24',
    '2024-10-03',
    '2024-10-03',
    '2024-10-22',
    '2024-11-12',
    '2024-12-06',
    '2024-12-09',
    '2024-12-11',
    '2024-12-17',
    '2024-12-17',
    '2024-12-20',
    '2025-01-22',
    '2025-01-28',
    '2025-01-31',
    '2025-02-05',
    '2025-02-17',
    '2025-02-18',
    '2025-02-25',
    '2025-02-26',
    '2025-03-12',
    '2025-03-31',
    '2025-04-15',
    '2025-04-15',
    '2025-04-16',
    '2025-04-16',
    '2025-04-21',
    '2025-05-06',
    '2025-05-20',
    '2025-05-21',
    '2025-05-21',
    '2025-05-22',
    '2025-06-17',
    '2025-06-17',
    '2025-07-21',
    '2025-07-22',
    '2025-07-28',
    '2025-08-05',
    '2025-08-26',
    '2025-09-05',
    '2025-09-25',
    '2025-10-14',
    '2025-12-02',
    '2025-12-09',
    '2025-12-18',
    '2025-12-18',
    '2025-12-31',
    '2026-02-05',
    '2026-02-12',
    '2026-02-16',
    '2026-02-26',
    '2026-03-17',
]

# 3. 窗口参数（可根据需要调整）
est_start = -130      # 估计窗口开始（相对于事件日）
est_end   = -11       # 估计窗口结束（避免与事件窗口重叠）

# 事件窗口定义：可以添加或修改
windows = {
    'car0': (-10, -2),
    'car1': (-1, 1),  # [-1, 1]
    'car2': (-2, 2),
    'car3': (-3, 3),
    'car5': (-5, 5),     # [-5, 5]
    'car10': (-10, 10),   # [-10, 10]
    'car15': (-15, 15),
    'car20': (-20, 20),
}

# ================== 以下代码自动运行，一般无需修改 ==================

# 读取 Stata 格式的日度数据
print("正在读取 daily_data.dta ...")
daily = pd.read_excel(r"D:\组会内容\数据2026\00060.xlsx")

# 检查数据中的列名，确保存在：公司代码、日期、个股收益率、市场收益率
# 假设列名为 'company_id', 'date', 'share_earn', 'market_earn'
# 如果实际列名不同，请在这里修改映射
daily.rename(columns={
    'code': 'company_id',          # 如果原数据中公司代码列名为 'code'
    # 其他可能的列名映射
}, inplace=True)

# 确保日期列是 datetime 类型（Stata 日期可能以整数形式存储）
if not pd.api.types.is_datetime64_any_dtype(daily['date']):
    # 假设 Stata 日期是从 1960-01-01 开始的天数
    daily['date'] = pd.to_datetime(daily['date'], origin='1960-01-01', unit='D')
else:
    daily['date'] = pd.to_datetime(daily['date'])

# 筛选目标公司的数据
comp_data = daily[daily['company_id'] == company_id].copy()
if comp_data.empty:
    raise ValueError(f"公司代码 {company_id} 在数据中不存在，请检查 company_id 或数据内容。")
print(f"公司 {company_id} 共有 {len(comp_data)} 条日度记录。")

# 按日期排序
comp_data.sort_values('date', inplace=True)

# 准备结果列表
results = []

# 循环每个事件日期
for i, event_date_str in enumerate(event_dates, 1):
    event_date = pd.to_datetime(event_date_str)
    print(f"处理事件 {i}/{len(event_dates)}: {event_date.date()}")
    
    # 计算相对日期（天数差）
    comp_data['rel_date'] = (comp_data['date'] - event_date).dt.days
    
    # 标记估计窗口
    in_est = comp_data['rel_date'].between(est_start, est_end)
    est_data = comp_data[in_est].dropna(subset=['share_earn', 'market_earn'])
    
    # 检查估计窗口数据量是否足够（例如至少30个交易日）
    if len(est_data) < 30:
        print(f"  警告：估计窗口有效数据仅 {len(est_data)} 天，可能影响回归准确性。")
    
    # 市场模型回归： share_earn = alpha + beta * market_earn
    X = sm.add_constant(est_data['market_earn'])
    y = est_data['share_earn']
    model = sm.OLS(y, X).fit()
    
    # 计算各事件窗口的 CAR
    car_vals = {}
    for win_name, (start, end) in windows.items():
        in_win = comp_data['rel_date'].between(start, end)
        win_data = comp_data[in_win].copy()
        if win_data.empty:
            car_vals[win_name] = np.nan
            continue
        
        # 预测期望收益
       # 手动构造包含常数项和 market_earn 的 DataFrame
        X_win = pd.DataFrame({
            'const': 1,
            'market_earn': win_data['market_earn']
})
        win_data['expected'] = model.predict(X_win)
        win_data['ar'] = win_data['share_earn'] - win_data['expected']
        car_vals[win_name] = win_data['ar'].sum()
    
    # 保存该事件的结果
    results.append({
        'event_date': event_date,
        **car_vals
    })

# 将结果转换为 DataFrame
result_df = pd.DataFrame(results)
# 添加事件序号（可选）
result_df.insert(0, 'event_id', range(1, len(result_df)+1))

# 显示前几行
print("\n计算结果预览：")
print(result_df.head(10))

# 保存为 Excel 文件（也可保存为 CSV）
result_df.to_excel('car_results.xlsx', index=False)
print("\n结果已保存至 car_results.xlsx")
