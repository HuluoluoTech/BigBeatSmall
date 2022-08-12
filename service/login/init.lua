--[[
	* 登录逻辑
]]

local json = require "json"
local skynet = require "skynet"
local s = require "service"

--用于存放客户端消息处理方法
s.client = {}
s.client.login = function(fd, msg, source)
	local playerid = tonumber(msg[2])
	print("登录方法中：")
	print("playerid: ", playerid)

	local pw = tonumber(msg[3])
	local gate = source

	local node = skynet.getenv("node")
    --校验用户名密码
	-- 此处要读取数据库，检验密码
	if pw ~= 123 then
		return {"login", 1, "密码错误"}
	else
		print("密码正确...")
	end

	--发给agentmgr
	local isok, agent = skynet.call("agentmgr", "lua", "reqlogin", playerid, node, gate)
	print("#isok: ", isok)
	if not isok then
		return {"login", 1, "请求mgr失败"}
	end

	--登录校验成功，通知gateway记录登录状态
	isok = skynet.call(gate, "lua", "sure_agent", fd, playerid, agent)
	print("#sure_agent return: ", isok)
	if not isok then
		return {"login", 1, "gate注册失败"}
	end

    skynet.error("login success "..playerid)

	local login_res = {
		["code"] = 0,
		["status"] = "success"
	}
	local res = json.encode(login_res)
    return res
end

--给resp添加client方法
s.resp.client = function(source, fd, cmd, msg)
	print("#login client")
	print("#soure	: ", source)
	print("#fd		: ", fd)
	print("#cmd		: ", cmd)

    if s.client[cmd] then
        local ret_msg = s.client[cmd]( fd, msg, source)
		print("#Response Message: ", ret_msg)
        skynet.send(source, "lua", "send_by_fd", fd, ret_msg)
    else
        skynet.error("s.resp.client fail", cmd)
    end
end

s.start(...)

