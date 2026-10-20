--全局开关
--[[
--默认选项 UGCPVPOptionConfig.otherSetting
--
--app需要的配置
{
	otherSetting = {
		[1] = {
			id = 1,
			enable = true,
			redPoint = false,
			displayName = "死亡掉落",
			type = "switch",
			toggle = true,
			subConfig = {
				{
					id = 1,
					enable = true,
					redPoint = false,
					displayName = "掉落物自动销毁",
					type = "switch",
					toggle = false,
					subConfig = {
						{
							id = 1,
							enable = true,
							redPoint = false,
							displayName = "掉落物销毁时长",
							type = "spinner",
							spinnerInfo = {
								items = {
									{displayName = "10s", value = 10},
									{displayName = "30s", value = 30},
									{displayName = "1min", value = 60},
									{displayName = "2min", value = 120},
									{displayName = "5min", value = 300},
								},
								defValue = 10
							}
						}
					}
				}
			}
		},
		[2] = {
			id = 2,
			enable = true,
			redPoint = false,
			displayName = "允许破坏地形",
			type = "switch",
			toggle = false
		},
		[3] = {
			id = 3,
			enable = true,
			redPoint = false,
			displayName = "允许放置方块",
			type = "switch",
			toggle = true
		},
		[4] = {
			id = 4,
			enable = true,
			redPoint = false,
			displayName = "允许破坏方块",
			type = "switch",
			toggle = true
		}
	}
}
--存档配置 UGCPVPConfig.json
{
	otherSetting = {
		dieDrop = false,
		breakMap = false,
		breakBlock = false,
		placeBlock = false,
		dropAutoDestroy = false,
		dropDestroyTime = 10,
	}
}
]]
--转换函数
local OtherSettingHelper = {}
function OtherSettingHelper.defaultOptionConfig()
	return TableUtil.copyTable(Global.setting.UGCPVPOptionConfig.otherSetting)
end
function OtherSettingHelper.updateRunConfig(opOtherSetting, runOtherSetting)
	runOtherSetting.dieDrop = opOtherSetting[1].toggle
	runOtherSetting.dropAutoDestroy = opOtherSetting[1].subConfig[1].toggle
	runOtherSetting.dropDestroyTime = opOtherSetting[1].subConfig[1].subConfig[1].spinnerInfo.defValue
	runOtherSetting.breakMap = opOtherSetting[2].toggle
	runOtherSetting.placeBlock = opOtherSetting[3].toggle
	runOtherSetting.breakBlock = opOtherSetting[4].toggle
end
function OtherSettingHelper.toAppConfig(opOtherSetting, runOtherSetting)
	opOtherSetting[1].toggle = runOtherSetting.dieDrop
	opOtherSetting[1].subConfig[1].toggle = runOtherSetting.dropAutoDestroy
	opOtherSetting[1].subConfig[1].subConfig[1].spinnerInfo.defValue = runOtherSetting.dropDestroyTime
	opOtherSetting[2].toggle = runOtherSetting.breakMap
	opOtherSetting[3].toggle = runOtherSetting.placeBlock
	opOtherSetting[4].toggle = runOtherSetting.breakBlock
end
function OtherSettingHelper.coverOptionConfig(opOtherSetting, runOtherSetting, newOtherSetting)
	opOtherSetting[1].toggle = newOtherSetting[1].toggle
	opOtherSetting[1].subConfig[1].toggle = false
	opOtherSetting[1].subConfig[1].subConfig[1].spinnerInfo.defValue = 10
	if newOtherSetting[1].subConfig and newOtherSetting[1].subConfig[1] then
		opOtherSetting[1].subConfig[1].toggle = newOtherSetting[1].subConfig[1].toggle
		if newOtherSetting[1].subConfig[1].subConfig and newOtherSetting[1].subConfig[1].subConfig[1] then
			opOtherSetting[1].subConfig[1].subConfig[1].spinnerInfo.defValue = newOtherSetting[1].subConfig[1].subConfig[1].spinnerInfo.defValue
		end
	end
	opOtherSetting[2].toggle = newOtherSetting[2].toggle
	opOtherSetting[3].toggle = newOtherSetting[3].toggle
	opOtherSetting[4].toggle = newOtherSetting[4].toggle

	OtherSettingHelper.updateRunConfig(opOtherSetting, runOtherSetting)
end
function OtherSettingHelper.loadComponentField(opOtherSetting, opConfig)
	for id, setting in ipairs(opOtherSetting) do
		setting.id = id
		setting.enable = true
		setting.redPoint = false
		setting.type = "switch"
		if setting.subConfig and setting.subConfig[1] then
			local sub = setting.subConfig[1]
			sub.id = 1
			sub.enable = true
			sub.redPoint = false
			sub.type = "switch"
			if sub.subConfig and sub.subConfig[1] then
				sub = sub.subConfig[1]
				sub.id = 1
				sub.enable = true
				sub.redPoint = false
				sub.type = "spinner"
				sub.spinnerInfo.items = {}
				for _, value in ipairs({10,30,60,120,300}) do
					table.insert(sub.spinnerInfo.items, {value = value})
				end
			end
		end
	end
end
function OtherSettingHelper.unloadComponentField(opOtherSetting, opConfig)
	for id, setting in ipairs(opOtherSetting) do
		setting.id = nil
		setting.enable = nil
		setting.redPoint = nil
		setting.type = nil
		if setting.subConfig and setting.subConfig[1] then
			local sub = setting.subConfig[1]
			sub.id = nil
			sub.enable = nil
			sub.redPoint = nil
			sub.type = nil
			if sub.subConfig and sub.subConfig[1] then
				sub = sub.subConfig[1]
				sub.id = nil
				sub.enable = nil
				sub.redPoint = nil
				sub.type = nil
				sub.spinnerInfo.items = nil
			end
		end
	end
end
function OtherSettingHelper.checkToSaveRunConfig(runOtherSetting, runConfig)
	return Define.RunningConfigErrorCode.None
end
function OtherSettingHelper.loadLang(opOtherSetting)
	for i, v in ipairs(opOtherSetting) do
		v.displayName = Lang:getString("custom_room_ugc_other_setting_name_" .. i)
	end
	local subConfig = opOtherSetting[1].subConfig[1]
	subConfig.displayName = Lang:getString("custom_room_ugc_other_setting_name_5")
	subConfig = opOtherSetting[1].subConfig[1].subConfig[1]
	subConfig.displayName = Lang:getString("custom_room_ugc_other_setting_name_6")
	for i, item in ipairs(subConfig.spinnerInfo.items) do
		item.displayName = Lang:getString("custom_room_ugc_other_setting_name_6_" .. i)
	end
end
function OtherSettingHelper.unloadLang(opOtherSetting)
	for i, v in ipairs(opOtherSetting) do
		v.displayName = nil
	end
	if opOtherSetting[1].subConfig then
		local subConfig = opOtherSetting[1].subConfig[1]
		if subConfig then
			subConfig.displayName = nil
			if subConfig.subConfig then
				subConfig = subConfig.subConfig[1]
				if subConfig then
					subConfig.displayName = nil
				end
			end
		end
	end
end
return OtherSettingHelper
