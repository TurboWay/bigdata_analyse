# bigdata_analyse
大数据分析项目

## wish

采用不同的技术栈，通过对不同行业的数据集进行分析，期望达到以下目标：

- 了解不同领域的业务分析指标 
- 深化数据处理、数据分析、数据可视化能力
- 增加大数据批处理、流处理的实践经验
- 增加数据挖掘的实践经验

## tip

- 项目主要使用的编程语言是 python、sql、hql
- .ipynb 可以用 jupyter notebook 打开，如何安装, 可以参考 [jupyter notebook](http://blog.turboway.top/article/jupyter/)
>jupyter notebook 是一种网页交互形式的 python 编辑器，直接通过 pip 安装，也支持 markdown，很适合用来做数据分析可视化以及写文章、写示例代码等。

## list

| 主题 | 处理方式 | 技术栈  |  数据集下载 |
| ------------ | ------------ | ------------ | ------------ |
| [1 亿条淘宝用户行为数据分析](https://github.com/TurboWay/bigdata_analyse/blob/main/UserBehaviorFromTaobao_Batch/用户行为数据分析.md)       |  离线处理  | 清洗 hive  + 分析 hive + 可视化 echarts | [阿里云](https://tianchi.aliyun.com/dataset/dataDetail?dataId=649&userId=1) 或者 [百度网盘](https://pan.baidu.com/s/15Ss-nDMA120EHhuwpzYm0g) 提取码：5ipq |
| [1000 万条淘宝用户行为数据实时分析](https://github.com/TurboWay/bigdata_analyse/blob/main/UserBehaviorFromTaobao_Stream/用户行为数据实时分析.md)       |  实时处理  | 数据源 kafka  + 实时分析 flink + 可视化（es + kibana）  | [百度网盘](https://pan.baidu.com/s/1CPD5jpmvOUvg1LETAVETGw)  提取码：m4mc|
| [300 万条《野蛮时代》的玩家数据分析](https://github.com/TurboWay/bigdata_analyse/blob/main/AgeOfBarbarians/野蛮时代数据分析.md)       |  离线处理  | 清洗 pandas  + 分析 mysql + 可视化 pyecharts | [百度网盘](https://pan.baidu.com/s/1Mi5lvGDF405Nk8Y2BZDzdQ) 提取码：paq4 |
| [130 万条深圳通刷卡数据分析](https://github.com/TurboWay/bigdata_analyse/blob/main/SZTcard/深圳通刷卡数据分析.md)       |  离线处理  | 清洗 pandas  + 分析 impala + 可视化 dbeaver | [百度网盘](https://pan.baidu.com/s/1WslwKXKhVH1q_6u4SvuKkQ) 提取码：t561 |
| [10 万条厦门招聘数据分析](https://github.com/TurboWay/bigdata_analyse/blob/main/AmoyJob/2021厦门招聘数据分析.md)       |  离线处理  | 清洗 pandas  + 分析 hive + 可视化 ( hue + pyecharts ) + 预测 sklearn | [百度网盘](https://pan.baidu.com/s/1mco8dKb5o0qPd2kqsj7bNg) 提取码：9wx0|
| [7000 条租房数据分析](https://github.com/TurboWay/bigdata_analyse/blob/main/RentFromDanke/租房数据分析.md)       |  离线处理  | 清洗 pandas  + 分析 sqlite + 可视化 matplotlib  | [百度网盘](https://pan.baidu.com/s/1l1x5qurJdkyUxAuhknj_Qw) 提取码：9en3 |
| [6000 条倒闭企业数据分析](https://nbviewer.jupyter.org/github/TurboWay/bigdata_analyse/blob/main/DeathCompany/倒闭企业数据分析.ipynb)       |  离线处理  | 清洗 pandas  + 分析 pandas + 可视化 (jupyter notebook + pyecharts) | [百度网盘](https://pan.baidu.com/s/1I6E6i4ZadxE9IlVPe3Bqwg) 提取码：xvgm |
| [COVID-19 疫情数据分析](https://nbviewer.jupyter.org/github/TurboWay/bigdata_analyse/blob/3fc3af081ad36e1c98b1b8edaf42035611930a30/COVID-19/新冠疫情数据分析.ipynb)       |  离线处理  | 清洗 pandas  + 分析 pandas + 可视化 (jupyter notebook + pyecharts) | [csse_covid_19_time_series](https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series) |

## refer

> 1. [https://tianchi.aliyun.com/dataset/](https://tianchi.aliyun.com/dataset/)
> 2. [https://opendata.sz.gov.cn/data/api/toApiDetails/29200_00403601](https://opendata.sz.gov.cn/data/api/toApiDetails/29200_00403601)
> 3. [https://www.kesci.com/home/dataset](https://www.kesci.com/home/dataset)
> 4. [https://github.com/CSSEGISandData/COVID-19](https://github.com/CSSEGISandData/COVID-19)