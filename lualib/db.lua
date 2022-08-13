--[[
    * 用来读取数据库信息

    数据库设计：
    1/ 注册账号、密码
    2/ 平台账号 和 玩家id 的对于
]]
local skynet = require "skynet"

function is_playerid_available(playerid)
    --#TODO
    print("Query DB...")
    print("playerid "..playerid.." is available.")

    return true
end

function is_password_valid(password)
    --#TODO
    print("Query DB...")
    print("password "..password.." is valid.")

    return true
end

function save_player_data(...)
    --#TODO
    skynet.error("Saving Player Data...")
end

function load_player_data(...)
    --#TODO
    skynet.error("Loading Player Data...")
	skynet.sleep(200)
end