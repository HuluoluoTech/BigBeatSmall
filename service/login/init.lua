--[[
	* 登录逻辑
]]

local json = require "json"
local skynet = require "skynet"
local s = require "service"

require "response"
require "db"

--用于存放客户端消息处理方法
s.client = {}
s.client.login = function(fd, msg, source)
	local message_len = #msg
	if message_len < 3 then
		local res = response(1, "failed", "参数个数错误")
		return res
	end

	local playerid 	= tonumber(msg[2])
	local password  = tonumber(msg[3])
	local gate 		= source

    --校验用户名密码
	-- 此处要读取数据库，检验密码
	if is_password_valid(password) == false then
		local login_wrong_password = response(1, "failed", "密码错误")
		return login_wrong_password
	end

	--发给agentmgr
	local node = skynet.getenv("node")
	local isok, agent = skynet.call("agentmgr", "lua", "reqlogin", playerid, node, gate)
	if not isok then
		print("主播")
		local res = response(1, "failed", "请求mgr失败")
		return res
	end

	--登录校验成功，通知gateway记录登录状态
	isok = skynet.call(gate, "lua", "sure_agent", fd, playerid, agent)
	if not isok then
		local res = response(1, "failed", "gate注册失败")
		return res
	end

	local login_success_res = response(0, "success")
    return login_success_res
end

--Gateway 会调用到该方法
--skynet.send(agent, "lua", "client", cmd, msg)
s.resp.client = function(source, fd, cmd, msg)
    if s.client[cmd] then
        local res = s.client[cmd]( fd, msg, source)
        skynet.send(source, "lua", "send_by_fd", fd, res)
    else
        skynet.error("s.resp.client fail", cmd)
    end
end

s.start(...)

