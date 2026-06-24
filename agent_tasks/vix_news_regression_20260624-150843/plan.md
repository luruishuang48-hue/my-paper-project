# Plan: 6.21事件集数据 VIX+新闻数量 全套回归

**任务时间**: 2026-06-24  
**数据源**: `data/relationships/6.21事件集数据.csv`  
**新变量**: VIX（宏观经济指标）、新闻数量（attention rate_X）

## 数据结构确认
- 5160 obs, 60 events, 112 cols  
- `VIX`: 全部非缺失（事件级别宏观变量）  
- `attention rate_1`: 3268 非缺失（发布前后各1天新闻数量）  
- `aa_intelligence_index`: 4042 非缺失  
- `relationship`: 字符串分类变量，需要构造二值dummy  

## 回归清单

### 主回归 (main_regression)
- 主预测变量: `aa_intelligence_index`
- 因变量: `car_1`, `car_20`
- 子样本: All / Open source / Closed source
- 控制变量: size, BM, volatility, momentum + **VIX** + **log(news+1)**
- SE: CR0 cluster by event

### 异质性分析 (heterogeneity)
- 关系分类子样本: competitor / downstream / upstream / owner+investor
- Mag7 vs non-Mag7
- 行业子样本

### 扩展分析 (extended)
- 时间趋势: intelligence × trend_month
- FF3 vs market model
- 中美模型比较
- Tier 1 子样本

### 媒体情绪 (media_sentiment)
- 媒体情绪作为调节变量: intelligence × sentiment
- 新闻数量作为调节变量: intelligence × news_count

## 输出文件
- `outputs/main_regression_results.csv`
- `outputs/heterogeneity_results.csv`
- `outputs/extended_results.csv`
- `outputs/vix_news_sensitivity.csv`
- `final_report.md`
