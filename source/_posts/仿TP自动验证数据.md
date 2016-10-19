title: 学习记录:仿TP自动验证数据
date: 2016-01-30 16:18:09
tags: [PHP,十八哥,自动验证]
categories:  [PHP学习记录]
---

# TP自动验证

&emsp;&emsp;数据对象是由表单提交的$_POST数据创建。需要使用系统的自动验证功能，只需要在Model类里面定义
<!--more-->
$_validate属性，是由多个验证因子组成的二维数组。

# 自动验证格式
``` php
# 这是检测的格式:
array('字段名称','运用场景0/1/2','错误信息','规则')
Protected $valid=array(
	array('goods_name','1','商品名不能为空','require'),
	array('cat_id','1','商品分类必须为整型','number'),
	array('is_new','0','只能是0或者1','in','0,1'),
	array('goods_brief','2','简介字数要在1到100间','between','10,100')
					);
```
## 解释意义
字段名称:
根据你的需要

运用场景:
0. 有字段检测,无此字段不检测
1. 必须检测的字段
2. 如有且内容不空,则检测,如签名档

规则:
1. require:检测是否为空
2. number:检测是否是数字
3. in(0,1):检测是不是值在参数里面
4. between(10,100):检测是不是在参数范围内

## validate代码如下:
``` php
function validate ($data){
	// 如果没有设置valid
	if(empty($this->valid)){
		// 返回检测成功
		return true;
	}
	// 循环规则数组
	foreach($this -> valid as $k => $v){
		//首先判断环境0,1,2
		switch($v['1']){
			case 1:
				// 1场景:必须检查
				// $v[0]是字段名
				// 如果没有设置了字段名
				if(!isset($data[$v[0]])){
					$this->err[]=$v['2'];
					return false;
				}
				// 再来检测值是否为空
				if($this->check($data[$v[0]],$v[3])){
					$this->err[]=$v[2];
					return false;
				}
				break;
			case 0: 
				// 如果没有设置,就不用验证,返回true
				if(!isset($data[$v[0]])){
					return true;
				}
				if(!$this->check($data[$v[0]],$v[3],$v[4])){
					$this->err[]=$v[2];
					return false;
				}
				break;
			case 2:
				// 如果字段没有设置返回true
				// 这里用了短路
				// 如果设置了,判断是否为空,如果为空,返回true
				// 如果不为空,且字段存在,条件false,不执行
				if(!isset($data[$v[0]])||empty($data[$v[0]])){
					return true;
				}
				if(!$this->check($data[$v[0]],$v[3],$v[4])){
					$this->err['err']=$v['2'];
					return false;
				}
				break;
		}
	}
}
```
## check代码如下:
``` php
// $value:字段名字
// $rules:规则
// $param:规则对应的参数
Protected function check($value,$rules='',$param=''){
	switch($rules){
		// 判断是否为空
		case 'require':
			return empty($value);
			break;
		// 当他不是数字的时候,返回true,在valid端就直接执行
		case 'number':
			return !is_numeric($value);
		// 判断在in中
		case 'in':
			$arr=explode(',',$param);
			return in_array($value,$arr);
		case 'between':
			$arr=explode(',',$param);
			return strlen($value)>=$arr[0]&&strlen($value)<=$arr[1];
			}
		}
```
# 总结
这样就可以自动验证了.但是功能只有几个,更多功能可以在check里面添加.