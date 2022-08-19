--[[
	* 登录逻辑
]]

local skynet = require "skynet"
local s 	 = require "service"

require "response"
require "db"
require "utils"

--用于存放客户端消息处理方法
s.client = {}
s.client.login = function(fd, msg, source)
	skynet.error("[login] login")
	-- local message_len = #msg
	-- if message_len < 3 then
	-- 	local res = response(1, "failed", "Wrong Params")
	-- 	return res
	-- end

	local playerid 	= msg['playerid'] --tonumber(msg[2])
	local password  = msg['password'] --msg[3]
	local gate 		= source

    --校验用户名密码
	-- 此处要读取数据库，检验密码
	if is_password_valid(password) == false then
		local login_wrong_password = response(1, "failed", "Password is uncorrect")
		return login_wrong_password
	end
	skynet.error("[login] Password is correct.")

	--request login to agentmgr
	local node = skynet.getenv("node")
	local isok, agent = skynet.call("agentmgr", "lua", "reqlogin", playerid, node, gate)
	if not isok then
		local res = response(1, "failed", "failed to call mgr' reqlogin function")
		return res
	end

	--notify gateway service
	-- local nname = skynet.localname(".xxx")
	-- print("nname: ", nname)
	isok = skynet.call(gate, "lua", "sure_agent", fd, playerid, agent)
	if not isok then
		local res = response(1, "failed", "call sure_agent failed")
		return res
	end

	local login_success_res = response(0, "success")
    return login_success_res
end

--Gateway 会调用到该方法
--skynet.send(agent, "lua", "client", cmd, msg)
s.resp.client = function(source, fd, cmd, msg)
	skynet.error("[login] source: ", source)
	skynet.error("[login] Client fd: ", fd, cmd)
    if s.client[cmd] then
        local res = s.client[cmd](fd, msg, source)
        skynet.call(source, "lua", "send_by_fd", fd, res)
    else
        skynet.error("s.resp.client fail", cmd)
    end
end

s.start(...)

