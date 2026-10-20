--[[83i4cLJWSTbYhgkDSF5oP0oCkuXZuAy7i4Nng7wSiIDytX1TUn5zJffxragVK4DBlBV85sXs6xlV3oD8y8mabQJ7yZpj4rlXW7v7O]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 10109
                          local checkFileName = "PlayerListener.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[rI3]]---@type SBasePlayer
local GamePlayer = require "entity.GamePlayer"

local PlayerListener = {}
local INVINCIBLE_TIME = 3000 -- 3秒无敌时间(毫秒)
local playerRespawnTime = {} -- 记录玩家重生时间
local playerLastAttackType = {} -- 记录玩家最后一次被攻击的类型

function PlayerListener:init()
    BaseListener.registerCallBack(CEvents.PlayerLoginEvent, self.onPlayerLogin)
    BaseListener.registerCallBack(CEvents.PlayerMoveEvent, self.onPlayerMove)
    BaseListener.registerCallBack(CEvents.PlayerAttackedEvent, self.onPlayerAttacked)
    BaseListener.registerCallBack(CEvents.PlayerDieEvent, self.onPlayerDied)
    BaseListener.registerCallBack(CEvents.PlayerLogoutEvent, self.onPlayerLogOut)
    BaseListener.registerCallBack(CEvents.PlayerReadyEvent, self.onPlayerReady)
    CEvents.EntityDeathDropItemEvent:registerCallBack(self.onEntityDeathDropItemEvent)
    CEvents.PlayerRespawnEvent:registerCallBack(self.onPlayerRespawn)
    -- 注册玩家死亡提示事件的回调
    BaseListener.registerCallBack(CEvents.PlayerDieTipEvent, self.onPlayerDieTip)
    CEvents.InventoryStackChange:registerCallBack(self.onInventoryStackChange)
    CEvents.PlayerUseCommonItemEvent:registerCallBack(self.onPlayerUseCommonItem)
    BaseListener.registerCallBack(CEvents.SpawnEntityEvent, self.onSpawnEntity)
    BaseListener.registerCallBack(CEvents.RemoveEntityEvent, self.onRemoveEntity)
end

function PlayerListener.onPlayerLogin(clientPeer)
    if PlayerManager:isPlayerFull() then
        return GameOverCode.PlayerIsEnough
    end
    local player = GamePlayer.new(clientPeer)
    player:init()
    PacketSender:broadCastPidPacket({
        pid = "customGamePlayerLogIn",
        data = player.userId
    })
    return GameOverCode.Success, player, 1
end

function PlayerListener.onPlayerMove(movePlayer, x, y, z)
    local player = PlayerManager:getPlayerByPlayerMP(movePlayer)
    if player.isSleeping and player.bedInfo and player.bedInfo.pos then
        local pos = VectorUtil.newVector3(x, y, z)
        local sleepPos = player.bedInfo.pos
        if VectorUtil.distanceXZ(sleepPos, pos) > 0.5 then
            player.isSleeping = false
        end
        return false
    end
    return true
end

function PlayerListener.onPlayerAttacked(injuredPlayer, attackerPlayer, attackType, attackValue, attackCd)
    local injured = PlayerManager:getPlayerByPlayerMP(injuredPlayer)
    local attacker = PlayerManager:getPlayerByPlayerMP(attackerPlayer)
    if not injured then
        return false
    end

    if injured.isTakingPicture or (injured.isSelectTeam and injured.isSelectTeam > 0) then
        return false
    end
    
    -- 记录玩家最后一次被攻击的类型
    playerLastAttackType[injured.userId] = attackType

    -- 检查是否在无敌时间内
    local lastRespawnTime = playerRespawnTime[injured.userId]
    if lastRespawnTime then
        local currentTime = Root.Instance():getCurrentTime() -- 通过Root实例调用getCurrentTime
        if currentTime - lastRespawnTime < INVINCIBLE_TIME then
            attackValue.value = 0
            return false
        end
    end

    if attackType == "outOfWorld" then
        attackValue.value = 9999
        return true
    end
	
	 --掉落受伤特殊处理。受伤高度改为2（ 正常情况下 满速度最高能跳5格，经过处理到这里就是3格)
    if attackType == "fall" and attackValue.value < 6 then
        return false
    end

    --掉落受伤特殊处理。受伤高度改为2（ 正常情况下 满速度最高能跳5格，经过处理到这里就是3格)
    if attackType == "fall" and attackValue.value < 6 then
        return false
    end

    -- 检查是否是枪械攻击，且全局禁止枪械
    if attackType and string.find(attackType, "player.gun") then
        if not attacker or not attacker:getPermissionSetting(Define.CustomRoomSettingType.CAN_USE_GUN) then
            attackValue.value = 0
            return false
        end
    end

    if not injured:getPermissionSetting(Define.CustomRoomSettingType.FOOD) then 
        attackValue.value = 0
    end

    if not attacker then
        injured:cancelSleep(injured:getHealth() <= attackValue.value)
        return true
    end

    if attacker:getPermissionSetting(Define.CustomRoomSettingType.PVP) then
        injured:cancelSleep(injured:getHealth() <= attackValue.value)
        local customGame = T(Global, "customGame")
        if customGame:getGameMode() == Define.CustomGameMode.RUN then
            if GameState ~= Define.GameState.Playing then
                return false
            end
            if not attacker.teamId or not injured.teamId or (attacker.teamId ~= 0 and attacker.teamId == injured.teamId) then
                return false
            end
        end
        return true
    else
        return false
    end
