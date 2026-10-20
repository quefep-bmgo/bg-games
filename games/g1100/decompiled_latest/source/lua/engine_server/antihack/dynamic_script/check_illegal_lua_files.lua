local CheckIllegalLuaFilesScript = class("CheckIllegalLuaFilesScript", require "engine_server.antihack.dynamic_script.check_base")

local checkScript = [[

local result = ""

for name, value in pairs(_G) do
    if type(value) == "function" then
        local info = debug.getinfo(value, "S")
        if info and info.source and info.source == "=[C]" then
            result = result ..name.."|"
        end
    end
end
]]

function CheckIllegalLuaFilesScript:getContent()
    return checkScript..self:getResultCode()
end

function CheckIllegalLuaFilesScript:getReportHackInfo()
    local HackReport = T(Global, "HackReport", nil)
    return HackReport.actionType.illegalLuaFiles, self.hackDesc
end

function CheckIllegalLuaFilesScript:needKickoutPlayer()
    local AntiHackConfig = T(Global, "AntiHackConfig")
    if AntiHackConfig:getConfig().kickOutIllegalLuaFiles then 
        return true
    end
    return false
end

function CheckIllegalLuaFilesScript:onSend(playerId, id)
    self.super:onSend(playerId, id)
end

local whiteList = {
"__destroySystemEditBox",
"__createSystemEditBox"
}

function CheckIllegalLuaFilesScript:onReciveResult(playerId, result, excuteFailed)
    self.super:onReciveResult(playerId, result)
    
    if excuteFailed then
        return false
    end

    print("CheckIllegalLuaFilesScript result: " .. (result or "nil"))
    

    local illegalFiles = {}
    
    if result and result ~= "" then
        local globalFunctions = StringUtil.split(result, "|")
        for _, globalFunction in ipairs(globalFunctions) do
            if not TableUtil.tableContain(whiteList, globalFunction) and  not _G[globalFunction] then
                table.insert(illegalFiles, globalFunction)
            end
        end
    
        if #illegalFiles > 0 then
            self.hackDesc = "Illegal Lua files: " ..StringUtil.v2s(illegalFiles)
            return true
        end
    end
    
    return false
end

return CheckIllegalLuaFilesScript
