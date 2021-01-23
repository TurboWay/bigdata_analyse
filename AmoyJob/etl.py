#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# @Time : 2021/1/21 21:06
# @Author : way
# @Site : 
# @Describe: 数据处理

import re
import pandas as pd

path = 'job.csv'
data = pd.read_csv(path, header=None)
data.columns = [
    'position', 'num', 'company', 'job_type', 'jobage', 'lang', 'age', 'sex', 'education', 'workplace', 'worktime',
    'salary', 'welfare', 'hr', 'phone', 'address', 'company_type', 'industry', 'require'
]

############################################### 数据清洗 #############################################################
# 数据重复处理: 删除重复值
# print(data[data.duplicated()])
data.drop_duplicates(inplace=True)
data.reset_index(drop=True, inplace=True)

# 缺失值查看、处理：
data.isnull().sum()

# 招聘人数处理：缺失值填 1 ，一般是一人; 若干人当成 3人
data['num'].unique()
data['num'].fillna(1, inplace=True)
data['num'].replace('若干', 3, inplace=True)

# 年龄要求：缺失值填 无限；格式化
data['age'].unique()
data['age'].fillna('不限', inplace=True)
data['age'] = data['age'].apply(lambda x: x.replace('岁至', '-').replace('岁', ''))

# 语言要求: 忽视精通程度，格式化
data['lang'].unique()
data['lang'].fillna('不限', inplace=True)
data['lang'] = data['lang'].apply(lambda x: x.split('水平')[0] )
data['lang'].replace('其他', '不限', inplace=True)

# 月薪: 格式化。根据一般经验取低值，比如 5000-6000, 取 5000
data['salary'].unique()
data['salary'] = data['salary'].apply(lambda x: x.replace('参考月薪： ', '') if '参考月薪： ' in str(x) else x)
data['salary'] = data['salary'].apply(lambda x: x.split('-', 1)[0] if '-' in str(x) else x )
data['salary'].fillna('0', inplace=True)

# 其它岗位说明：缺失值填无
data.fillna('其他', inplace=True)

# 工作年限格式化
def jobage_clean(x):
    if x in ['应届生', '不限']:
        return x
    elif re.findall('\d+年', x):
        return re.findall('(\d+)年', x)[0]
    elif '年' in x:
        x = re.findall('\S{1,2}年', x)[0]
        x = re.sub('厂|验|年|，', '', x)
        digit_map = {
            '一': 1, '二': 2, '三': 3, '四': 4, '五': 5, '六': 6, '七': 7, '八': 8, '九': 9, '十':10,
            '十一': 11, '十二': 12, '十三': 13, '十四': 14, '十五': 15, '十六': 16, '两':2
        }
        return digit_map.get(x, x)
    return '其它工作经验'

data['jobage'].unique()
data['jobage'] = data['jobage'].apply(jobage_clean)

# 性别格式化
data['sex'].unique()
data['sex'].replace('无', '不限', inplace=True)

# 工作类型格式化
data['job_type'].unique()
data['job_type'].replace('毕业生见习', '实习', inplace=True)

# 学历格式化
data['education'].unique()
data['education'] = data['education'].apply(lambda x: x[:2])

# 公司类型 格式化
def company_type_clean(x):
    if len(x) > 100 or '其他' in x:
        return '其他'
    elif re.findall('私营|民营', x):
        return '民营/私营'
    elif re.findall('外资|外企代表处', x):
        return '外资'
    elif re.findall('合资', x):
        return '合资'
    return x

data['company_type'].unique()
data['company_type'] = data['company_type'].apply(company_type_clean)

# 行业 格式化。多个行业，取第一个并简单归类
def industry_clean(x):
    if len(x) > 100  or '其他' in x:
        return '其他'
    industry_map = {
        'IT互联网': '互联网|计算机|网络游戏', '房地产': '房地产', '电子技术': '电子技术', '建筑': '建筑|装潢',
        '教育培训': '教育|培训', '批发零售': '批发|零售', '金融': '金融|银行|保险', '住宿餐饮': '餐饮|酒店|食品',
        '农林牧渔': '农|林|牧|渔', '影视文娱': '影视|媒体|艺术|广告|公关|办公|娱乐', '医疗保健': '医疗|美容|制药',
        '物流运输': '物流|运输', '电信通信': '电信|通信', '生活服务': '人力|中介'
    }
    for industry, keyword in industry_map.items():
        if re.findall(keyword, x):
            return industry
    return x.split('、')[0].replace('/', '')

data['industry'].unique()
data['industry'] = data['industry'].apply(industry_clean)

# 工作时间格式化
data['worktime'].unique()
data['worktime_day'] = data['worktime'].apply(lambda x: x.split('小时')[0] if '小时' in x else 0)
data['worktime_week'] = data['worktime'].apply(lambda x: re.findall('\S*周', x)[0] if '周' in x else 0)

# 从工作要求中正则解析出：技能要求
data['skill'] = data['require'].apply(lambda x: '、'.join(re.findall('[a-zA-Z]+', x)))

################################################## 数据保存 #########################################################
# 查看保存的数据
print(data.info)

# 保存清洗后的数据 csv
data.to_csv('job_clean.csv', index=False, header=None, encoding='utf-8-sig')
