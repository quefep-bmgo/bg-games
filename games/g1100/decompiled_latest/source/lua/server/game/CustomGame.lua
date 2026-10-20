local CustomGame = class("CustomGame")
local UGCExtraConfig = require "base.config.UGCExtraConfig"

local RangeDistance = 1000


function CustomGame:initOldPermSetting()
    self.oldGlobalPermSetting = {
        [Define.CustomRoomSettingType.PVP] = true,
        [Define.CustomRoomSettingType.FLY] = true,
        [Define.CustomRoomSettingType.PLACE_BLOCK] = true,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = true,
        [Define.CustomRoomSettingType.FOOD] = true,
        [Define.CustomRoomSettingType.FAST_BREAK_BLOCK] = true,
        [Define.CustomRoomSettingType.UNLIMIT_ITEM] = true,
        [Define.CustomRoomSettingType.SPECIAL_BLOCK] = true
    }
end

function CustomGame:getGlobalSettingForV1Setting()
    return  {
        [Define.CustomRoomSettingType.PVP] = true,
        [Define.CustomRoomSettingType.FLY] = true,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = true,
        [Define.CustomRoomSettingType.UNLIMIT_ITEM] = true,
        [Define.CustomRoomSettingType.DROP_ITEM_ON_DIE] = false,
        [Define.CustomRoomSettingType.CAN_USE_GUN] = true
    }
end

function CustomGame:init(ownerId, roomId, mapConfig, extraJsonStr)
    isGameStart = true
    isGameEnd = false

    BaseMain:setGameType("g1100")
    DBManager:setGameType("g1100")
    PlayerManager:setMaxPlayer(100)

    self.isCreative = false
    self.roomId = roomId
    self.isOldPermMgrGame = false -- 是否旧版权限管理。通过LoadDefaultPermissionSettingFromServer来最终确定
    self.globalPermSetting={} -- 全局设置 优先判断
    self.defaultPermRole = Define.CustomGamePermissionRole.Member -- 当前默认玩家角色。玩家进入游戏后根据该参数选择默认权限
    self.defaultPermSettingForRole={} -- 各个角色的默认权限
    self:initOldPermSetting()
    self:LoadDefaultPermissionSettingFromServer()
    self:initDefaultPermission()
    self.ownerId = ownerId
    self.initPos = {}
    self.MapRange = {}
    self.initPos = VectorUtil.newVector3(mapConfig.InitPos.x, mapConfig.InitPos.y, mapConfig.InitPos.z)
    GameServer:setInitPos(self.initPos)

    HostApi.setNeedFoodStats(false)
    HostApi.setGunFireIsNeedBullet(false)

    -- print("custom game init "..StringUtil.v2s(mapConfig))
    self.MapRange.maxX = self.initPos.x + RangeDistance
    self.MapRange.minX = self.initPos.x - RangeDistance
    
    self.MapRange.maxZ = self.initPos.z + RangeDistance
    self.MapRange.minZ = self.initPos.z - RangeDistance
    CEvents.UploadMapOverEvent:registerCallBack(function (code, innerCode, exitGame)
        self:onUploadMapOver(code, innerCode, exitGame)
    end)

    self:initGameExtra(extraJsonStr)
    self:initGameSetting()
end

function CustomGame:initGameSetting()
end

function CustomGame:initGameExtra(extraJsonStr)
    self.ugcExtraConfig = UGCExtraConfig.new(self.initPos, extraJsonStr)
    self.ugcExtraConfig:loadPrefabConfig(self:loadPrefabConfig())
    self.ugcExtraConfig:updateEditArea()
    self.ugcExtraConfig:createPrefab()
end

function CustomGame:loadPrefabConfig()
    return nil
end

function CustomGame:onCustomRoomSaveMap(data)
    self:saveUGCSetting(data)

    local result = CustomMapManager.Instance():tryUploadMap1(json.encode(data))
    if result ~= 0 then
        self:onUploadMapOver(result, 100, false)
    else
        self:waitUploadMapOver(data.exitGame)
    end
end

