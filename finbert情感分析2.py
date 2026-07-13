"""
FinBERT 情感分析 - 完整运行版（本地模型版，修复时区错误）
模型路径: D:\python314\model
"""

import pandas as pd
import numpy as np
import os
import re
from datetime import datetime
import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification
from torch.utils.data import DataLoader, TensorDataset
import warnings
warnings.filterwarnings('ignore')

# ==================== 配置 ====================
MODEL_DIR = "D:/python314/model"
DEVICE = "cuda" if torch.cuda.is_available() else "cpu"
BATCH_SIZE = 32

TEXT_COLUMN = "content"
FALLBACK_TEXT_COL = "title"

EVENT_NAME_COL = "event_name"
EVENT_ID_COL = "event_id"
EVENT_DATE_COL = "event_date"
PUBLISHED_COL = "published_at"

OUTPUT_DIR = "sentiment_results"
os.makedirs(OUTPUT_DIR, exist_ok=True)

WINDOWS = [(-2,-10),(1,1), (2,2), (3,3), (5,5), (10,10), (15,15), (20,20)]

# ==================== 加载本地模型 ====================
print("="*60)
print("正在加载本地 FinBERT 模型...")
print(f"模型路径: {MODEL_DIR}")
print(f"使用设备: {DEVICE}")

try:
    tokenizer = AutoTokenizer.from_pretrained(MODEL_DIR)
    model = AutoModelForSequenceClassification.from_pretrained(MODEL_DIR)
    model.to(DEVICE)
    model.eval()
    print("✅ 模型加载成功！")
except Exception as e:
    print(f"❌ 模型加载失败: {e}")
    print("请检查文件夹 D:/python314/model 是否包含所需文件")
    raise

# ==================== 情感分析函数 ====================
def analyze_sentiment_batch(df, text_column):
    texts = df[text_column].astype(str).tolist()
    encodings = tokenizer(texts, truncation=True, padding=True, max_length=512, return_tensors="pt")
    dataset = TensorDataset(encodings['input_ids'], encodings['attention_mask'])
    loader = DataLoader(dataset, batch_size=BATCH_SIZE)
    
    sentiments = []
    with torch.no_grad():
        for input_ids, attention_mask in loader:
            input_ids = input_ids.to(DEVICE)
            attention_mask = attention_mask.to(DEVICE)
            outputs = model(input_ids, attention_mask=attention_mask)
            probs = torch.softmax(outputs.logits, dim=-1).cpu().numpy()
            pos_prob = probs[:, 0]
            neg_prob = probs[:, 1]
            scores = pos_prob - neg_prob
            for i, score in enumerate(scores):
                sentiments.append({
                    'sentiment_score': float(score),
                    'sentiment_positive': float(pos_prob[i]),
                    'sentiment_negative': float(neg_prob[i]),
                    'sentiment_neutral': float(probs[i, 2]),
                    'sentiment_label': 'positive' if score >= 0.05 else 'negative' if score <= -0.05 else 'neutral'
                })
    return pd.concat([df, pd.DataFrame(sentiments)], axis=1)

def clean_text(series):
    series = series.fillna('').astype(str)
    series = series.str.replace(r'http\S+|www\S+', '', regex=True)
    series = series.str.replace(r'[^\w\s.,!?;:\'"-]', ' ', regex=True)
    series = series.str.replace(r'\s+', ' ', regex=True).str.strip()
    return series

def compute_days_offset(df):
    """修复时区不一致问题：统一转换为 UTC"""
    if EVENT_DATE_COL in df.columns and PUBLISHED_COL in df.columns:
        df[EVENT_DATE_COL] = pd.to_datetime(df[EVENT_DATE_COL], errors='coerce', utc=True)
        df[PUBLISHED_COL] = pd.to_datetime(df[PUBLISHED_COL], errors='coerce', utc=True)
        df['days_from_event'] = (df[PUBLISHED_COL] - df[EVENT_DATE_COL]).dt.days
        return df
    else:
        print("⚠️ 未找到 event_date 或 published_at 列，跳过窗口聚合步骤")
        return df

