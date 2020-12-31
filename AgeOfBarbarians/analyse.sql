-- 修改字段类型
alter table age_of_barbarians modify register_time timestamp(0);
alter table age_of_barbarians modify avg_online_minutes float(10, 2);
alter table age_of_barbarians modify pay_price float(10, 2);

-- 1.用户分析

-- 用户总量
select count(1) as total, count(distinct user_id) as users
from age_of_barbarians

-- PU ( Paying Users）：付费用户总量
select sum(case when pay_price > 0 then 1 else 0 end) as `付费用户`,
       sum(case when pay_price > 0 then 0 else 1 end) as `非付费用户`
from age_of_barbarians

-- DNU（Daily New Users）： 每日游戏中的新登入用户数量，即每日新用户数。
```
点击：点击广告页或者点击广告链接数
下载：点击后成功下载用户数
安装：下载程序并成功安装用户数
激活：成功安装并首次激活应用程序
注册：产生user_id
DNU：产生user_id并且首次登陆
```
select cast(register_time as date) as day,
       count(1) as dnu
from age_of_barbarians
group by cast(register_time as date)
order by day;

-- 每小时的新登入用户数量
select hour(cast(register_time as datetime)) as hour,
       count(1) as dnu
from age_of_barbarians
group by hour(cast(register_time as datetime))
order by hour;


--2.用户活跃度分析

-- DAU、WAU、MAU（Daily Active Users、Weekly Active Users、Monthly Active Users）：每日、每周、每月登陆游戏的用户数，一般为自然周与自然月。

-- 平均在线时长
select avg(avg_online_minutes) as `平均在线时长`,
       sum(case when pay_price > 0 then avg_online_minutes else 0 end) / sum(case when pay_price > 0 then 1 else 0 end) as `付费用户在线时长`,
       sum(case when pay_price > 0 then 0 else avg_online_minutes end) / sum(case when pay_price > 0 then 0 else 1 end) as `非付费用户在线时长`
from age_of_barbarians;



--3.用户付费情况分析

-- APA（Active Payment Account）：活跃付费用户数。
select count(1) as APA from age_of_barbarians where pay_price > 0 and avg_online_minutes > 0; -- 60987

-- ARPU(Average Revenue Per User) ：平均每用户收入。
select sum(pay_price)/sum(case when avg_online_minutes > 0 then 1 else 0 end) from age_of_barbarians;  -- 0.582407

-- ARPPU (Average Revenue Per Paying User)： 平均每付费用户收入。
select sum(pay_price)/sum(case when avg_online_minutes > 0 and pay_price > 0 then 1 else 0 end)  from age_of_barbarians; -- 29.190265

-- PUR(Pay User Rate)：付费比率，可通过 APA/AU 计算得出。
select sum(case when avg_online_minutes > 0 and pay_price > 0 then 1 else 0 end) / sum(case when avg_online_minutes > 0 then 1 else 0 end)
from age_of_barbarians;  -- 0.02

-- 付费用户人数，付费总额，付费总次数，平均每人付费，平均每人付费次数，平均每次付费
select  count(1) as pu,  -- 60988
        sum(pay_price) as sum_pay_price,  -- 1780226.7
        avg(pay_price) as avg_pay_price,  -- 29.189786
        sum(pay_count) as sum_pay_count,  -- 193030
        avg(pay_count) as avg_pay_count,  -- 3.165
        sum(pay_price) / sum(pay_count) as each_pay_price -- 9.222539
from age_of_barbarians
where pay_price > 0;


--4.用户习惯分析

--胜率
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

--pvp场次
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