function CustomGame:onUploadMapOver(code, innerCode, exitGame)
    if self.uploadMapTimer then
        LuaTimer:cancel(self.uploadMapTimer)
        self.uploadMapTimer = nil
    end

    local player = PlayerManager:getPlayerByUserId(self.ownerId)
    if player then
        player:sendPacket({
            pid = "customRoomSaveMapResult",
            data = {
                result = code,
                innerCode = innerCode
            }
        })
    end

    ---为了提示能正常发出，等3S之后 再关闭游戏
    ---
    if exitGame then
        LuaTimer:scheduleTimer(
            function()
                    local players = PlayerManager:getPlayers()
                    for i, player in pairs(players) do
                        if player.entityPlayerMP then
                            HostApi.sendGameoverByPlatformUserId(player.userId, "notify.server.close.by.host", GameOverCode.GameOver)
                        end
                    end
            end, 3000, 1)
    end
end

function CustomGame:waitUploadMapOver(exitGame)
    --10S之后如果还没有上传完成，则认为上传失败
    self.uploadMapTimer = LuaTimer:scheduleTimer(
        function()
            self:onUploadMapOver(3, 0, exitGame)
        end, 10000, 1)
end

function CustomGame:setNewOwner(owner)
    self.ownerId = owner
end

function CustomGame:getGlobalPermSetting(force)
    --if not self.isOldPermMgrGame or force then 
        return self.globalPermSetting
    --else
    --    return {}
   -- end
end

function CustomGame:getUGCRunningSetting()
    return nil;
end

function CustomGame:getUGCExtraConfig()
    return nil;
end

function CustomGame:getAllDefaultPermSetting()
    local allDefaultPerms = {}
    for i, v in pairs(self.defaultPermSettingForRole) do
        local permList = {}
        permList.permissionType = i
        permList.settingList = {}
        for pi, pv in pairs(v) do
            local perm = {}
            perm.id = pi
            perm.switch = pv
            table.insert(permList.settingList, perm)
        end
        table.insert(allDefaultPerms, permList)
    end
    return allDefaultPerms
end


function CustomGame:getAllPlayerPermSettingForApp()
    local allPlayerPerm = {}
    local players = PlayerManager:copyPlayers()
    for i, v in pairs(players) do
        local playerPerm = {}
        playerPerm.userId = v.userId
        playerPerm.permissionType = v.permissionRole or self.defaultPermRole
        playerPerm.settingList = {}
        
        local settings = v.permissionSetting or self.defaultPermSettingForRole[playerPerm.permissionType]
        if settings then
            --print("get permissionSetting "..tostring(v.userId)..StringUtil.v2s(settings))
            for pt, enabled in pairs(settings) do
                local setting = {}
                setting.id = pt
                setting.displayTitle = "room_setting_" .. pt
                setting.switch = enabled
                table.insert(playerPerm.settingList, setting)
            end
        end
        table.insert(allPlayerPerm, playerPerm)
    end
    return allPlayerPerm;
end

function CustomGame:netRoleNameToRoleType(name)
    local roleTypeMap = {
        ["owner"] = Define.CustomGamePermissionRole.Owner,
        ["admin"] = Define.CustomGamePermissionRole.Admin, 
        ["member"] = Define.CustomGamePermissionRole.Member,
        ["visitor"] = Define.CustomGamePermissionRole.Guest,
        ["custom"] = Define.CustomGamePermissionRole.UDefine
    }
    return roleTypeMap[name]
end

function CustomGame:getDefaultPermissionRole()
    return self.defaultPermRole
end

function CustomGame:getDefaultPermByRole(role)
    if not role then 
        role = Define.CustomGamePermissionRole.member
    end

    if self.isOldPermMgrGame then
        return self.oldGlobalPermSetting
    end

    --print("getDefaultPermByRole "..role..StringUtil.v2s(self.defaultPermSettingForRole, 10))
    return TableUtil.copyTable(self.defaultPermSettingForRole[role])
end

function CustomGame:netPermNameToPermType(name)
    local permTypeMap = {
        ["set_permission"] = Define.CustomRoomSettingType.SET_PERMISSION,
        ["place_block"] = Define.CustomRoomSettingType.PLACE_BLOCK,
        ["break_block"] = Define.CustomRoomSettingType.BREAK_BLOCK,
        ["fast_break_block"] = Define.CustomRoomSettingType.FAST_BREAK_BLOCK,
        ["pvp"] = Define.CustomRoomSettingType.PVP,
        ["fly"] = Define.CustomRoomSettingType.FLY,
        ["unlimit_item"] = Define.CustomRoomSettingType.UNLIMIT_ITEM,
        ["food"] = Define.CustomRoomSettingType.FOOD,
        ["special_block"] = Define.CustomRoomSettingType.SPECIAL_BLOCK
    }
    return permTypeMap[name]
