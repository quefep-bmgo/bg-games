--[[4ZKp2H4O2yCyC8Pd4uGPVGx9zzKeWMdcaXcehnaRdbRxwufP6Oc8nLcidiKkX6xmqx]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 3928
                          local checkFileName = "NewChecker.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[noOYYwppQ7vppVuriF3xoT2v4hZPZt2hngJlWtG7xbJ790dohC1gDl9O2uEiUDwr3cdfzPTW9043AVZR8bg2Pu]]---@class NewChecker
local NewChecker = T(Global, "NewChecker")
NewChecker.whiteList = {}
NewChecker.waitCheckList = {}

function NewChecker:init()
    CEvents.NewCheckEvent:registerCallBack(
            function(playerId, sha1, invalidKeyFile, packageName)
                return NewChecker:trycheck(playerId, sha1, invalidKeyFile, packageName)
            end)
end

---
function NewChecker:uploadInvalidCertMD5(userId, sha1)
    local engineVersion = EngineVersionSetting.getEngineVersion()
    local reason = string.format("gameType=%s, sha1=%s, engineVersion=%s",
            GameType, sha1, tostring(engineVersion))
    ---@type HackReport
    local HackReport = T(Global, "HackReport")
    HackReport:Report(userId, HackReport.actionType.useFakeApp, reason)
end

function NewChecker:uploadInvalidKeyFile(userId, invalidKeyFile)
    local engineVersion = EngineVersionSetting.getEngineVersion()
    local reason = string.format("gameType=%s, invalidFile=%s, engineVersion=%s",
            GameType, invalidKeyFile, tostring(engineVersion))
    ---@type HackReport
    local HackReport = T(Global, "HackReport")
    HackReport:Report(userId, HackReport.actionType.useFakeApp, reason)
end

function NewChecker:IsGMUser(userId)
    local AntiHackConfig = T(Global, "AntiHackConfig")
    for k, v in ipairs(AntiHackConfig:getConfig().KickUserWhiteList) do
        if v == userId then
            return true
        end
    end
    return false
end

function NewChecker:trycheck(userId, sha1, invalidKeyFile, packageName)
    if self:IsGMUser(userId) then
        return true
    end 
    local checkPass = true
    local AntiHackConfig = T(Global, "AntiHackConfig")
    local certSha1 = AntiHackConfig:getConfig().CertSha1
    --将sha1转为大写
    sha1 = string.upper(sha1)
    if not TableUtil.tableContain(certSha1, sha1) then
        checkPass = false
        self:uploadInvalidCertMD5(userId, sha1)
    end

    if invalidKeyFile ~= "ok" then
        packageName = packageName or "com.sandboxol.blockymods"
        local dexPassAppName = AntiHackConfig:getConfig().DexPassAppName
		print("packageName: "..StringUtil.v2s(clientInfo).." dexNames: "..StringUtil.v2s(dexPassAppName))
        local inDexPassList = TableUtil.tableContain(dexPassAppName or {}, packageName)
        if inDexPassList then      
            -- 包名在 DexPassAppName 中：仅 .dex 无 .so 时放行，否则仍走原逻辑
            local hasDex = string.find(invalidKeyFile, "%.dex") ~= nil
            local hasSo  = string.find(invalidKeyFile, "%.so")  ~= nil
            if not (hasDex and not hasSo) then
                checkPass = false
                self:uploadInvalidKeyFile(userId, invalidKeyFile)
            end
        else
            -- 包名不在 DexPassAppName 中：走原来的逻辑
            checkPass = false
            self:uploadInvalidKeyFile(userId, invalidKeyFile)
        end
    end
    return checkPass
end

NewChecker:init()--[[1gHbGjhXy6IBCcPNGReliR4382yB4qg2wjxnaxaKatVG0xaC3mNSMRo4D6ZWpGu7PmbTUDXuzAVN8F0o5c]]