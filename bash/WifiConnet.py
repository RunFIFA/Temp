import time
import subprocess
import os


# 查看设备情况
# nmcli dev
# nmcli dev wifi list
# nmcli dev wifi show

# 连接
# nmcli dev wifi connect TP-LINK_EC08 password lt302302302 wep-key-type key ifname wlx008736323df9

# 通过设备名控制
# nmcli device disconnect wlx008736323df9
# nmcli device connect wlx008736323df9

# 通过wifi名控制
# nmcli connect show
# nmcli connect del TP-LINK_luo
# nmcli connect up TP-LINK_luo
# nmcli connect down TP-LINK_luo
# nmcli connect down TP-LINK_luo


wifiList = [
 ( "RunFIFA嘅\"iPhone\"", "88888888" ),
 ( "TP-LINK_EC08", "lt302302302" ),
 ( "TP-LINK_luo", "27266325" ),
 ( "CMCC-luo2", "27266325" )
]

def getdevice():
  cmd = "nmcli dev | grep wlx | awk '{print $1}'"
  device = str(subprocess.check_output(cmd, shell = True ).decode())
  print(device)
  return device

def connect(device):
  for wifi in wifiList:
    try:
      cmd = "nmcli dev wifi connect " + wifi[0] + " password " + wifi[1] + " wep-key-type key ifname " + device
      ret = str(subprocess.check_output(cmd, shell = True ).decode())
      print(ret)
      if ret.find("successfully") != -1:
        break
    except:
      continue

if __name__ == '__main__':
  while True:
    device = getdevice()
    if ( device != "" ):
      connect(device)
      break
    else:
      time.sleep(10)