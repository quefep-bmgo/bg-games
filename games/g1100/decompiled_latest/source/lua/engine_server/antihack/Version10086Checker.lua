---@class Version10086Checker
local Version10086Checker = T(Global, "Version10086Checker")
---@type ConnectorCenter
local ConnectorCenter = T(Global, "ConnectorCenter")

local checkLua = "local tt = \"chlua\" \
        local st1 = \"Sec\" \
        local st2 = \"Tim\" \
        local st3 = \"er\" \
        local st = st1..st2..st3 \
        local stt = _G[st] \
        local rt = false \
        if stt ~= nil then  \
            local df1 = \"doF\" \
            local df2 = \"ind\" \
            local hf = stt[df1..df2] \
            local dc1 = \"doC\" \
            local dc2 = \"heck\" \
            local hc = stt[dc1..dc2] \
            local rt1 = hf ~= nil \
            local rt2 = hc ~= nil \
            rt = rt1 and rt2 \
        end \
        return { type = tt, ret = rt, sign = %d }"

Version10086Checker.waitResultPlayers = {}

function Version10086Checker:init()
    if isGarena then
        return
    end
    local this = self
    BaseListener.registerCallBack(CEvents.PlayerReadyEvent, function(player)
        if PlayerManager:isAIPlayer(player) then
            return
        end
        this:onPlayerLogin(player)
    end)

    BaseListener.registerCallBack(CEvents.PlayerLogoutEvent, function(player)
        this:onPlayerLogout(player.userId)
    end)
end

---@param player SBasePlayer
function Version10086Checker:onPlayerLogin(player)
    self:sendCheckCommand(player)
end

function Version10086Checker:handleCheckResult(playerId, resultStr)
    local success, resultBase = pcall(json.decode, resultStr or "{}")
    local result = resultBase["result"]
    if not success or not result or TableUtil.isEmpty(result) then
        LogUtil.logInfo("ExecuteLuaResult, result is empty.")
    elseif result.exception then
        self:uploadCheckFailedPlayer(playerId, result.exception)
        self:cleanWaitPlayer(playerId)
    elseif result.type == "chlua" then
        local rt = result["ret"]
        local sign = result["sign"]
        local playerCheckInfo = self.waitResultPlayers[playerId]
        if playerCheckInfo ~= nil then
            if sign == nil or tonumber(sign) ~= playerCheckInfo["sign"] then
                self:kickPlayer(playerId, "version10086 check failed sign error")
            end
        end
        if rt == nil or rt == false then
            self:kickPlayer(playerId, "version10086 check failed rt error")
        end
        self:cleanWaitPlayer(playerId)
        LogUtil.logInfo("[Version10086Checker:handleCheckResult]", playerId, "success!!!!")
        return true
    end
    return false
end

function Version10086Checker:cleanWaitPlayer(playerId)
    local playerInfo = self.waitResultPlayers[playerId]
    if playerInfo ~= nil then
        LuaTimer:cancel(playerInfo.timer)
    end
    self.waitResultPlayers[playerId] = nil
end

function Version10086Checker:kickPlayer(playerId, reason)
    self:uploadCheckFailedPlayer(playerId, reason)
    ---@type GameDynamicConfig
    local GameDynamicConfig = T(Global, "GameDynamicConfig")
    if GameDynamicConfig:getConfig().kickOutVersionCheckFailed then
        local player = PlayerManager:getPlayerByRakssid(playerId)
        if player then
            CEvents.PlayerCheatEvent:invoke(player.rakssid, 16)
        end
        HostApi.sendGameoverByPlatformUserId(playerId, "version cheat detected", 15)
    end
end

function Version10086Checker:uploadCheckFailedPlayer(userId, reason)
    local record = self.waitResultPlayers[userId]
    local rakssid = record and record.rakssid or 0
    local engineVersion = EngineVersionSetting.getEngineVersion()
    reason = string.format("gameType=%s, rakssid=%s, reason=%s, engineVersion=%s",
            GameType, tostring(rakssid), reason, tostring(engineVersion))
    ---@type HackReport
    local HackReport = T(Global, "HackReport")
    HackReport:Report(userId, HackReport.actionType.lowVersion, reason)
    LogUtil.logInfo("[Version10086Checker:uploadCheckFailedPlayer]", userId, reason)
end

local Connector2GameMsgType = {
    ExecuteLuaCode = 10102, ---执行Lua代码
}

---@param player SBasePlayer
function Version10086Checker:sendCheckCommand(player)
    local randomSign = math.random(100, 1000)
    local checker = self
    local userId = player.userId
    local rakssid = player.rakssid
    ---@type GameDynamicConfig
    local GameDynamicConfig = T(Global, "GameDynamicConfig")
    local timerKey = LuaTimer:schedule(function()
        checker:kickPlayer(userId, "version10086 check timeout")
    end, GameDynamicConfig:getConfig().kickOutVersionCheckTimeOut or 60000)

    self.waitResultPlayers[userId] = { timer = timerKey, sign = randomSign, rakssid = rakssid }

    local sendData = {}
    sendData.code = string.format(checkLua, randomSign)
    ConnectorCenter:onMsgReceive(Connector2GameMsgType.ExecuteLuaCode, { userId }, json.encode(sendData))
end

---@param player SBasePlayer
function Version10086Checker:testUseOldClient(player)
    local randomSign = math.random(100, 1000)
    local checker = self
    local userId = player.userId
    local rakssid = player.rakssid
    ---@type GameDynamicConfig
    local GameDynamicConfig = T(Global, "GameDynamicConfig")
    local timerKey = LuaTimer:schedule(function()
        checker:kickPlayer(userId, "version10086 check timeout")
    end, GameDynamicConfig:getConfig().kickOutVersionCheckTimeOut or 60000)

    self.waitResultPlayers[userId] = { timer = timerKey, sign = randomSign+100, rakssid = rakssid }

    local sendData = {}
    sendData.code = string.format(checkLua, randomSign)
    ConnectorCenter:onMsgReceive(Connector2GameMsgType.ExecuteLuaCode, { userId }, json.encode(sendData))
end

function Version10086Checker:onPlayerLogout(playerId)
    self:cleanWaitPlayer(playerId)
end

Version10086Checker:init()