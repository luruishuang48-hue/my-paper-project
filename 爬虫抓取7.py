
"""
大语言模型新闻收集器 - GDELT API修复版
版本: 3.1
功能: 修复查询语法错误和参数问题
"""

import pandas as pd
import requests
import time
from datetime import datetime, timedelta
import os
import re
from tqdm import tqdm
import warnings
import json
import urllib.parse
warnings.filterwarnings('ignore')

# ==================== 配置区域 ====================
LLM_EVENTS = [
    {
        "id": 1,
        "name": "Codex",
        "date": "2025-5-16",
        "company": "OpenAI",
        "keywords": ["Codex","OpenAI Codex"],
        "window_days": 7,
        "max_articles": 100
    },
    {
        "id": 2,
        "name": "ChatGPT Agent",
        "date": "2025-7-18",
        "company": "OpenAI",
        "keywords": ["ChatGPT Agent","OpenAI ChatGPT Agent"],
        "window_days": 7,
        "max_articles": 100
    },
    {
        "id": 3,
        "name": "Kimi K2",
        "date": "2025-7-11",
        "company": "Moonshot AI",
        "keywords": ["Kimi K2","KimiK2", "Moonshot AI Kimi K2", "月之暗面 Kimi K2"],
        "window_days": 7,
        "max_articles": 100
    },
    {
        "id": 4,
        "name": "gpt-oss-120b",
        "date": "2025-8-6",
        "company": "OpenAI",
        "keywords": ["gpt-oss-120b", "gpt oss 120b" "OpenAIgpt-oss-120b"],
        "window_days": 7,
        "max_articles": 100
    },
    {
        "id": 5,
        "name": "GPT-5_Release",
        "date": "2025-8-7",
        "company": "OpenAI",
        "keywords": ["GPT-5", "GPT 5", "GPT", "OpenAI GPT-5 "],
        "window_days": 7,
        "max_articles": 100
    },
]

OUTPUT_DIR = "llm_news_data"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# ==================== 修复的核心函数 ====================

def get_gdelt_date_range(date_str, window_days):
    """获取GDELT格式的时间范围"""
    event_date = datetime.strptime(date_str, '%Y-%m-%d')
    start_date = event_date - timedelta(days=window_days)
    end_date = event_date + timedelta(days=window_days)
    
    return {
        'start': start_date.strftime('%Y%m%d%H%M%S'),
        'end': end_date.strftime('%Y%m%d%H%M%S')
    }

def build_simple_gdelt_queries(event):
    """构建简单的GDELT查询（避免括号问题）"""
    queries = []
    
    # 方法1: 基本关键词
    for keyword in event['keywords']:
        # 移除可能引起问题的特殊字符
        clean_keyword = keyword.replace('(', '').replace(')', '')
        queries.append(f'"{clean_keyword}"')
    
    # 方法2: 公司+关键词
    company = event['company'].split('/')[0]
    for keyword in event['keywords'][:2]:
        clean_keyword = keyword.replace('(', '').replace(')', '')
        queries.append(f'{company} "{clean_keyword}"')
    
    # 方法3: 简单搜索
    main_keyword = event['keywords'][0].replace('(', '').replace(')', '')
    queries.append(f'{main_keyword} AI model')
    queries.append(f'{main_keyword} release')
    
    return queries

