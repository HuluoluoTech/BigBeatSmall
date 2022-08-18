--[[
	* service模块是对Skynet服务的一种封装。
]]

local skynet = require "skynet"
local cluster = require "skynet.cluster"

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

function traceback(err)
	skynet.error("[service] traceback error : ", tostring(err))
	skynet.error(tostring(err))
	skynet.error(debug.traceback())
end

local dispatch = function(session, address, cmd, ...)
	skynet.error("[service] dispatch: ", cmd)

	local fun = M.resp[cmd]
	if not fun then
		--将 message size 对应的消息附上当前消息的 session ，以及 skynet.PTYPE_RESPONSE 这个类别，发送给当前消息的来源 source .
		skynet.error("function "..cmd.."Not Found.")
		skynet.ret()
		return
	end

	--xpcall安全的调用方法
	local ret = table.pack(xpcall(fun, traceback, address, ...))
	skynet.error("xpcall call: "..cmd.." result: "..": ", ret[1])
	-- for i, v in pairs(ret) do
	-- 	print("#ret: ", i, v)
	-- end
	-- print("\n")

	local isok = ret[1]
	if not isok then
		skynet.error("xpcall failed to call: "..cmd)
		skynet.ret()
		return
	end

	skynet.retpack(table.unpack(ret,2))
end

function init()
	print("[service] M.init")

	--注册消息的处理函数
	skynet.dispatch("lua", dispatch)

	if M.init then
		M.init()
	end
end

--两个工具方法，对 本地 、cluster的封装
function M.call(node, srv, ...)
	print("[service] M.call: ", node, srv)

	local mynode = skynet.getenv("node")
	if node == mynode then
		return skynet.call(srv, "lua", ...)
	else
		return cluster.call(node, srv, ...)
	end
end

function M.send(node, srv, ...)
	skynet.error("[service] M.send: ", node, srv)

	local mynode = skynet.getenv("node")
	if node == mynode then
		return skynet.send(srv, "lua", ...)
	else
		return cluster.send(node, srv, ...)
	end
end

function M.start(name, id, ...)
	print("[service] name: "..name..", id: "..tostring(id))

	M.name = name
	M.id = tonumber(id)

	skynet.start(init)
end

M.resp.exit = function ()
	if M.exit then
		M.exit()
	end

	skynet.ret()
	skynet.exit()
end

return M