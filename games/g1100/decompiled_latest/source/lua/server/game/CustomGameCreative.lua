local CustomGameCreative = class("CustomGameCreative", require "game.CustomGame")

function CustomGameCreative:initDefaultPermission()
    self.V1RoomPermSetting = {
        [Define.CustomRoomSettingType.PVP] = false,
        [Define.CustomRoomSettingType.FLY] = true,
        [Define.CustomRoomSettingType.PLACE_BLOCK] = true,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = true,
        [Define.CustomRoomSettingType.FOOD] = false,
        [Define.CustomRoomSettingType.FAST_BREAK_BLOCK] = true,
        [Define.CustomRoomSettingType.UNLIMIT_ITEM] = true
    }

    self.globalPermSetting = {
        [Define.CustomRoomSettingType.PVP] = false,
        [Define.CustomRoomSettingType.FLY] = true,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = true,
        [Define.CustomRoomSettingType.UNLIMIT_ITEM] = true,
        [Define.CustomRoomSettingType.DROP_ITEM_ON_DIE] = false,
        [Define.CustomRoomSettingType.CAN_USE_GUN] = true
    }

    self.defaultPermSettingForRole[Define.CustomGamePermissionRole.Owner] = {
        [Define.CustomRoomSettingType.PVP] = true,
        [Define.CustomRoomSettingType.FLY] = true,
        [Define.CustomRoomSettingType.PLACE_BLOCK] = true,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = true,
        [Define.CustomRoomSettingType.FOOD] = false,
        [Define.CustomRoomSettingType.FAST_BREAK_BLOCK] = true,
        [Define.CustomRoomSettingType.UNLIMIT_ITEM] = true,
        [Define.CustomRoomSettingType.SPECIAL_BLOCK] = true
    }

    self.defaultPermSettingForRole[Define.CustomGamePermissionRole.Admin] = {
        [Define.CustomRoomSettingType.PVP] = false,
        [Define.CustomRoomSettingType.FLY] = true,
        [Define.CustomRoomSettingType.PLACE_BLOCK] = true,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = true,
        [Define.CustomRoomSettingType.FOOD] = false,
        [Define.CustomRoomSettingType.FAST_BREAK_BLOCK] = true,
        [Define.CustomRoomSettingType.UNLIMIT_ITEM] = true,
        [Define.CustomRoomSettingType.SPECIAL_BLOCK] = true
    }


    self.defaultPermSettingForRole[Define.CustomGamePermissionRole.Member]= {
        [Define.CustomRoomSettingType.PVP] = false,
        [Define.CustomRoomSettingType.FLY] = true,
        [Define.CustomRoomSettingType.PLACE_BLOCK] = true,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = true,
        [Define.CustomRoomSettingType.FOOD] = false,
        [Define.CustomRoomSettingType.FAST_BREAK_BLOCK] = true,
        [Define.CustomRoomSettingType.UNLIMIT_ITEM] = true,
        [Define.CustomRoomSettingType.SPECIAL_BLOCK] = false
    }

    self.defaultPermSettingForRole[Define.CustomGamePermissionRole.Guest]  = {
        [Define.CustomRoomSettingType.PVP] = false,
        [Define.CustomRoomSettingType.FLY] = false,
        [Define.CustomRoomSettingType.PLACE_BLOCK] = false,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = false,
        [Define.CustomRoomSettingType.FOOD] = false,
        [Define.CustomRoomSettingType.FAST_BREAK_BLOCK] = false,
        [Define.CustomRoomSettingType.UNLIMIT_ITEM] = false,
        [Define.CustomRoomSettingType.SPECIAL_BLOCK] = false
    }

    self.defaultPermSettingForRole[Define.CustomGamePermissionRole.UDefine]= {
        [Define.CustomRoomSettingType.PVP] = false,
        [Define.CustomRoomSettingType.FLY] = true,
        [Define.CustomRoomSettingType.PLACE_BLOCK] = true,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = true,
        [Define.CustomRoomSettingType.FOOD] = false,
        [Define.CustomRoomSettingType.FAST_BREAK_BLOCK] = true,
        [Define.CustomRoomSettingType.UNLIMIT_ITEM] = true,
        [Define.CustomRoomSettingType.SPECIAL_BLOCK] = false
    }
