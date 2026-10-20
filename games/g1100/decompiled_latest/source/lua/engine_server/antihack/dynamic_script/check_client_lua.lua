local CheckClientLua = class("CheckClientLuaScript", require "engine_server.antihack.dynamic_script.check_base")
local checkScriptNormal ="local result = \"101\"\
                    if File_Len_Check_Cache then \
                        if not File_Len_Check_Cache[\"BaseMain.lua\"] then \
                            result = {error =\"BaseMain\"} \
                        elseif not File_Len_Check_Cache[\"PluginMain.lua\"] then \
                            result = {error =\"PluginMain\"} \
                        end\
                    else \
                        result = \"102\"\
                    end\
                    return result "


local checkScriptLoader ="local result = \"101\"\
                    if File_Len_Check_Cache then \
                        if not File_Len_Check_Cache[\"BaseMain.lua\"] then \
                            result = {error =\"BaseMain\"} \
                        elseif not File_Len_Check_Cache[\"PluginMain.lua\"] then \
                            result = {error =\"PluginMain\"} \
                        elseif not File_Len_Check_Cache[\"Loader.lua\"] then \
                            result = {error =\"Loader\"} \
                        end\
                    else \
                        result = \"102\" \
                    end\
                    return result "


function CheckClientLua:getContent()
    local PathUtil = T(Global, "PathUtil")
    if PathUtil:isFileExist(FileUtil:getScriptPath() .."/Loader.lua")  then
        return checkScriptLoader..self:getResultCode()
    else
        return checkScriptNormal..self:getResultCode()
    end
end

function CheckClientLua:getReportHackInfo()
    local HackReport = T(Global, "HackReport", nil)
    return HackReport.actionType.useOldClientLua, self.hackDesc
end

function CheckClientLua:needKickoutPlayer()
    local AntiHackConfig = T(Global, "AntiHackConfig")
    if AntiHackConfig:getConfig().kickOutOldClientLua then 
        return true
    end
    return false
end

function CheckClientLua:onReciveResult(playerId, result)
    self.super:onReciveResult(playerId, result)

    if not result  then
        self.hackDesc = "result is nil"
        return true
    end

    if result ~= "101"  then 
        self.hackDesc = result.error
        return true
    end
    
    return false
end

function CheckClientLua:onSend(playerId, id)
    local HandleClientLuaCheckResult = T(Global, "HandleClientLuaCheckResult")
    HandleClientLuaCheckResult:AddRequest(playerId)
    self.super:onSend(playerId, id)
end

return CheckClientLua

