--[[
    * 游戏中的各种对象的创建方法汇总
    * （类似于 class 创建实例）
    * （游戏传统就是揉到逻辑里面？）
    * （先按自己的理解来写吧）
]]

-- 新建一个和playerid 映射的Ball对象
function new_ball(playerid)
    local m = {
        playerid = playerid,
        node     = nil,
        agent    = nil,
        x        = math.random( 0, 100),
        y        = math.random( 0, 100),
        size     = 2,
        speedx   = 0,
        speedy   = 0,
    }

    return m
end

function new_food(id)
    local m = {
        id = id,
        x = math.random( 0, 100),
        y = math.random( 0, 100),
    }

    return m
end
