--[[G260pxjuM65J8Vtq20NHsXG0zaQUro]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 6677
                          local checkFileName = "CustomGamePVP.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[XoD4BExDhRfsMc52Hm9dUTv]]local CustomGamePVP = class("CustomGamePVP", require "game.CustomGame")

function CustomGamePVP:initDefaultPermission()

	self.V1RoomPermSetting = {
		[Define.CustomRoomSettingType.PVP] = true,
		[Define.CustomRoomSettingType.FLY] = false,
		[Define.CustomRoomSettingType.PLACE_BLOCK] = true,
		[Define.CustomRoomSettingType.BREAK_BLOCK] = true,
		[Define.CustomRoomSettingType.FOOD] = true,
		[Define.CustomRoomSettingType.FAST_BREAK_BLOCK] = false,
		[Define.CustomRoomSettingType.UNLIMIT_ITEM] = false
    }

    self.globalPermSetting = {
        [Define.CustomRoomSettingType.PVP] = true,
        [Define.CustomRoomSettingType.FLY] = false,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = true,
        [Define.CustomRoomSettingType.UNLIMIT_ITEM] = false,
        [Define.CustomRoomSettingType.DROP_ITEM_ON_DIE] = false,
        [Define.CustomRoomSettingType.CAN_USE_GUN] = true
    }

    self.defaultPermSettingForRole[Define.CustomGamePermissionRole.Owner] = {
        [Define.CustomRoomSettingType.PVP] = true,
        [Define.CustomRoomSettingType.FLY] = true,
        [Define.CustomRoomSettingType.PLACE_BLOCK] = true,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = true,
        [Define.CustomRoomSettingType.FOOD] = true,
        [Define.CustomRoomSettingType.FAST_BREAK_BLOCK] = false,
        [Define.CustomRoomSettingType.UNLIMIT_ITEM] = true,
		[Define.CustomRoomSettingType.SPECIAL_BLOCK] = true
    }

    self.defaultPermSettingForRole[Define.CustomGamePermissionRole.Admin] = {
        [Define.CustomRoomSettingType.PVP] = true,
        [Define.CustomRoomSettingType.FLY] = false,
        [Define.CustomRoomSettingType.PLACE_BLOCK] = true,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = true,
        [Define.CustomRoomSettingType.FOOD] = false,
        [Define.CustomRoomSettingType.FAST_BREAK_BLOCK] = false,
        [Define.CustomRoomSettingType.UNLIMIT_ITEM] = false,
		[Define.CustomRoomSettingType.SPECIAL_BLOCK] = false
    }


    self.defaultPermSettingForRole[Define.CustomGamePermissionRole.Member]  = {
        [Define.CustomRoomSettingType.PVP] = true,
        [Define.CustomRoomSettingType.FLY] = false,
        [Define.CustomRoomSettingType.PLACE_BLOCK] = true,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = true,
        [Define.CustomRoomSettingType.FOOD] = true,
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
        [Define.CustomRoomSettingType.PLACE_BLOCK] = true,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = true,
        [Define.CustomRoomSettingType.FOOD] = true,
        [Define.CustomRoomSettingType.FAST_BREAK_BLOCK] = false,
        [Define.CustomRoomSettingType.UNLIMIT_ITEM] = false,
		[Define.CustomRoomSettingType.SPECIAL_BLOCK] = false
    }
end


function CustomGamePVP:onPlayerLogin(player)
    player.killNum = 0
    player.dieNum = 0
end

function CustomGamePVP:onPlayerReady(player)
    self:sendRealRankData(player)
end

function CustomGamePVP:onPlayerDied(player)
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
    player.dieNum = player.dieNum + 1
    self:sendRealRankData(player)
end

function CustomGamePVP:onPlayerKillOther(player, dier)
	player.killNum = player.killNum + 1
    self:sendRealRankData(player)
end


function CustomGamePVP:sortPlayerByKillNum()
	local players = PlayerManager:copyPlayers()
	table.sort(players, function(a, b)
        local aKillNum = a.killNum or 0
        local bKillNum = b.killNum or 0
        if aKillNum ~= bKillNum then
            return aKillNum > bKillNum
        end
        local aDieNum = a.dieNum or 0
        local bDieNum = b.dieNum or 0
        if aDieNum ~= bDieNum then
            return aDieNum < bDieNum
        end

        return a.userId > b.userId
    end)
	return players
end

function CustomGamePVP:getGameMode()
    return Define.CustomGameMode.PVP
end


function CustomGamePVP:sendRealRankData(player)
	local players = self:sortPlayerByKillNum()
	local index = 0
	local data = {}
	data.ranks = {}
    local ownIndex = {}
	for i, v in pairs(players) do
		index = index + 1
		local item = {}
		item.column_1 = tostring(index)
		item.column_2 = v.name
		item.column_3 = tostring(v.killNum)
		item.column_4 = tostring(v.dieNum)
		data.ranks[index] = item

        ownIndex[v.userId] = index
	end

	for i, v in pairs(players) do 
		local own = {}
		own.column_1 = tostring(ownIndex[v.userId])
		own.column_2 = v.name
		own.column_3 = tostring(v.killNum)
		own.column_4 = tostring(v.dieNum)
		data.own = own
        data.ignoreShowUi = true
		HostApi.updateRealTimeRankInfo(v.rakssid, json.encode(data))
	end
end
return CustomGamePVP--[[i9jsK]]---