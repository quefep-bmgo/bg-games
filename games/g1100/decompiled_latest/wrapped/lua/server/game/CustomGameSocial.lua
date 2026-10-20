--[[CbUv8sdYoOFdlRYN4XDSgZuZs0HL6t]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 4732
                          local checkFileName = "CustomGameSocial.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[XoVJjUOljkW9bzrmgnWWJYHK73]]local CustomGameSocial = class("CustomGameSocial", require "game.CustomGame")

function CustomGameSocial:initDefaultPermission()

    self.V1RoomPermSetting = {
        [Define.CustomRoomSettingType.PVP] = false,
        [Define.CustomRoomSettingType.FLY] = false,
        [Define.CustomRoomSettingType.PLACE_BLOCK] = false,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = false,
        [Define.CustomRoomSettingType.FOOD] = false,
        [Define.CustomRoomSettingType.FAST_BREAK_BLOCK] = false,
        [Define.CustomRoomSettingType.UNLIMIT_ITEM] = false
    }

    self.globalPermSetting = {
        [Define.CustomRoomSettingType.PVP] = false,
        [Define.CustomRoomSettingType.FLY] = false,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = false,
        [Define.CustomRoomSettingType.UNLIMIT_ITEM] = false,
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
        [Define.CustomRoomSettingType.PLACE_BLOCK] = false,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = false,
        [Define.CustomRoomSettingType.FOOD] = false,
        [Define.CustomRoomSettingType.FAST_BREAK_BLOCK] = false,
        [Define.CustomRoomSettingType.UNLIMIT_ITEM] = false,
        [Define.CustomRoomSettingType.SPECIAL_BLOCK] = false
    }

    self.defaultPermSettingForRole[Define.CustomGamePermissionRole.Member] = {
        [Define.CustomRoomSettingType.PVP] = false,
        [Define.CustomRoomSettingType.FLY] = false,
        [Define.CustomRoomSettingType.PLACE_BLOCK] = false,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = false,
        [Define.CustomRoomSettingType.FOOD] = false,
        [Define.CustomRoomSettingType.FAST_BREAK_BLOCK] = false,
        [Define.CustomRoomSettingType.UNLIMIT_ITEM] = false,
        [Define.CustomRoomSettingType.SPECIAL_BLOCK] = false
    }

    self.defaultPermSettingForRole[Define.CustomGamePermissionRole.Guest] = {
        [Define.CustomRoomSettingType.PVP] = false,
        [Define.CustomRoomSettingType.FLY] = false,
        [Define.CustomRoomSettingType.PLACE_BLOCK] = false,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = false,
        [Define.CustomRoomSettingType.FOOD] = false,
        [Define.CustomRoomSettingType.FAST_BREAK_BLOCK] = false,
        [Define.CustomRoomSettingType.UNLIMIT_ITEM] = false,
        [Define.CustomRoomSettingType.SPECIAL_BLOCK] = false
    }

    self.defaultPermSettingForRole[Define.CustomGamePermissionRole.UDefine] = {
        [Define.CustomRoomSettingType.PVP] = false,
        [Define.CustomRoomSettingType.FLY] = false,
        [Define.CustomRoomSettingType.PLACE_BLOCK] = false,
        [Define.CustomRoomSettingType.BREAK_BLOCK] = false,
        [Define.CustomRoomSettingType.FOOD] = false,
        [Define.CustomRoomSettingType.FAST_BREAK_BLOCK] = false,
        [Define.CustomRoomSettingType.UNLIMIT_ITEM] = false,
        [Define.CustomRoomSettingType.SPECIAL_BLOCK] = false
    }
end

function CustomGameSocial:onPlayerLogin(player)

end

function CustomGameSocial:getGameMode()
    return Define.CustomGameMode.SOCIAL
end

return CustomGameSocial--[[HhqaZte4fArZClijrstJLGTHGkopd046SvxPSFtPnbcLpR1UdQInWl717X0ZxAsm4nd]]