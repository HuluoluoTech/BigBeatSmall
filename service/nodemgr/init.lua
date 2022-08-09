--[[
	* 节点管理服务，每个节点会开启一个
]]
local skynet = require "skynet"
local s = require "service"

-- service.lua resp 再添加一个方法 
s.resp.newservice = function(source, name, ...)
	local srv = skynet.newservice(name, ...)
	return srv
end

s.start(...)