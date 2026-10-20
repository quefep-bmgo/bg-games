--[[iPy42gS5ExMLRhxB9X8i5VPDwuFmBzmqT7bjs5bGyR89zDenLtxwNo9X]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 23593
                          local checkFileName = "CustomGameUGC.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[OUP7QCHZzPY6WGkN9FgeQNgiJeZ7HpxEdxLl3xt4ExlGG9cI1tD7UlwjnFWgVgqoVFA]]local CustomGameUGC = class("CustomGameUGC", require "game.CustomGame")
local GameTeamMarker = require "data.GameTeamMarker"

function CustomGameUGC:initDefaultPermission()
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
        [Define.CustomRoomSettingType.PVP] = false,
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

function CustomGameUGC:initOldPermSetting()
    self.oldGlobalPermSetting = {
        [Define.CustomRoomSettingType.PVP] = false,
        [Define.CustomRoomSettingType.FLY] = true,
        [Define.CustomRoomSettingType.PLACE_BLOCK] = true,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = true,
        [Define.CustomRoomSettingType.FOOD] = false,
        [Define.CustomRoomSettingType.FAST_BREAK_BLOCK] = true,
        [Define.CustomRoomSettingType.UNLIMIT_ITEM] = true,
        [Define.CustomRoomSettingType.SPECIAL_BLOCK] = true
    }
end

function CustomGameUGC:getGlobalSettingForV1Setting()
    return  {
        [Define.CustomRoomSettingType.PVP] = false,
        [Define.CustomRoomSettingType.FLY] = true,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = true,
        [Define.CustomRoomSettingType.UNLIMIT_ITEM] = true,
        [Define.CustomRoomSettingType.DROP_ITEM_ON_DIE] = true,
        [Define.CustomRoomSettingType.CAN_USE_GUN] = true
    }
end

function CustomGameUGC:onPlayerLogin(player)
    if self.ugcExtraConfig.isEditable then
        self:_setSkyBox(player, false)
    end
end

-- 登出
function CustomGameUGC:onPlayerLogOut(player)
    self:checkExchangeOwner(player)
end

function CustomGameUGC:onPlayerReady(player)
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

function CustomGameUGC:getGameMode()
    return Define.CustomGameMode.EDIT
end

function CustomGameUGC:initGameSetting()
    self.teamMarkerRecord = {}

    self.configMgr = self.configMgr or require "base.config.UGCPVPConfigMgr"
    self.runConfig, self.configOption = self.configMgr:loadConfigForEditor(self.initPos)
    self:initTeamsPos(self.configOption.teamSetting)
    self:initTeamsMarker(self.configOption.winCondition)

    -- 在这里设置天空盒
    if self.ugcExtraConfig.isEditable then
        self:_setEditorSkyBox()
    end

    if self.timer then
        LuaTimer:cancel(self.timer)
        self.timer = nil
    end
    self.timer = LuaTimer:schedule(function()
        self._ticks = (self._ticks or 0) + 1
        Plugins.CallTargetPluginFunc("resources", "onTick", self._ticks)
    end, 1000, 1000)

    EngineWorld:stopWorldTime(12000)
end

function CustomGameUGC:loadPrefabConfig()
    self.configMgr = self.configMgr or require "base.config.UGCPVPConfigMgr"
    return self.configMgr:loadPrefabConfigForEditor()
end

function CustomGameUGC:getUGCExtraConfig()
    return self.ugcExtraConfig:getTableConfig()
end

function CustomGameUGC:getUGCSetting()
    if not self.configOption then
        self.configMgr = self.configMgr or require "base.config.UGCPVPConfigMgr"
        self.runConfig, self.configOption = self.configMgr:loadConfigForEditor(self.initPos)
    end
    -- print("get =============== " .. json.encode(self.configOption))
    return self.configOption
end

function CustomGameUGC:updateUGCSetting(data)
    local ret = {};

    local code, msg, args = self:_checkUGCTeamSetting(data.teamSetting)
    if code ~= 0 then
        ret.type = "teamSetting";
        ret.msg = msg;
        ret.code = code;
        ret.args = args;
        return ret;
    end

    local code, msg = self:_checkUGCWinCondition(data.winCondition)
    if code ~= 0 then
        ret.type = "winCondition";
        ret.msg = msg;
        ret.code = code;
        return ret;
    end

    local code, msg = self:_checkUGCGameSetting(data.gameSetting)
    if code ~= 0 then
        ret.type = "gameSetting";
        ret.msg = msg;
        ret.code = code;
        return ret;
    end

    local code, msg = self:_checkUGCOtherSetting(data.otherSetting)
    if code ~= 0 then
        ret.type = "otherSetting";
        ret.msg = msg;
        ret.code = code;
        return ret;
    end

    self.runConfig, self.configOption = self.configMgr:onCoverOpConfigAndRunConfig(data)
    self:initTeamsPos(self.configOption.teamSetting)
    self:initTeamsMarker(self.configOption.winCondition)

    ret.code = 1;
    ret.msg = 1;
    return ret;
end

-- 保存running json
function CustomGameUGC:saveUGCSetting(data)
    if not self.configMgr then
        return Define.RunningConfigErrorCode.OtherError1
    end
    
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
    
    if self.ugcExtraConfig.secondaryTag == "game" then
        self.configMgr:savePrafabConfig(configData)
        return self.configMgr:saveRunConfig()
    elseif self.ugcExtraConfig.secondaryTag == "map" then
        return self.configMgr:savePrafabConfig(configData)
    elseif self.ugcExtraConfig.secondaryTag == "building_prefab" then
        local aabb_min, aabb_max = CustomRoomUtil.getEditAreaBlockAABB(self.initPos, self.ugcExtraConfig:getBlockMap())
        configData.buildSize = self.ugcExtraConfig.buildSize
        configData.buildAABB = {
            min = aabb_min,
            max = aabb_max
        }
        return self.configMgr:savePrafabConfig(configData)
    else
        return self.configMgr:saveRunConfig()
    end
    return Define.RunningConfigErrorCode.OtherError1
end

-- 获取最大可进玩家数
function CustomGameUGC:getMaxPlayer()
    if self.configMgr then
        return self.configMgr:getMaxPlayer()
    end
    return 0;
end

function CustomGameUGC:takePictureStatus(userId, status)
    local player = PlayerManager:getPlayerByUserId(userId)
    if player then
        self:_setSkyBox(player, status)
    end
end

function CustomGameUGC:initTeamsPos(teamSetting)
    self.teamRecord = {}
    local teamCount = teamSetting.selectedTeamCount
    for i = 1, teamCount do
        table.insert(self.teamRecord, {
            teamId = i,
            position = teamSetting.teamStartingPositionList[i].position
        })
    end
    if self.teamEntity then
        for _, teamHash in pairs(self.teamEntity) do
            EngineWorld:removeEntity(teamHash)
        end
    end
    self.teamEntity = {}
    for _, team in pairs(self.teamRecord) do
        if team.position then
            self:onCreateTeamFlag(team.teamId, team.position)
        end
    end
end
function CustomGameUGC:onSelectTeamPos(teamId, pos)
    local isFind = false
    for _, team in pairs(self.teamRecord) do
        if team.teamId == teamId then
            isFind = true
            team.position = pos
            break
        end
    end
    if not isFind then
        table.insert(self.teamRecord, {
            teamId = teamId,
            position = pos
        })
    end
    self:onCreateTeamFlag(teamId, pos)
end
function CustomGameUGC:onCreateTeamFlag(teamId, pos)
    local toPlacePos = VectorUtil.add3(pos, VectorUtil.newVector3(0.5, 0, 0.5));
    local actor = Define.TeamFlagActor[teamId] or Define.TeamFlagActor[1]
    if self.teamEntity[teamId] then
        EngineWorld:removeEntity(self.teamEntity[teamId])
    end
    self.teamEntity[teamId] = EngineWorld:addActorNpc(toPlacePos, 0, actor, function(entity) entity:setFlying(true) end)
end

function CustomGameUGC:checkTeamMarker(player, vec3)
    local isMarker = false
    local canBreak = true
    local deleteTeamId = nil

    for teamId, marker in pairs(self.teamMarkerRecord) do
        if marker:IsEqual(vec3) then
            isMarker = true
            if player.isSelectTeam and player.isSelectTeam > 0 then
                marker:CreateMarkerBlockAndActor()
                canBreak = false
            else
                marker:DestroyMarkerBlockAndActor()
                deleteTeamId = teamId
            end
            break
        end
    end

    if deleteTeamId ~= nil then
        local markerList = self.configOption.winCondition.conditionList[Define.OverCondition.Marker].optInfo or {}
        for teamId, markerInfo in ipairs(markerList) do
            if deleteTeamId == teamId then
                local teamFlagChooseInfo = markerInfo.teamFlagChooseInfo
                teamFlagChooseInfo.itemId = 0
                teamFlagChooseInfo.meta = 0
                teamFlagChooseInfo.position = VectorUtil.ZERO
                markerInfo.redPoint = true
                break
            end
        end
        markerList = self.configOption.winCondition.conditionList[Define.OverCondition.MarkerAndKill].optInfo or {}
        for teamId, markerInfo in ipairs(markerList) do
            if deleteTeamId == teamId then
                local teamFlagChooseInfo = markerInfo.teamFlagChooseInfo
                teamFlagChooseInfo.itemId = 0
                teamFlagChooseInfo.meta = 0
                teamFlagChooseInfo.position = VectorUtil.ZERO
                markerInfo.redPoint = true
                break
            end
        end
    end

    return isMarker, canBreak
end
function CustomGameUGC:initTeamsMarker(winCondition)
    for teamId, marker in pairs(self.teamMarkerRecord) do
        marker:DestroyMarkerBlockAndActor(true)
    end
    self.teamMarkerRecord = {}

    if winCondition.selectedId == Define.OverCondition.Marker or winCondition.selectedId == Define.OverCondition.MarkerAndKill then
        local markerList = winCondition.conditionList[winCondition.selectedId].optInfo or {}
        for teamId, markerInfo in ipairs(markerList) do
            local teamFlagChooseInfo = markerInfo.teamFlagChooseInfo
            local marker = GameTeamMarker.new(teamId, self.configOption.teamSetting.selectedTeamCount ~= 0)
            marker.existence = true
            marker.isDestroyed = false
            marker.itemId = teamFlagChooseInfo.itemId
            marker.meta = teamFlagChooseInfo.meta
            marker.pos = VectorUtil.toVector3i(teamFlagChooseInfo.position)
            self.teamMarkerRecord[teamId] = marker
        end
    
        for teamId, marker in pairs(self.teamMarkerRecord) do
            marker:CreateMarkerBlockAndActor()
        end
    end
end
function CustomGameUGC:onSelectTeamMarker(player, teamId, itemId, meta, pos)
    local curMarker = self.teamMarkerRecord[teamId]
    if not curMarker then
        curMarker = GameTeamMarker.new(teamId, self.configOption.teamSetting.selectedTeamCount ~= 0)
        curMarker.existence = true
        curMarker.isDestroyed = false
        self.teamMarkerRecord[teamId] = curMarker
    else
        curMarker:DestroyMarkerBlockAndActor(true)
    end
    curMarker.itemId = itemId
    curMarker.meta = meta
    curMarker.pos = VectorUtil.toVector3i(pos)

    local ret = curMarker:CreateMarkerBlockAndActor(player)
    if not ret then
        self.teamMarkerRecord[teamId] = nil
    end
    return ret, curMarker.meta
end
function CustomGameUGC:thisBedIsGameMarker(bedPos1)
    for teamId, marker in pairs(self.teamMarkerRecord) do
        if marker:IsEqual(bedPos1) then
            return true
        end
    end
    return false
end

function CustomGameUGC:checkOutsideTheEditingArea(pos)
    return self.ugcExtraConfig:checkOutsideTheEditingArea(pos)
end
function CustomGameUGC:checkEditingAreaOverflowMaxCount()
    return self.ugcExtraConfig:checkEditingAreaOverflowMaxCount()
end
function CustomGameUGC:editingAreaBlockChange(pos, blockID, metadata)
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

function CustomGameUGC:_syncEditingAreaBlockNum()
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


function CustomGameUGC:_checkUGCTeamSetting(new_setting)
    local errorMap = {
        [1] = {code = 2, msg = 2},
        [2] = {code = 2, msg = 3},
        [3] = {code = 2, msg = 4},
        [4] = {code = 2, msg = 5},
    }
    local has = false
    for i = 1, #new_setting.teamCountOptionList do
        if new_setting.teamCountOptionList[i] == new_setting.selectedTeamCount then
            has = true
            break
        end
    end
    if not has then
        local eMap = errorMap[1]
        return eMap.code, eMap.msg
    end
    if new_setting.selectedTeamSize == 0 or new_setting.selectedTeamSize > 24 then
        local eMap = errorMap[2]
        return eMap.code, eMap.msg
    end
    local teamCount = new_setting.selectedTeamCount
    local teamSize = new_setting.selectedTeamSize
    local allCount = teamCount * teamSize
    if teamCount == 0 then
        allCount = teamSize
    end
    if allCount > 24 then
        local eMap = errorMap[3]
        return eMap.code, eMap.msg
    end
    for i = 1, teamCount do
        local pos = new_setting.teamStartingPositionList[i].position
        local blockId = EngineWorld:getBlockId(pos)
        if blockId ~= 0 then
            local eMap = errorMap[4]
            return eMap.code, eMap.msg, i
        end
    end
    if new_setting.randomSpawn == nil then
        new_setting.randomSpawn = {toggle = true}
    end
    if new_setting.equipAndItem == nil then
        new_setting.equipAndItem = {toggle = false}
    end
    return 0, 1
end
function CustomGameUGC:_checkUGCWinCondition(new_setting)
    local errorMap = {
        [Define.OverCondition.CollectNum] = {
            ["picture"] = {code = 3, msg = 6},
            ["progress"] = {code = 3, msg = 7},
        },
        [Define.OverCondition.KillNum] = {
            ["progress"] = {code = 3, msg = 8},
        },
        [Define.OverCondition.Survival] = {},
        [Define.OverCondition.Collect] = {
            ["picture"] = {code = 3, msg = 6},
        },
        [Define.OverCondition.Kill] = {},
        [Define.OverCondition.Marker] = {
            ["teamFlagChoose"] = {code = 3, msg = 6},
        },
        [Define.OverCondition.MarkerAndKill] = {
            ["teamFlagChoose"] = {code = 3, msg = 6},
        },
    }
    local selectedId = new_setting.selectedId
    if selectedId < 1 and selectedId > #new_setting.conditionList then
        return 4, 4
    end
    local condition = new_setting.conditionList[selectedId]
    local eMapType = errorMap[selectedId]
    
    for _, optInfo in ipairs(condition.optInfo) do
        if optInfo.itemInfo then
            local itemInfo = optInfo.itemInfo
            for _, item in ipairs(itemInfo) do
                local id, _ = self.configMgr:getItemUrl(item.itemId, item.meta)
                if id == 0 then
                    local eMap = eMapType["picture"]
                    return eMap.code, eMap.msg
                end
                -- item.itemId = itemCfg.itemId
                -- item.meta = itemCfg.meta
                -- item.fileName = itemCfg.fileName
            end
        elseif optInfo.progressInfo then
            local progressInfo = optInfo.progressInfo
            if progressInfo.values and progressInfo.values[1] and progressInfo.values[2] then
                local min = progressInfo.values[1]
                local max = progressInfo.values[2]
                local defValue = progressInfo.defValue
                if defValue < min or defValue > max then
                    local eMap = eMapType["progress"]
                    return eMap.code, eMap.msg
                end
            end
        elseif optInfo.teamFlagChooseInfo then
            -- local teamFlagChooseInfo = optInfo.teamFlagChooseInfo
            -- local id, _ = self.configMgr:getItemUrl(teamFlagChooseInfo.itemId, teamFlagChooseInfo.meta)
            -- if id == 0 then
            --     local eMap = eMapType["teamFlagChoose"]
            --     return eMap.code, eMap.msg
            -- end
            -- teamFlagChooseInfo.itemId = itemCfg.itemId
            -- teamFlagChooseInfo.meta = itemCfg.meta
        end
    end
    -- print("check =============== 2 " .. json.encode(condition.optInfo))
    return 0, 1
end
function CustomGameUGC:_checkUGCGameSetting(new_setting)
    local errorMap = {
        [1] = {code = 4, msg = 9},
        [2] = {code = 4, msg = 10},
        [3] = {code = 4, msg = 11},
        [4] = {code = 4, msg = 1},
        [5] = {code = 4, msg = 12},
    }
    for index, setting in ipairs(new_setting) do
        if setting.progressInfo then
            local progressInfo = setting.progressInfo
            if progressInfo.values and progressInfo.values[1] and progressInfo.values[2] then
                local min = progressInfo.values[1]
                local max = progressInfo.values[2]
                local defValue = progressInfo.defValue
                if defValue < min or defValue > max then
                    local eMap = errorMap[index]
                    return eMap.code, eMap.msg
                end
            end
        end
    end
    return 0, 1
end
function CustomGameUGC:_checkUGCOtherSetting(new_setting)
    return 0, 1
end

function CustomGameUGC:_setSkyBox(player, status)
    local sky = nil
    if status then
        sky = Global.setting.SkyBoxConfig.nor_sky
    else
        sky = Global.setting.SkyBoxConfig.edit_sky
    end
    HostApi.setCustomSceneSwitch(player.rakssid, sky.skyType, sky.cloudType, sky.showSunAndMoon, sky.showMeteor, sky.showStarEffect)
end

function CustomGameUGC:_setEditorSkyBox()
    local sky = Global.setting.SkyBoxConfig.edit_sky

    local skyInfo = SkyInfo.new()
    skyInfo.skyboxId = sky.skyboxId;
    skyInfo.skyboxName = sky.skyboxName;
    skyInfo.startFadeOut = sky.startFadeOut;
    skyInfo.endFadeOut = sky.endFadeOut;
    skyInfo.rotateAxisY = sky.rotateAxisY;
    HostApi.addSkyInfo(skyInfo)

    HostApi.setSceneSwitch(sky.skyType, sky.cloudType, sky.showSunAndMoon, sky.showMeteor, sky.showStarEffect)
end

return CustomGameUGC
--[[Ab3trRzGWEYMRSXgZy]]---