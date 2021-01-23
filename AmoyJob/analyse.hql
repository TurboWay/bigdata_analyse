-- 启用本地模式
set hive.exec.mode.local.auto=true;
set hive.exec.mode.local.auto.inputbytes.max=52428800;
set hive.exec.mode.local.auto.input.files.max=10;

-- 整体情况（招聘企业数、岗位数、招聘人数、平均薪资）
select count(distinct company) as `企业数`,
       count(1) as `岗位数`,
       sum(num) as `招聘人数`,
       sum(salary * num) / sum(case when salary > 0 then num else 0 end) as `平均工资`
from job;

-- 最缺人的行业 TOP 10
select industry, sum(num) as workers
from job
group by industry
order by workers desc
limit 10;

-- 公司类型情况
select  company_type,
        sum(num) as workers,
        sum(salary * num) / sum(case when salary > 0 then num else 0 end) as avg_salary
from job
group by company_type;

-- 最缺人的公司 TOP 10
select company, sum(num) as workers
from job
group by company
order by workers desc
limit 10;

-- 平均薪资最高的公司 TOP 10
select company, sum(salary * num) / sum(num) as avg_salary
from job
where salary > 0
group by company
order by avg_salary desc
limit 10;

-- 工作时间
select worktime_day, count(1) cn
from job
where worktime_day < 24
and worktime_day > 0
group by worktime_day
order by cn desc
limit 10;

select worktime_week, count(1) cn
from job
where worktime_week <> '0'
group by worktime_week
order by cn desc
limit 10;

-- 工作地点(导出为 workplace.csv)
select workplace, count(1) as cn
from(
select regexp_replace(b.workplace, '厦门市', '') as workplace
from job
lateral view explode(split(workplace, '、|，')) b AS workplace
) as a
where workplace rlike '湖里|海沧|思明|集美|同安|翔安'
group by workplace;

-- 福利词云(导出为 welfare.csv)
select fl, count(1)
from(
select b.fl
from job
lateral view explode(split(welfare,'、'))  b AS fl
) as a
where fl <> '其他'
group by fl;

-- 工作经验
select case when jobage in ('其它工作经验', '不限', '应届生') then jobage
            when jobage between 1 and 3 then '1-3 年'
            when jobage between 3 and 5 then '3-5 年'
            when jobage between 5 and 10 then '5-10 年'
            when jobage >= 10 then '10 年以上'
            else jobage end as jobage,
       count(1) as `岗位数量`,
       sum(salary * num) / sum(case when salary > 0 then num else 0 end) as `平均工资`
from job
group by case when jobage in ('其它工作经验', '不限', '应届生') then jobage
            when jobage between 1 and 3 then '1-3 年'
            when jobage between 3 and 5 then '3-5 年'
            when jobage between 5 and 10 then '5-10 年'
            when jobage >= 10 then '10 年以上'
            else jobage end;

-- 学历
select education,
       count(1) as `岗位数量`,
       sum(salary * num) / sum(case when salary > 0 then num else 0 end) as `平均工资`
from job
group by education;

-- 性别
select sex,
       count(1) as `岗位数量`,
       sum(salary * num) / sum(case when salary > 0 then num else 0 end) as `平均工资`
from job
group by sex;

-- 年龄
select case when age = '不限' then '不限'
            when split(age, '-')[1] >= 35 then '35岁及以下'
            else  '35岁以上' end as age,
       count(1) as `岗位数量`,
       sum(salary * num) / sum(case when salary > 0 then num else 0 end) as `平均工资`
from job
group by case when age = '不限' then '不限'
              when split(age, '-')[1] >= 35 then '35岁及以下'
              else  '35岁以上' end
-- 语言
select lang, count(1) as cn
from job
where lang <> '不限'
group by lang
order by cn desc;

-- 技能
select sk, count(1) as cn
from(
select upper(b.sk) as sk
from job
lateral view explode(split(skill,'、'))  b AS sk
) as a
where sk in ('C', 'JAVA', 'PYTHON', 'PHP', 'SQL', 'GO')
group by sk
order by cn desc;

select 'Java' as lang, sum(salary * num) / sum(case when salary > 0 then num else 0 end) as `平均工资`
from job
where lower(skill) rlike 'java'
union all
select 'Python' as lang, sum(salary * num) / sum(case when salary > 0 then num else 0 end) as `平均工资`
from job
where lower(skill) rlike 'python'
union all
select 'Php' as lang, sum(salary * num) / sum(case when salary > 0 then num else 0 end) as `平均工资`
from job
where lower(skill) rlike 'php'
union all
select 'Sql' as lang, sum(salary * num) / sum(case when salary > 0 then num else 0 end) as `平均工资`
from job
where lower(skill) rlike 'sql'
union all
select 'Go' as lang, sum(salary * num) / sum(case when salary > 0 then num else 0 end) as `平均工资`
from job
where lower(skill) rlike 'go'
union all
select 'C' as lang, sum(salary * num) / sum(case when salary > 0 then num else 0 end) as `平均工资`
from job
where lower(skill) rlike 'c';

-- 模型训练(导出为 train.csv)
select education, case when jobage = '应届生' then 0 else jobage end as jobage, avg(salary) as avg_salary
from job
where salary > '0'
and education <> '不限'
and jobage not in ('不限', '其它工作经验')
group by education, case when jobage = '应届生' then 0 else jobage end