def fetch_gdelt_simple(event, use_real_api=True):
    """使用简单查询的GDELT抓取"""
    
    if not use_real_api:
        return create_sample_news(event)
    
    date_range = get_gdelt_date_range(event['date'], event['window_days'])
    all_articles = []
    
    print(f"  正在从GDELT抓取数据 ({event['name']})...")
    
    # 获取查询列表
    queries = build_simple_gdelt_queries(event)
    
    for query in queries[:3]:  # 尝试前3个查询
        try:
            print(f"  查询: {query[:50]}...")
            
            # 修复的API参数
            url = "https://api.gdeltproject.org/api/v2/doc/doc"
            params = {
                "query": query,
                "mode": "artlist",  # 修正: artlist 不是 artist
                "format": "json",
                "maxrecords": min(50, event['max_articles']),  # 降低数量避免限制
                "startdatetime": date_range['start'],
                "enddatetime": date_range['end'],  # 修正: enddatetime 不是 enddate
                "sort": "date",
                "sortorder": "desc"  # 修正: sortorder 不是 sorter
            }
            
            response = requests.get(url, params=params, timeout=30)
            
            if response.status_code == 200:
                try:
                    data = response.json()
                    
                    # 处理返回数据
                    articles = []
                    if isinstance(data, dict) and 'articles' in data:
                        articles = data['articles']
                    elif isinstance(data, list):
                        articles = data
                    
                    print(f"    找到 {len(articles)} 篇文章")
                    
                    for article in articles:
                        try:
                            # 基本字段提取
                            title = article.get('title', '') or article.get('snippet', '')[:100]
                            content = article.get('snippet', '') or article.get('content', '') or ''
                            
                            # 如果内容太短，使用标题
                            if len(content) < 50 and title:
                                content = title
                            
                            article_data = {
                                'event_id': event['id'],
                                'event_name': event['name'],
                                'event_date': event['date'],
                                'company': event['company'],
                                'published_at': article.get('seendate', event['date']),
                                'title': str(title).strip(),
                                'url': article.get('url', ''),
                                'source': article.get('domain', 'Unknown'),
                                'language': article.get('language', 'en'),
                                'content': str(content).strip(),
                                'keyword': query,
                                'source_api': 'gdelt',
                                'gdelt_tone': float(article.get('tone', 0)) if article.get('tone') else 0,
                                'url_image': article.get('urlimage', ''),
                                'char_count': len(str(content))
                            }
                            
                            # 验证基本内容
                            if article_data['content'] and len(article_data['content']) > 20:
                                all_articles.append(article_data)
                                
                        except Exception as e:
                            continue
                    
                except json.JSONDecodeError:
                    # 尝试文本解析
                    text = response.text
                    print(f"    JSON解析失败，响应长度: {len(text)}")
                    
            elif response.status_code == 429:
                print(f"    请求过于频繁，等待10秒...")
                time.sleep(10)
                # 重试一次
                response = requests.get(url, params=params, timeout=30)
                if response.status_code == 200:
                    try:
                        data = response.json()
                        # 处理数据...
                    except:
                        pass
            else:
                print(f"    API请求失败 (状态码: {response.status_code})")
            
            # 重要：遵守API限制，每次请求后等待
            time.sleep(6)  # 避免429错误
            
        except requests.exceptions.Timeout:
            print(f"    请求超时，跳过")
            continue
        except Exception as e:
            print(f"    查询出错: {str(e)[:100]}")
            continue
    
    return pd.DataFrame(all_articles)

def fetch_gdelt_backup(event):
    """备用方法：使用更保守的查询"""
    date_range = get_gdelt_date_range(event['date'], event['window_days'])
    all_articles = []
    
    print("  尝试备用查询...")
    
    # 非常简单的查询
    simple_queries = [
        event['keywords'][0],  # 只用第一个关键词
        f"{event['company']} AI",
        "artificial intelligence model"
    ]
    
    for query in simple_queries:
        try:
            url = "https://api.gdeltproject.org/api/v2/doc/doc"
            params = {
                "query": query,
                "mode": "artlist",
                "format": "json",
                "maxrecords": 20,  # 更少的记录
                "startdatetime": date_range['start'],
                "enddatetime": date_range['end']
            }
            
            response = requests.get(url, params=params, timeout=30)
            
            if response.status_code == 200:
                try:
                    data = response.json()
                    
                    articles = []
                    if isinstance(data, dict) and 'articles' in data:
                        articles = data['articles']
                    elif isinstance(data, list):
                        articles = data
                    
                    for article in articles:
                        # 手动检查相关性
                        title = article.get('title', '').lower()
                        content = (article.get('snippet', '') or '').lower()
                        
                        # 检查是否包含任何关键词
                        relevant = False
                        for keyword in event['keywords']:
                            if keyword.lower() in title or keyword.lower() in content:
                                relevant = True
                                break
                        
                        if relevant:
                            article_data = {
                                'event_id': event['id'],
                                'event_name': event['name'],
                                'event_date': event['date'],
                                'company': event['company'],
                                'published_at': article.get('seendate', event['date']),
                                'title': article.get('title', ''),
                                'url': article.get('url', ''),
                                'source': article.get('domain', 'Unknown'),
                                'content': article.get('snippet', '') or '',
                                'keyword': query,
                                'char_count': len(article.get('snippet', '') or '')
                            }
                            all_articles.append(article_data)
                
                except:
                    pass
            
            time.sleep(5)  # 更长的延迟
            
        except Exception as e:
            continue
    
    return pd.DataFrame(all_articles)

