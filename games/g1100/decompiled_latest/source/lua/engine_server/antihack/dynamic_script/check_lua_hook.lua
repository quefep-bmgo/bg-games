local CheckLuaHook = class("CheckLuaHookScript", require "engine_server.antihack.dynamic_script.check_base")


local checkScript = [[
local vf2sInfo = debug.getinfo(VFS2.testForUpdate, "S")
local vfs2Path = vf2sInfo.source:sub(2)
local io_open_sInfo = debug.getinfo(io.open, "S")
local io_open_Path = io_open_sInfo.source:sub(2)
local result = vfs2Path .. "|" .. io_open_Path
]]

function CheckLuaHook:getContent()
    return checkScript..self:getResultCode()
end

function CheckLuaHook:getReportHackInfo()
    local HackReport = T(Global, "HackReport", nil)
    return HackReport.actionType.illegalLuaFiles, self.hackDesc
end

function CheckLuaHook:needKickoutPlayer()
    local AntiHackConfig = T(Global, "AntiHackConfig")
    if AntiHackConfig:getConfig().kickOutIllegalLuaFiles then 
        return true
    end
    return false
end

function CheckLuaHook:onSend(playerId, id)
    self.super:onSend(playerId, id)
end

function CheckLuaHook:onReciveResult(playerId, result, excuteFailed)
    self.super:onReciveResult(playerId, result)

    if excuteFailed then
        return false
    end

    print("CheckLuaHook result: " .. (result or "nil"))
    
    -- Parse the JSON result
    local json = require("engine_base.util.json")
    local illegalFiles = {}

    if result and result ~= "" then
        local filePaths = StringUtil.split(result, "|")

        if filePaths[1] ~= filePaths[2] then
            self.hackDesc = "Illegal Lua hook: " ..StringUtil.v2s(filePaths)
            return true
        end
    end
        
    return false
end

return CheckLuaHook
