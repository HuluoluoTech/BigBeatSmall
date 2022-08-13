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
            ["reason"] = arg[1]
        }
    end

	local data = json.encode(res)
    return data
end

function response_with_data(code, status, data)
    local res_data = {
        ["code"]   = code,
        ["status"] = status,
        ["data"] = data
    }

    local res = json.encode(res_data)
    return res
end