#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# @Time : 2020/5/27 14:24
# @Author : way
# @Site : 
# @Describe:

import sys
import time
import json
import queue
from kafka import KafkaProducer
from concurrent.futures import ThreadPoolExecutor

servers = ['172.16.122.17:9092', ]
topic = 'user_behavior'
path = 'user_behavior.log'

producer = KafkaProducer(bootstrap_servers=servers, value_serializer=lambda m: json.dumps(m).encode('utf-8'))


def send(line):
    cols = line.strip('\n').split(',')
    ts = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.localtime(int(cols[4])))
    value = {"user_id": cols[0], "item_id": cols[1], "category_id": cols[2], "behavior": cols[3], "ts": ts}
    producer.send(topic=topic, value=value).get(timeout=10)


if __name__ == "__main__":
    num = 2000

    if len(sys.argv) > 1:
        num = int(sys.argv[1])


    class BoundThreadPoolExecutor(ThreadPoolExecutor):

        def __init__(self, *args, **kwargs):
            super(BoundThreadPoolExecutor, self).__init__(*args, **kwargs)
            self._work_queue = queue.Queue(num * 2)


    with open(path, 'r', encoding='utf-8') as f:
        pool = BoundThreadPoolExecutor(max_workers=num)
        # for result in pool.map(send, f):
        #     ...
        for arg in f:
            pool.submit(send, arg)
        pool.shutdown(wait=True)