end

function CustomGameCreative:onPlayerReady(player)
    if not self.ugcExtraConfig.isEditable then
        player:getEntityPlayer():setWatchMode(true)
        player:clearInv()
    else
        local disableMap = {}
        for _, block in pairs(self.ugcExtraConfig.disabledBlocks) do
            disableMap[block] = true
        end
        local initItem = {1, 2, 3, 4, 5, 7, 12, 13, 14, 15}
        for _, v in pairs(initItem) do
            if not disableMap[tostring(v).."#0"] then
                player:addItem(v, 64)
            end
        end
    end
end

function CustomGameCreative:getGameMode()
    return Define.CustomGameMode.CREATIVE
end

function CustomGameCreative:loadPrefabConfig()
    self.configMgr = self.configMgr or require "base.config.UGCPVPConfigMgr"
    return self.configMgr:loadPrefabConfigForEditor()
end

function CustomGameCreative:getUGCExtraConfig()
    return self.ugcExtraConfig:getTableConfig()
end

function CustomGameCreative:saveUGCSetting(data)
    if self.ugcExtraConfig.secondaryTag == "map" or self.ugcExtraConfig.secondaryTag == "building_prefab" then
        self.configMgr = self.configMgr or require "base.config.UGCPVPConfigMgr"
        
        local firstEditUserId = self.ugcExtraConfig.firstEditUserId
        if not firstEditUserId then
            firstEditUserId = data.userId
        end
        local lastEditUserId = data.userId
        local mapName = self.ugcExtraConfig.fileName or ""
        if mapName == "" then
            mapName = "building_" .. tostring(os.time()) .. ".csv"
        end
        local configData = {
            firstEditUserId = firstEditUserId,
            lastEditUserId = lastEditUserId,
            fileName = mapName,
            primaryTag = self.ugcExtraConfig.primaryTag,
            secondaryTag = self.ugcExtraConfig.secondaryTag,
            initPos = CustomRoomUtil.toBoxOrigin(self.initPos),
            saveBlockCsv = self.ugcExtraConfig:needSaveBlockCsv(),
            blockMap = self.ugcExtraConfig:getBlockMap()
        }

        if self.ugcExtraConfig.secondaryTag == "map" then
            self.configMgr:savePrafabConfig(configData)
        elseif self.ugcExtraConfig.secondaryTag == "building_prefab" then
            local aabb_min, aabb_max = CustomRoomUtil.getEditAreaBlockAABB(self.initPos, self.ugcExtraConfig:getBlockMap())
            configData.buildSize = self.ugcExtraConfig.buildSize
            configData.buildAABB = {
                min = aabb_min,
                max = aabb_max
            }
            self.configMgr:savePrafabConfig(configData)
        end
    end
end

function CustomGameCreative:checkOutsideTheEditingArea(pos)
    return self.ugcExtraConfig:checkOutsideTheEditingArea(pos)
end
function CustomGameCreative:checkEditingAreaOverflowMaxCount()
    return self.ugcExtraConfig:checkEditingAreaOverflowMaxCount()
end
function CustomGameCreative:editingAreaBlockChange(pos, blockID, metadata)
    if not self.ugcExtraConfig:needSaveBlockCsv() then
        return
    end

    if blockID == 0 then
        if self.ugcExtraConfig:editingAreaBlockBreak(pos) then
            self:_syncEditingAreaBlockNum()
        end
    else
        if self.ugcExtraConfig:editingAreaBlockPlace(pos, blockID, metadata) then
            self:_syncEditingAreaBlockNum()
        end
    end
end

function CustomGameCreative:_syncEditingAreaBlockNum()
    self.timerKey = self.timerKey or 0
    if self.timerKey ~= 0 then
        LuaTimer:cancel(self.timerKey)
        self.timerKey = 0
    end

    self.timerKey = LuaTimer:scheduleTimer(function()
        PacketSender:broadCastPidPacket({
            pid = "syncCustomRoomEditAreaBlockNum",
            blockNum = self.ugcExtraConfig.blockNum
        })
        self.timerKey = 0
    end, 100, 1)
end

return CustomGameCreative