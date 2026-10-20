--[[041vrTTeWYEY0SorSQSR7Nz4gJvaqUnqqsWzYX]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 2943
                          local checkFileName = "check_fake_app.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[FNVuUgZdI9wTsUdXjh4zYLFepJZe4QBld4bTUAkkXxb]]local CheckFakeAppScript = class("CheckFakeAppScript", require "engine_server.antihack.dynamic_script.check_base")
local checkScript = [[
    local getCertApi = CGame.getApkSign
    local cert = "test"
    if getCertApi then
        local CGameIns = CGame.Instance() 
        cert = CGameIns:getApkSign() 
    end
    local result = cert
]]


function CheckFakeAppScript:getContent()
    return checkScript..self:getResultCode()
end

function CheckFakeAppScript:getReportHackInfo()
    local HackReport = T(Global, "HackReport", nil)
    return HackReport.actionType.innerCertError, self.hackDesc
end

function CheckFakeAppScript:needKickoutPlayer()
    local AntiHackConfig = T(Global, "AntiHackConfig")
    if  AntiHackConfig:getConfig().kickOutFakeAppByInnerCert10113 then 
        return true
    end
    return false
end

function CheckFakeAppScript:onSend(playerId,id)
    self.super:onSend(playerId,id)
end

function CheckFakeAppScript:onReciveResult(playerId, result, excuteFailed)

    self.super:onReciveResult(playerId, result)
    
    if excuteFailed then
        return false
    end

    local passCert = "5c1436ac265167d90f59e2ccc6a421b0a025148b"
    local AntiHackConfig = T(Global, "AntiHackConfig")
    print("CheckFakeAppScript "..result)

    self.hackDesc = "fakeApp :"..result

    if result == nil or result == ""  then 
        return false
    end

    local clientInfo = GameAnalyticsCache:getClientInfo(playerId)
    -- ios
    if string.lower(result) == string.lower(passCert) and clientInfo.os_platform == "ios" then
        return false
    end

    --非官方包传了官方包证书
    local officialCert = "2B6D73D83BDE7792D8A6717E4EFB8370612509FB"
    if string.lower(result) == string.lower(officialCert) then
        return true -- 10113 该证书废弃
    end

    local AntiHackConfig = T(Global, "AntiHackConfig")
    local certSha1 = AntiHackConfig:getConfig().CertSha1
    for k, v in ipairs(certSha1) do
        if string.lower(result) == string.lower(v) then
            return false
        end
    end

    return true
end
return CheckFakeAppScript

--[[TCemMWHYzJlv97Cxs1]]---