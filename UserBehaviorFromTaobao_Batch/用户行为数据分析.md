[TOC]

# 1. 数据集说明

这是一份来自淘宝的用户行为数据，时间区间为 2017-11-25 到 2017-12-03，总计 100,150,807 条记录，大小为 3.5 G，包含 5 个字段。

# 2. 数据处理

## 2.1 数据导入 
将数据加载到 hive, 然后通过 hive 对数据进行数据处理。

```sql
-- 建表
drop table if exists user_behavior;
create table user_behavior (
`user_id` string comment '用户ID',
`item_id` string comment '商品ID',
`category_id` string comment '商品类目ID',
`behavior_type` string  comment '行为类型，枚举类型，包括(pv, buy, cart, fav)',
`timestamp` int comment '行为时间戳',
`datetime` string comment '行为时间')
row format delimited
fields terminated by ','
lines terminated by '\n';

-- 加载数据
LOAD DATA LOCAL INPATH '/home/getway/UserBehavior.csv'
OVERWRITE INTO TABLE user_behavior ;
```

## 2.2 数据清洗
数据处理主要包括：删除重复值，时间戳格式化，删除异常值。

```sql
--数据清洗，去掉完全重复的数据
insert overwrite table user_behavior
select user_id, item_id, category_id, behavior_type, timestamp, datetime
from user_behavior
group by user_id, item_id, category_id, behavior_type, timestamp, datetime;

--数据清洗，时间戳格式化成 datetime
insert overwrite table user_behavior
select user_id, item_id, category_id, behavior_type, timestamp, from_unixtime(timestamp, 'yyyy-MM-dd HH:mm:ss')
from user_behavior;

--查看时间是否有异常值
select date(datetime) as day from user_behavior group by date(datetime) order by day;

--数据清洗，去掉时间异常的数据
insert overwrite table user_behavior
select user_id, item_id, category_id, behavior_type, timestamp, datetime
from user_behavior
where cast(datetime as date) between '2017-11-25' and '2017-12-03';

--查看 behavior_type 是否有异常值
select behavior_type from user_behavior group by behavior_type;
```

# 3.数据分析可视化

## 3.1 用户流量及购物情况

```sql
--总访问量PV，总用户量UV
select sum(case when behavior_type = 'pv' then 1 else 0 end) as pv,
       count(distinct user_id) as uv
from user_behavior;
```

