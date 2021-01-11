-- 建表
CREATE TABLE `sztcard`(
    `card_no` string COMMENT '卡号',
    `deal_date` string COMMENT '交易日期时间',
    `deal_type` string COMMENT '交易类型',
    `deal_money` float COMMENT '交易金额',
    `deal_value` float COMMENT '交易值',
    `equ_no` string COMMENT '设备编码',
    `company_name` string COMMENT '公司名称',
    `station` string COMMENT '线路站点',
    `car_no` string COMMENT '车牌号',
    `conn_mark` string COMMENT '联程标记',
    `close_date` string COMMENT '结算日期'
)
row format delimited
fields terminated by ','
lines terminated by '\n';

-- 加载数据
LOAD DATA INPATH '/tmp/SZTcard.csv' OVERWRITE INTO TABLE sztcard;