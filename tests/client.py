import socket

import json
import threading
from time import sleep

host = '127.0.0.1'
port = 8001

password = "123"

###
# 通信协议：
#
# login 登录协议： login,playerid,password#
# enter 进入游戏： enter#
# 
#
###

def new_client():
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client.connect((host, port))

    return client
    
def reqlogin(playerid, password):
    reqdata = "login," + playerid + "," + password + "#"
    print("reqdata: ", reqdata)

    client = new_client()
    client.send(reqdata.encode('utf-8'))
    respdata = client.recv(1024)

    res = json.loads(respdata)
    print("res: ", res)
    # if res['code'] != 0:
    #     print("登录失败， 原因: ", res["reason"])
    #     return
      
    # 等一秒钟，模拟用户点击进入游戏按钮
    sleep(1)

    print("玩家 ", playerid, " 点击了 [进入游戏] 按钮")
    enter(client)

    simulate_play()
    close(client)

    return respdata

def simulate_play():
    sleep(500) # 等一下，就当在play
    
def close(client):
    client.close()

def enter(client):
    reqdata = "enter#"
    client.send(reqdata.encode('utf-8'))
    respdata = client.recv(1024)
    print("进入游戏返回数据: ", respdata.decode('utf-8'))

threading.Thread(target=reqlogin, args=("1001", password)).start()
# threading.Thread(target=reqlogin, args=("1002", password)).start()