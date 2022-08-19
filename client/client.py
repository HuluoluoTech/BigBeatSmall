import socket
import json
import threading
from time import sleep
from bitstring import pack
from bitstring import BitStream
from utils import print_align
from config import HOST, PORT, PASSWORD
import protofiles.login_pb2 as login_pb
import protofiles.header_pb2 as header_pb
import protofiles.enter_pb2 as enter_pb
    
###############################################################################
#
# 客户端发起的通信协议格式
# 1 登录协议： login,playerid,PASSWORD
# 2 进入游戏： enter
# 3 移动协议： shift, x, y
#
###############################################################################
def protocol_login(playerid, PASSWORD):
    res = "login," + playerid + "," + PASSWORD
    return res

def protocol_enter():
    res = "enter"
    return res

def protocol_shift(x, y):
    res = "shift," + x + "," + y
    return res

###############################################################################
#
# 使用bitstring打包通信协议格式
# 1 登录协议： pack(login,playerid,PASSWORD)
# 2 进入游戏： enter
# 3 移动协议： shift, x, y
#
###############################################################################

def pack_login(playerid, PASSWORD):
    protocol_login_bin = protocol_login(playerid, PASSWORD)
    bin = pack('uint:16, bits:104', 13, bytes(protocol_login_bin.encode('utf-8')))
    return bin

def pack_enter():
    protocol_enter_bin = protocol_enter()
    bin = pack('uint:16, bits:40', 5, bytes(protocol_enter_bin.encode('utf-8')))
    return bin

def pack_shift(x, y):
    protocol_shift_bin = protocol_shift(x, y)
    bin = pack('uint:16, bits:104', 13, bytes(protocol_shift_bin.encode('utf-8')))
    return bin

def protoc_enter():
    enter = enter_pb.Enter()
    enter.id = 2
    return enter.SerializeToString()

def protoc_login(playerid):
    login = login_pb.Login()
    login.id = 3
    login.playerid = playerid
    login.password = PASSWORD
    return login.SerializeToString()
    
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
# 1. 请求登录
# 2. 请求进入
#
###############################################################################
def req_login(client, playerid, PASSWORD):
    print_align("[Login]", "娱乐一下，登录游戏看看...")

    pl = protoc_login(int(playerid))
    bin = pack('uint:16, bits:72', 9, bytes(pl))
    client.send(bin.tobytes())
    
    # client.send(pack_login(playerid, PASSWORD).tobytes())
    respdata = client.recv(1024)

    res = json.loads(respdata)
    if res["code"] != 0:
        print_align("[Login]", "Woopo... 登录失败了，因为: " + res["reason"])
        return False
    else:
        print_align("[Login]", "恭喜，网络还行，登录成功了， 马上进入游戏开始Play吧...")
        return True

def req_enter(client, playerid):
    print_align("[Enter]", "玩家 " + str(playerid) + " 快速点击了 [进入游戏] 按钮， 迫不及待了...")

    # 等一秒钟，模拟用户点击进入游戏按钮
    sleep(1)

    pe = protoc_enter()
    bin = pack('uint:16, bits:16', 2, bytes(pe))
    client.send(bin.tobytes())

    # protocol = pack_enter()
    # client.send(protocol.tobytes())
    respdata = client.recv(1024)
    res = json.loads(respdata)
    if res["code"] != 0:
        print_align("[Enter]", "进入游戏失败了，因为: " + res["reason"])
        return False
    else:
        print_align("[Enter]", "进入游戏成功, 开始大玩儿一场吧, Let's Rocket it!")
        return True

###############################################################################
#
# 客户端游戏具体逻辑（shift协议在此执行...）
#
###############################################################################
def simulate_play():
    elpase = 5 # 等一下，就当在play
    print_align("[Play]", "先玩儿" + "["+str(elpase)+"S] 再说...")
    print_align("[Play]",  "Playing...")

    # 游戏逻辑
    sleep(elpase)
    
    print_align("[Play]", "["+str(elpase)+"S]" + "时间到，该写作业了，拜拜下次再约...")
    
def close(client):
    print_align("[Close]", "断开链接, 下线了...")
    client.close()

###############################################################################
#
# 客户端 Player 生命周期
#
###############################################################################
def play(playid, PASSWORD):
    client = new_client()
    res = req_login(client, playid, PASSWORD)
    if res == False:
        return

    res = req_enter(client, playid)
    if res == False:
        return
    
    simulate_play()

    close(client)

###############################################################################
#
# 客户端发起模拟
#
###############################################################################
# 玩家个数
N = 1 

# 玩家基础值
BASEE = 100

# 开启游戏
def run():
    for idx in range(1, N+1):
        playerid = idx + BASEE
        print_align("[main]", "玩家 "+str(playerid) + " 准备进入游戏......")
        threading.Thread(target=play, args=(str(playerid), PASSWORD)).start()

run()