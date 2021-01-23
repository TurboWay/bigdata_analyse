-- 建表
CREATE TABLE `job`(
    `position` string COMMENT '职位',
    `num` string COMMENT '招聘人数',
    `company` string COMMENT '公司',
    `job_type` string COMMENT '职位类型',
    `jobage` string COMMENT '工作年限',
    `lang` string COMMENT '语言',
    `age` string COMMENT '年龄',
    `sex` string COMMENT '性别',
    `education` string COMMENT '学历',
    `workplace` string COMMENT '工作地点',
    `worktime` string COMMENT '工作时间',
    `salary` string COMMENT '薪资',
    `welfare` string COMMENT '福利待遇',
    `hr` string COMMENT '招聘人',
    `phone` string COMMENT '联系电话',
    `address` string COMMENT '联系地址',
    `company_type` string COMMENT '公司类型',
    `industry` string COMMENT '行业',
    `require` string COMMENT '岗位要求',
    `worktime_day` string COMMENT '工作时间(每天)',
    `worktime_week` string COMMENT '工作时间(每周)',
    `skill` string COMMENT '技能要求'
)
row format delimited
fields terminated by ','
lines terminated by '\n';

-- 加载数据
LOAD DATA INPATH '/tmp/job_clean.csv' OVERWRITE INTO TABLE job;
