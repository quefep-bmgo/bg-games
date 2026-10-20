--[[]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 5558
                          local checkFileName = "UGCPVPGameConfig.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[7OjNLb5NT69HrQ]]--对局相关配置
--示范数据
--[[
--默认选项 UGCPVPOptionConfig.gameSetting
--
--app需要的配置
{
	gameSetting = {
		[1] = {
			id = 1,
			enable = true,
			redPoint = false,
			displayName = "对局时长",
			type = "progress",
			progressInfo = {values = {1,20}, defValue = 2, unit = "min"}
		},
		[2] = {
			id = 2,
			enable = true,
			redPoint = false,
			displayName = "开局等待时长",
			type = "progress",
			progressInfo = {values = {1,30}, defValue = 10, unit = "s"}
		},
		[3] = {
			id = 3,
			enable = true,
			redPoint = false,
			displayName = "开局最小人数",
			type = "progress",
			progressInfo = {values = {1,24}, defValue = 1, unit = "人"}
		},
		[4] = {
			id = 4,
			enable = true,
			redPoint = false,
			displayName = "开局期间允许加入",
			type = "switch",
			toggle = true
		},
		[5] = {
			id = 5,
			enable = true,
			redPoint = false,
			displayName = "复活延迟",
			type = "progress",
			progressInfo = {values = {1,20}, defValue = 10, unit = "s"}
		}
	}
}
--存档配置 UGCPVPConfig.json
{
	gameSetting = {
		gameTime = 0, --对局时长
		waitingPlayerTime = 0, -- 开局等待时长
		startPlayers = 0,-- 开局最小人数
		allowJoinAfterStart = false, -- 是否允许开局后加入
		RespawnTime = 0 -- 复活时间
	}
}
--]]
--转换函数
local GameSettingHelper = {}
function GameSettingHelper.defaultOptionConfig()
	return TableUtil.copyTable(Global.setting.UGCPVPOptionConfig.gameSetting)
end
function GameSettingHelper.updateRunConfig(opGameSetting, runGameSetting)
	runGameSetting.gameTime = opGameSetting[1].progressInfo.defValue	--对局时长
	runGameSetting.waitingPlayerTime = opGameSetting[2].progressInfo.defValue	-- 开局等待时长
	runGameSetting.startPlayers = opGameSetting[3].progressInfo.defValue-- 开局最小人数
	runGameSetting.allowJoinAfterStart = opGameSetting[4].toggle		-- 是否允许开局后加入
	runGameSetting.RespawnTime = opGameSetting[5].progressInfo.defValue	-- 复活时间
end
function GameSettingHelper.toAppConfig(opGameSetting, runGameSetting)
	opGameSetting[1].progressInfo.defValue = runGameSetting.gameTime	--对局时长
	opGameSetting[2].progressInfo.defValue = runGameSetting.waitingPlayerTime	-- 开局等待时长
	opGameSetting[3].progressInfo.defValue = runGameSetting.startPlayers-- 开局最小人数
	opGameSetting[4].toggle = runGameSetting.allowJoinAfterStart		-- 是否允许开局后加入
	opGameSetting[5].progressInfo.defValue = runGameSetting.RespawnTime	-- 复活时间
end
function GameSettingHelper.coverOptionConfig(opGameSetting, runGameSetting, newGameSetting)
	opGameSetting[1].progressInfo.defValue = newGameSetting[1].progressInfo.defValue	--对局时长
	opGameSetting[2].progressInfo.defValue = newGameSetting[2].progressInfo.defValue	-- 开局等待时长
	opGameSetting[3].progressInfo.defValue = newGameSetting[3].progressInfo.defValue	-- 开局最小人数
	opGameSetting[4].toggle = newGameSetting[4].toggle		-- 是否允许开局后加入
	opGameSetting[5].progressInfo.defValue = newGameSetting[5].progressInfo.defValue	-- 复活时间

	GameSettingHelper.updateRunConfig(opGameSetting, runGameSetting)
end
function GameSettingHelper.loadComponentField(opGameSetting, opConfig)
	for id, setting in ipairs(opGameSetting) do
		setting.id = id
		setting.enable = true
		setting.redPoint = false
		if setting.progressInfo then
			setting.type = "progress"
			if id == 1 then
				setting.progressInfo.values = {10, 60}
			elseif id == 2 then
				setting.progressInfo.values = {5, 60}
			elseif id == 3 then
				setting.progressInfo.values = {2, 24}
			elseif id == 5 then
				setting.progressInfo.values = {1, 20}
			end
		else
			setting.type = "switch"
		end
	end
	if opConfig.winCondition.selectedId == Define.OverCondition.Survival then
		opGameSetting[5].enable = false
	else
		opGameSetting[5].enable = true
	end
end
function GameSettingHelper.unloadComponentField(opGameSetting, opConfig)
	for id, setting in ipairs(opGameSetting) do
		setting.id = nil
		setting.enable = nil
		setting.redPoint = nil
		setting.type = nil
		if progressInfo then
			progressInfo.values = nil
		end
	end
end
function GameSettingHelper.checkToSaveRunConfig(runGameSetting, runConfig)
	return Define.RunningConfigErrorCode.None
end
function GameSettingHelper.loadLang(opGameSetting)
	for i, v in ipairs(opGameSetting) do
		v.displayName = Lang:getString("custom_room_ugc_game_setting_name_" .. i)
		if v.type == "progress" then
			v.progressInfo.unit = Lang:getString("custom_room_ugc_game_setting_unit_" .. i)
		end
	end
end
function GameSettingHelper.unloadLang(opGameSetting)
	for i, v in ipairs(opGameSetting) do
		v.displayName = nil
		if v.type == "progress" then
			v.progressInfo.unit = nil
		end
	end
end
return GameSettingHelper
--[[2klWbQMopb]]