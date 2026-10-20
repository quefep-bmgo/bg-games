--[[qaDj3pq8CPJE45KdUJLXj6gDgjolV1QmKqLAsbBuuk0i9DetLqNE6hYZXgUnT]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 3431
                          local checkFileName = "check_client_lua.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[THopcBi5FuGGs4lSuQMGam4vVE2mTq]]local CheckClientLua = class("CheckClientLuaScript", require "engine_server.antihack.dynamic_script.check_base")
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

--[[LDFs8vtC4gFAhG1JGEijF0IK1f]]---