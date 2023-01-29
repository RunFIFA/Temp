#!/usr/bin/python
# -*- coding: UTF-8 -*-

import telepot
from pprint import pprint
from telepot.loop import MessageLoop


TOKEN = '6057449043:AAFtypHMYSJK0MgatH_21fvqmvZlNLJYRmg'

def handle(msg):
    content_type, chat_type, chat_id = telepot.glance(msg)
    print(content_type, chat_type, chat_id)

    if content_type == 'text':
        bot.sendMessage(chat_id, msg['text'])


bot = telepot.Bot(TOKEN)
bot.getMe()

MessageLoop(bot, handle).run_as_thread()
print ('Listening ...')


while 1:
    time.sleep(10)



#https://codeantenna.com/a/KeogAqyIZz
#https://zhuanlan.zhihu.com/p/30450761
