import socket

from questionary import password

host = '127.0.0.1'
port = 8001

userid = 123
password = "123"

client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client.connect((host, port))
# msg = 'hello'
# client.send(msg.encode('utf-8'))
# data = client.recv(1024)
# print("服务的发来的消息：%s" %data)

# 客户端 reqlogin 格式: login, userid, password#

def reqlogin():
    reqdata = "login," + "1001"+","+password+"#"
    print("reqdata: ", reqdata)
    client.send(reqdata.encode('utf-8'))
    respdata = client.recv(1024)
    print("登录返回：", respdata)

def close():
    client.close()

reqlogin()