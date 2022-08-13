--[[
    用于处理agent的战斗逻辑
]]
local skynet = require "skynet"
local config_run = require "config_run"
local mynode = skynet.getenv("node")
local s = require "service"

s.client = {}

s.snode = nil --scene_node 场景服务的节点
s.sname = nil --scene_id 名字

--[[
    * agent应尽可能地进入个同节点的scene
    #TODO: 如果为了同一个节点高选中，不用真加入！！！
    【用区间取值法控制、0-10，随机落到0-9的都取同节点】
]]
local function random_scene()
    local nodes = {}

    --把所有配置了场景服务的节点都放在表nodes中
    --同一节点（mynode）会插入多次
    --使它能有更高被选中的概率
    for i, v in pairs(config_run.scene) do
        table.insert(nodes, i)

        if config_run.scene[mynode] then
            table.insert(nodes, mynode)
        end
    end

    local idx = math.random(1, #nodes)
    local scenenode = nodes[idx]

    --具体场景
    local scenelist = config_run.scene[scenenode]
    idx = math.random( 1, #scenelist)
    local sceneid = scenelist[idx]

    return scenenode, sceneid
end

-- --[[
--     进入战斗
-- ]]
s.client.enter = function(msg)
    print("#agent 进入游戏")

    if s.sname then
        local res = response(1, "failed", "已在场景")
        return res
    end

    local snode, sid = random_scene()
    local sname = "scene"..sid
    local isok = s.call(snode, sname, "enter", s.id, mynode, skynet.self())
    if not isok then
        local res = response(1, "failed", "进入失败")
        return res
    end

    s.snode = snode
    s.sname = sname

    return nil
end

-- --[[
--     * 玩家改变移动方向
--     * client 发送 shift协议 给 服务端
-- ]]
s.client.shift = function(msg)
    if not s.sname then
        return
    end

    local x = msg[2] or 0
    local y = msg[3] or 0

    s.call(s.snode, s.sname, "shift", s.id, x, y)
end

-- --[[
--     给场景服务发送leave消息
--     #TODO: 关于 S 中方法的组织问题？
--     resp / client ????
-- ]]
s.leave_scene = function()
    --不在场景
    if not s.sname then
        return
    end

    s.call(s.snode, s.sname, "leave", s.id)

    s.snode = nil
    s.sname = nil
end