#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# @Time : 2020/12/30 14:40
# @Author : way
# @Site : 
# @Describe:  数据处理

import os
import pandas as pd
import numpy as np
from sqlalchemy import create_engine

############################################# 合并数据文件 ##########################################################
# 只取用于分析的字段，因为字段数太多，去掉没用的字段可以极大的节省内存和提高效率
dir = r"C:\Users\Administrator\Desktop\AgeOfBarbarians"
data_list = []
for path in os.listdir(dir):
    path = os.path.join(dir, path)
    data = pd.read_csv(path)
    data = data[
        ['user_id', 'register_time', 'pvp_battle_count', 'pvp_lanch_count', 'pvp_win_count', 'pve_battle_count',
         'pve_lanch_count', 'pve_win_count', 'avg_online_minutes', 'pay_price', 'pay_count']
    ]
    data_list.append(data)
data = pd.concat(data_list)

############################################# 输出处理 ##########################################################
# 没有重复值
# print(data[data.duplicated()])

# 没有缺失值
# print(data.isnull().sum())

############################################# 数据保存 ##########################################################
# 保存清洗后的数据 mysql
engine = create_engine('mysql://root:root@172.16.122.25:3306/test?charset=utf8')
data.to_sql('age_of_barbarians', con=engine, index=False, if_exists='append')