end

function PlayerListener.onPlayerDied(diePlayer, _, killPlayer)
    local dier = PlayerManager:getPlayerByPlayerMP(diePlayer)
    if not dier then
        return false
    end

    local customGame = T(Global, "customGame")
    customGame:onPlayerDied(dier)
    
    local killer = PlayerManager:getPlayerByPlayerMP(killPlayer)
    if killer then 
        customGame:onPlayerKillOther(killer, dier)
    end

    customGame:onPlayerDiedEnd(dier, killer)
    return true
end

-- 处理玩家死亡提示事件
function PlayerListener.onPlayerDieTip(diePlayer, _, killPlayer)
    local dier = PlayerManager:getPlayerByPlayerMP(diePlayer)
    if not dier then
        return false
    end
    
    -- 检查是否是被枪械击杀
    local attackType = playerLastAttackType[dier.userId]
    if attackType and string.find(attackType, "player.gun") then
        -- 如果是被枪械击杀，不显示公屏提示
        return false
    end
    
    -- 其他死亡原因，正常显示公屏提示
    return true
end

function PlayerListener.onPlayerLogOut(player)
    -- 清理玩家重生时间记录和攻击类型记录
    playerRespawnTime[player.userId] = nil
    playerLastAttackType[player.userId] = nil

    PacketSender:broadCastPidPacket({
        pid = "customGamePlayerLogOut",
        data = player.userId
    })

    local customGame = T(Global, "customGame")
    customGame:onPlayerLogOut(player)
    local ownerId = customGame:getOwnerId()
    if player.userId ~= ownerId then
        return
    end
    local players = PlayerManager:getPlayers()
    for i, player in pairs(players) do
        if player.entityPlayerMP then
            HostApi.sendGameoverByPlatformUserId(player.userId, "game_room_error_code_400002", GameOverCode.GameOver) --多语言已有
        end
    end
end
function PlayerListener.onPlayerReady(player)
    local customGame = T(Global, "customGame")
    local players = PlayerManager:getPlayers()
    for i, _player in pairs(players) do
        if _player.userId ~= player.userId and _player.isSleeping and _player.bedInfo and _player.bedInfo.pos then
            player:sendPacket({
                pid = "setSleep",
                playerId = _player.userId
            })
        end
    end
    customGame:onPlayerReady(player)
end
function PlayerListener.onPlayerRespawn(respawnPlayer)
    local player = PlayerManager:getPlayerByUserId(respawnPlayer:getPlatformUserId())
    if not player then
        return false
    end

    player:rebirth(true)
    player:addCustomEffect("InvincibleEffect" .. tostring(player.userId), "g1014_wudi.effect", INVINCIBLE_TIME)

    -- 记录重生时间
    playerRespawnTime[player.userId] = Root.Instance():getCurrentTime() -- 通过Root实例调用getCurrentTime
    return true
end

function PlayerListener.onEntityDeathDropItemEvent(entityId, damageType)
    local player = PlayerManager:getPlayerByEntityId(entityId)
    if not player then
        return false
    end

    --如果禁止玩家掉落物品  返回false
    local customGame = T(Global, "customGame")
    local ret = customGame:canDeathDropItem(player)
    if not ret then
        player.inventory = InventoryUtil:getPlayerInventoryInfo(player, nil, 36)
        return false
    end
    return ret
end

function PlayerListener.onInventoryStackChange(rakssid, slot)
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if not player or not player.teamId or player.teamId == 0 then
        return
    end
    if not GameConfig then
        return
    end
    local customGame = T(Global, "customGame")
    customGame:updateCollectScore(player.teamId)
end

function PlayerListener.onPlayerUseCommonItem(rakssId, itemId)
    local player = PlayerManager:getPlayerByRakssid(rakssId)
    if player == nil then
        return
    end
    if itemId >= 467 and itemId <= 471 then
        local pos = player:getPosition()
        BridgeConfig:buildBridge(itemId, player:getYaw(), VectorUtil.toBlockVector3(pos.x, pos.y - 1, pos.z))
    end
end

function PlayerListener.onSpawnEntity(IEntity)
    if IEntity.type == EntityType.Item then
        local itemStack = IEntity.entity:getItemStack()
        if itemStack then
            local customGame = T(Global, "customGame")
            customGame:onDropSpawnEntity(IEntity)
        end
    end
end

function PlayerListener.onRemoveEntity(IEntity)
end

PlayerListener:init()

return PlayerListener--[[uiHC]]---