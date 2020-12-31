#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# @Time : 2020/12/30 15:46
# @Author : way
# @Site : 
# @Describe:

import os
import pandas as pd
from sqlalchemy import create_engine
from pyecharts import options as opts
from pyecharts.charts import Pie, Line, Bar, Liquid

engine = create_engine('mysql://root:root@172.16.122.25:3306/test?charset=utf8')

# PU 占比
sql = """
select sum(case when pay_price > 0 then 1 else 0 end) as `付费用户`,
       sum(case when pay_price > 0 then 0 else 1 end) as `非付费用户`
from age_of_barbarians
"""
data = pd.read_sql(con=engine, sql=sql)
c1 = (
    Pie()
    .add(
        "",
        [list(z) for z in zip(data.columns, data.values[0])],
    )
    .set_series_opts(label_opts=opts.LabelOpts(formatter="{b}: {c} 占比: {d}%"))
    .render("pie_pu.html")
)
os.system("pie_pu.html")

# DNU 柱形图
sql = """
select cast(register_time as date) as day,
       count(1) as dnu
from age_of_barbarians
group by cast(register_time as date)
order by day;
"""
data = pd.read_sql(con=engine, sql=sql)

c2 = (
    Bar()
    .add_xaxis(list(data['day']))
    .add_yaxis("新增用户数", list(data['dnu']))
    .set_global_opts(title_opts=opts.TitleOpts(title="每日新增用户数量"))
    .render("bar_dnu.html")
)
os.system("bar_dnu.html")

# 每小时注册情况
sql = """
select hour(cast(register_time as datetime)) as hour,
       count(1) as dnu
from age_of_barbarians
group by hour(cast(register_time as datetime))
order by hour;
"""
data = pd.read_sql(con=engine, sql=sql)
c3 = (
    Line()
    .add_xaxis(list(data['hour']))
    .add_yaxis("新增用户数", list(data['dnu']))
    .set_global_opts(title_opts=opts.TitleOpts(title="每小时新增用户数量"))
    .render("line_dnu.html")
)
os.system("line_dnu.html")

# 每小时注册情况
sql = """
select avg(avg_online_minutes) as `平均在线时长`,
       sum(case when pay_price > 0 then avg_online_minutes else 0 end) / sum(case when pay_price > 0 then 1 else 0 end) as `付费玩家在线时长`,
       sum(case when pay_price > 0 then 0 else avg_online_minutes end) / sum(case when pay_price > 0 then 0 else 1 end) as `非付费玩家在线时长`
from age_of_barbarians;
"""
data = pd.read_sql(con=engine, sql=sql)
c4 = (
    Bar()
    .add_xaxis(list(data.columns))
    .add_yaxis("平均在线时长(单位：分钟)", list(data.values[0]))
    .set_global_opts(title_opts=opts.TitleOpts(title="平均在线时长"))
    .render("bar_online.html")
)
os.system("bar_online.html")

# 付费比率
sql = """
select sum(case when avg_online_minutes > 0 and pay_price > 0 then 1 else 0 end) / sum(case when avg_online_minutes > 0 then 1 else 0 end) as `rate`
from age_of_barbarians;  
"""
data = pd.read_sql(con=engine, sql=sql)
c5 = (
    Liquid()
    .add("lq", [data['rate'][0], data['rate'][0]])
    .set_global_opts(title_opts=opts.TitleOpts(title="付费比率"))
    .render("liquid_base.html")
)
os.system("liquid_base.html")

# 用户游戏胜率
sql = """
select 'PVP' as `游戏类型`,
       sum(pvp_win_count) / sum(pvp_battle_count) as `平均胜率`,
       sum(case when pay_price > 0 then pvp_win_count else 0 end) / sum(case when pay_price > 0 then pvp_battle_count else 0 end) as `付费用户胜率`,
       sum(case when pay_price = 0 then pvp_win_count else 0 end) / sum(case when pay_price = 0 then pvp_battle_count else 0 end) as `非付费用户胜率`
from age_of_barbarians
union all
select 'PVE' as `游戏类型`,
       sum(pve_win_count) / sum(pve_battle_count) as `平均胜率`,
       sum(case when pay_price > 0 then pve_win_count else 0 end) / sum(case when pay_price > 0 then pve_battle_count else 0 end) as `付费用户胜率`,
       sum(case when pay_price = 0 then pve_win_count else 0 end) / sum(case when pay_price = 0 then pve_battle_count else 0 end) as `非付费用户胜率`
from age_of_barbarians
"""
data = pd.read_sql(con=engine, sql=sql)
c6 = (
    Bar()
    .add_dataset(
    source=[data.columns.tolist()] + data.values.tolist()
    )
    .add_yaxis(series_name="平均胜率", y_axis=[])
    .add_yaxis(series_name="付费用户胜率", y_axis=[])
    .add_yaxis(series_name="非付费用户胜率", y_axis=[])
    .set_global_opts(
        title_opts=opts.TitleOpts(title="游戏胜率"),
        xaxis_opts=opts.AxisOpts(type_="category"),
    )
    .render("dataset_bar_rate.html")
)
os.system("dataset_bar_rate.html")

# 用户游戏场次
sql = """
select 'PVP' as `游戏类型`,
       avg(pvp_battle_count) as `平均场次`,
       sum(case when pay_price > 0 then pvp_battle_count else 0 end) / sum(case when pay_price > 0 then 1 else 0 end) as `付费用户平均场次`,
       sum(case when pay_price = 0 then pvp_battle_count else 0 end) / sum(case when pay_price = 0 then 1 else 0 end) as `非付费用户平均场次`
from age_of_barbarians
union all 
select 'PVE' as `游戏类型`,
       avg(pve_battle_count) as `均场次`,
       sum(case when pay_price > 0 then pve_battle_count else 0 end) / sum(case when pay_price > 0 then 1 else 0 end) as `付费用户平均场次`,
       sum(case when pay_price = 0 then pve_battle_count else 0 end) / sum(case when pay_price = 0 then 1 else 0 end) as `非付费用户平均场次`
from age_of_barbarians
"""
data = pd.read_sql(con=engine, sql=sql)
c7 = (
    Bar()
    .add_dataset(
    source=[data.columns.tolist()] + data.values.tolist()
    )
    .add_yaxis(series_name="平均场次", y_axis=[])
    .add_yaxis(series_name="付费用户平均场次", y_axis=[])
    .add_yaxis(series_name="非付费用户平均场次", y_axis=[])
    .set_global_opts(
        title_opts=opts.TitleOpts(title="游戏场次"),
        xaxis_opts=opts.AxisOpts(type_="category"),
    )
    .render("dataset_bar_times.html")
)
os.system("dataset_bar_times.html")