import socket

import json
import threading
from time import sleep

host = '127.0.0.1'
port = 8001

password = "123"

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
    # print("登录返回： ", json.dumps(respdata).decode("utf-8"))
    print("登录返回： ", respdata.decode("utf-8"))

    simulate_play()
    close(client)

    return respdata

def simulate_play():
    sleep(500) # 等一下，就当在play
    
def close(client):
    client.close()

threading.Thread(target=reqlogin, args=("1001", password)).start()
threading.Thread(target=reqlogin, args=("1002", password)).start()