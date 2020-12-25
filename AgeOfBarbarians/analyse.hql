--1.新增用户分析

-- 新增用户总量
select count(1) from age_of_barbarians;  --3116941

-- PU ( Paying Users）：付费用户总量
select count(1) from age_of_barbarians where pay_price > 0;  --60988

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
       count(1) as dnu,
       sum(case when pay_price > 0 then 1 else 0 end ) as dnpu
from age_of_barbarians
group by cast(register_time as date)
order by day;

-- 每小时的新登入用户数量
select hour(cast(register_time as datetime)) as hour,
       count(1) as dnu,
       sum(case when pay_price > 0 then 1 else 0 end ) as dnpu
from age_of_barbarians
group by hour(cast(register_time as datetime))
order by hour;


--2.用户活跃度分析

-- DAU、WAU、MAU（Daily Active Users、Weekly Active Users、Monthly Active Users）：每日、每周、每月登陆游戏的用户数，一般为自然周与自然月。

-- 平均在线时长
select avg(avg_online_minutes) from age_of_barbarians; --10.615346021266106

-- 付费玩家的平均在线时长
select avg(avg_online_minutes) from age_of_barbarians where pay_price > 0; --138.80478126869235


--3.玩家付费情况分析

-- APA（Active Payment Account）：活跃付费用户数。
select count(1) as APA from age_of_barbarians where pay_price > 0 and avg_online_minutes > 0; --60987

-- ARPU(Average Revenue Per User) ：平均每用户收入。
select sum(pay_price)/sum(case when avg_online_minutes > 0 then 1 else 0 end) from age_of_barbarians;  --0.5824066558640159

-- ARPPU (Average Revenue Per Paying User)： 平均每付费用户收入。
select sum(pay_price)/sum(case when avg_online_minutes > 0 and pay_price > 0 then 1 else 0 end)  from age_of_barbarians; --29.190265138469332

-- PUR(Pay User Rate)：付费比率，可通过 APA/AU 计算得出。
select sum(case when avg_online_minutes > 0 and pay_price > 0 then 1 else 0 end) / sum(case when avg_online_minutes > 0 then 1 else 0 end)
from age_of_barbarians;  --0.019952085159256484

-- 付费玩家人数，付费总额，付费总次数，平均每人付费，平均每人付费次数，平均每次付费
select  count(1) as pu,  --60988
        sum(pay_price) as sum_pay_price,  --1780226.6999998293
        avg(pay_price) as avg_pay_price,  --29.189786515377275
        sum(pay_count) as sum_pay_count,  --193030.0
        avg(pay_count) as avg_pay_count,  --3.165048862071227
        sum(pay_price) / sum(pay_count) as each_pay_price --9.222538983576797
from age_of_barbarians
where pay_price > 0;


--4.玩家习惯分析

--胜率
select sum(pvp_win_count) / sum(pvp_battle_count) as pvp_win_rate,  --玩家pvp胜率
       sum(case when pay_price > 0 then pvp_win_count else 0 end) / sum(case when pay_price > 0 then pvp_battle_count else 0 end) as pve_win_rate_pay,  --付费玩家pve胜率
       sum(case when pay_price = 0 then pvp_win_count else 0 end) / sum(case when pay_price = 0 then pvp_battle_count else 0 end) as pve_win_rate_nor,  --非付费玩家pve胜率
       sum(pve_win_count) / sum(pve_battle_count) as pve_win_rate,  --玩家pve胜率
       sum(case when pay_price > 0 then pve_win_count else 0 end) / sum(case when pay_price > 0 then pve_battle_count else 0 end) as pve_win_rate_pay,  --付费玩家pve胜率
       sum(case when pay_price = 0 then pve_win_count else 0 end) / sum(case when pay_price = 0 then pve_battle_count else 0 end) as pve_win_rate_nor  --非付费玩家pve胜率
from age_of_barbarians;

--pvp场次
select sum(pvp_battle_count) as pvp_battle_count,  --玩家pvp场次
       avg(pvp_battle_count) as pvp_battle_count_avg,  --玩家平均pvp场次
       sum(case when pay_price > 0 then pvp_battle_count else 0 end) as pvp_battle_count_pay,  --付费玩家pvp场次
       sum(case when pay_price > 0 then pvp_battle_count else 0 end) / sum(case when pay_price > 0 then 1 else 0 end), --付费玩家平均pvp场次
       sum(case when pay_price = 0 then pvp_battle_count else 0 end) as pvp_battle_count_nor,  --非付费玩家pvp场次
       sum(case when pay_price = 0 then pvp_battle_count else 0 end) / sum(case when pay_price = 0 then 1 else 0 end) --非付费玩家平均pvp场次
from age_of_barbarians;

--pve场次
select sum(pve_battle_count) as pve_battle_count,  --玩家pve场次
       avg(pve_battle_count) as pve_battle_count_avg,  --玩家平均pve场次
       sum(case when pay_price > 0 then pve_battle_count else 0 end) as pve_battle_count_pay,  --付费玩家pve场次
       sum(case when pay_price > 0 then pve_battle_count else 0 end) / sum(case when pay_price > 0 then 1 else 0 end), --付费玩家平均pve场次
       sum(case when pay_price = 0 then pve_battle_count else 0 end) as pve_battle_count_nor,  --非付费玩家pvp场次
       sum(case when pay_price = 0 then pve_battle_count else 0 end) / sum(case when pay_price = 0 then 1 else 0 end) --非付费玩家平均pve场次
from age_of_barbarians;