def test_gdelt_api():
    """测试GDELT API连接和查询"""
    print("测试GDELT API连接...")
    
    test_queries = [
        "GPT-4",
        "Llama 2",
        "Claude 2"
    ]
    
    for query in test_queries:
        try:
            url = "https://api.gdeltproject.org/api/v2/doc/doc"
            params = {
                "query": f'"{query}"',
                "mode": "artlist",
                "format": "json",
                "maxrecords": 5,
                "startdatetime": "20230701000000",
                "enddatetime": "20230731000000"
            }
            
            print(f"测试查询: {query}")
            response = requests.get(url, params=params, timeout=30)
            
            print(f"  状态码: {response.status_code}")
            
            if response.status_code == 200:
                try:
                    data = response.json()
                    if isinstance(data, dict) and 'articles' in data:
                        print(f"  找到文章: {len(data['articles'])} 篇")
                    elif isinstance(data, list):
                        print(f"  找到文章: {len(data)} 篇")
                    else:
                        print(f"  响应格式: {type(data)}")
                except json.JSONDecodeError:
                    print(f"  JSON解析失败，响应: {response.text[:200]}")
            else:
                print(f"  错误: {response.text[:200]}")
            
            time.sleep(5)
            
        except Exception as e:
            print(f"  异常: {e}")
    
    print("测试完成")

def clean_articles(df):
    """清洗文章数据"""
    if df.empty:
        return df
    
    df_clean = df.copy()
    
    # 去重
    df_clean = df_clean.drop_duplicates(subset=['title', 'url'], keep='first')
    
    # 过滤空内容
    df_clean['content'] = df_clean['content'].fillna('')
    df_clean = df_clean[df_clean['content'].str.len() > 20]
    
    # 清理文本
    df_clean['title'] = df_clean['title'].apply(lambda x: re.sub(r'\s+', ' ', str(x)).strip())
    df_clean['content'] = df_clean['content'].apply(lambda x: re.sub(r'\s+', ' ', str(x)).strip())
    
    return df_clean

def create_sample_news(event):
    """创建示例新闻数据"""
    import random
    
    sources = ['Reuters', 'TechCrunch', 'Bloomberg', 'The Verge', 'CNBC', 'BBC']
    adjectives = ['revolutionary', 'groundbreaking', 'innovative', 'advanced', 'cutting-edge']
    
    articles = []
    event_date = datetime.strptime(event['date'], '%Y-%m-%d')
    
    for i in range(5):
        # 随机发布日期（事件前后3天）
        days_offset = random.randint(-5, 5)
        pub_date = event_date + timedelta(days=days_offset)
        
        title = f"{event['company']} releases {event['name'].split('_')[0]}, a {random.choice(adjectives)} AI model"
        content = f"{event['company']} has announced the release of {event['name'].split('_')[0]}, marking a significant advancement in artificial intelligence technology."
        
        articles.append({
            'event_id': event['id'],
            'event_name': event['name'],
            'event_date': event['date'],
            'company': event['company'],
            'published_at': pub_date.strftime('%Y-%m-%d'),
            'title': title,
            'url': f"https://example.com/{event['name'].lower()}/{i}",
            'source': random.choice(sources),
            'content': content,
            'keyword': event['keywords'][0],
            'char_count': len(content)
        })
    
    return pd.DataFrame(articles)

