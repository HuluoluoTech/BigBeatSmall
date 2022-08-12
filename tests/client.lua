#!/usr/bin/lua

local socket = require("socket")


local host = "127.0.0.1"
local port = 8001

local reqlogin = function(id, password)
    print("#[登录] 玩家ID: "..id.." , 密码: "..password)
    local sock = assert(socket.connect(host, port))
    sock:send("xxx")
end

print("package.path: "..package.path)

reqlogin("001", "password")