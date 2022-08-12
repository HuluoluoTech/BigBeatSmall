--[[
	* 玩家登录后，gateway会将客户端协议转发给agent, 也就是游戏逻辑部分
]]

local skynet = require "skynet"
local s = require "service"

s.client = {}
s.gate = nil --用于保存玩家对应gateway的id

require "scene"
--登录后客户端发送“work”协议，s.client.work方法将被调用。
s.client.work = function(msg)
	print("#agent working......")
	s.data.coin = s.data.coin + 1
	return {"work", s.data.coin}
end

-- service.lua resp 添加方法
s.resp.client = function(source, cmd, msg)
	print("#agent cmd => ", cmd)
    s.gate = source
    if s.client[cmd] then
		local ret_msg = s.client[cmd]( msg, source)
		if ret_msg then
			skynet.send(source, "lua", "send", s.id, ret_msg) 
		end
    else
        skynet.error("s.resp.client fail", cmd)
    end
end

s.resp.kick = function(source)
	s.leave_scene()
	--在此处保存角色数据
	skynet.sleep(200)
end

s.resp.exit = function(source)
	print("#agent exit.")

	skynet.exit()
end

s.resp.send = function(source, msg)
	skynet.send(s.gate, "lua", "send", s.id, msg)
end

s.init = function( )
	--playerid = s.id
	--在此处加载角色数据
	skynet.sleep(200)

	s.data = {
		coin = 100,
		hp = 200,
	}
end

s.start(...)