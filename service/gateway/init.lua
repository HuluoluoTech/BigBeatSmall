--[[
    * gateway 服务的实现
]]

local skynet        = require "skynet"
local config_run    = require "config_run"
local socketdriver  = require "skynet.socketdriver"
local netpack       = require "skynet.netpack"
local s             = require "service" --import 的是 'service.lua', 在 lualib 中

--import utils.lua, 包含了 pack / unpack 工具方法
require "utils"
require "protoparser"

local queue

-- 用于保存客户端连接信息
-- [socket_id] = conn
local conns = {}

--用于记录[已登录]的玩家信息
--[playerid] = new_gateplayer
local players = {}

--连接类
local function new_conn()
    local m = {
        fd       = nil, --socket fd
        playerid = nil, --playerid
    }

    return m
end

--玩家类
local function new_gateplayer()
    local m = {
        playerid = nil,
        agent    = nil,
		conn     = nil,
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
    skynet.error("[gateway] send_by_fd: ", fd, msg)

    if not conns[fd] then
        return
    end

    socketdriver.send(fd, msg)

    skynet.error("[gateway] Write response Data to Player.\n")
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
    skynet.error("[gateway] sure_agent")

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

    print("[gateway] Create New GatePlayer: ", players[playerid].playerid)
    print("[gateway] Online Players: ", count_table(players))
    for key, _ in pairs(players) do
        skynet.error("[gateway] PlayerID: ", key)
    end
    skynet.error("\n")

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
        local reason = "disconnect"
        skynet.call("agentmgr", "lua", "reqkick", playerid, reason)
    end
end

--第二种登出：gateway发送 reqkick 请求给 agentmgr
s.resp.kick = function(source, playerid)
    skynet.error("[gateway] kick")
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
    socketdriver.close(c.fd)
end

function process_msg(fd, msgstr)
    skynet.error("[gateway] process_msg: ", msgstr)

    local buff = parse(msgstr)
    if not buff then
        return
    end

    -- local cmd, msg  = str_unpack(msgstr)
    local cmd       = buff.cmd
    local msg       = buff --buff.password

    local conn      = conns[fd]
    local playerid  = conn.playerid
    --playerid is nil
    if not playerid then
        print("[gateway] Ready to Login...")
        local node = skynet.getenv("node")
        local nodecfg = config_run[node]
        local loginid = math.random(1, #nodecfg.login)

        --main创建服务的时候的login服务名称
        local login = "login"..loginid

        print("\n[gateway] Login params:")
        print("#Login Server: ", login)
        print("#Login CMD   : ", cmd)
        print("#Login Params: ", dump(msg))
        print("\n")

		skynet.send(login, "lua", "client", fd, cmd, msg)
    else
        local gplayer = players[playerid] 
        local agent   = gplayer.agent

        --client是自定义的消息名
		skynet.send(agent, "lua", "client", cmd, msg)
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------

-- 链接处理
function process_connect(fd, addr)
    skynet.error("[gateway] new conn fd:"..fd.." addr:"..addr)

	local c = new_conn()
    conns[fd] = c
    c.fd = fd

    socketdriver.start(fd)
end

--关闭连接
function process_close(fd)
    skynet.error("close fd:"..fd)
    netpack.clear(queue)
end

--发生错误
function process_error(fd, error)
    skynet.error("error fd:"..fd.." error:"..error)
end

--发生警告
function process_warning(fd, size)
    skynet.error("warning fd:"..fd.." size:"..size)
end

--处理消息
function process_data(fd, msg, sz)
    local str = netpack.tostring(msg,sz)
    process_msg(fd, str)
end

--收到多于1条消息时
function process_more()
    for fd, msg, sz in netpack.pop, queue do
        skynet.fork(process_data, fd, msg, sz)
    end
end
----------------------------------------------------------------------------------------------------------------------------------
-- message queue

--解码底层传来的SOCKET类型消息
function socket_unpack( msg, sz )
    -- skynet.error("[netpack] unpack... msg: ", dump(msg))
    return netpack.filter( queue, msg, sz)
end

--处理底层传来的SOCKET类型消息
function socket_dispatch(_, _, q, type, ...)
    skynet.error("[gateway] socket_dispatch type:"..(type or "nil"))
    if type == nil then
        return
    end

    queue = q
    if type == "open" then
        process_connect(...)
    elseif type == "data" then
        process_data(...)
    elseif type == "more" then
        process_more(...)
    elseif type == "close" then
        process_close(...)
    elseif type == "error" then
        process_error(...)
    elseif type == "warning" then
        process_warning(...)
    end
end

-- 开启8888端口的监听，当有网络事件（新连接、连接关
-- 闭、收到数据）发生时，先用socket_unpack方法解析它，再用
-- dispatch方法处理它。
function init()
    skynet.error("[gateway] Init...")

    --注册SOCKET类型消息
    skynet.register_protocol({
        name = "socket",
        id = skynet.PTYPE_SOCKET,
        unpack = socket_unpack,
        dispatch = socket_dispatch,
    })

    local node      = skynet.getenv("node")
    local nodecfg   = config_run[node]
    local port      = nodecfg.gateway[s.id].port
    local listenfd  = socketdriver.listen("0.0.0.0", port)

    skynet.error("[Gateway] Listening socket :", "0.0.0.0", port)

    socketdriver.nodelay(listenfd)
    socketdriver.start(listenfd)
end

s.start(...)
