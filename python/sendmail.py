#!/usr/bin/python
# -*- coding: UTF-8 -*-
 
import smtplib
from email.mime.text import MIMEText
from email.utils import formataddr
 
my_sender='779770838@qq.com'
my_pass = 'xxxxxxxxxxxxxxxx'
my_user='373665997@qq.com'

def mail():
    # ret=True
    # try:
        msg=MIMEText('你好，兄弟','plain','utf-8')
        msg['From']=formataddr(["FromRunoob",my_sender])
        msg['To']=formataddr(["FK",my_user])
        msg['Subject']="菜鸟教程发送邮件测试"
 
        server=smtplib.SMTP_SSL("smtp.qq.com", 465)
        server.login(my_sender, my_pass)
        server.sendmail(my_sender,[my_user,],msg.as_string())
        server.quit()
    # except Exception:
        # ret=False
    # return ret
 
ret=mail()
if ret:
    print("邮件发送成功")
else:
    print("邮件发送失败")

