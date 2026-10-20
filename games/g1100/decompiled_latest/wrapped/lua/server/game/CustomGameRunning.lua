--[[qaDj3pq8CPJE45KdUJLXj6gDgjolV1QmKqLAsbBuuk0i9DetLqNE6hYZXgUnT]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 39245
                          local checkFileName = "CustomGameRunning.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[wtcz1h0K8fOhggkPWp0RWasJQyKwsKywKFXCTcrlYqX]]require "task.GameOverTask"
require "task.GameTimeTask"
require "task.WaitingPlayerTask"
local CustomGameRunning = class("CustomGameRunning", require "game.CustomGame")
local GameTeamMarker = require "data.GameTeamMarker"
---@type GameTeam
local GameTeam = require "data.GameTeam"
---@type [string, GameTeam]
local Teams = {}

-- 击杀或收集
local GameOverKillOrCollectFunc = function(customGameRun, Teams, param, isEndMatch)
    local winTeam = 0
    if customGameRun.allowJoinAfterStart then
        return winTeam
    end
    if customGameRun.isTeamMatch then
        local survivalTeam = {}
        for _, team in pairs(Teams) do
            if team:getLifeCount() > 0 then
                table.insert(survivalTeam, team.id)
            end
        end
        if #survivalTeam == 1 then
            winTeam = survivalTeam[1]
        end
    else
        local size = TableUtil.getTableSize(Teams)
        if size == 1 then
            for _, team in pairs(Teams) do
                winTeam = team.id
            end
        end
    end
    return winTeam
end
-- 击杀或收集达到数量
local GameOverKillNumOrCollectNumFunc = function(customGameRun, Teams, param, isEndMatch)
    local goal = param[1]
    local winTeam = 0
    for _, team in pairs(Teams) do
        if team:getScore() >= goal then
            winTeam = team.id
            break
        end
    end
    if winTeam == 0 and isEndMatch then
        local rank = {}
        for _, team in pairs(Teams) do
            table.insert(rank, {
                id = team.id,
                score = team:getScore()
            })
        end
        table.sort(rank, function(a, b)
            return a.score > b.score
        end)
        if #rank > 0 then
            if rank[1].score > 0 then
                winTeam = rank[1].id
            end
        end
    end
    if winTeam == 0 then
        winTeam = GameOverKillOrCollectFunc(customGameRun, Teams, param, isEndMatch)
    end
    return winTeam
end
-- 生存到最后
local GameOverSurvivalFunc = function(customGameRun, Teams, param, isEndMatch)
    local survivalTeam = {}
    for _, team in pairs(Teams) do
        if team:getLifeCount() > 0 then
            table.insert(survivalTeam, team.id)
        end
    end
    if #survivalTeam == 1 then
        return survivalTeam[1]
    end
    return 0
end
-- 摧毁标志物
local GameOverMarkerFunc = function(customGameRun, Teams, param, isEndMatch)
    local markerTeam = {}
    for _, team in pairs(Teams) do
        if not team:getMarkerIsDestroyed() then
            table.insert(markerTeam, team.id)
        end
    end
    if #markerTeam == 1 then
        return markerTeam[1]
    end
    return 0
end
-- 摧毁标志物和击杀
local GameOverMarkerAndKillFunc = function(customGameRun, Teams, param, isEndMatch)
    local survivalTeam = {}
    for _, team in pairs(Teams) do
        if team:getLifeCount() > 0 then
            table.insert(survivalTeam, team.id)
        elseif not team:getMarkerIsDestroyed() then
            table.insert(survivalTeam, team.id)
        end
    end
    if #survivalTeam == 1 then
        return survivalTeam[1]
    end
    return 0
end
local GameOverFunc = {}
GameOverFunc[Define.OverCondition.CollectNum] = GameOverKillNumOrCollectNumFunc
GameOverFunc[Define.OverCondition.KillNum] = GameOverKillNumOrCollectNumFunc
GameOverFunc[Define.OverCondition.Survival] = GameOverSurvivalFunc
GameOverFunc[Define.OverCondition.Collect] = GameOverKillOrCollectFunc
GameOverFunc[Define.OverCondition.Kill] = GameOverKillOrCollectFunc
GameOverFunc[Define.OverCondition.Marker] = GameOverMarkerFunc
GameOverFunc[Define.OverCondition.MarkerAndKill] = GameOverMarkerAndKillFunc

local JoinGameAfterStartSign = {}
JoinGameAfterStartSign[Define.OverCondition.CollectNum] = true
JoinGameAfterStartSign[Define.OverCondition.KillNum] = true
JoinGameAfterStartSign[Define.OverCondition.Survival] = false
JoinGameAfterStartSign[Define.OverCondition.Collect] = true
JoinGameAfterStartSign[Define.OverCondition.Kill] = true
JoinGameAfterStartSign[Define.OverCondition.Marker] = true
JoinGameAfterStartSign[Define.OverCondition.MarkerAndKill] = false

-- 默认排行规则
local TeamRankingDefaultRulesFunc = function(list)
    table.sort(list, function(a, b)
        if a.score == b.score then
            return a.id < b.id
        else
            return a.score > b.score
        end
    end)
    for i, v in ipairs(list) do
        v.rank = i
    end
end
-- 标志物排行规则
local TeamRankingMarkerRulesFunc = function(list)
    table.sort(list, function(a, b)
        if a.markerState == b.markerState then
            if a.score == b.score then
                return a.id < b.id
            else
                return a.score > b.score
            end
        else
            return a.markerState < b.markerState
        end
    end)
    for i, v in ipairs(list) do
        v.rank = i
    end
end
local TeamRankingRulesFunc = {}
TeamRankingRulesFunc[Define.OverCondition.CollectNum] = TeamRankingDefaultRulesFunc
TeamRankingRulesFunc[Define.OverCondition.KillNum] = TeamRankingDefaultRulesFunc
TeamRankingRulesFunc[Define.OverCondition.Survival] = TeamRankingDefaultRulesFunc
TeamRankingRulesFunc[Define.OverCondition.Collect] = TeamRankingDefaultRulesFunc
TeamRankingRulesFunc[Define.OverCondition.Kill] = TeamRankingDefaultRulesFunc
TeamRankingRulesFunc[Define.OverCondition.Marker] = TeamRankingMarkerRulesFunc
TeamRankingRulesFunc[Define.OverCondition.MarkerAndKill] = TeamRankingMarkerRulesFunc

function CustomGameRunning:initDefaultPermission()
	self.V1RoomPermSetting = {
		[Define.CustomRoomSettingType.PVP] = true,
		[Define.CustomRoomSettingType.FLY] = false,
		[Define.CustomRoomSettingType.PLACE_BLOCK] = false,
		[Define.CustomRoomSettingType.BREAK_BLOCK] = false,
		[Define.CustomRoomSettingType.FOOD] = false,
		[Define.CustomRoomSettingType.FAST_BREAK_BLOCK] = false,
		[Define.CustomRoomSettingType.UNLIMIT_ITEM] = false
    }

    self.globalPermSetting = {
        [Define.CustomRoomSettingType.PVP] = true,
        [Define.CustomRoomSettingType.FLY] = false,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = false,
        [Define.CustomRoomSettingType.UNLIMIT_ITEM] = false,
        [Define.CustomRoomSettingType.DROP_ITEM_ON_DIE] = false,
        [Define.CustomRoomSettingType.CAN_USE_GUN] = true
    }

    self.defaultPermSettingForRole[Define.CustomGamePermissionRole.Owner] = {
        [Define.CustomRoomSettingType.PVP] = true,
        [Define.CustomRoomSettingType.FLY] = false,
        [Define.CustomRoomSettingType.PLACE_BLOCK] = false,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = false,
        [Define.CustomRoomSettingType.FOOD] = false,
        [Define.CustomRoomSettingType.FAST_BREAK_BLOCK] = false,
        [Define.CustomRoomSettingType.UNLIMIT_ITEM] = false,
		[Define.CustomRoomSettingType.SPECIAL_BLOCK] = false
    }

    self.defaultPermSettingForRole[Define.CustomGamePermissionRole.Admin] = {
        [Define.CustomRoomSettingType.PVP] = true,
        [Define.CustomRoomSettingType.FLY] = false,
        [Define.CustomRoomSettingType.PLACE_BLOCK] = false,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = false,
        [Define.CustomRoomSettingType.FOOD] = false,
        [Define.CustomRoomSettingType.FAST_BREAK_BLOCK] = false,
        [Define.CustomRoomSettingType.UNLIMIT_ITEM] = false,
		[Define.CustomRoomSettingType.SPECIAL_BLOCK] = false
    }


    self.defaultPermSettingForRole[Define.CustomGamePermissionRole.Member]  = {
        [Define.CustomRoomSettingType.PVP] = true,
        [Define.CustomRoomSettingType.FLY] = false,
        [Define.CustomRoomSettingType.PLACE_BLOCK] = false,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = false,
        [Define.CustomRoomSettingType.FOOD] = false,
        [Define.CustomRoomSettingType.FAST_BREAK_BLOCK] = false,
        [Define.CustomRoomSettingType.UNLIMIT_ITEM] = false,
		[Define.CustomRoomSettingType.SPECIAL_BLOCK] = false
    }

    self.defaultPermSettingForRole[Define.CustomGamePermissionRole.Guest]= {
        [Define.CustomRoomSettingType.PVP] = false,
        [Define.CustomRoomSettingType.FLY] = false,
        [Define.CustomRoomSettingType.PLACE_BLOCK] = false,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = false,
        [Define.CustomRoomSettingType.FOOD] = false,
        [Define.CustomRoomSettingType.FAST_BREAK_BLOCK] = false,
        [Define.CustomRoomSettingType.UNLIMIT_ITEM] = false,
		[Define.CustomRoomSettingType.SPECIAL_BLOCK] = false
    }

    self.defaultPermSettingForRole[Define.CustomGamePermissionRole.UDefine]  = {
        [Define.CustomRoomSettingType.PVP] = true,
        [Define.CustomRoomSettingType.FLY] = false,
        [Define.CustomRoomSettingType.PLACE_BLOCK] = false,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = false,
        [Define.CustomRoomSettingType.FOOD] = false,
        [Define.CustomRoomSettingType.FAST_BREAK_BLOCK] = false,
        [Define.CustomRoomSettingType.UNLIMIT_ITEM] = false,
		[Define.CustomRoomSettingType.SPECIAL_BLOCK] = false
    }
end

function CustomGameRunning:initOldPermSetting()
    self.oldGlobalPermSetting = {
        [Define.CustomRoomSettingType.PVP] = true,
        [Define.CustomRoomSettingType.FLY] = true,
        [Define.CustomRoomSettingType.PLACE_BLOCK] = true,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = true,
        [Define.CustomRoomSettingType.FOOD] = true,
        [Define.CustomRoomSettingType.FAST_BREAK_BLOCK] = false,
        [Define.CustomRoomSettingType.UNLIMIT_ITEM] = false,
        [Define.CustomRoomSettingType.SPECIAL_BLOCK] = true
    }
end

function CustomGameRunning:getGlobalSettingForV1Setting()
    return  {
        [Define.CustomRoomSettingType.PVP] = true,
        [Define.CustomRoomSettingType.FLY] = false,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = true,
        [Define.CustomRoomSettingType.UNLIMIT_ITEM] = false,
        [Define.CustomRoomSettingType.DROP_ITEM_ON_DIE] = true,
        [Define.CustomRoomSettingType.CAN_USE_GUN] = true
    }
end

function CustomGameRunning:getGameMode()
    return Define.CustomGameMode.RUN
end

-- GameConfig               游戏配置
-- Teams                    队伍列表
-- GameState                游戏状态

-- self.allowJoinAfterStart 中途加入对战
-- self.isTeamMatch         队赛
-- self.isIndividualMatch   个人赛
-- self.randomSpawn         个人赛下随机出生点
-- self.itemSpawnEIDList    物品掉落或者出现过在地图上的物品类Map
-- self.chestList           箱子列表
-- self.conditionType       胜负条件类型
-- self.dieDrop             死亡掉落
-- self.dropAutoDestroy     死亡掉落自动销毁
-- self.dropDestroyTime     死亡掉落自动销毁时间
-- self.checkGameOver       检测游戏是否结束
-- self.playerFollowMap     观战玩家跟随Map
-- self.checkFollowMap      检测观战是否有效
-- self.deadTeleportMap     死亡玩家待传送Map

-- 准备
function CustomGameRunning:initGameSetting()
    isGameStart = false
    isGameEnd = true
    self.configMgr = self.configMgr or require "base.config.UGCPVPConfigMgr"
    GameConfig = self.configMgr:loadConfigForRunning(self.initPos)
    -- GameConfig.winCondition.type = Define.OverCondition.Collect
    -- GameConfig.winCondition.param = {10, 2, 0}
    -- GameConfig.teamSetting.teamCount = 0
    -- GameConfig.teamSetting.teamSize = 2
    -- GameConfig.gameSetting.startPlayers = 2

    local teamCount = GameConfig.teamSetting.teamCount
    -- 中途加入对战
    self.allowJoinAfterStart = GameConfig.gameSetting.allowJoinAfterStart
    -- 是否队赛
    self.isTeamMatch = teamCount > 0
    -- 是否个人赛
    self.isIndividualMatch = teamCount == 0
    -- 个人赛下随机出生点
    self.randomSpawn = false
    if self.isIndividualMatch then
        self.randomSpawn = GameConfig.teamSetting.randomSpawn
    end
    -- 物品掉落或者出现过在地图上的物品类entityId列表
    self.itemSpawnEIDList = {}
    -- 箱子列表
    self.chestList = {}
    -- 胜负条件类型
    self.conditionType = GameConfig.winCondition.type
    -- 死亡掉落
    self.dieDrop = GameConfig.otherSetting.dieDrop
    -- 死亡掉落自动销毁
    self.dropAutoDestroy = GameConfig.otherSetting.dropAutoDestroy
    -- 死亡掉落自动销毁时间
    self.dropDestroyTime = GameConfig.otherSetting.dropDestroyTime
    -- 检测游戏是否结束
    self.checkGameOver = false
    -- 观战玩家跟随Map
    self.playerFollowMap = {}
    -- 检测观战是否有效
    self.checkFollowMap = false
    -- 死亡玩家待传送Map
    self.deadTeleportMap = {}

    for i = 1, teamCount do
        Teams[i] = self:NewTeam(i)
    end
    local maxPlayer = teamCount * GameConfig.teamSetting.teamSize
    if self.isIndividualMatch then
        maxPlayer = GameConfig.teamSetting.teamSize
    end
    PlayerManager:setMaxPlayer(maxPlayer)
    GameState = Define.GameState.Ready
    WaitingPlayerTask:start()
end
-- 游戏开始
function CustomGameRunning:startMatch()
    isGameStart = true
    isGameEnd = false
    local players = PlayerManager:getPlayers()
    for _, player in pairs(players) do
        self:cancelFollowPlayer(player)
        player:resetScore()
        player:setHealth(player:getMaxHealth())
        player:setFoodLevel(20)
    end
    self.winTeam = 0
    if self.isTeamMatch then
        local count = TableUtil.getTableSize(Teams)
        if count < 1 then
            return
        end
        local index = 1
        for _, player in pairs(players) do
            ---@type GameTeam
            local team = Teams[index] or Teams[1]
            team:addPlayer(player)
            index = (index + 1) % count
            if index == 0 then
                index = count
            end
            player:teleportToTeamInit()
            player:setShowName(player:buildShowName(), 0)
        end
    else
        local index = 1
        for _, player in pairs(players) do
            local team = Teams[index]
            if not team then
                team = self:NewTeam(index)
                Teams[index] = team
            end
            team:addPlayer(player)
            player:teleportToTeamInit()
            player:setShowName(player:buildShowName(), 0)
            index = index + 1
        end
    end
    GameState = Define.GameState.Playing
    GameTimeTask:start()
    HostApi.sendStartGame(PlayerManager:getPlayerCount(), true)
    local remainingTime = GameTimeTask:getRemainingTime()
    for _, player in pairs(players) do
        self:sendStartGame(player, remainingTime)
        MsgSender.sendMsgToTarget(player.rakssid, IMessages:msgGameStart())
    end
    self:syncTeam() -- startMatch
    for teamId, _ in pairs(Teams) do
        self:updateCollectScore(teamId)
    end
end
-- 判断游戏结束
function CustomGameRunning:ifGameOver(isEndMatch)
    self.checkGameOver = false
    if GameState ~= Define.GameState.Playing then
        return
    end
    self.winTeam = 0
    
    local gameOverFunc = GameOverFunc[self.conditionType]
    if gameOverFunc then
        self.winTeam = gameOverFunc(self, Teams, GameConfig.winCondition.param, isEndMatch)
    end

    if not isEndMatch then
        self:syncTeam() -- ifGameOver
        if self.winTeam ~= 0 then
            GameTimeTask:stop()
        end
    end
end
-- 游戏结束
function CustomGameRunning:endMatch()
    isGameStart = false
    isGameEnd = true
    if self.conditionType == Define.OverCondition.Kill or self.conditionType == Define.OverCondition.Collect then
        local rank = {}
        for _, team in pairs(Teams) do
            table.insert(rank, {
                id = team.id,
                score = team:getScore()
            })
        end
        table.sort(rank, function(a, b)
            return a.score > b.score
        end)
        self.winTeam = 0
        if #rank > 0 then
            if rank[1].score > 0 then
                self.winTeam = rank[1].id
            end
        end
        self:syncTeam() -- endMatch
    else
        if self.winTeam == 0 then
            self:ifGameOver(true)
        end
    end
    self:onGameEnd(self.winTeam)
    GameState = Define.GameState.Settlement
    GameOverTask:start()
end
-- 同步结算信息
function CustomGameRunning:onGameEnd(winTeam)
    local inGamePlayer = {}
    local players = PlayerManager:getPlayers()
    for _, player in pairs(players) do
        if player.teamId and player.teamId ~= 0 then
            table.insert(inGamePlayer, player)
        end
    end
    table.sort(inGamePlayer, function(a, b)
        if a.score ~= b.score then
            return a.score > b.score
        end
        return a.userId > b.userId
    end)
    local record = {}
    local userId_record = {}
    for rank, player in ipairs(inGamePlayer) do
        local item = self:newSettlementItem(player, rank, winTeam)
        record[rank] = item
        userId_record[player.userId] = item
    end
    local result = nil
    for _, player in pairs(players) do
        if player.teamId and player.teamId ~= 0 then
            result = {}
            result.players = record
            result.own = userId_record[player.userId]
        else
            result = nil
        end
        player:sendPacket({
            pid = "showSummary",
            data = result
        })
    end
end
-- 重置游戏
function CustomGameRunning:resetGame()
    Plugins.CallTargetPluginFunc("resources", "resetResources")
    HostApi.sendResetGame(PlayerManager:getPlayerCount())
    local world = EngineWorld:getWorld()
    if world then
        world:resetChest()
    end
    for entityId, _ in pairs(self.itemSpawnEIDList) do
        EngineWorld:removeEntity(tonumber(entityId))
    end
    self.itemSpawnEIDList = {}
    for _, chest in pairs(self.chestList) do
        chest:resetChest()
    end
    self.chestList = {}
    HostApi.resetMap()
    for _, team in pairs(Teams) do
        team:reset()
    end
    if self.isIndividualMatch then
        Teams = {}
    end
    local players = PlayerManager:getPlayers()
    for _, player in pairs(players) do
        if not player.isLife then
            player.isLife = true
            player.clientPeer:rebirth()
        end
        self:cancelFollowPlayer(player)
        player:resetScore()
        player:setHealth(player:getMaxHealth())
        player:setFoodLevel(20)
        player:setTeamId(0)
        player:teleportToTeamInit()
        player:clearInv()
        player:setShowName(player:buildShowName(), 0)
    end
    self.deadTeleportMap = {}
    GameState = Define.GameState.Ready
    WaitingPlayerTask:start()
end


-- 登录
function CustomGameRunning:onPlayerLogin(player)
    if not self.allowJoinAfterStart then
        if GameState == Define.GameState.Playing then
            self:setFollowPlayer(player, player.userId, true)
        end
        return
    end
    if GameState ~= Define.GameState.Playing then
        return
    end
    if not JoinGameAfterStartSign[self.conditionType] then
        self:setFollowPlayer(player, player.userId, true)
        return
    end
end
-- 登录后1s
function CustomGameRunning:onPlayerLoginAfter1Sec(player)
    if GameState ~= Define.GameState.Playing then
        return
    end
    if not self:checkJoinGameInLogin(player) then
        self:syncTeam(player) -- onPlayerLoginAfter1Sec
    end
end
-- 能否加入游戏
function CustomGameRunning:checkJoinGameInLogin(player)
    if not self.allowJoinAfterStart then
        if GameState == Define.GameState.Playing then
            self:sendStartGame(player, GameTimeTask:getRemainingTime())
        end
        return false
    end
    if not JoinGameAfterStartSign[self.conditionType] then
        self:sendStartGame(player, GameTimeTask:getRemainingTime())
        return false
    end
    -- 允许中途加入游戏
    if self.isIndividualMatch then
        local index, team = self:NewEmptyTeam()
        if index == 0 then
            self:setFollowPlayer(player, player.userId, true)
            return false
        end
        Teams[index] = team
        team:addPlayer(player)
    else
        local count = TableUtil.getTableSize(Teams)
        if count == 0 then
            self:setFollowPlayer(player, player.userId, true)
            return false
        end
        local team = self:GetSmallestTeam()
        team:addPlayer(player)
    end
    player:teleportToTeamInit()
    player:setShowName(player:buildShowName(), 0)
    HostApi.sendStartGame(PlayerManager:getPlayerCount(), true)
    self:sendStartGame(player, GameTimeTask:getRemainingTime())
    MsgSender.sendMsgToTarget(player.rakssid, IMessages:msgGameStart())
    for teamId, _ in pairs(Teams) do
        self:updateCollectScore(teamId)
    end
    self:syncTeam(player) -- checkJoinGameInLogin
    return true
end
-- 登出
function CustomGameRunning:onPlayerLogOut(player)
    self:checkWacth(player)
    self:checkExchangeOwner(player)
    self.deadTeleportMap[player.userId] = nil
    local teamId = player.teamId or 0
    if teamId == 0 or not Teams[teamId] then
        return
    end
    local team = Teams[teamId]
    team:subPlayer(player.userId)
    if self.isIndividualMatch then
        self:DeleteTeam(teamId)
    end
    self.checkGameOver = true
    self.checkFollowMap = true
end
-- 玩家死亡 @param player GamePlayer
function CustomGameRunning:onPlayerDied(player)
    -- print("onPlayerDied player died userId:" .. tostring(player.userId))
    self.deadTeleportMap[player.userId] = player
    if not player.isLife then
        return
    end
    player.isLife = false
    if not player.teamId or player.teamId == 0 or not Teams[player.teamId] then
        RespawnHelper.addRespawnCountdown(player, 0)
        self:setFollowPlayer(player, player.userId)
    else
        self.checkFollowMap = true
        local team = Teams[player.teamId]
        if self.conditionType == Define.OverCondition.Survival then
            team:subPlayer(player.userId)
            if self.isIndividualMatch then
                self:DeleteTeam(player.teamId)
            end
            self:setFollowPlayer(player, player.userId)
            self.checkGameOver = true
        else
            if self.conditionType == Define.OverCondition.Marker or self.conditionType == Define.OverCondition.MarkerAndKill then
                if team:getMarkerIsDestroyed() then
                    team:subPlayer(player.userId)
                    if self.isIndividualMatch then
                        self:DeleteTeam(player.teamId)
                    end
                    self:setFollowPlayer(player, player.userId)
                    self.checkGameOver = true
                    return
                end
            end
            if self.randomSpawn then
                local randomNumber = math.random(1, #GameConfig.teamSetting.birthPositions)
                local pos = GameConfig.teamSetting.birthPositions[randomNumber]
                team:setRespawnPos(player, pos)
            end
            local respawnTime = GameConfig.gameSetting.RespawnTime
            RespawnHelper.addRespawnCountdown(player, respawnTime)
            self:sendPlayerRespawnCountdown(player, respawnTime)
        end
    end
end
-- 击杀玩家
function CustomGameRunning:onPlayerKillOther(player, dier)
    -- print("onPlayerKillOther player userId:" .. tostring(player.userId))
    if GameState ~= Define.GameState.Playing then
        return
    end
    self:sendPlayerKillAndKilled(player, dier)
    if self.conditionType == Define.OverCondition.CollectNum or self.conditionType == Define.OverCondition.Collect then
        return
    end
    player.score = (player.score or 0) + 1
    player.killNum = (player.killNum or 0) + 1
    ---@type GameTeam
    local team = Teams[player.teamId]
    if not team then
        return
    end
    team:addScore(1)
end
-- 玩家死亡结束
function CustomGameRunning:onPlayerDiedEnd(dier, killer)
    -- print("onPlayerDiedEnd dier:" .. tostring(dier) .. " killer:" .. tostring(killer))
    if self.conditionType == Define.OverCondition.CollectNum or self.conditionType == Define.OverCondition.Collect then
        return
    end
    if dier.teamId and dier.teamId > 0 then
        if self.conditionType == Define.OverCondition.Survival then
            self.checkGameOver = true
            return
        end
    end
    if not killer then
        return
    end
    if GameState ~= Define.GameState.Playing then
        return
    end
    local team = Teams[killer.teamId]
    if not team then
        return
    end
    self.checkGameOver = true
end
-- 玩家重生
function CustomGameRunning:onPlayerRebirth(player)
    if self:canDeathDropItem(player) then
        if player.teamId and player.teamId ~= 0 then
            local team = self:getTeam(player.teamId)
            if team then
                team:initEquipmentsAndItems(player)
            end
        end
    end
end
-- 打开箱子
function CustomGameRunning:onChestOpen(vec3, inv, rakssid)
    local key = tostring(vec3.x) .. " " .. tostring(vec3.y).. " " .. tostring(vec3.z)
    if not self.chestList[key] then
        self.chestList[key] = inv
    end
end
-- 掉落物品
function CustomGameRunning:onDropSpawnEntity(IEntity)
    local time = 0
    if self.dieDrop and self.dropAutoDestroy then
        time = os.time() + self.dropDestroyTime or 10
    end
    self.itemSpawnEIDList[IEntity.entityId] = time
end
-- 更新收集分数
function CustomGameRunning:updateCollectScore(teamId)
    if self.conditionType ~= Define.OverCondition.Collect and self.conditionType ~= Define.OverCondition.CollectNum then
        return
    end
    if GameState ~= Define.GameState.Playing then
        return
    end
    local team = Teams[teamId]
    if not team then
        return
    end
    team:updateCollectScore()
    self.checkGameOver = true
end
-- 同步排行榜
function CustomGameRunning:syncTeam(sendPlayer)
    local packet = {
        pid = "SyncTeamInfo",
        data = {
            isTeamMatch = self.isTeamMatch,
            conditionType = self.conditionType,
            info = {}
        }
    }
    for _, team in pairs(Teams) do
        table.insert(packet.data.info, {
            id = team.id,
            num = team:getLifeCount(),
            score = team:getScore(),
            markerState = team:getMarkerState(),
            -- isTeamMatch = self.isTeamMatch,
            -- conditionType = self.conditionType,
        })
    end

    local func = TeamRankingRulesFunc[self.conditionType]
    if not func then
        print("No TeamRankingRulesFunc in " .. self.conditionType)
        func = TeamRankingDefaultRulesFunc
    end
    func(packet.data.info)

    if sendPlayer then
        PacketSender:sendPidPacket(sendPlayer.rakssid, packet)
    else
        local players = PlayerManager:getPlayers()
        for _, player in pairs(players) do
            PacketSender:sendPidPacket(player.rakssid, packet)
        end
    end
end
-- 发送游戏开始
function CustomGameRunning:sendStartGame(player, remainingTime)
    PacketSender:sendPidPacket(player.rakssid, {
        pid = "StartGame",
        teamId = player.teamId or 0,
        gameEndTime = remainingTime
    })
end
-- 发送玩家复活倒计时
function CustomGameRunning:sendPlayerRespawnCountdown(player, respawnTime)
    PacketSender:sendPidPacket(player.rakssid, {
        pid = "playerRespawnCountdown",
        respawnTime = respawnTime
    })
end
-- 发送玩家击杀玩家
function CustomGameRunning:sendPlayerKillAndKilled(killer, dier)
    if not killer or not dier then
        return
    end
    PacketSender:sendPidPacket(killer.rakssid, {
        pid = "killPlayerInGame",
        killerUserId = killer.userId,
        dierUserId = dier.userId
    })
    PacketSender:sendPidPacket(dier.rakssid, {
        pid = "playerKilledInGame",
        killerUserId = killer.userId,
        dierUserId = dier.userId
    })
end

function CustomGameRunning:onTick(ticks)
    if GameState == Define.GameState.Playing then
        if self.dieDrop and self.dropAutoDestroy then
            local now = os.time()
            for entityId, destroyTime in pairs(self.itemSpawnEIDList) do
                if destroyTime <= now then
                    self.itemSpawnEIDList[entityId] = nil
                    EngineWorld:removeEntity(tonumber(entityId))
                end
            end
        end
        if self.checkGameOver then
            self:ifGameOver()
        end
        if self.checkFollowMap then
            self:refreshFollowMap()
        end
    end

    for userId, player in pairs(self.deadTeleportMap) do
        if player then
            player:teleportToTeamInit()
        end
        self.deadTeleportMap[userId] = nil
    end
end

-- 判断床是否为标志物
function CustomGameRunning:thisBedIsGameMarker(bedPos1)
    if self.conditionType == Define.OverCondition.Marker or self.conditionType == Define.OverCondition.MarkerAndKill then
        for _, team in pairs(Teams) do
            if team:findMarkerByPos(bedPos1) then
                return true
            end
        end
    end
    return false
end
-- 检测队伍的标志物
function CustomGameRunning:checkTeamMarker(player, vec3)
    local isMarker = false
    local canBreak = true

    if self.conditionType == Define.OverCondition.Marker or self.conditionType == Define.OverCondition.MarkerAndKill then
        local teamId = 0
        if player then
            teamId = player.teamId or 0
        end
        local marker = nil
        for _, team in pairs(Teams) do
            marker = team:findMarkerByPos(vec3)
            if marker then
                break
            end
        end
        if marker then
            isMarker = true
            if marker.teamId == teamId or GameState ~= Define.GameState.Playing then
                marker:CreateMarkerBlockAndActor()
                canBreak = false
            else
                marker:DestroyMarkerBlockAndActor()
                self.checkGameOver = true
            end
        end
    end
    return isMarker, canBreak
end
-- 是否允许破坏方块
function CustomGameRunning:canBreakBlock(vec3)
    if GameState ~= Define.GameState.Playing then
        return false
    end
    if EngineWorld:isBlockChange(vec3) then
        return GameConfig.otherSetting.breakBlock
    end
    return GameConfig.otherSetting.breakMap
end
-- 是否允许放置方块
function CustomGameRunning:canPlaceBlock(vec3)
    if GameState ~= Define.GameState.Playing then
        return false
    end
    return GameConfig.otherSetting.placeBlock or false
end
-- 是否死亡掉落道具
function CustomGameRunning:canDeathDropItem(player)
    if GameState ~= Define.GameState.Playing then
        return false
    end
    return self.dieDrop
end

-- 结算item信息
function CustomGameRunning:newSettlementItem(player, rank, winner)
    local item = {}
    item.name = player.name
    item.rank = rank
    item.score = player.score or 0
    item.teamId = player.teamId
    item.isWin = player.teamId == winner
    return item
end

-- 获取ugc配置
function CustomGameRunning:getUGCRunningSetting()
    return GameConfig
end

---------------------------------------------------------------
-- Team相关
---------------------------------------------------------------
function CustomGameRunning:getTeam(teamId)
    return Teams[teamId]
end
function CustomGameRunning:NewTeam(index)
    local pos = nil
    if self.randomSpawn then
        local randomNumber = math.random(1, #GameConfig.teamSetting.birthPositions)
        pos = GameConfig.teamSetting.birthPositions[randomNumber]
    else
        pos = GameConfig.teamSetting.birthPositions[index]
    end
    local color = GameConfig.teamSetting.teamColorList[index]
    local equipmentsList = GameConfig.teamSetting.equipmentsList or {}
    local equipments = equipmentsList[index] or {}
    local itemsList = GameConfig.teamSetting.itemsList or {}
    local items = itemsList[index] or {}
    local marker = GameTeamMarker.new(index, self.isTeamMatch)
    if self.conditionType == Define.OverCondition.Marker or self.conditionType == Define.OverCondition.MarkerAndKill then
        local startIndex = index * 6 - 4
        param = GameConfig.winCondition.param
        marker.existence = true
        marker.itemId = param[startIndex] or 0
        marker.meta = param[startIndex + 1] or 0
        marker.pos = VectorUtil.newVector3i(
            param[startIndex + 2] or 0,
            param[startIndex + 3] or 0,
            param[startIndex + 4] or 0)
    end
    local config = {
        id = index,
        pos = VectorUtil.toVector3(pos),
        color = color,
        equipments = equipments,
        items = items,
        marker = marker
    }
    return GameTeam.new(config)
end
function CustomGameRunning:NewEmptyTeam()
    local maxIndex = PlayerManager:getMaxPlayer()
    for index = 1, maxIndex do
        if Teams[index] == nil then
            local team = self:NewTeam(index)
            return index, team
        end
    end
    return 0, nil
end
function CustomGameRunning:GetSmallestTeam()
    local sortList = {}
    for index = 1, #Teams do
        local team = Teams[index]
        if team and not team:getMarkerIsDestroyed() then
            local count = team:getLifeCount()
            if count == 0 then
                return team
            end
            table.insert(sortList, {count = count, index = index})
        end
    end
    table.sort(sortList, function(a, b)
        if a.count == b.count then
            return a.index < b.index
        else
            return a.count < b.count
        end
    end)
    return Teams[sortList[1].index]
end
function CustomGameRunning:DeleteTeam(index)
    local team = Teams[index]
    if team then
        team:reset()
    end
    Teams[index] = nil
end
---------------------------------------------------------------

---------------------------------------------------------------
-- 观战相关
---------------------------------------------------------------
-- 清除观战
function CustomGameRunning:checkWacth(player)
    if self.playerFollowMap[player.userId] then
        self.playerFollowMap[player.userId] = nil
    end
end
-- 刷新观战列表
function CustomGameRunning:refreshFollowMap()
    self.checkFollowMap = false
    for watchUserId, followUserId in pairs(self.playerFollowMap) do
        local watchPlayer = PlayerManager:getPlayerByUserId(watchUserId)
        if not watchPlayer then
            self.playerFollowMap[watchUserId] = nil
            goto continue
        end
        if watchUserId == followUserId then
            goto continue
        end
        
        local followPlayer = PlayerManager:getPlayerByUserId(followUserId)
        local invalid = (not followPlayer) or (not followPlayer.isLife) or (followPlayer:getEntityPlayer():isWatchMode())
        if invalid then
            self:setFollowPlayer(watchPlayer, watchUserId)
        end

        ::continue::
    end
end
-- 设置观战并跟随玩家
function CustomGameRunning:setFollowPlayer(player, followUserId, watchMode)
    if watchMode == true then
        player:getEntityPlayer():setWatchMode(true)
    end
    local playerUserIdList = self:getFollowPlayerList(player)
    self.playerFollowMap[player.userId] = followUserId
    self:sendFollowPlayer(player, followUserId, #playerUserIdList)
end
-- 取消观战并跟随玩家
function CustomGameRunning:cancelFollowPlayer(player)
    player:getEntityPlayer():setWatchMode(false)
    self.playerFollowMap[player.userId] = nil
    player:sendPacket({
        pid = "cancelFollowPlayer"
    })
end
-- 查找前一个可以跟随的玩家
function CustomGameRunning:findPreviousFollower(player)
    local playerUserIdList, index = self:getFollowPlayerList(player)
    if index == 0 then
        index = 1
    else
        index = index - 1
        if index == 0 then
            index = #playerUserIdList
        end
    end
    local newUserId = playerUserIdList[index]
    self.playerFollowMap[player.userId] = newUserId
    self:sendFollowPlayer(player, newUserId, #playerUserIdList)
end
-- 查找后一个可以跟随的玩家
function CustomGameRunning:findLatterFollower(player)
    local playerUserIdList, index = self:getFollowPlayerList(player)
    if index == 0 then
        index = 1
    else
        index = index + 1
        if index > #playerUserIdList then
            index = 1
        end
    end
    local newUserId = playerUserIdList[index]
    self.playerFollowMap[player.userId] = newUserId
    self:sendFollowPlayer(player, newUserId, #playerUserIdList)
end
-- 获取可跟随的玩家列表
function CustomGameRunning:getFollowPlayerList(player)
    local selfUserId = player.userId
    local curFollowUserId = self.playerFollowMap[selfUserId]
    local teamId = player.teamId or 0

    local playerUserIdList = {}
    table.insert(playerUserIdList, selfUserId)

    if teamId == 0 or self.isIndividualMatch then
        -- 获取所有活着的参赛玩家
        for _, team in pairs(Teams) do
            local playerList = team:getCurPlayers()
            for userId, _ in pairs(playerList) do
                table.insert(playerUserIdList, userId)
            end
        end
    else
        -- 获取队伍活着的玩家
        local team = Teams[teamId]
        if team then
            local playerList = team:getCurPlayers()
            for userId, _ in pairs(playerList) do
                table.insert(playerUserIdList, userId)
            end
        end
    end

    local index = 0
    if #playerUserIdList > 1 then
        table.sort(playerUserIdList, function(a, b) return a > b end)
        for i, userId in ipairs(playerUserIdList) do
            if userId == curFollowUserId then
                index = i
                break
            end
        end
    else
        if curFollowUserId == playerUserIdList[1] then
            index = 1
        end
    end

    return playerUserIdList, index
end
-- 发送设置跟随玩家
function CustomGameRunning:sendFollowPlayer(player, followUserId, followNum)
    player:sendPacket({
        pid = "followPlayer",
        followUserId = followUserId,
        followNum = followNum
    })
end
---------------------------------------------------------------

return CustomGameRunning--[[1hh9DCmSuTZfmquvTOz23IJNTCT5vmNXpJ2Rn0llnPMzd2ltn0sPwiJc8GcZ3A5iEKpOL3zp85vBSV]]---