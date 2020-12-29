#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# @Time : 2020/12/29 13:36
# @Author : way
# @Site : 
# @Describe: 数据可视化

# 解决中文字体问题
import matplotlib as mpl

mpl.rcParams['font.sans-serif'] = ['KaiTi']
mpl.rcParams['font.serif'] = ['KaiTi']

import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
from sqlalchemy import create_engine

engine = create_engine('sqlite:///D:/GitHub/bigdata_analyse/rent.db')

# 地区-房源
sql = """
select 位置1, count(1) as total, count(distinct 小区) as com, sum(价格)/sum(面积) as per
from rent
group by 位置1
"""
data = pd.read_sql(con=engine, sql=sql)
data = data.sort_values(by='total', ascending=False)
plt.bar(data['位置1'], data['total'], label='房源数量')
for x, y in zip(data['位置1'], data['total']):
    plt.text(x, y, y, ha='center', va='bottom', fontsize=11)
plt.legend()
plt.show()

# 小区-租金/平米
sql = """
select 小区, 位置1, count(1) as total, sum(价格)/sum(面积) as per
from rent
group by 小区, 位置1
order by per desc
limit 10
"""
data = pd.read_sql(con=engine, sql=sql)
data = data.sort_values(by='per')
plt.barh(data['小区'], data['per'], label='租金(元/平米)', color='g')
for x, y in zip(data['小区'], data['per']):
    plt.text(y, x, y, ha='left', va='center', fontsize=11)
plt.legend()
plt.show()

# 户型-房源数量
sql = """
select substr(户型, 0, 3) as 户型, count(1) as total, sum(价格)/sum(面积) as per
from rent
group by substr(户型, 0, 3)
order by 1
"""
data = pd.read_sql(con=engine, sql=sql)
plt.bar(data['户型'], data['total'], label='房源数量')
for x, y in zip(data['户型'], data['total']):
    plt.text(x, y, y, ha='center', va='bottom', fontsize=11)
plt.legend()
plt.show()

# 电梯房-房源数量
sql = """
select case when 总楼层 > 7 then '电梯房' else '非电梯房' end as tp, count(1) as total, sum(价格)/sum(面积) as per
from rent
group by case when 总楼层 > 7 then '电梯房' else '非电梯房' end
order by total desc
"""
data = pd.read_sql(con=engine, sql=sql)
plt.pie(data['total'],
        labels=data['tp'],
        colors=['m','g'],
        startangle=90,
        shadow= True,
        explode=(0,0.1),
        autopct='%1.1f%%')
plt.title('房源数量占比')
plt.show()

plt.bar(data['tp'], data['per'], label='租金(元/平米)')
for x, y in zip(data['tp'], data['per']):
    plt.text(x, y, y, ha='center', va='bottom', fontsize=11)
plt.legend()
plt.show()

# 电梯楼层-价格
sql = """
select case when 总楼层 > 7 then '电梯房'
            else '非电梯房' end as tp1,
       case when 1.0 * 所在楼层/总楼层 > 0.66 then '高层'
            when 1.0 * 所在楼层/总楼层 > 0.33 then '中层'
            else '低层' end as tp2,
       count(1) as total, sum(价格)/sum(面积) as per
from rent
group by case when 总楼层 > 7 then '电梯房'
              else '非电梯房' end,
         case when 1.0 * 所在楼层/总楼层 > 0.66 then '高层'
              when 1.0 * 所在楼层/总楼层 > 0.33 then '中层'
              else '低层' end
order by 1, 2  desc
"""
data = pd.read_sql(con=engine, sql=sql)
data['floor'] = data['tp1'] + '(' + data['tp2'] + ')'
plt.plot(data['floor'], data['total'], label='房源数量')
for x, y in zip(data['floor'], data['total']):
    plt.text(x, y, y, ha='center', va='bottom', fontsize=11)
plt.plot(data['floor'], data['per'], label='租金(元/平米)')
for x, y in zip(data['floor'], data['per']):
    plt.text(x, y, y, ha='center', va='bottom', fontsize=11)
plt.legend()
plt.show()

# 地铁数-租金
sql = """
select 地铁数, count(1) as total, sum(价格)/sum(面积) as per
from rent
group by 地铁数
order by 1
"""
data = pd.read_sql(con=engine, sql=sql)
data['地铁数'] = data['地铁数'].astype(np.str)
plt.plot(data['地铁数'], data['per'], label='租金(元/平米)')
for x, y in zip(data['地铁数'], data['per']):
    plt.text(x, y, y, ha='center', va='bottom', fontsize=11)
plt.legend()
plt.xlabel('地铁数')
plt.show()

# 地铁距离-租金
sql = """
select case when 距离地铁距离 between 0 and 500 then '500米以内'
			when 距离地铁距离 between 501 and 1000 then '1公里以内'
			when 距离地铁距离 between 1001 and 1500 then '1.5公里以内'
			else '1.5公里以外' end as ds,
      count(1) as total, sum(价格)/sum(面积) as per
from rent
group by case when 距离地铁距离 between 0 and 500 then '500米以内'
			  when 距离地铁距离 between 501 and 1000 then '1公里以内'
			  when 距离地铁距离 between 1001 and 1500 then '1.5公里以内'
        else '1.5公里以外' end
order by 1
"""
data = pd.read_sql(con=engine, sql=sql)
map_dt = {
    '1.5公里以外': 4,
    '1.5公里以内': 3,
    '1公里以内': 2,
    '500米以内': 1
}
data['st'] = data['ds'].apply(lambda x: map_dt[x])
data.sort_values(by='st', inplace=True)
plt.plot(data['ds'], data['per'], label='租金(元/平米)')
for x, y in zip(data['ds'], data['per']):
    plt.text(x, y, y, ha='center', va='bottom', fontsize=11)
plt.legend()
plt.xlabel('距离地铁距离')
plt.show()
