---@class APKChecker
local APKChecker = T(Global, "APKChecker")
APKChecker.whiteList = {}
APKChecker.waitCheckList = {}

function APKChecker:init()
    self:loadWhiteList()
    CEvents.CheckAPKCertEvent:registerCallBack(
            function(playerId, md5)
                return APKChecker:tryCheckMD5(playerId, md5)
            end)
end

function APKChecker:loadWhiteList()
    local engineVersion = EngineVersionSetting.getEngineVersion()
    WebService:GetAPKCERTWhiteList(engineVersion,
            function(code, data)
                APKChecker:readWhiteList(data)
            end)
end

function APKChecker:readWhiteList(data)
    for _, value in pairs(data) do
        if not TableUtil.tableContain(self.whiteList, value) then
            table.insert(self.whiteList, value)
        end
    end
    self:handleWaitCheckList()
end

function APKChecker:handleWaitCheckList()
    for _, value in pairs(self.waitCheckList) do
        self:checkMD5Impl(value.userId, value.md5)
    end
    self.waitCheckList = {}
end

function APKChecker:checkMD5Impl(userId, md5)
    local findInWhiteList = false
    for _, value in pairs(self.whiteList) do
        if md5 == value then
            findInWhiteList = true
        end
    end

    local checkPass = true
    if findInWhiteList == false then
        self:uploadInvalidCertMD5(userId, md5)
        ---@type GameDynamicConfig
        local GameDynamicConfig = T(Global, "GameDynamicConfig")
        if GameDynamicConfig:getConfig().kickOutPiracyApp then
            checkPass = false
        end
    end
    return checkPass
end

function APKChecker:uploadInvalidCertMD5(userId, md5)
    local engineVersion = EngineVersionSetting.getEngineVersion()
    local reason = string.format("gameType=%s, md5=%s, engineVersion=%s",
            GameType, md5, tostring(engineVersion))
    ---@type HackReport
    local HackReport = T(Global, "HackReport")
    HackReport:Report(userId, HackReport.actionType.useFakeApp, reason)
end

function APKChecker:tryCheckMD5(userId, md5)
    local checkPass = true
    if next(self.whiteList) == nil then
        table.insert(self.waitCheckList, { userId = userId, md5 = md5 })
    else
        checkPass = self:checkMD5Impl(userId, md5)
    end
    return checkPass
end

function APKChecker:testCheckMD5(userId, md5)
    self:tryCheckMD5(userId, md5)
    HostApi.sendGameoverByPlatformUserId(userId, "cheat detected", 15)
end

APKChecker:init()