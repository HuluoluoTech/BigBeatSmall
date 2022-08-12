--[[
* gateway 服务的实现
]]

local skynet = require "skynet"
local socket = require "skynet.socket"
local config_run = require "config_run"
local s = require "service" --import 的是 'service.lua', 在 lualib 中
local json = require "json"

require "utils" --import utils.lua, 包含了 pack / unpack 工具方法

-- 用于保存客户端连接信息
local conns = {} --[socket_id] = conn

--用于记录[已登录]的玩家信息
local players = {} --[playerid] = new_gateplayer

--连接类
local function new_conn()
    local m = {
        fd = nil, --socket fd
        playerid = nil, --playerid
    }

    return m
end

--玩家类
local function new_gateplayer()
    local m = {
        playerid = nil,
        agent = nil,
		conn = nil,
    }

    return m
end

--[[
    * 设置 service.lua 中的变量
    * 给 resp 添加方法:
    1/ send_by_fd
    2/ send
    3/ sure_agent
    4/ kick
]]

--用于login服务的消息转发，功能是将消息发送到指定fd的客户端
s.resp.send_by_fd = function(source, fd, msg)
    if not conns[fd] then
        return
    end

    -- local buff = str_pack(msg[1], msg)
    
        --debug
        -- skynet.error("send "..fd.." ["..buff[1].."] {"..table.concat( buff, ",").."}")
    

    -- local json_res = json.encode(buff)
	socket.write(fd, msg)

    print("response 数据写完毕, Data: ", msg)
end

--用于agent的消息转发，功能是将消息发送给指定玩家id的客户端
s.resp.send = function(source, playerid, msg)
	local gplayer = players[playerid]
    if gplayer == nil then
		return
    end
    local c = gplayer.conn
    if c == nil then
		return
    end

    s.resp.send_by_fd(nil, c.fd, msg)
end

--登录成功后确认接口
s.resp.sure_agent = function(source, fd, playerid, agent)
	local conn = conns[fd]
	if not conn then --登陆过程中已经下线
		skynet.call("agentmgr", "lua", "reqkick", playerid, "未完成登陆即下线")
		return false
	end

	conn.playerid = playerid

    local gplayer = new_gateplayer()
    gplayer.playerid = playerid
    gplayer.agent    = agent
	gplayer.conn     = conn

    --登录成功后，记录玩家信息
    players[playerid] = gplayer

    print("## 登录成功新建player: ", players[playerid].playerid)
    print("目前在线的玩家个数: ", count_table(players))
    for key, _ in pairs(players) do
        -- TODO  
        print("玩家ID: ", key)
    end

	return true
end

--第一种登出：客户端掉线
local disconnect = function(fd)
    local c = conns[fd]
    if not c then
        return
    end

    local playerid = c.playerid
    --还没完成登录
    if not playerid then
        return
    --已在游戏中
    else
        players[playerid] = nil
        local reason = "断线"
        skynet.call("agentmgr", "lua", "reqkick", playerid, reason)
    end
end

--第二种登出：gateway发送 reqkick 请求给 agentmgr
s.resp.kick = function(source, playerid)
    local gplayer = players[playerid]
    if not gplayer then
        return
    end

    local c = gplayer.conn
	players[playerid] = nil

    if not c then
        return
    end
    conns[c.fd] = nil

    disconnect(c.fd)
    socket.close(c.fd)
end

local process_msg = function(fd, msgstr)
    print("#gateway fd: ", fd)
    print("#gateway proccess_msg msgstr: "..msgstr)

    local cmd, msg = str_unpack(msgstr)
    skynet.error("#after unpack, recv "..fd.." ["..cmd.."] {"..table.concat( msg, ",").."}")

    print("#msg: ", dump(msg))
    print("#conns:", dump(conns))

    local conn = conns[fd]
    local playerid = conn.playerid
    print("#playerid: ", playerid)

    --尚未完成登录流程
    if not playerid then
        print("未登录状态， 准备登录...")
        local node = skynet.getenv("node")
        local nodecfg = config_run[node]
        local loginid = math.random(1, #nodecfg.login)
        --#TODO 为什么把 loginid 频道这里？？？
        --main创建服务的时候的login服务名称
        local login = "login"..loginid

        print("#登录参数:")
        print("#login: ", login)
        print("#cmd: ", cmd)
        print("#msg: ", dump(msg))
        print("#登录参数End")
		skynet.send(login, "lua", "client", fd, cmd, msg)
    --完成登录流程
    else
        local gplayer = players[playerid]
        local agent = gplayer.agent

        --client是自定义的消息名
		skynet.send(agent, "lua", "client", cmd, msg)
    end

    print("#proccess msg end")
end

local process_buff = function(fd, readbuff)
    while true do
        -- local msgstr, rest = string.match( readbuff, "(.-)\r\n(.*)")
        local msgstr, rest = string.match( readbuff, "(.-)#(.*)")
        print("#proccess buff, msgstr / rest: ", msgstr, rest)
        if msgstr then
            readbuff = rest
            process_msg(fd, msgstr)
        else
            return readbuff
        end
    end
end

--每一条连接接收数据处理
--协议格式 cmd,arg1,arg2,...#
local recv_loop = function(fd)
    socket.start(fd)
    skynet.error("socket connected " ..fd)

    local readbuff = ""
    while true do
        local recvstr = socket.read(fd)
        if recvstr then
        print("#recvstr: "..recvstr)
        readbuff = readbuff..recvstr
            readbuff = process_buff(fd, readbuff)
            print("#recv_loop readbuff: "..readbuff.."END")
        else
            skynet.error("socket close " ..fd)
			disconnect(fd)
            socket.close(fd)
            return
        end
    end
end

--有新连接时
local connect = function(fd, addr)
    print("connect from " .. addr .. " " .. fd)
	local c = new_conn()
    conns[fd] = c
    c.fd = fd

    skynet.fork(recv_loop, fd)
end

--服务启动后，service模块会调用s.init方法
function s.init()
    print("#gateway init")

    local node = skynet.getenv("node")
    local nodecfg = config_run[node]
    local port = nodecfg.gateway[s.id].port

    local listenfd = socket.listen("0.0.0.0", port)
    skynet.error("Gateway Listen socket :", "0.0.0.0", port)

    --skynet.fork发起协程，协程recv_loop是个循环
    socket.start(listenfd , connect)
end

-- start
s.start(...)

--[[ 带有粘包处理
function process_msgbuff(id, msgbuff)
    skynet.error("process_msgbuff" .. msgbuff)
    
    local cmd, msg = jspack.unpack(msgbuff)
    
    print(cmd)
    print(msg.hello)
    print(msg.a)
    --socket.write(id, msgbuff)
    --分发
end

function process_buff(id, readbuff)
    while true do
        local bufflen = string.len(readbuff)
        if bufflen < 2 then 
            break
        end
        local len, remain = string.unpack(string.format("> i2 c%d", bufflen-2), readbuff)
        if bufflen < len then
            break
        end

        local str, nextbuff = string.unpack(string.format("> c%d c%d", len, bufflen-2-len), remain)
        readbuff = nextbuff or ""
        
        process_msgbuff(id, str)
    end
    return  readbuff 
end

--每一条连接做处理
function run(id)
    socket.start(id)
    local readbuff = ""
	while true do
		local str = socket.read(id)
        if str then
            readbuff = readbuff..str
            skynet.error("recv " ..str)
            readbuff = process_buff(id, readbuff)
        else
            skynet.error("close " ..id)
            socket.close(id)
            return
		end
	end
end
--]]
