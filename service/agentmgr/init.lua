--[[
	* 管理agent的服务，它是登录过程的仲裁服务，控制着登录流程。

	职责：
	1、登录仲裁：判断玩家是否在线
	2、顶替已在线玩家：如果角色已在线，踢下去。
	3、记录在线信息：将新建的mgrplayer对象记录为STATUS.LOGIN（登录中）状态
	4、请求nodemgr创建agent服务
	5、登录完成，设置mgrplayer为STATUS.GAME状态（游戏中），并返回true及agent服务的id
]]

local skynet = require "skynet"
local s = require "service"

--状态
STATUS = {
	LOGIN 	= 2, --登录中
	GAME 	= 3, --游戏中，已经登录
	LOGOUT 	= 4, --登出中
}

--所有玩家的[在线]状态
local players = {}

--创建玩家
local function new_mgrplayer()
    local m = {
        playerid 	= nil, --玩家id
		node 		= nil, --玩家对应gateway和agent所在的节点
        agent 		= nil, --玩家对应agent服务的id
		status 		= nil, --状态
		gate 		= nil, --玩家对应gateway的id
    }

    return m
end

--[[
	* service.lua 添加 resp 方法
	1/ reqlogin
	2/ reqkick
]]
s.resp.reqlogin = function(source, playerid, node, gate)
	print("#agentmgr reqlogin playerid: ", playerid)

	local mplayer = players[playerid]
	--登陆过程禁止顶替
	if mplayer and mplayer.status == STATUS.LOGOUT then
		print("不能顶替掉。。。")
		skynet.error("reqlogin fail, at status LOGOUT " ..playerid)
		return false
	end

	if mplayer and mplayer.status == STATUS.LOGIN then
		skynet.error("reqlogin fail, at status LOGIN " ..playerid)
		return false
	end

	--在线，顶替
	if mplayer then
		print("#同一个角色，踢掉 playerid : ", mplayer.playerid)
		local pnode 	= mplayer.node
		local pagent 	= mplayer.agent
		local pgate 	= mplayer.gate
		mplayer.status 	= STATUS.LOGOUT,

		--#TODO: 为什么s.call直接调用，call 方法不是在 M 中？？？
		s.call(pnode, pagent, "kick")
		s.send(pnode, pagent, "exit")
		s.send(pnode, pgate, "send", playerid, {"kick","顶替下线"})
		s.call(pnode, pgate, "kick", playerid)
	end

	--上线
	local player    = new_mgrplayer()

	player.playerid = playerid
	player.node 	= node
	player.gate 	= gate
    player.agent 	= nil
	player.status 	= STATUS.LOGIN

	players[playerid] = player

	print("#创建新的 player, and status: ", player.status)

	local agent = s.call(node, "nodemgr", "newservice", "agent", "agent", playerid)
	print("#新的agent创建成功。。。")
	player.agent 	= agent
	player.status 	= STATUS.GAME

	return true, agent
end

s.resp.reqkick = function(source, playerid, reason)
	print("#agentmgr reqkick reason: ", reason)
	
	local mplayer = players[playerid]
	if not mplayer then
		return false
	end

	if mplayer.status ~= STATUS.GAME then
		return false
	end

	local pnode 	= mplayer.node
	local pagent 	= mplayer.agent
	local pgate 	= mplayer.gate
	mplayer.status 	= STATUS.LOGOUT

	s.call(pnode, pagent, "kick")
	s.send(pnode, pagent, "exit")
	s.send(pnode, pgate, "kick", playerid)

	players[playerid] = nil

	return true
end

--情况 永不下线

s.start(...)
