--[[qaDj3pq8CPJE45KdUJLXj6gDgjolV1QmKqLAsbBuuk0i9DetLqNE6hYZXgUnT]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 8595
                          local checkFileName = "CustomGameCreative.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[Jus93iokkfK4M1y782tNS26hcEoZSBXGlcLeSV3lbeO0R8i5WkJL9cJtow6p0y1iBGwdUdA0eWUQw2iy5JHUqsVnApz5cl6slkZPOJuqJCbrLkfRrxi91huLwoOCu4aCfEOMOPgruU0GzLQSMUUYebj64maDOnWq03BOAF0a1y664wDC2EkfOsQe08AtN5ib4OzrRwJxbqkHUEjdjbbX34ltM4ZG1hhC3I77cc7LcFrlUBRVli7SFKlftektrmZNLMKuHyYRcryMEn1bhUZFwMjVgOn6QwLt0vGrMvJ]]local CustomGameCreative = class("CustomGameCreative", require "game.CustomGame")

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

return CustomGameCreative--[[iCoFiCA9i]]---