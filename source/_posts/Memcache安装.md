title: Memcache安装
date: 2016-03-05 17:06:30
tags: [Memcache,linux]
categories: [Memcache安装]
---

# Windows
<!--more-->
## 一、安装memcached
1. 下载 Memcached
   度娘有编译好的memcached.exe可以下载
2. 将memcached放到/wamp/bin/mem/中
``` bat
	cd /wamp/bin/mem
	memcached.exe -d install //安装
	memcached.exe -d start //注册服务
```
3. memcached的启动
``` bat
	memcached.exe -m 64 -p 11211 -vvv
```
4. memcached的连接
``` bat
	telnet 127.0.0.1 11211
```
5. 按下ctrl+],打开回显,并回车

## 二、安装php的memcached扩展
> 
1. 寻找合适的dll,需要考虑三个参数
	1. php版本
	2. ts or nts(线程安全 县城不安全)
	3. vc6 vc9 vc11
2. 找到合适的dll下载,并放在php/ext目录下
3. 修改php.ini
   先通过phpinfo()确认真正使用的php.ini文件是哪一个
   观察extension_dir路径
   添加extension=php_memcache.dll
4. 重启apache

# Linux
## 一、安装memcached
1. 准备编译环境
> 在linux编译,需要gcc,make,autoconf,libtool等工具
``` bat
// 安装编译环境
yum install gcc make,cmake,autoconf,libtool
```
2. 下载相应的库和memcached源码
> memcached依赖于lieevent库,因此,需要编译libevent
libevent.org和memcached.org在下载最新的stable版本
```
#cd /usr/local/src
#wget https://github.com/libevent/libevent/releases/download/release-2.0.22-stable/libevent-2.0.22-stable.tar.gz
```
3. 同理下载mem安装包
4. 编译安装libevent
> 
```
#tar zxvf libevent(可以按住tab,能自动补全)
#cd libevent(tab)
#./configure --prefix=/usr/local/libevent
#make && make install
```
5. 同理编译安装memcached
> 
```
#tar zxvf mem(可以按住tab,能自动补全)
#cd memca(tab)
#./configure --prefix=/usr/local/memcache --with-libevent=/usr/local/libevent
#make && make install
```
注:在虚拟机下练习编译的时候,一个容易碰到的问题,虚拟机的时间不对,导致gcc编译过程中,检测时间无法通过,一直处于编译过程
解决:
``` 
#date -s 'yyyy-mm-dd hh:mm:ss'
#clock -w #把时间写入cmos
```
启动
> 
-u nobody方式运行
-d 指定memcached后台进程执行

## 二、安装扩展
> 扩展编译的通用方法:
以memcache扩展为例
1. 到软件你的官方(如memcached)或者php.net寻找源码并下载
2. 进入到 /memcache目录
3. 根据当前的php版本动态创建扩展的configure文件
```
# cd /memcached
# /usr/local/php/bin/phpize --with-php-config=/usr/local/php/bin/php-config
# ./configure --with-php-config=/usr/local/php/bin/php-config
```
4. make && make install
5. 把生成的扩展so,在php.ini里面引入
```
# 复制php.ini到php中
# cp /usr/local/src/php-5.5.12/php.ini-development /usr/local/php/lib/php.ini
```
6. 重启apache
```
# cd /usr/local/httpd
# ./bin/apa(按tab) restart
```