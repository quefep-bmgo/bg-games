---@class NewChecker
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

NewChecker:init()