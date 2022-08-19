--[[
    ** 关于 pbc 的安装问题：(本地lua安装版本，必须和skynet自带的lua版本一致！！！)
    1、需要在pbc根目录 make
    2、进入binding/lua53
    3、make
    4、cp protobuf.so / protobuf.lua 到相应的luapath 即可
]]

local pb     = require "protobuf"
local skynet = require "skynet"

--[[
    注册用到的协议
]]
pb.register_file("./protofiles/header.pb")
pb.register_file("./protofiles/login.pb")

local function parse_login(buff)

    local umsg = pb.decode("login.Login", buff)
    print("umsg:", umsg)
    if umsg then
        print("id:", umsg.id)
        print("playerid:"..umsg.playerid)
        print("password:"..umsg.password)
        return {
            ['cmd'] = "login",
            ['playerid'] = umsg.playerid,
            ['password'] = umsg.password
        }
    else
        print("error")
    end
end

local function parse_enter(msg)
    return {
        ['cmd'] = "enter"
    }
end

function parse(msg)
    skynet.error("[parse] Ready to parsing...")

    local header = pb.decode("login.Login", msg)
    if not header then
        return nil
    end

    print("protoc id : ", header.id)

    if header.id == 2 then
        return parse_enter(msg)
    elseif header.id == 3 then
        return parse_login(msg)
    end

    return nil
end