def aggregate_by_window(df):
    if 'days_from_event' not in df.columns:
        return pd.DataFrame()
    if EVENT_NAME_COL not in df.columns and EVENT_ID_COL not in df.columns:
        print("⚠️ 缺少事件标识列，无法按窗口聚合")
        return pd.DataFrame()
    
    group_cols = []
    if EVENT_ID_COL in df.columns:
        group_cols.append(EVENT_ID_COL)
    if EVENT_NAME_COL in df.columns:
        group_cols.append(EVENT_NAME_COL)
    
    results = []
    for name, group in df.groupby(group_cols):
        for left, right in WINDOWS:
            window_size = right
            mask = (group['days_from_event'] >= -window_size) & (group['days_from_event'] <= window_size)
            window_df = group[mask]
            if len(window_df) == 0:
                continue
            scores = window_df['sentiment_score']
            labels = window_df['sentiment_label']
            row = {
                'window_days': window_size,
                'window_range': f"[-{window_size},+{window_size}]",
                'article_count': len(window_df),
                'sentiment_mean': scores.mean(),
                'sentiment_std': scores.std(),
                'positive_pct': (labels == 'positive').mean() * 100,
                'negative_pct': (labels == 'negative').mean() * 100,
                'neutral_pct': (labels == 'neutral').mean() * 100,
            }
            if EVENT_ID_COL in df.columns:
                row['event_id'] = name[0] if isinstance(name, tuple) else name
            if EVENT_NAME_COL in df.columns:
                row['event_name'] = name[1] if isinstance(name, tuple) else name
            results.append(row)
    return pd.DataFrame(results)

# ==================== 主程序 ====================
def main():
    print("\n请选择要分析的 CSV 文件")
    try:
        import tkinter as tk
        from tkinter import filedialog
        root = tk.Tk()
        root.withdraw()
        filepath = filedialog.askopenfilename(title="选择新闻数据 CSV 文件", filetypes=[("CSV files", "*.csv")])
        root.destroy()
    except:
        filepath = input("请输入 CSV 文件路径: ").strip()
    
    if not filepath or not os.path.exists(filepath):
        print("文件不存在，程序退出。")
        return
    
    print(f"\n读取文件: {filepath}")
    try:
        df = pd.read_csv(filepath, encoding='utf-8')
    except UnicodeDecodeError:
        df = pd.read_csv(filepath, encoding='latin1')
    print(f"原始数据: {len(df)} 行")
    
    # 确定文本列
    if TEXT_COLUMN in df.columns:
        text_col = TEXT_COLUMN
    elif FALLBACK_TEXT_COL in df.columns:
        text_col = FALLBACK_TEXT_COL
        print(f"未找到 {TEXT_COLUMN} 列，使用 {text_col} 作为文本列")
    else:
        print(f"错误：文件中既没有 {TEXT_COLUMN} 列也没有 {FALLBACK_TEXT_COL} 列")
        return
    
    print("清洗文本...")
    df['cleaned_text'] = clean_text(df[text_col])
    before_len = len(df)
    df = df[df['cleaned_text'].str.len() > 30]
    print(f"有效文本数: {len(df)} (过滤掉 {before_len - len(df)} 条短文本)")
    
    if len(df) == 0:
        print("无有效文本，退出")
        return
    
    print("执行 FinBERT 情感分析...")
    df = analyze_sentiment_batch(df, 'cleaned_text')
    
    print("计算日期偏移...")
    df = compute_days_offset(df)
    
    base_name = os.path.splitext(os.path.basename(filepath))[0]
    detail_path = os.path.join(OUTPUT_DIR, f"{base_name}_detailed.csv")
    df.to_csv(detail_path, index=False, encoding='utf-8-sig')
    print(f"✅ 详细结果已保存: {detail_path}")
    
    if 'days_from_event' in df.columns and (EVENT_NAME_COL in df.columns or EVENT_ID_COL in df.columns):
        panel = aggregate_by_window(df)
        if not panel.empty:
            panel_path = os.path.join(OUTPUT_DIR, f"{base_name}_window_sentiment.csv")
            panel.to_csv(panel_path, index=False, encoding='utf-8-sig')
            print(f"✅ 多窗口聚合结果已保存: {panel_path}")
            print("\n前10行预览:")
            print(panel.head(10))
    
    print("\n" + "="*50)
    print("情感分析完成！整体统计:")
    print(f"  平均情感得分: {df['sentiment_score'].mean():.4f}")
    print(f"  正面比例: {(df['sentiment_label']=='positive').mean()*100:.1f}%")
    print(f"  负面比例: {(df['sentiment_label']=='negative').mean()*100:.1f}%")
    print(f"  中性比例: {(df['sentiment_label']=='neutral').mean()*100:.1f}%")
    print("="*50)

if __name__ == "__main__":
    main()
