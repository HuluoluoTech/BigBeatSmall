--[[
	* main 服务， 主要职责
	1、启动nodemgr
	2、启动cluster
	3、启动gateway
	4、启动login
	5、启动agentmgr
	6、启动scene
]]
local skynet = require "skynet"
local skynet_manager = require "skynet.manager"
local cluster = require "skynet.cluster"
local config_run = require "config_run"

-- 打印吉祥物
require("utils")
print_mascot()

--[[
* 剥离一个function出来，所有的closure看着比较乱的感觉，包括Rust的！
* 执行逻辑
]]
local function run()
	--初始化当前Node
	local current_node = skynet.getenv("node")
	local node_cfg = config_run[current_node]

	--[[
		* 节点管理
		* nodemgr : node = 1 : 1
	]]
	local node_mgr = skynet.newservice("nodemgr","nodemgr", 0)
	skynet.name("nodemgr", node_mgr)
	skynet.error("nodemgr service ID: ", node_mgr)

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

--服务入口
skynet.start(run)