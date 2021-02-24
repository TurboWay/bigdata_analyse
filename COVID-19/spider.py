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
def download(url):
    try:
        file = url.split('/')[-1]
        with open(file, 'w', encoding='utf-8-sig') as f:
            f.write(requests.get(url).text)
        print(f'{file} has been updated success')
        return True
    except Exception as e:
        print(e)
        return False


if __name__ == "__main__":
    urls = [
        'https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv',
        'https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv',
        'https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv'
    ]
    for url in urls:
        download(url)
