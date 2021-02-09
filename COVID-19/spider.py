#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# @Time : 2021/2/9 11:06
# @Author : way
# @Site : 
# @Describe:

import requests


# 重试装饰器
def retry(func):
    max_retry = 5

    def run(*args, **kwargs):
        for i in range(max_retry + 1):
            if func(*args, **kwargs):
                break
            else:
                print("retrying...")
        else:
            print("update fail !!!")

    return run


@retry
def download(file):
    try:
        url_head = 'https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/csse_covid_19_time_series/'
        with open(file, 'w', encoding='utf-8-sig') as f:
            url = url_head + file
            f.write(requests.get(url).text)
        print(f'{file} has been updated success')
        return True
    except:
        return False


if __name__ == "__main__":
    files = [
        'time_series_covid19_confirmed_global.csv',
        'time_series_covid19_deaths_global.csv',
        'time_series_covid19_recovered_global.csv'
    ]
    for file in files:
        download(file)
