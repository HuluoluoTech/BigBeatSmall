import socket

host = '127.0.0.1'
port = 8001
client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client.connect((host, port))
msg = 'hello'
client.send(msg.encode('utf-8'))
data = client.recv(1024)
print("服务的发来的消息：%s" %data)
client.close()