def collect_events(events_list, use_real_api=True):
    """收集所有事件的新闻"""
    
    print("=" * 70)
    print("大语言模型新闻收集系统")
    print(f"模式: {'真实API' if use_real_api else '示例数据'}")
    print("=" * 70)
    
    all_data = []
    stats = []
    
    for event in tqdm(events_list, desc="处理进度"):
        print(f"\n[{event['id']}/{len(events_list)}] {event['name']}")
        print(f"  日期: {event['date']}, 公司: {event['company']}")
        
        if use_real_api:
            # 主方法
            df = fetch_gdelt_simple(event, use_real_api=True)
            
            # 如果主方法失败，尝试备用方法
            if df.empty:
                print("  主方法无结果，尝试备用方法...")
                df = fetch_gdelt_backup(event)
        else:
            df = create_sample_news(event)
        
        if not df.empty:
            df = clean_articles(df)
            
            # 计算距离事件的天数
            try:
                df['published_date'] = pd.to_datetime(df['published_at'], errors='coerce')
                event_date = pd.to_datetime(event['date'])
                df['days_from_event'] = (df['published_date'] - event_date).dt.days
            except:
                df['days_from_event'] = 0
            
            all_data.append(df)
            
            stats.append({
                'event': event['name'],
                'articles': len(df),
                'sources': df['source'].nunique()
            })
            
            print(f"  ✓ 获取 {len(df)} 篇文章")
            
            # 保存单个事件数据
            event_file = os.path.join(OUTPUT_DIR, f"{event['name']}.csv")
            df.to_csv(event_file, index=False, encoding='utf-8')
        else:
            print(f"  ✗ 未获取到文章")
            stats.append({
                'event': event['name'],
                'articles': 0,
                'sources': 0
            })
        
        # 事件间延迟
        if use_real_api and event['id'] < len(events_list):
            print(f"  等待8秒继续...")
            time.sleep(8)
    
    # 合并数据
    if all_data:
        final_df = pd.concat(all_data, ignore_index=True)
        
        # 保存最终数据
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        mode = "real" if use_real_api else "sample"
        
        csv_file = os.path.join(OUTPUT_DIR, f"llm_news_{mode}_{timestamp}.csv")
        final_df.to_csv(csv_file, index=False, encoding='utf-8')
        
        # 保存统计
        stats_df = pd.DataFrame(stats)
        stats_file = os.path.join(OUTPUT_DIR, f"stats_{timestamp}.csv")
        stats_df.to_csv(stats_file, index=False)
        
        print("\n" + "=" * 70)
        print("收集完成!")
        print("=" * 70)
        print(f"\n汇总:")
        print(f"  总文章数: {len(final_df)}")
        print(f"  事件数: {len(events_list)}")
        print(f"  平均每事件: {len(final_df)/len(events_list):.1f} 篇文章")
        
        # 显示每个事件的结果
        print("\n各事件统计:")
        for stat in stats:
            print(f"  {stat['event']}: {stat['articles']} 篇文章")
        
        print(f"\n数据已保存到: {csv_file}")
        
        return final_df, stats_df
    else:
        print("\n未收集到任何数据")
        return pd.DataFrame(), pd.DataFrame()

def main():
    """主函数"""
    
    print("大语言模型新闻收集器 v3.1")
    print("-" * 60)
    
    print("\n选项:")
    print("1. 测试GDELT API连接")
    print("2. 真实API抓取")
    print("3. 使用示例数据")
    print("4. 查看事件配置")
    
    try:
        choice = input("\n请选择 (1-4): ").strip()
    except:
        choice = "3"
    
    if choice == "1":
        test_gdelt_api()
        return
    elif choice == "4":
        print(f"\n配置了 {len(LLM_EVENTS)} 个事件:")
        for event in LLM_EVENTS:
            print(f"  {event['id']}. {event['name']} ({event['date']})")
            print(f"      公司: {event['company']}")
            print(f"      关键词: {', '.join(event['keywords'])}")
        return
    
    use_real_api = (choice == "2")
    
    if use_real_api:
        print("\n⚠ 注意:")
        print("1. 需要稳定的网络连接")
        print("2. GDELT API有请求限制")
        print("3. 每个请求后会有延迟")
        confirm = input("\n继续? (y/n): ").lower()
        if confirm != 'y':
            use_real_api = False
            print("切换到示例数据模式")
    
    try:
        data, stats = collect_events(LLM_EVENTS, use_real_api=use_real_api)
        
        if not data.empty:
            print("\n后续步骤建议:")
            print("1. 检查收集的数据文件")
            print("2. 进行情感分析")
            print("3. 分析不同事件的媒体关注度")
    
    except Exception as e:
        print(f"\n错误: {e}")
        import traceback
        traceback.print_exc()
    
    input("\n按回车键退出...")

if __name__ == "__main__":
    main()


