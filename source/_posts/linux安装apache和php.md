title: linux下安装apache和php
date: 2016-03-05 18:16:19
tags: [linux,apache,php]
categories: [apache]
---
# 一、apache编译
<!--more-->
```
# cd /usr/local/src/
# wget http://httpd.apache.org/download.cgi
# tar zvxf apache(按tab)
# cd apache(按tab) 
# ./configure --prefix=/usr/local/httpd 
# make && make install
```
> 开启apache
```
# cd /usr/local/httpd
# ./bin/apachectl start
```

# 二、php编译
1. 解压
```
# cd /usr/local/src/
# wget http://...
# tar zfvx php(按tab)
# cd php(按tab)
```
2. 编译安装php
```
# ./configure --prefix=/usr/local/php --with-apxs2=/usr/local/httpd/bin/apxs --enable-mysqlnd
# make && make install
```

# 三、整合apache+php
1. 配置http.conf主要是整合php作为apache的模块出现(有时会自动配置好)
2. 我们在httpd.conf里加一句AddType application/x-httpd-php .php
```
# cd /usr/local/httpd/conf/
# vim httpd.conf
# AddType application/x-httpd-php .php
```
3. 重启apache
> 注:libxml库会出错:xml2-config not found,please check your libxml2 instaration;
解决方法:yum install libxml2-devel