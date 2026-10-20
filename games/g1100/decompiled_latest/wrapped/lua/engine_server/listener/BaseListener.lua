--[[O3tW]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 25804
                          local checkFileName = "BaseListener.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[jJ]]---
--- Created by Jimmy.
--- DateTime: 2018/9/13 0028 11:37
---
local callbacks = T(Global, "BaseListener.callbacks")

GameType = Server.Instance():getConfig().gameType

local function tryCallEvent(event, ...)
    local callback = callbacks[event]
    if not callback then
        return false, false
    end
    local result = false
    for _, func in pairs(callback) do
        result = func(...) or result
    end
    return true, result
end

---@type SConnectorCenter
local SConnectorCenter = T(Global, "ConnectorCenter")
---@type GameDynamicConfig
local GameDynamicConfig = T(Global, "GameDynamicConfig")
---@type PacketChecker
local PacketChecker = T(Global, "PacketChecker")
---@type SandboxolChecker
local SandboxolChecker = T(Global, "SandboxolChecker")
---@type ClientFileChecker
local ClientFileChecker = T(Global, "ClientFileChecker")

BaseListener = {}

local function IsWatch(userId)
    local manager = GameServer:getRoomManager()
    if not manager:isUserAttrExisted(userId) then
        return false
    end
    local attr = manager:getUserAttrInfo(userId)
    if attr.followEnterType == 2 then
        return true
    end
    return false
end

---@param player SBasePlayer
---@param follower SBasePlayer
local function setFollowModeAndTeleport(player, follower)
    LuaTimer:schedule(function()
        player:setAllowFlying(true)
        player:setFlying(true)
    end, 10)
    PacketSender:sendIntoFollowMode(player.rakssid, follower and tostring(follower.userId) or 0)
    PacketSender:sendLuaCommonData(player.rakssid, "JoinGameStatus", tostring(PlayerManager:getJoinGameStatus()))
end

---@param player SBasePlayer
local function intoFollowMode(player, targetUserId)
    local targetPlayer = PlayerManager:getPlayerByUserId(targetUserId)
    if not targetPlayer then
        local players = PlayerManager:getPlayers()
        for _, v in pairs(players) do
            if v.userId ~= player.userId then
                targetPlayer = v
                break
            end
        end
    end
    player:addNightVisionPotionEffect(43200)
    if targetPlayer then
        player:teleportPos(targetPlayer:getPosition())
    end
    Events.PlayerIntoFollowModeEvent:invoke(player, targetPlayer)
    setFollowModeAndTeleport(player, targetPlayer)
end

function BaseListener.registerCallBack(event, func)
    callbacks[event] = callbacks[event] or {}
    if TableUtil.tableContain(callbacks[event], func) then
        return
    end
    table.insert(callbacks[event], func)
end

function BaseListener:init()
    CEvents.GameInitEvent:registerCallBack(self.onGameInit)
    CEvents.PlayerLoginEvent:registerCallBack(self.onPlayerLogin)
    CEvents.PlayerLogoutEvent:registerCallBack(self.onPlayerLogout)
    CEvents.PlayerReadyEvent:registerCallBack(self.onPlayerReady)
    CEvents.PlayerAttackedEvent:registerCallBack(self.onPlayerHurt)
    CEvents.PlayerFirstSpawnEvent:registerCallBack(self.onPlayerFirstSpawn)
    CEvents.PlayerRespawnEvent:registerCallBack(self.onPlayerRespawn)
    CEvents.PlayerReviewPlayerEvent:registerCallBack(self.onPlayerReviewPlayer)
    CEvents.PlayerDieEvent:registerCallBack(self.onPlayerDied)
    CEvents.PlayerDieTipEvent:registerCallBack(self.onPlayerDiedTip)
    CEvents.PlayerMoveEvent:registerCallBack(self.onPlayerMove)
    CEvents.PlayerAfterRespawnEvent:registerCallBack(self.onPlayerAfterRespawn)
    CEvents.ClientCommonDataEvent:registerCallBack(self.onClientCommonData)
    CEvents.SpawnEntityEvent:registerCallBack(self.onSpawnEntity)
    CEvents.RemoveEntityEvent:registerCallBack(self.onRemoveEntity)
    CEvents.PlayerReconnectSuccessEvent:registerCallBack(self.onPlayerReconnectSuccess)
    CEvents.SavePlayerDBDataEvent:registerCallBack(self.onSavePlayerDBData)
    CEvents.PlayerDynamicAttrEvent:registerCallBack(self.onPlayerDynamicAttr)
    CEvents.GameStatusChangeEvent:registerCallBack(self.onGameStatusChange)
    CEvents.ReceiveRoomCommonMsgEvent:registerCallBack(self.onReceiveRoomCommonMsg)
    CEvents.EnginePayMoneyEvent:registerCallBack(self.onEnginePayMoney)
    Events.GetDataFromDBEvent:registerCallBack(self.onGetDataFromDB)
    CEvents.BeforeCloseSessionEvent:registerCallBack(self.onBeforeCloseSession)
    CEvents.ServerQuitEvent:registerCallBack(self.onServerQuit)
    CEvents.ServerDataReportEvent:registerCallBack(self.onServerDataReport)
    CEvents.RechargeResultEvent:registerCallBack(self.onRechargeResult)
    CEvents.PacketBindEntityEvent:registerCallBack(self.onBindEntity)
    CEvents.PacketUnbindEntityEvent:registerCallBack(self.onUnbindEntity)
    CEvents.RemoteLuaResultEvent:registerCallBack(self.onRemoteLuaResult)
end

---@param GamePath string
---@param ver string
---@param serverWorld ServerWorld
---@param config RoomGameConfig
function BaseListener.onGameInit(GamePath, ver, serverWorld, config)
    HostApi.log(VarDump(ServerWorld))
    BaseMain:setIsChina(config.isChina)

    local isJsonConfig = false
    local mapPath = string.gsub(tostring(GamePath), "config.yml", "")

    local ibegin, _ = string.find(tostring(GamePath), "config.yml")
    if not ibegin then
        mapPath = string.gsub(tostring(GamePath), "config.json", "")
        isJsonConfig = true
    end
    --[[
        2021/3/31
        目前不支持服务器和客户端使用不同的配置文件，但是服务器和客户端允许有同名
        但不同逻辑的XXXXConfig.lua文件，也就是说服务器和客户端允许有不同的预处理逻
        辑。所以服务器和客户端可能需要使用不一样的离线预处理后的二进制配置文件。
        所以暂时禁用服务器使用二进制配置文件，地图的二进制配置文件是客户端专用的。
        目前只关注客户端的游戏启动速度，所以客户端能使用二进制配置文件就可以了
    ]]
    ConfigLoader.setBinaryEnabled(false)
    ConfigLoader.setMapPath(mapPath)
    FileUtil:setMapPath(mapPath)
    FileUtil:setRootPath("./")
    EngineWorld:setWorld(serverWorld)
    PacketSender:init()
    AppProps:init()
    WebService:init(ver, config)
    CommonTask:start()
    PlayerManager:setMaxPlayer(config.maxPlayers)
    PlayerManager:setRoomMaxPlayer(config.maxPlayers)
    PlayerManager:setWatchMode(config.watchMode)
    GMHelper:init()
    GameAnalytics:init()
    Global:loadSetting()
    Plugins.LoadAllPlugins()
    Plugins.CallPluginFunc("onGameInit")
    if isJsonConfig then
        tryCallEvent(CEvents.GameInitEvent, FileUtil.getConfigFromJson(GamePath))
    else
        tryCallEvent(CEvents.GameInitEvent, FileUtil.getConfigFromYml("config"))
    end
    WebService:GetExpRule()
    ServerLang:init()
    PlayerIdentityCache:init()
    SumRechargeConfig:init()
    MaxRecordHelper:init()
    require "engine_server.config.GameDynamicConfig"
    require "engine_server.antihack.AntiHacker"
    if isLocalWin then
        startLuaHotUpdate()
    end
    if not isTest and not isStaging then
        ---@type string[]
        local GMProtectFunc = T(Global, "GMProtectFunc")
        table.insert(GMProtectFunc, "isGMOpen")
        table.insert(GMProtectFunc, "init")
        table.insert(GMProtectFunc, "onPlayerReady")
        table.insert(GMProtectFunc, "onPlayerLogout")
        ---正式服非预发布重置GMHelper的所有方法
        LuaTimer:schedule(function()
            for key, value in pairs(GMHelper) do
                if TableUtil.tableContain(GMProtectFunc, key) then
                    goto CONTINUE
                end
                if type(value) ~= "function" then
                    goto CONTINUE
                end
                ---@param player SBasePlayer
                GMHelper[key] = function(self, player, name)
                    if key == "callCommand" then
                        CEvents.HackReportEvent:invoke(player.userId, 11, name)
                    else
                        CEvents.HackReportEvent:invoke(player.userId, 11, key)
                    end
                end
                :: CONTINUE ::
            end
        end, 1000)
    end
end

---@param clientPeer ClientPeer
---@param clientInfo string
---@param enableIndie number
---@param gameTimeToday number
function BaseListener.onPlayerLogin(clientPeer, clientInfo, enableIndie, gameTimeToday)
    ---玩家进入游戏前发送服务器配置
    local builder = DataBuilder.new()
    local config = GameServer:getServerConfig()
    builder:addParam("isChina", BaseMain:isChina())
    builder:addParam("isStaging", isStaging)
    builder:addParam("regionId", config.regionId)
    builder:addParam("gameId", config.gameId)
    builder:addParam("tags", config.tags)
    builder:addParam("serverOsTime", os.time())
    PacketSender:sendLuaCommonData(clientPeer:getRakssid(), "ServerInfo", builder:getData(), true)
    local userId = clientPeer:getPlatformUserId()
    if not GameDynamicConfig:isCanEnterGame() then
        HostApi.sendGameoverByPlatformUserId(userId, "low.engine.version.tip", GameOverCode.GameOver)
        return false
    end
    SandboxolChecker:onPlayerLogin()
    if IsWatch(userId) then
        ---好友跟随进入观战模式
        local player = BasePlayer.new(clientPeer)
        PlayerManager:addWatcher(player)
        PacketSender:getSender():sendPlayerDBDataReady(clientPeer:getRakssid())
        player:subHealth(player:getHealth() + 1)
        player:sendLoginResult(true, player.dynamicAttr.team, "",
                PlayerManager:getPlayerCount(), PlayerManager:getMaxPlayer())
        SConnectorCenter:onUserLogin(userId)
        return false
    end
    ---@type SBasePlayer
    local player = PlayerManager:getPlayerByUserId(userId)
    if player and not PlayerManager:isAIPlayer(player) then
        ---顶号登录，直接使用现有玩家，不重置玩家数据
        local entityPlayerMP = clientPeer:getEntityPlayer()
        local oldPlayerMP = player.entityPlayerMP
        if oldPlayerMP then
            local oldPosition = oldPlayerMP:getPosition()
            local oldYaw = oldPlayerMP:getYaw()
            entityPlayerMP:clonePlayer(player.entityPlayerMP, true)
            player:initStaticAttr(oldPlayerMP:getTeamId())
            LuaTimer:schedule(function()
                player:teleportPosWithYaw(oldPosition, oldYaw)
            end, 100)
        else
            player:initStaticAttr(player.dynamicAttr.team)
        end
        player.clientPeer = clientPeer
        player.entityPlayerMP = entityPlayerMP
        player.rakssid = clientPeer:getRakssid()
        player.isKickOut = false
        if player:checkReady() then
            ---顶号登录需要保存一次数据，否则会拉取到旧数据
            DBManager:callSavePlayerData(player)
        end
        HostApi.sendGameStatus(clientPeer:getRakssid(), 1)
        LogUtil.logInfo("[BaseListener.onPlayerLogin] player repeat login, userId="
                .. player.userId .. ", isReady=" .. tostring(player:checkReady()))
        return DBManager:onPlayerLogin(player)
    end
    ---------------正常登录流程---------------
    if PlayerManager:isPlayerFull() then
        HostApi.sendGameover(clientPeer:getRakssid(), IMessages:msgGamePlayerIsEnough(), GameOverCode.PlayerIsEnough)
        return true
    end
    GameAnalyticsCache:addClientInfo(clientPeer:getPlatformUserId(), clientInfo)
    local code, status, c_callback, delayDBTime
    local callback = callbacks[CEvents.PlayerLoginEvent]
    if callback == nil then
        code = GameOverCode.Success
        player = BasePlayer.new(clientPeer)
        player:initStaticAttr(player.dynamicAttr.team)
    else
        code, player, status, c_callback, delayDBTime = callback[1](clientPeer)
        if code == GameOverCode.GameStarted then
            HostApi.sendGameover(clientPeer:getRakssid(), IMessages:msgGameHasStarting(), GameOverCode.GameStarted)
            return true
        end
        if code == GameOverCode.GameEnd then
            HostApi.sendGameover(clientPeer:getRakssid(), IMessages:msgGameEnd(), GameOverCode.GameEnd)
            return true
        end
        if code ~= GameOverCode.Success then
            HostApi.sendGameover(clientPeer:getRakssid(), IMessages:msgGameOver(), GameOverCode.GameOver)
            return true
        end
        if player == nil then
            code = GameOverCode.Success
            player = BasePlayer.new(clientPeer)
            player:initStaticAttr(player.dynamicAttr.team)
        end
    end
    SConnectorCenter:onUserLogin(clientPeer:getPlatformUserId())
    PlayerManager:addPlayer(player)
    if BaseMain:isChina() and Platform.isLinux() then
        player.gameTimeToday = gameTimeToday or 0
    else
        player.gameTimeToday = -1
    end
    player.enableIndie = enableIndie or false
    if PlayerManager:isPlayerFull() then
        HostApi.sendStartGame(PlayerManager:getPlayerCount())
    end
    if status ~= nil and status >= 1 and status <= 2 then
        HostApi.sendGameStatus(clientPeer:getRakssid(), status)
    end
    if c_callback ~= nil then
        c_callback()
    end
    Plugins.CallPluginFunc("onPlayerLogin", player)
    WebService:GetUserMoney(player.userId)
    if delayDBTime and delayDBTime > 0 then
        LuaTimer:schedule(function()
            player = PlayerManager:getPlayerByUserId(player.userId)
            if not player then
                return
            end
            if DBManager:onPlayerLogin(player) then
                PacketSender:sendPlayerDBReady(player)
            end
        end, delayDBTime)
        return false
    else
        if DBManager:onPlayerLogin(player) then
            print("PacketSender:sendPlayerDBReady " .. StringUtil.v2s(player.userId))
            PacketSender:sendPlayerDBReady(player)
        end
        return false
    end
end

function BaseListener.onPlayerLogout(rakssid)
    local watcher = PlayerManager:getWatcherByRakssid(rakssid)
    if watcher then
        SConnectorCenter:onUserOut(watcher.userId)
        PacketChecker:onPlayerLogout(watcher.userId)
        ClientFileChecker:clearCheckTask(watcher.userId)
        PlayerManager:subWatcher(watcher)
        GMHelper:onPlayerLogout(watcher)
        tryCallEvent(CEvents.WatcherLogoutEvent, watcher)
        return true
    end

    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if not player then
        return false
    end
    Plugins.CallPluginFunc("onPlayerLogoutBefore", player)
    GMHelper:onPlayerLogout(player)
    SConnectorCenter:onUserOut(player.userId)
    PacketChecker:onPlayerLogout(player.userId)
    ClientFileChecker:clearCheckTask(player.userId)
    GameGroupManager:removeUser(player.userId)
    SumRechargeHelper:onPlayerLogout(player.userId)
    PlayerManager:subPlayer(player)
    local clear = function()
        ---玩家正常退出游戏后，保存一次数据
        if not player.isKickOut then
            DBManager:callSavePlayerData(player)
        end
        Plugins.CallPluginFunc("onPlayerLogout", player)
        player:onPlayerLogout()
        if DBManager:isAutoCache() then
            DBManager:removeCache(player.userId)
        end
        RewardManager:removeRewardCache(player.userId)
        GameAnalyticsCache:removeCache(player.userId)
        MaxRecordHelper:onPlayerLogout(player.userId)
        SumRechargeHelper:removeCache(player)
    end
    tryCallEvent(CEvents.PlayerLogoutEvent, player)
    clear()
    return true
end

function BaseListener.onPlayerReady(rakssid)
    local player = PlayerManager:getWatcherByRakssid(rakssid)
    if player then
        SConnectorCenter:onUserIn(player.userId)
        PacketSender:sendDataReport(rakssid, "follow_watch", GameType)
        intoFollowMode(player, player.dynamicAttr.targetUserId)
        Events.WatcherReadyEvent:invoke(player)
        return
    end
    player = PlayerManager:getPlayerByRakssid(rakssid)
    if player == nil then
        HostApi.sendGameover(rakssid, IMessages:msgGameOver(), GameOverCode.ReadyNoPlayer)
        return
    end
    if player:checkReady() then
        BaseListener.onSavePlayerDBData(player.userId)
        HostApi.sendGameover(rakssid, IMessages:msgGameOver(), GameOverCode.GameOver)
        LogUtil.logError("BaseListener.onPlayerReady() repeat ready userId=" .. player.userId)
        return
    end
    SConnectorCenter:onUserIn(player.userId)
    local callback = callbacks[CEvents.PlayerReadyEvent]
    if not callback then
        return
    end
    player.isReady = true
    Plugins.CallPluginFunc("onPlayerReady", player)
    local _, time = tryCallEvent(CEvents.PlayerReadyEvent, player)
    DBManager:onPlayerReady(player)
    SumRechargeHelper:onPlayerReady(player)
    ExchangeHelper:onPlayerReady(player)
    GMHelper:onPlayerReady(player)
    player:uploadTotalRecharge()
    if type(time) == "number" and time > 0 then
        player:addNightVisionPotionEffect(time)
    end
    if player.dynamicAttr.followEnterType == 1 then
        PacketSender:sendDataReport(rakssid, "follow_game", GameType)
    end
    WebService:GetVipInfo(player.userId)
    WebService:GetUserPrivilege(player.userId)
end

---@param clientPeer ClientPeer
function BaseListener.onPlayerFirstSpawn(clientPeer)
    local player = PlayerManager:getPlayerByRakssid(clientPeer:getRakssid())
    if player == nil then
        return
    end
    PlayerIdentityCache:onPlayerSpawn(player)
    tryCallEvent(CEvents.PlayerFirstSpawnEvent)
end

---@param playerMP EntityPlayerMP
function BaseListener.onPlayerAfterRespawn(playerMP)
    local player = PlayerManager:getPlayerByUserId(playerMP:getPlatformUserId())
    if player == nil then
        return
    end
    tryCallEvent(CEvents.PlayerAfterRespawnEvent, player)
end

---@param playerMP EntityPlayerMP
function BaseListener.onPlayerRespawn(playerMP)
    local player = PlayerManager:getPlayerByUserId(playerMP:getPlatformUserId())
    if player == nil then
        return
    end
    PlayerIdentityCache:onPlayerSpawn(player)
    if player.clientPeer then
        player:respawn(player.clientPeer)
    end
    local _, time = tryCallEvent(CEvents.PlayerRespawnEvent, player)
    if type(time) == "number" and time > 0 then
        player:addNightVisionPotionEffect(time)
    end
end

function BaseListener.onPlayerReviewPlayer(selfId, targetId)
    local player = PlayerManager:getPlayerByRakssid(selfId)
    if not player then
        return
    end
    player:setShowName(player:buildShowName(), targetId)
end

function BaseListener.onGetDataFromDB(userId, subKey, data)
    local callback = callbacks[Events.GetDataFromDBEvent]
    if not callback then
        return
    end
    local player = PlayerManager:getPlayerByUserId(userId)
    if player ~= nil then
        if DBManager:isAutoCache() then
            DBManager:addCache(userId, subKey, data)
        end
        tryCallEvent(Events.GetDataFromDBEvent, player, subKey, data)
    end
end

function BaseListener.onClientCommonData(userId, key, data)
    local success, result = pcall(CommonDataEvents.dispatchEvent, CommonDataEvents, userId, key, data)
    if not success then
        PacketChecker:addErrorTimes(userId)
        LogUtil.logScriptException(result)
    end
end

---@param entity Entity
function BaseListener.onSpawnEntity(entity, type, properties)
    if not EngineWorld:getWorld() then
        return
    end
    tryCallEvent(CEvents.SpawnEntityEvent, EntityCache:createEntityCache(entity, type, properties))
end

function BaseListener.onRemoveEntity(entityId)
    EntityCache:removeEntityCache(entityId)
end

---@param hurtPlayer EntityPlayerMP
---@param hurtFrom EntityPlayerMP
function BaseListener.onPlayerHurt(hurtPlayer, hurtFrom, ...)
    ---攻击者如果是 观战者拦截攻击
    if hurtFrom and PlayerManager:getWatcherByUserId(hurtFrom:getPlatformUserId()) then
        return false
    end
    local register, result = tryCallEvent(CEvents.PlayerAttackedEvent, hurtPlayer, hurtFrom, ...)
    if not register then
        return true
    end
    return result
end

---@param diePlayer EntityPlayerMP
---@param killPlayer EntityPlayerMP
function BaseListener.onPlayerDied(diePlayer, isKillByPlayer, killPlayer)
    ---死亡者如果是 观战者必须死
    if diePlayer and PlayerManager:getWatcherByUserId(diePlayer:getPlatformUserId()) then
        return true
    end
    local register, result = tryCallEvent(CEvents.PlayerDieEvent, diePlayer, isKillByPlayer, killPlayer)
    if not register then
        return true
    end
    return result
end

---@param diePlayer EntityPlayerMP
---@param killPlayer EntityPlayerMP
function BaseListener.onPlayerDiedTip(diePlayer, killPlayer)
    ---死亡者如果是 观战者 不提示
    if diePlayer and PlayerManager:getWatcherByUserId(diePlayer:getPlatformUserId()) then
        return false
    end
    local register, result = tryCallEvent(CEvents.PlayerDieTipEvent, diePlayer, killPlayer)
    if not register then
        return true
    end
    return result
end

local function isNaN(value)
    return value ~= value
end

---@param playerMp EntityPlayerMP
function BaseListener.onPlayerMove(playerMp, x, y, z)
    if isNaN(x) or isNaN(y) or isNaN(z) then
        return false
    end
    ---移动者如果是 观战者 默认允许移动
    if playerMp and PlayerManager:getWatcherByUserId(playerMp:getPlatformUserId()) then
        return true
    end
    if x == 0 and y == 0 and z == 0 then
        return true
    end
    local register, result = tryCallEvent(CEvents.PlayerMoveEvent, playerMp, x, y, z)
    if not register then
        return true
    end
    return result
end

function BaseListener.onPlayerReconnectSuccess(clientPeer)

end

function BaseListener.onSavePlayerDBData(userId)
    local player = PlayerManager:getPlayerByUserId(userId)
    if player ~= nil then
        ---玩家被踢退出游戏，保存一次数据
        player.isKickOut = true
        player.isKickOutDB = true
        DBManager:callSavePlayerData(player)
    end
end

---@param attr UserAttrInfo
function BaseListener.onPlayerDynamicAttr(attr)
    local userId = attr.userId
    if not Platform.isWindow() and not ServerHelper.getBoolPrefs("DisableRoomUserManager") then
        if Server.Instance():getEnableRoom() then
            LuaTimer:schedule(function(requestId)
                local player = PlayerManager:getPlayerByUserId(userId)
                local watcher = PlayerManager:getWatcherByUserId(userId)
                if not player and not watcher then
                    GameServer:getRoomManager():sendUserOut(userId, requestId)
                end
            end, 90000, nil, attr.requestId)
        end
    end
    if attr.followEnterType == 2 then
        return
    end
    tryCallEvent(CEvents.PlayerDynamicAttrEvent, attr)
end

function BaseListener.onGameStatusChange(status)
    PlayerManager:onGameStatusChange(status)
end

function BaseListener.onReceiveRoomCommonMsg(content)
    local ok, result = pcall(json.decode, content)
    if not ok then
        return
    end
    tryCallEvent(CEvents.ReceiveRoomCommonMsgEvent, result)
end

function BaseListener.onServerDataReport(uid, event, args)
    if isLocalWin then
        return
    end
    GameAnalytics:newDesign(uid, event, args)

end

function BaseListener.onBeforeCloseSession(uid, totalPacketsPerSec, totalInvalidPackets)
    if isLocalWin then
        return
    end
    GameAnalytics:newDesign(uid, "DDOS_PACKETS_INFO", { totalPacketsPerSec = totalPacketsPerSec, totalInvalidPackets = totalInvalidPackets })
end

function BaseListener.onServerQuit(blackListCount)
    if isLocalWin then
        return
    end
    GameAnalytics:newDesign(0, "BLACKLIST_COUNT", { blackListCount = blackListCount })
end

function BaseListener.onRechargeResult(rakssid, type, result)
    if result ~= 1 then
        ---购买不成功
        return
    end
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if not player then
        return
    end
    if type == 1 then
        ---购买金魔方
        player:uploadTotalRecharge()
    elseif type == 5 then
        ---购买代金券
    elseif type == 6 then
        ---更新订阅状态
        WebService:GetVipInfo(player.userId)
    end
    WebService:GetUserMoney(player.userId)
    WebService:GetUserPrivilege(player.userId)
end

function BaseListener.onEnginePayMoney(userId, uniqueId, currencyType, price, reason, sessionId)
    local player = PlayerManager:getPlayerByUserId(userId)
    if not player then
        return
    end
    PayHelper.payMoneySync(player, uniqueId, currencyType, price, function()
        HttpRequest.onPayResult(sessionId, userId, true)
    end, function()
        HttpRequest.onPayResult(sessionId, userId, false)
    end, nil, reason, 1)
end

function BaseListener.onRemoteLuaResult(playerId, id, result)
    local player = PlayerManager:getPlayerByUserId(playerId)
    if not player then
        return
    end
    tryCallEvent(CEvents.RemoteLuaResultEvent, player, id, result)
end

function BaseListener.onBindEntity()
    return false
end

function BaseListener.onUnbindEntity()
    return false
end

return BaseListener--[[KAAUlhGr9aqzOQKVRJiHkBRMZPDuItvsCY35bVTJZ]]