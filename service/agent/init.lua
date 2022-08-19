--[[
	* 玩家登录后，gateway会将客户端协议转发给agent, 也就是游戏逻辑部分
]]

local skynet = require "skynet"
local s 	 = require "service"

require "db"
require "sceneapi"

-- s.client = {}
s.gate = nil --用于保存玩家对应gateway的id

--登录后客户端发送“work”协议，s.client.work方法将被调用。
s.client.work = function(msg)
	print("#agent working......")
	s.data.coin = s.data.coin + 1

	local data = {
		["coin"] = s.data.coin
	}
	local res = response_with_data(0, "success", data)
	return res
end

--[[
	* client 协议
]]
s.resp.client = function(source, cmd, msg)
	print("#agent cmd => ", cmd)

	for i, v in pairs(s.client) do
		print("I: ", i)
	end
	s.gate = source 
    if s.client[cmd] then
		local ret_msg = s.client[cmd]( msg, source)
		print("Return Message: ", ret_msg)
		if ret_msg then
			skynet.send(source, "lua", "send", s.id, ret_msg)
		end
    else
        skynet.error("s.resp.client fail", cmd)
		local res = response(1, "failed", "调用了未知的方法 => ["..cmd.."]")
		skynet.send(source, "lua", "send", s.id, res)
    end
end

--[[
	当客户端掉线时，agent需要向场景服务请求退出
]]
s.resp.kick = function(source)
	s.leave_scene()

	save_player_data()

	--模拟保存时间
	skynet.sleep(200)
end

--[[
	退出服务
]]
s.resp.exit = function(source)
	print("[agent] exit.")

	skynet.exit()
end

s.resp.send = function(source, msg)
	skynet.send(s.gate, "lua", "send", s.id, msg)
end

s.init = function( )
	--playerid = s.id
	skynet.error("[agent] init")

	load_player_data()

	s.data = {
		coin = 100,
		hp = 200,
	}
end

s.start(...)