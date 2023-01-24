#!/usr/bin/python
# -*- coding: UTF-8 -*-

import requests

cookies = {
    'session': 'e12c3e22-ef78-4752-bf59-59e13dc098c6',
    '_ga': 'GA1.2.277964026.1674036574',
    'Hm_lvt_0838dad5461d14f63bdf207a43a54c29': '1674381526,1674391787,1674476141,1674550541',
    '__cf_bm': 'l4Xpgt_kRg4P453.0PIChi0.y2OJ9v5poahBGry.Nrk-1674550541-0-AVekRCqnM2XCJ6e8CZ3i7Ag46MetLeL0y1kJfCaQ0SQPcTAYoiS0FuEeFGrEGQGo4KHTGIpnyGQxJEe+PLD9/+UfxXyifiFYmV1JUOsxI1XDrLIjQkpt/qEUAyj2NivxEtd8Z6B+C52w8zUCiTDYFLg=',
    'Hm_lpvt_0838dad5461d14f63bdf207a43a54c29': '1674550587',
}

headers = {
    'authority': 'dashboard.cpolar.com',
    'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
    'accept-language': 'zh-CN,zh;q=0.9',
    # 'cookie': 'session=e12c3e22-ef78-4752-bf59-59e13dc098c6; _ga=GA1.2.277964026.1674036574; Hm_lvt_0838dad5461d14f63bdf207a43a54c29=1674381526,1674391787,1674476141,1674550541; __cf_bm=l4Xpgt_kRg4P453.0PIChi0.y2OJ9v5poahBGry.Nrk-1674550541-0-AVekRCqnM2XCJ6e8CZ3i7Ag46MetLeL0y1kJfCaQ0SQPcTAYoiS0FuEeFGrEGQGo4KHTGIpnyGQxJEe+PLD9/+UfxXyifiFYmV1JUOsxI1XDrLIjQkpt/qEUAyj2NivxEtd8Z6B+C52w8zUCiTDYFLg=; Hm_lpvt_0838dad5461d14f63bdf207a43a54c29=1674550587',
    'referer': 'https://dashboard.cpolar.com/status',
    'sec-ch-ua': '"Not_A Brand";v="99", "Google Chrome";v="109", "Chromium";v="109"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"Windows"',
    'sec-fetch-dest': 'document',
    'sec-fetch-mode': 'navigate',
    'sec-fetch-site': 'same-origin',
    'sec-fetch-user': '?1',
    'upgrade-insecure-requests': '1',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36',
}

response = requests.get('https://dashboard.cpolar.com/status', cookies=cookies, headers=headers)


