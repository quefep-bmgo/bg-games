local misc = require("misc")
---@class Md5Util
local Md5Util = {}

---@param content string
function Md5Util.md5(content)
    if misc.md5 then
        return misc.md5(content)
    else
        return Md5Util.md5_sandbox(content)
    end
end

function Md5Util.md5_file(path)
    if misc.md5_file then
        local md5 = misc.md5_file(path)
        if md5 == path then
            return ""
        else
            return md5
        end
    else
        return Md5Util.md5_file_sandbox(path)
    end
end

---@param content string
function Md5Util.md5_sandbox(content)
    local len = #content
    if len <= 2048 then
        return content
    else
        local size = math.floor(len / 2048)
        if size <= 1 then
            return content
        end
        local result = ""
        for i = 1, 2048 do
            local start = (i - 1) * size + 1
            if start <= len then
                result = result .. content:sub(start, start)
            end
        end
        return result
    end
end

function Md5Util.md5_file_sandbox(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        file:close()
        return Md5Util.md5_sandbox(content)
    else
        return ""
    end
end

return Md5Util