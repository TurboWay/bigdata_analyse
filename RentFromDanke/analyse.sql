-- 1.整体情况（出租房数量，每平米租金）
select count(1) as total,  -- 出租房总数量
	   sum(价格)/sum(面积) as per, -- 平均每平米租金
	   avg(面积) as avg_area -- 每套房源的平均出租面积
from rent


-- 2.地区分析
select 位置1, count(1) as total, count(distinct 小区) as com, sum(价格)/sum(面积) as per
from rent
group by 位置1
order by total desc

-- 3.小区分析
select 小区, 位置1, count(1) as total, sum(价格)/sum(面积) as per
from rent
group by 小区, 位置1
order by total desc


-- 4.户型楼层分析
--户型
select 户型, count(1) as total, sum(价格)/sum(面积) as per
from rent
group by 户型
order by total desc

select substr(户型, 0, 3) as 户型, count(1) as total, sum(价格)/sum(面积) as per
from rent
group by substr(户型, 0, 3)
order by 1

--电梯
select case when 总楼层 > 7 then '电梯房' else '非电梯房' end as tp, count(1) as total, sum(价格)/sum(面积) as per
from rent
group by case when 总楼层 > 7 then '电梯房' else '非电梯房' end
order by total desc

-- 所在楼层
select case when 1.0 * 所在楼层/总楼层 > 0.66 then '高层'
            when 1.0 * 所在楼层/总楼层 > 0.33 then '中层'
            else '底层' end as tp,
       count(1) as total, sum(价格)/sum(面积) as per
from rent
group by case when 1.0 * 所在楼层/总楼层 > 0.66 then '高层'
              when 1.0 * 所在楼层/总楼层 > 0.33 then '中层'
              else '底层' end
order by total desc

-- 电梯&所在楼层
select case when 总楼层 > 7 then '电梯房'
            else '非电梯房' end as tp1,
       case when 1.0 * 所在楼层/总楼层 > 0.66 then '高层'
            when 1.0 * 所在楼层/总楼层 > 0.33 then '中层'
            else '低层' end as tp2,
       count(1) as total, sum(价格)/sum(面积) as per
from rent
group by case when 总楼层 > 7 then '电梯房'
              else '非电梯房' end,
         case when 1.0 * 所在楼层/总楼层 > 0.66 then '高层'
              when 1.0 * 所在楼层/总楼层 > 0.33 then '中层'
              else '低层' end
order by 1, 2  desc

-- 5.交通分析

--地铁数
select 地铁数, count(1) as total, sum(价格)/sum(面积) as per
from rent
group by 地铁数
order by 1

--距离地铁距离
select case when 距离地铁距离 between 0 and 500 then '500米以内'
			when 距离地铁距离 between 501 and 1000 then '1公里以内'
			when 距离地铁距离 between 1001 and 1500 then '1.5公里以内'
			else '1.5公里以外' end as ds,
      count(1) as total, sum(价格)/sum(面积) as per
from rent
group by case when 距离地铁距离 between 0 and 500 then '500米以内'
			  when 距离地铁距离 between 501 and 1000 then '1公里以内'
			  when 距离地铁距离 between 1001 and 1500 then '1.5公里以内'
              else '1.5公里以外' end
order by 1