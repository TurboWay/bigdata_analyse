/*
说明：手游《野蛮时代》玩家数据
来源：https://js.dclab.run/v2/cmptDetail.html?id=226
大小：642 M （训练集）+ 219 M（测试集）= 861 M
记录数：2,288,007 （训练集）+ 828,934（测试集）= 3,116,941
字段数：109
*/

-- 建表
drop table if exists age_of_barbarians;
create table age_of_barbarians (
`user_id` string comment '玩家唯一ID',
`register_time` string comment '玩家注册时间',
`wood_add_value` string comment '木头获取数量',
`wood_reduce_value` string comment '木头消耗数量',
`stone_add_value` string comment '石头获取数量',
`stone_reduce_value` string comment '石头消耗数量',
`ivory_add_value` string comment '象牙获取数量',
`ivory_reduce_value` string comment '象牙消耗数量',
`meat_add_value` string comment '肉获取数量',
`meat_reduce_value` string comment '肉消耗数量',
`magic_add_value` string comment '魔法获取数量',
`magic_reduce_value` string comment '魔法消耗数量',
`infantry_add_value` string comment '勇士招募数量',
`infantry_reduce_value` string comment '勇士损失数量',
`cavalry_add_value` string comment '驯兽师招募数量',
`cavalry_reduce_value` string comment '驯兽师损失数量',
`shaman_add_value` string comment '萨满招募数量',
`shaman_reduce_value` string comment '萨满损失数量',
`wound_infantry_add_value` string comment '勇士伤兵产生数量',
`wound_infantry_reduce_value` string comment '勇士伤兵恢复数量',
`wound_cavalry_add_value` string comment '驯兽师伤兵产生数量',
`wound_cavalry_reduce_value` string comment '驯兽师伤兵恢复数量',
`wound_shaman_add_value` string comment '萨满伤兵产生数量',
`wound_shaman_reduce_value` string comment '萨满伤兵恢复数量',
`general_acceleration_add_value` string comment '通用加速获取数量',
`general_acceleration_reduce_value` string comment '通用加速使用数量',
`building_acceleration_add_value` string comment '建筑加速获取数量',
`building_acceleration_reduce_value` string comment '建筑加速使用数量',
`reaserch_acceleration_add_value` string comment '科研加速获取数量',
`reaserch_acceleration_reduce_value` string comment '科研加速使用数量',
`training_acceleration_add_value` string comment '训练加速获取数量',
`training_acceleration_reduce_value` string comment '训练加速使用数量',
`treatment_acceleraion_add_value` string comment '治疗加速获取数量',
`treatment_acceleration_reduce_value` string comment '治疗加速使用数量',
`bd_training_hut_level` string comment '建筑：士兵小屋等级',
`bd_healing_lodge_level` string comment '建筑：治疗小井等级',
`bd_stronghold_level` string comment '建筑：要塞等级',
`bd_outpost_portal_level` string comment '建筑：据点传送门等级',
`bd_barrack_level` string comment '建筑：兵营等级',
`bd_healing_spring_level` string comment '建筑：治疗之泉等级',
`bd_dolmen_level` string comment '建筑：智慧神庙等级',
`bd_guest_cavern_level` string comment '建筑：联盟大厅等级',
`bd_warehouse_level` string comment '建筑：仓库等级',
`bd_watchtower_level` string comment '建筑：瞭望塔等级',
`bd_magic_coin_tree_level` string comment '建筑：魔法幸运树等级',
`bd_hall_of_war_level` string comment '建筑：战争大厅等级',
`bd_market_level` string comment '建筑：联盟货车等级',
`bd_hero_gacha_level` string comment '建筑：占卜台等级',
`bd_hero_strengthen_level` string comment '建筑：祭坛等级',
`bd_hero_pve_level` string comment '建筑：冒险传送门等级',
`sr_scout_level` string comment '科研：侦查等级',
`sr_training_speed_level` string comment '科研：训练速度等级',
`sr_infantry_tier_2_level` string comment '科研：守护者',
`sr_cavalry_tier_2_level` string comment '科研：巨兽驯兽师',
`sr_shaman_tier_2_level` string comment '科研：吟唱者',
`sr_infantry_atk_level` string comment '科研：勇士攻击',
`sr_cavalry_atk_level` string comment '科研：驯兽师攻击',
`sr_shaman_atk_level` string comment '科研：萨满攻击',
`sr_infantry_tier_3_level` string comment '科研：战斗大师',
`sr_cavalry_tier_3_level` string comment '科研：高阶巨兽骑兵',
`sr_shaman_tier_3_level` string comment '科研：图腾大师',
`sr_troop_defense_level` string comment '科研：部队防御',
`sr_infantry_def_level` string comment '科研：勇士防御',
`sr_cavalry_def_level` string comment '科研：驯兽师防御',
`sr_shaman_def_level` string comment '科研：萨满防御',
`sr_infantry_hp_level` string comment '科研：勇士生命',
`sr_cavalry_hp_level` string comment '科研：驯兽师生命',
`sr_shaman_hp_level` string comment '科研：萨满生命',
`sr_infantry_tier_4_level` string comment '科研：狂战士',
`sr_cavalry_tier_4_level` string comment '科研：龙骑兵',
`sr_shaman_tier_4_level` string comment '科研：神谕者',
`sr_troop_attack_level` string comment '科研：部队攻击',
`sr_construction_speed_level` string comment '科研：建造速度',
`sr_hide_storage_level` string comment '科研：资源保护',
`sr_troop_consumption_level` string comment '科研：部队消耗',
`sr_rss_a_prod_levell` string comment '科研：木材生产',
`sr_rss_b_prod_level` string comment '科研：石头生产',
`sr_rss_c_prod_level` string comment '科研：象牙生产',
`sr_rss_d_prod_level` string comment '科研：肉类生产',
`sr_rss_a_gather_level` string comment '科研：木材采集',
`sr_rss_b_gather_level` string comment '科研：石头采集',
`sr_rss_c_gather_level` string comment '科研：象牙采集',
`sr_rss_d_gather_level` string comment '科研：肉类生产',
`sr_troop_load_level` string comment '科研：部队负重',
`sr_rss_e_gather_level` string comment '科研：魔法采集',
`sr_rss_e_prod_level` string comment '科研：魔法生产',
`sr_outpost_durability_level` string comment '科研：据点耐久',
`sr_outpost_tier_2_level` string comment '科研：据点二',
`sr_healing_space_level` string comment '科研：医院容量',
`sr_gathering_hunter_buff_level` string comment '科研：领土采集奖励',
`sr_healing_speed_level` string comment '科研：治疗速度',
`sr_outpost_tier_3_level` string comment '科研：据点三',
`sr_alliance_march_speed_level` string comment '科研：联盟行军速度',
`sr_pvp_march_speed_level` string comment '科研：战斗行军速度',
`sr_gathering_march_speed_level` string comment '科研：采集行军速度',
`sr_outpost_tier_4_level` string comment '科研：据点四',
`sr_guest_troop_capacity_level` string comment '科研：增援部队容量',
`sr_march_size_level` string comment '科研：行军大小',
`sr_rss_help_bonus_level` string comment '科研：资源帮助容量',
`pvp_battle_count` string comment 'PVP次数',
`pvp_lanch_count` string comment '主动发起PVP次数',
`pvp_win_count` string comment 'PVP胜利次数',
`pve_battle_count` string comment 'PVE次数',
`pve_lanch_count` string comment '主动发起PVE次数',
`pve_win_count` string comment 'PVE胜利次数',
`avg_online_minutes` string comment '在线时长',
`pay_price` string comment '付费金额',
`pay_count` string comment '付费次数',
`prediction_pay_price` string comment '45日付费金额' )
row format delimited
fields terminated by ','
lines terminated by '\n';

-- 加载数据
LOAD DATA LOCAL INPATH '/home/getway/tap_fun_test.csv'
INTO TABLE age_of_barbarians ;
LOAD DATA LOCAL INPATH '/home/getway/tap_fun_train.csv'
INTO TABLE age_of_barbarians ;

-- 去掉 csv 的标题数据
insert overwrite table age_of_barbarians
select * from age_of_barbarians
where user_id <> 'user_id';

-- 查看数据重复性（基于 user_id 唯一，无重复记录）
select count(1), count(distinct user_id)
from age_of_barbarians ;

-- 查看基本数据样例
select user_id, register_time, avg_online_minutes , pay_price, pay_count
from age_of_barbarians
limit 100 ;
