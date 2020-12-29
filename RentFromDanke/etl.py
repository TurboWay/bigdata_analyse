#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# @Time : 2020/12/25 13:49
# @Author : way
# @Site : 
# @Describe: 数据处理

import re
import pandas as pd
import numpy as np
from sqlalchemy import create_engine

############################################# 合并数据文件 ##########################################################
dir = r"C:\Users\Administrator\Desktop\RentFromDanke"
data_list = []
for i in range(1, 9):
    path = f"{dir}\\bj_danke_{i}.csv"
    data = pd.read_csv(path)
    data_list.append(data)
data = pd.concat(data_list)

############################################### 数据清洗 #############################################################
#  数据重复处理: 删除重复值
# print(data[data.duplicated()])
data.drop_duplicates(inplace=True)
data.reset_index(drop=True, inplace=True)

# 缺失值处理：直接删除缺失值所在行，并重置索引
# print(data.isnull().sum())
data.dropna(axis=0, inplace=True)
data.reset_index(drop=True, inplace=True)

# 异常值清洗
data['户型'].unique()
# print(data[data['户型'] == '户型'])
data = data[data['户型'] != '户型']

# 清洗，列替换
data.loc[:, '地铁'] = data['地铁'].apply(lambda x: x.replace('地铁：', ''))

# 增加列
data.loc[:, '所在楼层'] = data['楼层'].apply(lambda x: int(x.split('/')[0]))
data.loc[:, '总楼层'] = data['楼层'].apply(lambda x: int(x.replace('层', '').split('/')[-1]))
data.loc[:, '地铁数'] = data['地铁'].apply(lambda x: len(re.findall('线', x)))
data.loc[:, '距离地铁距离'] = data['地铁'].apply(lambda x: int(re.findall('(\d+)米', x)[-1]) if re.findall('(\d+)米', x) else -1)

# 数据类型转换
data['价格'] = data['价格'].astype(np.int64)
data['面积'] = data['面积'].astype(np.int64)
data['距离地铁距离'] = data['距离地铁距离'].astype(np.int64)

################################################## 数据保存 #########################################################
# 查看保存的数据
print(data.info)

# 保存清洗后的数据 csv
# data.to_csv('D:/GitHub/bigdata_analyse/rent.csv', index=False)

# 保存清洗后的数据 sqlite
engine = create_engine('sqlite:///D:/GitHub/bigdata_analyse/rent.db')
data.to_sql('rent', con=engine, index=False, if_exists='append')
