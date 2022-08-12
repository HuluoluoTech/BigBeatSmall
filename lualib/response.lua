--[[
    * Request/Response数据处理相关方法
]]

local json = require "json"

-- Dump Request
function request(mod, cmd, ...)
    print("Request Mod : ", mod)
    print("Request cmd : ", cmd)
end

function response(code, status, ...)
    local arg = { ... }
    local res = {}
    if code == 0 then
        res = {
            ["code"]   = code,
            ["status"] = status,
        }
    else
        res = {
            ["code"]   = code,
            ["status"] = status,
            ["reason"] = arg[3]
        }
    end

	local data = json.encode(res)

    return data
end