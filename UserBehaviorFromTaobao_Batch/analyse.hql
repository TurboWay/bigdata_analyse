--1、用户流量及购物情况

--总访问量PV，总用户量UV
select sum(case when behavior_type = 'pv' then 1 else 0 end) as pv,
       count(distinct user_id) as uv
from user_behavior;

--日均访问量，日均用户量
select cast(datetime as date) as day,
       sum(case when behavior_type = 'pv' then 1 else 0 end) as pv,
       count(distinct user_id) as uv
from user_behavior
group by cast(datetime as date)
order by day;

--每个用户的购物情况，加工到 user_behavior_count
create table user_behavior_count as
select user_id,
       sum(case when behavior_type = 'pv' then 1 else 0 end) as pv,   --点击数
       sum(case when behavior_type = 'fav' then 1 else 0 end) as fav,  --收藏数
       sum(case when behavior_type = 'cart' then 1 else 0 end) as cart,  --加购物车数
       sum(case when behavior_type = 'buy' then 1 else 0 end) as buy  --购买数
from user_behavior
group by user_id;

--点击数最多的用户前十
select * from user_behavior_count order by pv desc limit 10;

--复购率：产生两次或两次以上购买的用户占购买用户的比例
select sum(case when buy > 1 then 1 else 0 end) / sum(case when buy > 0 then 1 else 0 end)
from user_behavior_count;


--2、用户行为转化漏斗

--点击/(加购物车+收藏)/购买 , 各环节转化率
select a.pv,
       a.fav,
       a.cart,
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

--3、购买率高和购买率低的人群有什么特征

--购买率高
select *, buy / pv as buy_rate
from user_behavior_count
where buy > 0 and pv > 0
order by buy_rate desc
limit 10;

--购买率低
select *, buy / pv as buy_rate
from user_behavior_count
where buy > 0 and pv > 0
order by buy_rate
limit 10;

--4、基于时间维度了解用户的行为习惯

-- 一天的活跃时段分布
select hour(datetime) as hour,
       sum(case when behavior_type = 'pv' then 1 else 0 end) as pv,   --点击数
       sum(case when behavior_type = 'fav' then 1 else 0 end) as fav,  --收藏数
       sum(case when behavior_type = 'cart' then 1 else 0 end) as cart,  --加购物车数
       sum(case when behavior_type = 'buy' then 1 else 0 end) as buy  --购买数
from user_behavior
group by hour(datetime)
order by hour;

--一周用户的活跃分布
select pmod(datediff(datetime, '1920-01-01') - 3, 7) as weekday,
       sum(case when behavior_type = 'pv' then 1 else 0 end) as pv,   --点击数
       sum(case when behavior_type = 'fav' then 1 else 0 end) as fav,  --收藏数
       sum(case when behavior_type = 'cart' then 1 else 0 end) as cart,  --加购物车数
       sum(case when behavior_type = 'buy' then 1 else 0 end) as buy  --购买数
from user_behavior
group by pmod(datediff(datetime, '1920-01-01') - 3, 7)
order by weekday;

--5、基于RFM模型找出有价值的用户

/*
RFM模型是衡量客户价值和客户创利能力的重要工具和手段，其中由3个要素构成了数据分析最好的指标，分别是：
R-Recency（最近一次购买时间）
F-Frequency（消费频率）
M-Money（消费金额）
*/

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

--对用户进行评分
/*
对有购买行为的用户按照排名进行分组，共划分为四组，
对排在前四分之一的用户打4分，排在四分之一到四分之二的用户打3分，排在前四分之二到四分之三的用户打2分，剩余的用户打1分，
按照这个规则分别对用户时间间隔排名打分和购买频率排名打分，最后把两个分数合并在一起作为该名用户的最终评分。
*/
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
       case ntile(4) over(order by R_rank) when 1 then 4
                                           when 2 then 3
                                           when 3 then 2
                                           when 4 then 1
       end as R_score,
       case ntile(4) over(order by F_rank) when 1 then 4
                                           when 2 then 3
                                           when 3 then 2
                                           when 4 then 1
       end as F_score
from cte
) as a
order by score desc
limit 20;


--6、商品维度的分析

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