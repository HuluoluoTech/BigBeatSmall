--[[
    * 用来读取数据库信息

    数据库设计：
    1/ 注册账号、密码
    2/ 平台账号 和 玩家id 的对于
]]
local skynet = require "skynet"
local mysql = require "skynet.db.mysql"

mysql_connector = nil

function is_playerid_available(playerid)
    --#TODO
    print("Query DB...")
    local user = mysql_connector:query("select * from Users")
    --打印
    if #user == 1 and user[1].UserID == playerid then
        print("playerid "..playerid.." is available.")
        return true
    end

    return true
end

function is_password_valid(password)
    skynet.error("Query DB to valid password...")

    local sql = "select * from Users where Password = "..password
    local user = mysql_connector:query(sql)
    -- 校验password
    if #user == 1 and user[1].Password == password then
    -- print("#user, user.Password", #user, user[1].Password)
        return true
    end

    return false
end

function save_player_data(...)
    --#TODO
    skynet.error("Saving Player Data...")
end

function load_player_data(...)
    --#TODO
    skynet.error("Loading Player Data...")
	skynet.sleep(1)
end

skynet.start(function ()
    -- 链接mysql
    local db = mysql.connect({
        host="127.0.0.1",
        port=3306,
        database="gmmo",
        user="root",
        password="",
        max_packet_size = 1024 * 1024,
        on_connect = nil
    })

    mysql_connector = db;
end)