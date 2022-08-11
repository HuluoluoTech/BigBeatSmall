--[[
* service 的入口函数
]]

-- import 必要的 package
local skynet = require "skynet"
local skynet_manager = require "skynet.manager"
local cluster = require "skynet.cluster"
local config_run = require "config_run"

-- local package_path = package.path
-- package.path = package_path.."./lualib/utils.lua"
-- print("package path: "..package.path)

local utils = require("utils")

--[[
* 剥离一个function出来，目前直接closure看着不太舒服，比较乱的感觉
* 执行逻辑
]] 
local function run()
	print_mascot()

	--初始化当前Node
	local current_node = skynet.getenv("node")
	local node_cfg = config_run[current_node]

	--节点管理
	--[[
		* API: newservice

		newservice(name, ...) 启动一个名为 name 的新服务。
		- name 是脚本的名字（不用写 .lua 后缀）
		- 这是一个阻塞 API
	]]
	local node_mgr = skynet.newservice("nodemgr","node_mgr", 0)
	skynet.name("node_mgr", node_mgr)

	--集群
	cluster.reload(config_run.cluster)
	cluster.open(current_node)

	--开启gate服务
	for i, v in pairs(node_cfg.gateway or {}) do
		local srv = skynet.newservice("gateway","gateway", i)
		skynet.name("gateway"..i, srv)
	end

	--开始login服务
	for i, v in pairs(node_cfg.login or {})  do
	local srv = skynet.newservice("login","login", i)
		skynet.name("login"..i, srv)
	end

	--开启agentmgr服务
	--#TODO
	--agentmgr 设为全局服务？？？
	local anode = config_run.agentmgr.node
	if current_node == anode then
		local srv = skynet.newservice("agentmgr", "agentmgr", 0)
		skynet.name("agentmgr", srv)
	else
		local proxy = cluster.proxy(anode, "agentmgr")
		skynet.name("agentmgr", proxy)
	end

	--scene (sid->sceneid)服务
	for _, sid in pairs(config_run.scene[current_node] or {}) do
		local srv = skynet.newservice("scene", "scene", sid)
		skynet.name("scene"..sid, srv)
	end

	--退出服务
	skynet.exit()
end

--开启服务
skynet.start(run)