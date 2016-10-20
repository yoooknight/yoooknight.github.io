title: Python模拟登录知乎
date: 2016-10-20 22:28:53
tags: [Python]
categories: [Python]
---

# 一 Analysis
1. 登录知乎的路径，经过查询资料以及一些工具分析出知乎的登录路径是根据你的账户类型切换：
    手机号：http://www.zhihu.com/logn/phone_num
    邮箱：http://www.zhihu.com/logn/email
2. 登录知乎遇到验证码，可以通过一些验证码库来自动识别，也可以通过下载验证码的图片进行人工识别，这里我选择第二种方式来解决验证码问题。
3. 发送http请求被拒绝的问题都很好解决，可以通过修改http请求的headers伪装浏览器访问，我这里只是选择User-Agent的伪装

# 二 Coding
1. 模块的引入
首先一些基本的模块需要引入，os,sys,random,pickle等
然后实现主要功能就要通过xia mian个模块
```
import requests (这个模块替代了urllib.request，功能比较强大)
from PIL import Image(这个模块可以直接打开一个图片文件，用来识别验证码)
from bs4 import BeautifulSoup as BS (这个模块代替了re的正则表达式，更
方便快捷地抓取需要的数据)
(注意：上面的模块都不是python中自带的模块，需要通过pip来安装这些模块)
```

2. 废话不多说，直接上完整代码
```
import urllib.request
import requests
import time
import json
import os
import re
import sys
import subprocess
from bs4 import BeautifulSoup as BS
from PIL import Image
import random
import pickle

class ZhiClient(object):
    TYPE_PHOME_NUM = "phone_num"
    TYPE_EAMAIL = "email"
    loginURL = r"http://www.zhihu.com/login/{0}"
    homeURL = r"http://www.zhihu.com"
    captchaURL = "http://www.zhihu.com/captcha.gif?r=%d&type=login" % int(time.time())

    headers = {  
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.86 Safari/537.36",  
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",  
        "Accept-Encoding": "gzip, deflate",  
        "Host": "www.zhihu.com",  
        "Upgrade-Insecure-Requests": "1",  
    }  

    User_Agent = {'User-Agent': "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36"}

    captchaFile = os.path.join(sys.path[0], "captcha.gif")
    cookieFile = os.path.join(sys.path[0], "cookie")

    def __init__(self):
        os.chdir(sys.path[0]) # 设置脚本所在目录为当前工作目录

        self.__session = requests.Session()
        # self.__session.headers = self.headers

        # 若已经有cookie则直接登录
        self.__cookie = self.__loadCookie()
        print(bool(self.__cookie))
        if self.__cookie:
            print("检测到cookie文件，请直接使用cookie登录")
            self.__session.cookies.update(self.__cookie)
            soup = BS(self.open(r"http://www.zhihu.com/").text, "html.parser")
            print("已登陆账号：%s" % soup.find("span", class_ = "name").getText())
        else:
            print("没有找到cookie文件，请调用一次login方法登陆一次！")
            username = input("请输入你的账号：")
            password = input("请输入你的密码：")

            self.login(username, password)

    # 登录
    def login(self, username, password):
        self.__username = username
        self.__password = password
        self.__loginURL = self.loginURL.format(self.__getUserNameType(username))

        print(self.__username)
        print(self.__password)
        print(self.__loginURL)

        # 随便开个网页，获取登录所需的_xsrf
        html = self.open(self.homeURL)

        soup = BS(html.text, "html.parser")
        _xsrf = soup.find('input',attrs={'name':'_xsrf'})['value']


        # 下载验证码图片
        while True:
            captcha = self.open(self.captchaURL).content

            with open(self.captchaFile, 'wb') as output:
                output.write(captcha)

            # 人眼识别
            print("="*50)
            print(self.captchaFile)
            print("已打开验证码图片，请识别！")
            
            # 显示图片
            img = Image.open(self.captchaFile)
            img.show()
            captcha = input(" 请输入验证码：")
            os.remove(self.captchaFile)

            # 发送post请求
            data = {
                "_xsrf": _xsrf,
                "password": self.__password,
                "remember_me": "true",
                self.__getUserNameType(self.__username): self.__username,
                "captcha": captcha
            }
            print(data)

            res = self.__session.post(self.__loginURL, data=data, headers = self.User_Agent)
            cookies = res.cookies
            # requests.cookies.RequestsCookieJar
            # print(type(cookies))
            # print("*"*50)

            # https://www.zhihu.com/captcha.gif?r=1463377588&type=login
            # print(self.captchaURL)
            # print(res.cookies)
            print("*"*50)
            # print(res.text) #调试

            if res.json()["r"] == 0:
                print("登录成功")
                print(res)
                self.__saveCookie(cookies)
                break
            else:
                print("登录失败")
                print("错误信息 －－－－> ", res.json()['msg'])
    def __getUserNameType(self, username):
        if username.isdigit():
            return self.TYPE_PHOME_NUM
        return self.TYPE_EAMAIL

    def __saveCookie(self, cookies):
        # r = self.__session.get(self.homeURL)
        # cookies = r.cookies
        cookies = requests.utils.dict_from_cookiejar(self.__session.cookies)

        # with open(self.cookieFile, "w") as output:
           #  cookies = cookie
        #     json.dump(cookies, output)
        #     print("="*50)
        #     print("已在同目录下生成cookie文件", self.cookieFile)
        with open(self.cookieFile, "wb") as output:
            # print(cookies)
            pickle.dump(cookies, output)
            print("="*50)
            print("已在同目录下生成cookie文件", self.cookieFile)
 
    def __loadCookie(self):
        if os.path.exists(self.cookieFile):
            print("="*50)
            with open(self.cookieFile, "rb") as f:
                cookie = pickle.load(f)
                return cookie
        else:
            return None

    def open(self, url, delay = 0, timeout = 0):
        if delay:
            time.sleep(timeout)
        return self.__session.get(url, headers = self.User_Agent)


    def getSession(self):
        return self.__session

if __name__ == '__main__':
    client = ZhiClient()

```
# 三 问题分析
在实现代码的时候总会出现各种问题，我总结在这里，方便以后我能回顾这些错误
1. 在获取_xsrf的时候，向知乎网站发送请求的时候，返回的一直都是500错误，这是因为我在最开始的时候没有伪装成浏览器，导致请求被拒绝了，再添加上了之后就可以获取到正确的数据
2. 在获取验证码的时候，路径没有找对，导致获取到的验证码一直返回“该验证码会话已经失效”，正确的新链接需要添加上时间戳
3. 在登录成功后获取cookie也遇到了难题，一直没有找到正确的获取方法，经过百度的帮助，最终才能正确保存cookie

下一次我准备完成一个贴吧robot自动发帖功能，searching...