![image-20201228145436838](https://gitee.com/TurboWay/blogimg/raw/master/img/image-20201228145436838.png)

```sql
--日均访问量，日均用户量
select cast(datetime as date) as day,
       sum(case when behavior_type = 'pv' then 1 else 0 end) as pv,
       count(distinct user_id) as uv
from user_behavior
group by cast(datetime as date)
order by day;
```

![image-20201228151058279](https://gitee.com/TurboWay/blogimg/raw/master/img/image-20201228151058279.png)

![image-20201228151535393](https://gitee.com/TurboWay/blogimg/raw/master/img/image-20201228151535393.png)


```sql
--每个用户的购物情况，加工到 user_behavior_count
create table user_behavior_count as
select user_id,
       sum(case when behavior_type = 'pv' then 1 else 0 end) as pv,   --点击数
       sum(case when behavior_type = 'fav' then 1 else 0 end) as fav,  --收藏数
       sum(case when behavior_type = 'cart' then 1 else 0 end) as cart,  --加购物车数
       sum(case when behavior_type = 'buy' then 1 else 0 end) as buy  --购买数
from user_behavior
group by user_id;

--复购率：产生两次或两次以上购买的用户占购买用户的比例
select sum(case when buy > 1 then 1 else 0 end) / sum(case when buy > 0 then 1 else 0 end)
from user_behavior_count;
```

![image-20201228152004432](https://gitee.com/TurboWay/blogimg/raw/master/img/image-20201228152004432.png)

* 小结：2017-11-25 到 2017-12-03 这段时间，PV 总数为 89,660,671 ，UV 总数为 987,991。从日均访问量趋势来看，进入 12 月份之后有一个比较明显的增长，猜测可能是因为临近双 12 ，电商活动引流产生，另外，2017-12-02 和 2017-12-03 刚好是周末，也可能是周末的用户活跃度本来就比平常高。总体的复购率为 66.01%，说明用户的忠诚度比较高。

## 3.2 用户行为转换率

```sql
--点击/(加购物车+收藏)/购买 , 各环节转化率
select a.pv,
       a.fav,
       a.cart,
       a.fav + a.cart as `fav+cart`,
       a.buy,
       round((a.fav + a.cart) / a.pv, 4) as pv2favcart,
       round(a.buy / (a.fav + a.cart), 4) as favcart2buy,
       round(a.buy / a.pv, 4) as pv2buy
from(
select sum(pv) as pv,   --点击数
       sum(fav) as fav,  --收藏数
       sum(cart) as cart,  --加购物车数
       sum(buy) as buy  --购买数
from user_behavior_count
) as a;
```

![image-20201228144958757](https://gitee.com/TurboWay/blogimg/raw/master/img/image-20201228144958757.png)

![image-20201228144814773](https://gitee.com/TurboWay/blogimg/raw/master/img/image-20201228144814773.png)

* 小结：2017-11-25 到 2017-12-03 这段时间，点击数为 89,660,671 ，收藏数为 2,888,258，加购物车数为5,530,446，购买数为 2,015,807。总体的转化率为 2.25%，这个值可能是比较低的，从加到购物车数来看，有可能部分用户是准备等到电商节日活动才进行购买。所以合理推断：一般电商节前一段时间的转化率会比平常低。

## 3.3 用户行为习惯

```sql
-- 一天的活跃时段分布
select hour(datetime) as hour,
       sum(case when behavior_type = 'pv' then 1 else 0 end) as pv,   --点击数
       sum(case when behavior_type = 'fav' then 1 else 0 end) as fav,  --收藏数
       sum(case when behavior_type = 'cart' then 1 else 0 end) as cart,  --加购物车数
       sum(case when behavior_type = 'buy' then 1 else 0 end) as buy  --购买数
from user_behavior
group by hour(datetime)
order by hour;
```

![image-20201228153206947](https://gitee.com/TurboWay/blogimg/raw/master/img/image-20201228153206947.png)

```sql
--一周用户的活跃分布
select pmod(datediff(datetime, '1920-01-01') - 3, 7) as weekday,
       sum(case when behavior_type = 'pv' then 1 else 0 end) as pv,   --点击数
       sum(case when behavior_type = 'fav' then 1 else 0 end) as fav,  --收藏数
       sum(case when behavior_type = 'cart' then 1 else 0 end) as cart,  --加购物车数
       sum(case when behavior_type = 'buy' then 1 else 0 end) as buy  --购买数
from user_behavior
where date(datetime) between '2017-11-27' and '2017-12-03'
group by pmod(datediff(datetime, '1920-01-01') - 3, 7)
order by weekday;
```

![image-20201228153751943](https://gitee.com/TurboWay/blogimg/raw/master/img/image-20201228153751943.png)

![image-20201228154533968](https://gitee.com/TurboWay/blogimg/raw/master/img/image-20201228154533968.png)

* 小结：晚上21点-22点之间是用户一天中最活跃的时候，凌晨 4 点，则是活跃度最低的时候。一周中，工作日活跃度都差不多，到了周末活跃度有明显提高。

## 3.4 基于 RFM 模型找出有价值的用户

RFM 模型是衡量客户价值和客户创利能力的重要工具和手段，其中由3个要素构成了数据分析最好的指标，分别是：
* R-Recency（最近一次购买时间）
* F-Frequency（消费频率）
* M-Money（消费金额）

```sql
--R-Recency（最近一次购买时间）, R值越高，一般说明用户比较活跃
select user_id,
       datediff('2017-12-04', max(datetime)) as R,
       dense_rank() over(order by datediff('2017-12-04', max(datetime))) as R_rank
from user_behavior
where behavior_type = 'buy'
group by user_id
limit 10;

--F-Frequency（消费频率）, F值越高，说明用户越忠诚
select user_id,
       count(1) as F,
       dense_rank() over(order by count(1) desc) as F_rank
from user_behavior
where behavior_type = 'buy'
group by user_id
limit 10;

--M-Money（消费金额），数据集无金额，所以就不分析这一项 
```

对有购买行为的用户按照排名进行分组，共划分为5组，
前  - 1/5 的用户打5分
前 1/5 - 2/5 的用户打4分
前 2/5 - 3/5 的用户打3分
前 3/5 - 4/5 的用户打2分
前 4/5 - 的用户打1分
按照这个规则分别对用户时间间隔排名打分和购买频率排名打分，最后把两个分数合并在一起作为该名用户的最终评分

```sql
with cte as(
select user_id,
       datediff('2017-12-04', max(datetime)) as R,
       dense_rank() over(order by datediff('2017-12-04', max(datetime))) as R_rank,
       count(1) as F,
       dense_rank() over(order by count(1) desc) as F_rank
from user_behavior
where behavior_type = 'buy'
group by user_id)

select user_id, R, R_rank, R_score, F, F_rank, F_score,  R_score + F_score AS score
from(
select *,
       case ntile(5) over(order by R_rank) when 1 then 5
                                           when 2 then 4
                                           when 3 then 3
                                           when 4 then 2
                                           when 5 then 1
       end as R_score,
       case ntile(5) over(order by F_rank) when 1 then 5
                                           when 2 then 4
                                           when 3 then 3
                                           when 4 then 2
                                           when 5 then 1
       end as F_score
from cte
) as a
order by score desc
limit 20;
```

![image-20201228155700646](https://gitee.com/TurboWay/blogimg/raw/master/img/image-20201228155700646.png)

* 小结：可以根据用户的价值得分，进行个性化的营销推荐。

## 3.5 商品维度的分析

```sql
--销量最高的商品
select item_id ,
       sum(case when behavior_type = 'pv' then 1 else 0 end) as pv,   --点击数
       sum(case when behavior_type = 'fav' then 1 else 0 end) as fav,  --收藏数
       sum(case when behavior_type = 'cart' then 1 else 0 end) as cart,  --加购物车数
       sum(case when behavior_type = 'buy' then 1 else 0 end) as buy  --购买数
from user_behavior
group by item_id
order by buy desc
limit 10;

--销量最高的商品大类
select category_id ,
       sum(case when behavior_type = 'pv' then 1 else 0 end) as pv,   --点击数
       sum(case when behavior_type = 'fav' then 1 else 0 end) as fav,  --收藏数
       sum(case when behavior_type = 'cart' then 1 else 0 end) as cart,  --加购物车数
       sum(case when behavior_type = 'buy' then 1 else 0 end) as buy  --购买数
from user_behavior
group by category_id
order by buy desc
limit 10;
```

* 小结：缺失商品维表，所以没有太多分析价值。假如有商品维表，可以再展开，以商品纬度进行分析，比如不同行业、不同产品的转化率，还有竞品分析等等。