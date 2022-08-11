--[[
	* service模块是对Skynet服务的一种封装。
]]

local skynet = require "skynet"
local cluster = require "skynet.cluster"
local utils = require "utils"

-- #TODO
-- 为什么 这个 M 变量名经常出现？？？
local M = {
	name = "", 	--服务类型
	id = 0,		--服务id

	--回调函数
	exit = nil,
	init = nil,

	resp = {}, --resp表会存放着消息处理方法
}

--[[
function exit_dispatch()
	if M.exit then
		M.exit()
	end
	skynet.ret()
	skynet.exit()
end
--]]

function traceback(err)
	skynet.error(tostring(err))
	skynet.error(debug.traceback())
end

local dispatch = function(session, address, cmd, ...)
	local fun = M.resp[cmd]
	if not fun then
		--将 message size 对应的消息附上当前消息的 session ，以及 skynet.PTYPE_RESPONSE 这个类别，发送给当前消息的来源 source .
		skynet.ret()
		return
	end

	--xpcall安全的调用fun方法
	local ret = table.pack(xpcall(fun, traceback, address, ...))
	local isok = ret[1]

	if not isok then
		skynet.ret()
		return
	end

	skynet.retpack(table.unpack(ret,2))
end

function init()
	print("#service init()")
	print("M: "..dump(M))

	--注册消息的处理函数
	skynet.dispatch("lua", dispatch)
	if M.init then
		M.init()
	end
end

--两个工具方法，对 本地 、cluster的封装
function M.call(node, srv, ...)
	local mynode = skynet.getenv("node")
	if node == mynode then
		return skynet.call(srv, "lua", ...)
	else
		return cluster.call(node, srv, ...)
	end
end

function M.send(node, srv, ...)
	local mynode = skynet.getenv("node")
	if node == mynode then
		return skynet.send(srv, "lua", ...)
	else
		return cluster.send(node, srv, ...)
	end
end

function M.start(name, id, ...)
	print("#service name: "..name..", id: "..tostring(id))

	M.name = name
	M.id = tonumber(id)
	skynet.start(init)
end

return M