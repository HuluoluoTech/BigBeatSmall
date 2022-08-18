from base64 import encode
import socket
import bitstring

import json
import threading
from time import sleep
from bitstring import pack
from bitstring import BitStream

HOST = '127.0.0.1'
PORT = 8002

password = "123"

def pack_login():
    login = 'login,101,123'
    bin = pack('uint:16, bits:104', 13, bytes(login.encode('utf-8')))
    return bin

###############################################################################
#
# 客户端发起的通信协议格式
# 1 登录协议： login,playerid,password#
# 2 进入游戏： enter#
# 3 移动协议： shift, x, y#
#
###############################################################################
def protocol_login(playerid, password):
    res = "login," + playerid + "," + password + "#"
    return res

def protocol_enter():
    res = "enter#"
    return res

def protocol_shift(x, y):
    res = "shift," + x + "," + y + "#"
    return res

###############################################################################
#
# 玩家新建客户端链接
#
###############################################################################
def new_client():
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client.connect((HOST, PORT))

    return client

###############################################################################
#
# 客户端发起通信协议
#
###############################################################################
def req_login(client, playerid, password):
    print_align("[Login]", "娱乐一下，登录游戏看看...")
    protocol = protocol_login(playerid, password)
    # client.send(protocol.encode('utf-8'))
    client.send(pack_login().tobytes())
    respdata = client.recv(1024)

    res = json.loads(respdata)
    if res["code"] != 0:
        print_align("[Login]", "Woopo... 登录失败了，因为: " + res["reason"])
        return False
    else:
        print_align("[Login]", "恭喜，网络还行，登录成功了， 马上进入游戏开始Play吧...")
        return True

def req_enter(client):
    protocol = protocol_enter()
    client.send(protocol.encode('utf-8'))
    respdata = client.recv(1024)
    res = json.loads(respdata)
    if res["code"] != 0:
        print_align("[Enter]", "进入游戏失败了，因为: " + res["reason"])
        return False
    else:
        print_align("[Enter]", "进入游戏成功, 开始大玩儿一场吧, Let's Rocket it!")
        return True

def enter(client, playerid):
    # 等一秒钟，模拟用户点击进入游戏按钮
    sleep(1)

    print_align("[Enter]", "玩家 " + str(playerid) + " 快速点击了 [进入游戏] 按钮， 迫不及待了...")

    ret = req_enter(client)
    if ret == False:
        return False
    
    return True

def simulate_play():
    elpase = 5 # 等一下，就当在play
    print_align("[Play]", "先玩儿" + "["+str(elpase)+"S] 再说...")
    print_align("[Play]",  "Playing...")
    sleep(elpase)
    print_align("[Play]", "["+str(elpase)+"S]" + "时间到，该写作业了，拜拜下次再约...")
    
def close(client):
    print_align("[Close]", "断开链接, 下线了...")
    client.close()

# Player 生命周期
def play(playid, password):
    client = new_client()
    res = req_login(client, playid, password)
    if res == False:
        return

    res = enter(client, playid)
    if res == False:
        return
    
    simulate_play()

    close(client)

def Align(string, length=0):
    if length == 0:
        return string
    
    slen = len(string)
    re = string
    if isinstance(string, str):
        placeholder = ' '
    else:
        placeholder = u' '
    
    while slen < length:
        re += placeholder
        slen += 1
    
    return re

def print_align(name, string):
    print (Align(name, 10) + Align(string, 10))

# 模拟玩家个数
N = 1
BASEE = 100
def run():
    for idx in range(1, N+1):
        playerid = idx + BASEE
        print_align("[main]", "玩家 "+str(playerid) + " 准备进入游戏......")
        threading.Thread(target=play, args=(str(playerid), password)).start()

run()