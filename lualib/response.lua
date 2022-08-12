--[[
    * Request/Response数据处理相关方法
]]

function response(code, status, ...)
    local arg = { ... }
    local res = nil
    if code == 0 then
        res = {
            ["code"] = code,
            ["status"] = status,
        }
    else
        res = {
            ["code"] = code,
            ["status"] = status,
            ["reason"] = arg[3]
        }
    end

    return res
end