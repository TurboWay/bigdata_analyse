-- 乘客主题

-- (整体) 通勤费用
select  '整体' deal_type,
        count(1) as cnt,
        sum(deal_money) / 100 as total,
		avg(deal_money) / 100 as per
from sztcard
where deal_type in ('地铁出站', '巴士')
union all
select  deal_type,
        count(1) as cnt,
        sum(deal_money) / 100 as total,
		avg(deal_money) / 100 as per
from sztcard
where deal_type in ('地铁出站', '巴士')
group by deal_type;

-- 优惠情况
select case when a.distinct_count = 1 then '全票'
            when a.distinct_count = 0.95 then '9.5 折'
            when a.distinct_count >= 0.9 then '9 折'
            when a.distinct_count >= 0.85 then '8.5 折'
            when a.distinct_count >= 0.75 then '7.5 折'
            when a.distinct_count >= 0.5 then '半票'
            when a.distinct_count = 0 then '免票'
            end as distinct_count_range,
       sum(cn) as cn
from(
select deal_money / deal_value as distinct_count, count(1) as cn
from sztcard
where deal_value  > 0
group by deal_money / deal_value
) as a
group by case when a.distinct_count = 1 then '全票'
            when a.distinct_count = 0.95 then '9.5 折'
            when a.distinct_count >= 0.9 then '9 折'
            when a.distinct_count >= 0.85 then '8.5 折'
            when a.distinct_count >= 0.75 then '7.5 折'
            when a.distinct_count >= 0.5 then '半票'
            when a.distinct_count = 0 then '免票'
            end;

-- (整体) 出行时间分布
select  hour(deal_date) as h, count(1) as ct
from sztcard
where deal_type in ('地铁入站', '巴士')
group by hour(deal_date)
order by h;

-- (地铁) 通勤时间
with tt as(
select *, row_number() over( partition by card_no order by deal_date) as px
from sztcard
where deal_type rlike '地铁'
),
tt2 as(
select t1.card_no,
       t1.deal_type as in_type, t1.company_name as in_company, t1.station as in_station, t1.deal_date as in_date,
       t2.deal_type as out_type, t2.company_name as out_company, t2.station as out_station, t2.deal_date as out_date,
       unix_timestamp(t2.deal_date) - unix_timestamp(t1.deal_date) as diff_sec
from tt as t1
inner join tt as t2 on t1.card_no = t2.card_no and t1.px = t2.px - 1
where t2.deal_type = '地铁出站'
and t1.deal_type = '地铁入站'
and t1.station <> t2.station
and substring(t1.deal_date, 1, 10) = '2018-09-01'
and substring(t2.deal_date, 1, 10) = '2018-09-01'
)

select avg(diff_sec)/60 from tt2;


-- 地铁主题

-- (基于站点) 进站 top
select station, count(1) as cn
from sztcard
where deal_type = '地铁入站'
and station > ''
group by station
order by cn desc
limit 10;

-- (基于站点) 出站 top
select station, count(1) as cn
from sztcard
where deal_type = '地铁出站'
and station > ''
group by station
order by cn desc
limit 10;

-- (基于站点) 进出站 top
select station, count(1) as cn
from sztcard
where deal_type in ('地铁出站', '地铁入站')
and station > ''
group by station
order by cn desc
limit 10;

-- (基于站点) 站点收入 top
select station, sum(deal_money) / 100 as sm
from sztcard
where deal_type in ('地铁出站', '地铁入站')
and station > ''
group by station
order by sm desc
limit 10;

-- (基于线路) 运输贡献度 top
-- 进站算一次，出站并且联程算一次
select company_name, count(1) as cn
from sztcard
where company_name rlike '地铁'
and (deal_type = '地铁出站' and conn_mark = '1' or deal_type = '地铁入站')
group by company_name
order by cn desc;

-- (基于线路) 运输效率 top
-- 每条线路单程直达乘客耗时平均值排行榜
with tt as(
select *, row_number() over( partition by card_no order by deal_date) as px
from sztcard
where deal_type rlike '地铁'
),
tt2 as(
select t1.card_no,
       t1.deal_type as in_type, t1.company_name as in_company, t1.station as in_station, t1.deal_date as in_date,
       t2.deal_type as out_type, t2.company_name as out_company, t2.station as out_station, t2.deal_date as out_date,
       unix_timestamp(t2.deal_date) - unix_timestamp(t1.deal_date) as diff_sec
from tt as t1
inner join tt as t2 on t1.card_no = t2.card_no and t1.px = t2.px - 1
where t2.deal_type = '地铁出站'
and t1.deal_type = '地铁入站'
and t1.station <> t2.station
and substring(t1.deal_date, 1, 10) = '2018-09-01'
and substring(t2.deal_date, 1, 10) = '2018-09-01'
)

select in_company, avg(diff_sec) / 60 avg_min
from tt2
where in_company = out_company
group by in_company
order by avg_min;

-- (基于线路) 换乘比例 top
-- 每线路换乘出站乘客百分比排行榜
with tt as(
select *, row_number() over( partition by card_no order by deal_date) as px
from sztcard
where deal_type rlike '地铁'
),
tt2 as(
select t1.card_no,
       t1.deal_type as in_type, t1.company_name as in_company, t1.station as in_station, t1.deal_date as in_date,
       t2.deal_type as out_type, t2.company_name as out_company, t2.station as out_station, t2.deal_date as out_date,
       t2.conn_mark,
       unix_timestamp(t2.deal_date) - unix_timestamp(t1.deal_date) as diff_sec
from tt as t1
inner join tt as t2 on t1.card_no = t2.card_no and t1.px = t2.px - 1
where t2.deal_type = '地铁出站'
and t1.deal_type = '地铁入站'
and t1.station <> t2.station
and substring(t1.deal_date, 1, 10) = '2018-09-01'
and substring(t2.deal_date, 1, 10) = '2018-09-01'
)

select out_company, sum(case when conn_mark = '1' then 1 else 0 end) / count(1) as per
from tt2
group by out_company
order by per desc;

-- (基于线路) 线路收入 top
select company_name, sum(deal_money) / 100 as sm
from sztcard
where deal_type rlike '地铁'
group by company_name
order by sm desc;

-- 巴士主题

-- (基于公司) 巴士公司收入 top
select company_name, sum(deal_money) / 100 as sm
from sztcard
where deal_type not rlike '地铁'
group by company_name
order by sm desc;

-- (基于公司) 巴士公司贡献度 top
select company_name, count(1) as cn
from sztcard
where deal_type not rlike '地铁'
group by company_name
order by cn desc;