end

function CustomGame:updateDeaultPermForRoleFromNet(roleName, permsNames)
    for _, v in pairs(permsNames) do
        local permType = self:netPermNameToPermType(v.perm)
        if permType then 
            self.defaultPermSettingForRole[self:netRoleNameToRoleType(roleName)][permType] = v.toggle
        end
    end
end

function CustomGame:LoadDefaultPermissionSettingFromServer()
    local getDefaultPermissionUrl = WebService.ServerHttpHost.."/game/api/v1/inner/gameroom/permissions"
    local this = self
    --self.roomId = "29394874362953738"
    local params = {
        { "roomId", tostring(self.roomId)},-- roomId 就是string
    }
    WebService.asyncGet(getDefaultPermissionUrl, params, function(data, code)
        if data then
            print("getDefaultPermissionUrl "..StringUtil.v2s(data, 10))
            this:setDefaultPermRole(this:netRoleNameToRoleType(data.defaultRole))
            if data.roles then
                for _, role in ipairs(data.roles) do
                    this:updateDeaultPermForRoleFromNet(role.role, role.perms)
                end
            end
            print("custom game default perm "..StringUtil.v2s(this.defaultPermSettingForRole, 10))
        else
            this:initOldPermConfig()
        end
    end)
end

function CustomGame:initOldPermConfig()
    print("init old perm mgr")
    self.isOldPermMgrGame = true
    self.globalPermSetting = self:getGlobalSettingForV1Setting()
    self.defaultPermRole = Define.CustomGamePermissionRole.Member
end

function CustomGame:setDefaultPermRole(role)
    self.defaultPermRole = role
end

function CustomGame:getInitPos()
    return self.initPos
end

function CustomGame:getOwnerId()
    return self.ownerId or self.super.ownerId
end

--V1版本用同步房间权限设置
function CustomGame:updateCustomRoomPermSetting(setting)
    PacketSender:broadCastPidPacket({
        pid = "updateCustomRoomPermSetting",
        data = setting
    })
end


function CustomGame:updateGlobalPermSetting(userName, perms)
    for _, v in pairs(perms) do
        if self.globalPermSetting[v.id] ~= nil then 
            self.globalPermSetting[v.id] = not v.switch
            if v.id == Define.CustomRoomSettingType.FLY then
                local players = PlayerManager:getAllPlayer()
                for _, player in pairs(players) do
                    player:globalChangeFlyPermStatus(self.globalPermSetting[v.id])
                end
            end
        end
    end

    PacketSender:broadCastPidPacket({
        pid = "updateCustomRoomGlobalPermSetting",
        data = {
            setting = self.globalPermSetting,
            userName = userName
        }
    })
end

function CustomGame:onPlayerLogin(player)

end

function CustomGame:onPlayerLoginAfter1Sec(player)

end

function CustomGame:onPlayerReady(player)

end

function CustomGame:onPlayerLogOut(player)

end

function CustomGame:getGameMode()

end

function CustomGame:onChestOpen(vec3, inv, rakssid)

end

function CustomGame:onDropSpawnEntity(IEntity)
end

---@param player GamePlayer
function CustomGame:onPlayerDied(player)
    RespawnHelper.addRespawnCountdown(player, 0)
    player.respawnOnBed = false
    if player.bedInfo and player.bedInfo.pos then
        local blockId1 = EngineWorld:getBlockId(player.bedInfo.bedPos[1])
        local blockId2 = EngineWorld:getBlockId(player.bedInfo.bedPos[2])
        if blockId1 ~= BlockID.BED or blockId2 ~= BlockID.BED then
            player:setRespawnPos(self.initPos)
            return
        end
        player.respawnOnBed = true
    end
end

function CustomGame:onPlayerDiedEnd(dier, killer)

end

function CustomGame:onPlayerKillOther(player, dier)

end

function CustomGame:onPlayerRebirth(player)

end

function CustomGame:startMatch()

end

function CustomGame:endMatch()

end

function CustomGame:checkOwner(userId)
    local ownerId = self:getOwnerId()
    if userId ~= ownerId then
        return false
    end
    return true
end

function CustomGame:checkTeamMarker(player, vec3)
    -- isMarker, canBreak
    return false, true
end

function CustomGame:canBreakBlock(vec3)
    return true
end

