--[[
    * 通信协议
]]

--[[
    balllist, playerID, x, y
]]
function protocol_balllist(balls)
    local msg = {"balllist"}
    for i, v in pairs(balls) do
        table.insert( msg, v.playerid )
        table.insert( msg, v.x )
        table.insert( msg, v.y )
        table.insert( msg, v.size )
    end

    return msg
end

--[[
    foodlist, FoodID, x, y
]]
function protocol_foodlist(foods)
    local msg = {"foodlist"}
    for i, v in pairs(foods) do
        table.insert( msg, v.id )
        table.insert( msg, v.x )
        table.insert( msg, v.y )
    end
    return msg
end

--[[
    addfood, FoodID, x, y
]]
function protocol_addfood(food)
    local msg = {"addfood", food.id, food.x, food.y}
    return msg
end

--[[
    eat, playerID, foodID, playerNewSize
]]
function protocol_eatfood(ball, foodid)
    local msg = {"eat", ball.playerid, foodid, ball.size}
    return msg
end

--[[
    move, playerID, x, y
]]
function protocol_move(ball)
    local msg = {"move", ball.playerid, ball.x, ball.y}
    return msg
end