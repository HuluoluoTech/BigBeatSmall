local skynet = require "skynet"
local s = require "service"
require "response"
require "entity"
require "utils"
require "protocol"

--玩家 <=> ball 的映射关系
--[playerid] = ball
local balls = {}

--食物的映射
--[id] = food
local foods = {}

local food_maxid = 0
local food_count = 0

local max_food_nums = 50

--广播
-- local function broadcast(msg)
--     for i, v in pairs(balls) do
--         s.send(v.node, v.agent, "send", msg)
--     end
-- end

--进入
s.resp.enter = function(source, playerid, node, agent)
    print("#Secne....")

    if balls[playerid] then
        skynet.error("已经有了映射关系,不用再次创建Ball对象")
        return false
    end

    local b = new_ball(playerid)
    --新建Ball，马上进行广播
    local entermsg = {"enter", playerid, b.x, b.y, b.size}
    broadcast(balls, entermsg)

    b.node = node
    b.agent = agent

    --回应
    local res = response(0, "success", "进入场景成功")
    s.send(b.node, b.agent, "send", res)

    --记录映射关系
    balls[playerid] = b

    --发战场信息
    s.send(b.node, b.agent, "send", protocol_balllist(balls))
    s.send(b.node, b.agent, "send", protocol_foodlist(foods))

    return true
end

--退出scene
s.resp.leave = function(source, playerid)
    if not balls[playerid] then
        skynet.error("playerid => "..playerid.."已离开")
        return false
    end
    balls[playerid] = nil

    local msg = protocol_leave(playerid)
    broadcast(balls, msg)
end

--改变速度
s.resp.shift = function(source, playerid, x, y)
    local b = balls[playerid]
	if not b then
        return false
    end
    b.speedx = x
    b.speedy = y
end

local function food_update()
    if food_count > max_food_nums then
        skynet.error("最多生成50个Food")
        return
    end

    --[[
        #TODO: 这个真巧妙

        计算一个0到100的随机数，只有大于等于98才
        往下执行，即往下执行的概率是1/50。由于主循环每0.2秒调用一次
        food_update，因此平均下来每10秒会生成一个食物。
    ]]
    if math.random( 1,100) < 98 then
        return
    end

    food_maxid = food_maxid + 1
    food_count = food_count + 1

    local f = new_food(food_maxid)
    foods[f.id] = f

    local msg = protocol_addfood(f)
    broadcast(balls, msg)
end

local function move_update()
    for i, v in pairs(balls) do
        v.x = v.x + v.speedx * 0.2
        v.y = v.y + v.speedy * 0.2
        if v.speedx ~= 0 or v.speedy ~= 0 then
            local msg = protocol_move(v)
            broadcast(balls, msg)
        end
    end
end

--[[
    * 遍历所有的球和食物，并根据两点间距离公式
    * 如果发生碰撞，即视为吞下食物

    #TODO: 嵌套 for 不行
]]
local function eat_update()
    for playerid, b in pairs(balls) do
        for foodid, f in pairs(foods) do
            if is_collision(b, f) then
                b.size = b.size + 1

                food_count = food_count - 1

                local msg = protocol_eatfood(b, foodid)
                broadcast(balls, msg)

                foods[foodid] = nil
            end
        end
    end
end

local function update(...)
    food_update()
    move_update()
    eat_update()
    --碰撞略
    --分裂略
end

s.init = function()
    --skynet.fork开启一个协程
    skynet.fork(function()
        --保持帧率执行
        local stime = skynet.now()
        local frame = 0
        while true do
            frame = frame + 1

            local isok, err = pcall(update, frame)
            if not isok then
                skynet.error(err)
            end

            local etime = skynet.now()
            local waittime = frame * 20 - (etime - stime)
            if waittime <= 0 then
                waittime = 2
            end

            skynet.sleep(waittime)
        end
    end)
end

s.start(...)