function CustomGame:canPlaceBlock(vec3)
    return true
end

function CustomGame:canDeathDropItem(player)
    return player:getPermissionSetting(Define.CustomRoomSettingType.DROP_ITEM_ON_DIE)
end

function CustomGame:onTick(ticks)

end

function CustomGame:checkOutsideTheEditingArea(pos)
    return false
end
function CustomGame:checkEditingAreaOverflowMaxCount()
    return false
end
function CustomGame:editingAreaBlockChange(pos, blockID, metadata)
end

function CustomGame:onSelectTeamPos(teamId, pos)
end

function CustomGame:onSelectTeamMarker(player, teamId, itemId, meta, pos)
    return false, meta
end

function CustomGame:saveUGCSetting(data)
end

function CustomGame:getMaxPlayer()
    return 0
end

function CustomGame:getMaxPlayer()
    return 100
end

function CustomGame:thisBedIsGameMarker(bedPos1)
    return false
end

function CustomGame:takePictureStatus(userId, status)

end

function CustomGame:getAllowJoinAfterStart()
    return false
end

-- 切换房主
function CustomGame:checkExchangeOwner(player)
    local userId = player.userId
    if not self:checkOwner(userId) then
        return
    end
    
    local list = {}
    local players = PlayerManager:getPlayers()
    for _, player in pairs(players) do
        if player.userId ~= userId and not player.isOldPermMgrPlayer then
            table.insert(list, {userId = player.userId, inGameTime = player.inGameTime})
        end
    end
    if #list == 0 then
        return
    elseif #list > 1 then
        table.sort(list, function(a, b) return a.inGameTime > b.inGameTime end)
    end
    
    local newOwnerPlayer = PlayerManager:getPlayerByUserId(list[1].userId)
    self:exchangeOwner(player, newOwnerPlayer)
end
    
function CustomGame:exchangeOwner(oldOwnerPlayer, newOwnerPlayer)
    local ret = 1
    local returnMsg = ""

    local newOwnerUserId = 0
    local oldOwnerUserId = 0
    if newOwnerPlayer then
        newOwnerUserId = newOwnerPlayer.userId
    end
    if oldOwnerPlayer then
        oldOwnerUserId = oldOwnerPlayer.userId
    end

    if not oldOwnerPlayer or not newOwnerPlayer or not self:checkOwner(oldOwnerUserId) then
        ret = 0
        returnMsg = "player.is.not.exist"
    elseif newOwnerPlayer.isOldPermMgrPlayer then
        ret = 0
        returnMsg = "customGame.notify.low.version"
    else
        self:setNewOwner(newOwnerUserId)
        newOwnerPlayer.permissionRole = Define.CustomGamePermissionRole.Owner
        newOwnerPlayer.permissionSetting = self:getDefaultPermByRole(Define.CustomGamePermissionRole.Owner)
        newOwnerPlayer.entityPlayerMP:setBoolProperty("DisableChat", false)
        oldOwnerPlayer.permissionRole = Define.CustomGamePermissionRole.Admin
        oldOwnerPlayer.permissionSetting = self:getDefaultPermByRole(Define.CustomGamePermissionRole.Admin)
        Server.Instance():exchangeCustomGameOwner(newOwnerUserId)
        PacketSender:broadCastPidPacket({
            pid = "notifyExchangeOwner",
            data = {
                old = oldOwnerPlayer.name,
                new = newOwnerPlayer.name
            }
        })
        oldOwnerPlayer:sendPacket({
            pid = "syncPermissionRole",
            role = oldOwnerPlayer.permissionRole
        })
        newOwnerPlayer:sendPacket({
            pid = "syncPermissionRole",
            role = newOwnerPlayer.permissionRole
        })
    end

    if oldOwnerPlayer then
        oldOwnerPlayer:sendPacket({
            pid = "exchangeOwnerResult",
            data ={
                ret = ret,
                oldOwner = oldOwnerUserId,
                newOwner = newOwnerUserId
            },
            msg = returnMsg
        })
    end

    if ret == 1 then
        newOwnerPlayer:sendPacket({
            pid = "exchangeOwnerResult",
            data ={
                ret = ret,
                oldOwner = oldOwnerUserId,
                newOwner = newOwnerUserId
            },
            msg = returnMsg
        })
    end
end

function CustomGame:findPreviousFollower(player)
end

function CustomGame:findLatterFollower(player)
end

return CustomGame