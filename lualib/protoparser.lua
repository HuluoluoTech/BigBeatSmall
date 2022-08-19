--[[
    ** 关于 pbc 的安装问题：(本地lua安装版本，必须和skynet自带的lua版本一致！！！)
    1、需要在pbc根目录 make
    2、进入binding/lua53
    3、make
    4、cp protobuf.so / protobuf.lua 到相应的luapath 即可
]]

local pb = require "protobuf"

function test()
    pb.register_file("./protofiles/login.pb")
    local msg = {
        playerid = 101,
        password = "123"
    }

    --encode
    local buff = pb.encode("login.Login", msg)
    print("len:"..string.len(buff))
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