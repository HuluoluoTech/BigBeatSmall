--[[
	* 节点管理服务，每个节点会开启一个

	职责：
	1、提供创建服务的远程调用接口
]]
local skynet = require "skynet"
local s = require "service"

-- service.lua resp 再添加一个方法 
s.resp.newservice = function(source, name, ...)
	print("#nodemgr.newservice source: "..source)

	local srv = skynet.newservice(name, ...)
	return srv
end

s.start(...)