#!/usr/bin/python
# -*- coding: UTF-8 -*-
 
import sys
import time
import smtplib
from email.mime.text import MIMEText
from email.utils import formataddr
 
my_sender='779770838@qq.com'
my_pass = 'wjqcrfcrympebfbb'
my_user='373665997@qq.com'


def getcontext():
    context=''
    for arg in sys.argv[1:]:
      context = context  + arg + '\n'
    context = context + "system is normal\n" + "Time: " + time.strftime("%H:%M:%S", time.localtime())
    print(context)
    return context

def sendmail():
    ret=True
    try:
        msg=MIMEText(getcontext(),'plain','utf-8')
        msg['From']=formataddr(["luorunfa",my_sender])
        msg['To']=formataddr(["hony",my_user])
        msg['Subject']="服务器邮箱"
 
        server=smtplib.SMTP_SSL("smtp.qq.com", 465)
        server.login(my_sender, my_pass)
        server.sendmail(my_sender,[my_user,],msg.as_string())
        server.quit()
    except Exception:
        ret=False
    return ret
 
ret=sendmail()
if ret:
    print("邮件发送成功")
else:
    print("邮件发送失败")

    
    
# POP/STMP: uliyybcgoowybccf
# IMAP/SMTP:wjqcrfcrympebfbb