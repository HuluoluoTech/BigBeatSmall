import socket

import json

host = '127.0.0.1'
port = 8001

userid = 123
password = "123"

client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client.connect((host, port))

def reqlogin():
    reqdata = "login," + "1001"+","+password+"#"
    print("reqdata: ", reqdata)
    client.send(reqdata.encode('utf-8'))
    respdata = client.recv(1024)
    # print("登录返回： ", json.dumps(respdata).decode("utf-8"))
    print("登录返回： ", respdata.decode("utf-8"))

def close():
    client.close()

reqlogin()