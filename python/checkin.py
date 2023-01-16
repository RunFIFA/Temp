#!/usr/bin/python
# -*- coding: UTF-8 -*-

from __future__ import print_function
import requests
import time
import random
import sys


accountList = (
    ["account", "passwd"],
    ["account", "passwd"]
)

headers = {
    'authority': 'neworld.cloud',
    'accept': 'application/json, text/javascript, */*; q=0.01',
    'accept-language': 'zh-CN,zh;q=0.9',
    'origin': 'https://neworld.cloud',
    'sec-ch-ua': '" Not A;Brand";v="99", "Chromium";v="102", "Google Chrome";v="102"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"Windows"',
    'sec-fetch-dest': 'empty',
    'sec-fetch-mode': 'cors',
    'sec-fetch-site': 'same-origin',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.5005.115 Safari/537.36',
    'x-requested-with': 'XMLHttpRequest',
}

def getCookie(account, passwd):
    print('\033[94m'"---------开始登录---------"+'\033[0m')
    
    timestamp = str( int(str(time.time()).split('.')[0]) + 86400 )
    cookies = {
        'ip': '720c880ad931cc350c791a2d79680e18',
        'expire_in': timestamp, }
    
    data = {
        'code': '',
        'email': account,
        'passwd': passwd,
        'fingerprint': '4fa3d911e01ebb8d175c6ab3ec8f0579', }
        
    response = requests.post('https://neworld.cloud/auth/login', cookies=cookies, headers=headers, data=data)
    cookies = requests.utils.dict_from_cookiejar(response.cookies)
    return response, cookies


def checkin(cookies):
    print('\033[94m'+"---------开始签到---------"+'\033[0m')
    
    response = requests.post('https://neworld.cloud/user/checkin', cookies=cookies, headers=headers)
    return response


def getinform(response):
    print("返回信息:" + str(eval(response.text)['msg']) )
    print("返回参数:", end="")
    print( response.url, response.status_code, response.reason, response.encoding, response.apparent_encoding, response.text )
    print("认证信息:", end="")
    print( requests.utils.dict_from_cookiejar(response.cookies) )


if __name__=='__main__':
    print('\033[91m'+"---------------------------欢迎使用Neworld签到脚本---------------------------"+'\033[0m')
    for account, passwd in accountList:
        try:
            print('\033[92m'+"------------------------------ %s 开始签到------------------------------" % account +'\033[0m')
            time.sleep( random.randint(1,10) )  #防检测，防crontab固定时间执行
            response, cookies  = getCookie( account, passwd )
            getinform(response)
            
            time.sleep( random.randint(3,10) )  #防检测
            response = checkin(cookies)
            getinform(response)
        except Exception as e:
            print('\033[91m'+"%s 签到失败, 错误信息如下:" % account +'\033[0m')
            print(e)
            print(sys.exc_info())
            continue
