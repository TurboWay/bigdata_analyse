#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# @Time : 2021/1/8 20:03
# @Author : way
# @Site : 
# @Describe: 数据处理 https://opendata.sz.gov.cn/data/dataSet/toDataDetails/29200_00403601

import json
import pandas as pd

############################################# 解析 json 数据文件 ##########################################################
path = r"C:\Users\Administrator\Desktop\2018record3.jsons"
data = []
with open(path, 'r', encoding='utf-8') as f:
    for line in f.readlines():
        data += json.loads(line)['data']
data = pd.DataFrame(data)
columns = ['card_no', 'deal_date', 'deal_type', 'deal_money', 'deal_value', 'equ_no', 'company_name', 'station', 'car_no', 'conn_mark', 'close_date']
data = data[columns]  # 调整字段顺序
data.info()

############################################# 输出处理 ##########################################################
# 全部都是 交通运输 的刷卡数据
print(data['company_name'].unique())

# 删除重复值
# print(data[data.duplicated()])
data.drop_duplicates(inplace=True)
data.reset_index(drop=True, inplace=True)

# 缺失值
# 只有线路站点和车牌号两个字段存在为空，不做处理
# print(data.isnull().sum())

# 去掉脏数据
data = data[data['deal_date'] > '2018-08-31']
############################################# 数据保存 ##########################################################
print(data.info)

# 数据保存为 csv
data.to_csv('SZTcard.csv', index=False, header=None)
