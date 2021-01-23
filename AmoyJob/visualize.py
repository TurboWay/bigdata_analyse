#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# @Time : 2021/01/22 21:36
# @Author : way
# @Site : 
# @Describe: 数据可视化

import os
import pandas as pd
from pyecharts import options as opts
from pyecharts.charts import WordCloud
from pyecharts.globals import SymbolType

data = pd.read_csv('welfare.csv')

words = data.values
c = (
    WordCloud()
    .add("", words, word_size_range=[20, 100], shape=SymbolType.DIAMOND)
    .set_global_opts(title_opts=opts.TitleOpts())
    .render("wordcloud.html")
)
os.system("wordcloud.html")