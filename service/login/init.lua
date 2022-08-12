--[[
	* 登录逻辑
]]

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

	--回应gate
	isok = skynet.call(gate, "lua", "sure_agent", fd, playerid, agent)
	print("#sure_agent return: ", isok)
	if not isok then
		return {"login", 1, "gate注册失败"}
	end

    skynet.error("login succ "..playerid)

    return {"login", 0, "登陆成功"}
end

--给resp添加client方法
s.resp.client = function(source, fd, cmd, msg, dm)
	print("#login client :")
	print("#soure: ", source)
	print("#fd: ", fd)
	print("#cmd: ", cmd)
	-- print("#msg: ", dump(msg))
	print("#dm: ", dm)

    if s.client[cmd] then
        local ret_msg = s.client[cmd]( fd, msg, source)
		print("#ret_msg: ", ret_msg)
        skynet.send(source, "lua", "send_by_fd", fd, ret_msg)
    else
        skynet.error("s.resp.client fail", cmd)
    end
end

s.start(...)

