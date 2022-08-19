--[[
    ** 关于 pbc 的安装问题：(本地lua安装版本，必须和skynet自带的lua版本一致！！！)
    1、需要在pbc根目录 make
    2、进入binding/lua53
    3、make
    4、cp protobuf.so / protobuf.lua 到相应的luapath 即可
]]

local pb = require "protobuf"

--[[
    注册用到的协议
]]
pb.register_file("./protofiles/login.pb")

local function parse_login(buff)
    --解码
    local umsg = pb.decode("login.Login", buff)
    if umsg then
        print("id:"..umsg.id)
        print("playerid:"..umsg.playerid)
        print("password:"..umsg.password)
    else
        print("error")
    end
end

function parse(protocol, msg)
    if protocol == "login" then
        parse_login(msg)
    elseif protocol == "enter" then
        print("....parse  enter....")
    end
end