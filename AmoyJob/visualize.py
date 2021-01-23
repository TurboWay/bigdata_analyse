#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# @Time : 2021/01/22 21:36
# @Author : way
# @Site : 
# @Describe: 数据可视化

import os
import pandas as pd
from pyecharts import options as opts
from pyecharts.charts import WordCloud, Map
from pyecharts.globals import SymbolType

# 福利词云
data = pd.read_csv('welfare.csv')

c = (
    WordCloud()
    .add("", data.values, word_size_range=[20, 100], shape=SymbolType.DIAMOND)
    .set_global_opts(title_opts=opts.TitleOpts())
    .render("wordcloud.html")
)
os.system("wordcloud.html")

# 岗位分布
data = pd.read_csv('workplace.csv')

c1 = (
    Map()
    .add("岗位数", data.values, "厦门")
    .set_global_opts(
        title_opts=opts.TitleOpts(title="厦门岗位分布图"),
        visualmap_opts=opts.VisualMapOpts(max_=20000, min_=5000)
    )
    .render("workplace.html")
)
os.system("workplace.html")
