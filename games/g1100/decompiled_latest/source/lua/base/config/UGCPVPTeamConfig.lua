--队伍相关配置
--示范数据
--[[
--默认选项 UGCPVPOptionConfig.teamSetting
--
--app需要的配置
{
	teamSetting = {
    	teamCountOptionList = {0, 2, 3, 4, 6, 12}, -- 队伍个数列表
    	teamSizeOptionList = {24, 12, 8, 6, 4, 2},  -- 客户端会加特殊逻辑：队伍个数为 0 的时候可选择参赛总人数为 2-24 
	    selectedTeamCount = 1, --默认选择的队伍个数
    	selectedTeamSize = 2, --默认选择的队伍人数
		defBirthPosition = { x=111, y=222, z=111 }, -- 默认出生点
		itemsMaxSize=36,
		equipAndItem = {
			enable = true,
			redPoint = false,
			displayName = "是否设置初始装备和道具",
			type = "switch",
			toggle = false
		}
    	teamStartingPositionList = {
			{
				teamId=1,
				position={x=111,y=222,z=111},
				equipments={ {id=1,itemId=0,meta=0},{id=2,itemId=0,meta=0},{id=3,itemId=0,meta=0},{id=4,itemId=0,meta=0} },
				items={ {id=1,itemId=0,meta=0,count=1} }
			}
		}, -- 队伍的出生点和ID信息
		teamColorList = {#112233,#445566,#778899,#112233,#445566,#778899,...}, -- 队伍颜色列表
		randomSpawn = {enable = true, redPoint = false, displayName = "随机出生", type = "switch", toggle = true},
	}
}
--存档配置 UGCPVPConfig.json
{
	teamSetting = {
    	teamCount = 2, --队伍数
    	teamSize = 2, --队伍人数
    	birthPositions = {
			{x = 111, y = 222, z = 111}
		}, -- 出生点列表
    	teamColorList = {112233,445566,778899,112233,445566,778899}, -- 队伍颜色列表
    	equipmentsList = {
			{{id=1,itemId=0,meta=0},{id=2,itemId=0,meta=0},{id=3,itemId=0,meta=0},{id=4,itemId=0,meta=0}}
		}, -- 队伍装备列表
    	itemsList = {
			{{itemId=0,meta=0}}
		}, -- 队伍物品列表
    	randomSpawn = true
	}
}
--]]
-- 转换函数
local TeamSettingHelper = {}
function TeamSettingHelper.defaultOptionConfig()
	return TableUtil.copyTable(Global.setting.UGCPVPOptionConfig.teamSetting)
end
function TeamSettingHelper.updateRunConfig(opTeamSetting, runTeamSetting)
	runTeamSetting.teamCount = opTeamSetting.selectedTeamCount or opTeamSetting.teamCountOptionList[1]
    runTeamSetting.teamSize = opTeamSetting.selectedTeamSize or opTeamSetting.teamSizeOptionList[5]

	runTeamSetting.birthPositions = {}
	runTeamSetting.teamColorList = {}
	runTeamSetting.equipmentsList = {}
	runTeamSetting.itemsList = {}
	local teamCount = runTeamSetting.teamCount
	if teamCount == 0 then
		teamCount = runTeamSetting.teamSize
	end
	opTeamSetting.teamStartingPositionList = opTeamSetting.teamStartingPositionList or {}
	for i = 1, teamCount do
		opTeamSetting.teamStartingPositionList[i] = opTeamSetting.teamStartingPositionList[i] or {}
		local teamInfo = opTeamSetting.teamStartingPositionList[i]

		if not teamInfo.position then
			teamInfo.position = VectorUtil.toVector3(opTeamSetting.defBirthPosition)
		end
		local pos = VectorUtil.add3(teamInfo.position, VectorUtil.newVector3(0.5, 0, 0.5))

		teamInfo.equipments = teamInfo.equipments or {{itemId=0,meta=0},{itemId=0,meta=0},{itemId=0,meta=0},{itemId=0,meta=0}}
		local equipments = {}
		for _, equipment in ipairs(teamInfo.equipments) do
			table.insert(equipments, {itemId = equipment.itemId, meta = equipment.meta})
		end

		teamInfo.items = teamInfo.items or {}
		local items = {}
		for _, item in ipairs(teamInfo.items) do
			table.insert(items, {itemId = item.itemId, meta = item.meta, count = item.count})
		end

		runTeamSetting.birthPositions[i] = pos
		local colorIndex = i % 12
		if colorIndex == 0 then
			colorIndex = 12
		end
		runTeamSetting.teamColorList[i] = TeamSettingHelper._getTeamColor(colorIndex)
		runTeamSetting.equipmentsList[i] = equipments
		runTeamSetting.itemsList[i] = items
	end
	for i = teamCount + 1, #opTeamSetting.teamStartingPositionList do
		opTeamSetting.teamStartingPositionList[i] = nil
	end
	runTeamSetting.randomSpawn = opTeamSetting.randomSpawn.toggle
end
function TeamSettingHelper.toAppConfig(opTeamSetting, runTeamSetting)
	for i = 1, #opTeamSetting.teamCountOptionList do
		if opTeamSetting.teamCountOptionList[i] == runTeamSetting.teamCount then
			opTeamSetting.selectedTeamCount = runTeamSetting.teamCount
			break
		end
	end
	if not opTeamSetting.selectedTeamCount then
		opTeamSetting.selectedTeamCount = opTeamSetting.teamCountOptionList[1]
	end

	local allCount = opTeamSetting.selectedTeamCount * runTeamSetting.teamSize
	if opTeamSetting.selectedTeamCount > 0 and allCount > 24 then
		for i = 1, #opTeamSetting.teamSizeOptionList do
			local size = opTeamSetting.teamSizeOptionList[i]
			allCount = opTeamSetting.selectedTeamCount * size
			if allCount <= 24 then
				opTeamSetting.selectedTeamSize = size
				break
			end
		end
	else
		opTeamSetting.selectedTeamSize = runTeamSetting.teamSize
	end
	if not opTeamSetting.selectedTeamSize then
		opTeamSetting.selectedTeamSize = 1
	end

	opTeamSetting.teamStartingPositionList = {}
	local teamCount = opTeamSetting.selectedTeamCount
	if teamCount == 0 then
		teamCount = opTeamSetting.selectedTeamSize
	end

	for i = 1, teamCount do
		local pos = opTeamSetting.defBirthPosition
		if runTeamSetting.birthPositions and runTeamSetting.birthPositions[i] then
			pos = VectorUtil.sub3(runTeamSetting.birthPositions[i], VectorUtil.newVector3(0.5, 0, 0.5))
		end

		local equipments = {}
		if runTeamSetting.equipmentsList and runTeamSetting.equipmentsList[i] then
			local equipmentsInfo = runTeamSetting.equipmentsList[i]
			for _, equipment in ipairs(equipmentsInfo) do
				table.insert(equipments, {itemId = equipment.itemId, meta = equipment.meta})
			end
		else
			for i = 1, 4 do
				table.insert(equipments, {itemId = 0, meta = 0})
			end
		end

		local items = {}
		if runTeamSetting.itemsList and runTeamSetting.itemsList[i] then
			local itemsInfo = runTeamSetting.itemsList[i]
			for _, item in ipairs(itemsInfo) do
				table.insert(items, {itemId = item.itemId, meta = item.meta, count = item.count})
			end
		end

		opTeamSetting.teamStartingPositionList[i] = {
			teamId = i,
			position = pos,
			equipments = equipments,
			items = items
		}
	end

	opTeamSetting.randomSpawn.toggle = runTeamSetting.randomSpawn or false
end
function TeamSettingHelper.coverOptionConfig(opTeamSetting, runTeamSetting, newTeamSetting)
	opTeamSetting.selectedTeamCount = newTeamSetting.selectedTeamCount
	opTeamSetting.selectedTeamSize = newTeamSetting.selectedTeamSize
	opTeamSetting.teamStartingPositionList = {}
	for i = 1, #newTeamSetting.teamStartingPositionList do
		local teamInfo = newTeamSetting.teamStartingPositionList[i]
		local equipments = {}
		for _, equipment in ipairs(teamInfo.equipments) do
			table.insert(equipments, {itemId = equipment.itemId, meta = equipment.meta})
		end
		local items = {}
		for _, item in ipairs(teamInfo.items) do
			table.insert(items, {itemId = item.itemId, meta = item.meta, count = item.count})
		end
		opTeamSetting.teamStartingPositionList[i] = {
			teamId = teamInfo.teamId,
			position = VectorUtil.toVector3(teamInfo.position),
			equipments = equipments,
			items = items
		}
	end
	opTeamSetting.randomSpawn.toggle = newTeamSetting.randomSpawn.toggle
    TeamSettingHelper.updateRunConfig(opTeamSetting, runTeamSetting)
end
function TeamSettingHelper.loadComponentField(opTeamSetting, opConfig)
	local configMgr = require "base.config.UGCPVPConfigMgr"
	opTeamSetting.itemsMaxSize = 36
	for i = 1, #opTeamSetting.teamStartingPositionList do
		local teamInfo = opTeamSetting.teamStartingPositionList[i]
		teamInfo.equipments = teamInfo.equipments or {}
		for index, equipment in ipairs(teamInfo.equipments) do
			if equipment.itemId and equipment.itemId ~= 0 then
				local id, fileName = configMgr:getItemUrl(equipment.itemId, equipment.meta)
				equipment.id = id
				equipment.fileName = fileName
				equipment.subtype = index
			else
				equipment.id = 0
				equipment.fileName = ""
				equipment.subtype = index
			end
		end
		teamInfo.items = teamInfo.items or {}
		for _, item in ipairs(teamInfo.items) do
			if item.itemId and item.itemId ~= 0 then
				local id, fileName = configMgr:getItemUrl(item.itemId, item.meta)
				item.id = id
				item.fileName = fileName
			else
				item.id = 0
				item.fileName = ""
			end
		end
	end

	opTeamSetting.randomSpawn.type = "switch"
	if opTeamSetting.selectedTeamCount == 0 then
		opTeamSetting.randomSpawn.enable = true
	else
		opTeamSetting.randomSpawn.enable = false
	end
	opTeamSetting.randomSpawn.redPoint = false

	opTeamSetting.equipAndItem = opTeamSetting.equipAndItem or {}
	local clientInfoStr = HostApi.getClientInfo()
	local clientInfo = json.decode(clientInfoStr)
	if clientInfo.version_code <= 5571 then
		opTeamSetting.equipAndItem.toggle = false
	else
		opTeamSetting.equipAndItem.toggle = true
	end
	opTeamSetting.equipAndItem.type = "switch"
	opTeamSetting.equipAndItem.enable = true
	opTeamSetting.equipAndItem.redPoint = false
end
function TeamSettingHelper.unloadComponentField(opTeamSetting, opConfig)
	opTeamSetting.itemsMaxSize = nil
	for i = 1, #opTeamSetting.teamStartingPositionList do
		local teamInfo = opTeamSetting.teamStartingPositionList[i]
		teamInfo.equipments = teamInfo.equipments or {}
		for _, equipment in ipairs(teamInfo.equipments) do
			equipment.id = nil
			equipment.fileName = nil
			equipment.type = nil
			equipment.subtype = nil
		end
		teamInfo.items = teamInfo.items or {}
		for _, item in ipairs(teamInfo.items) do
			item.id = nil
			item.fileName = nil
		end
	end
	opTeamSetting.randomSpawn.type = nil
	opTeamSetting.randomSpawn.enable = nil
	opTeamSetting.randomSpawn.redPoint = nil

	if opTeamSetting.equipAndItem then
		opTeamSetting.equipAndItem.type = nil
		opTeamSetting.equipAndItem.enable = nil
		opTeamSetting.equipAndItem.redPoint = nil
	end
end
function TeamSettingHelper.checkToSaveRunConfig(runTeamSetting, runConfig)
	return Define.RunningConfigErrorCode.None
end
function TeamSettingHelper.loadLang(opTeamSetting)
	local randomSpawn = opTeamSetting.randomSpawn or {}
	randomSpawn.displayName = Lang:getString("custom_room_ugc_team_setting_random_spawn")

	local equipAndItem = opTeamSetting.equipAndItem or {}
	equipAndItem.displayName = Lang:getString("custom_room_ugc_team_setting_equip_and_item")
end
function TeamSettingHelper.unloadLang(opTeamSetting)
	local randomSpawn = opTeamSetting.randomSpawn or {}
	randomSpawn.displayName = nil

	local equipAndItem = opTeamSetting.equipAndItem or {}
	equipAndItem.displayName = nil
end
function TeamSettingHelper._getTeamColor(teamId)
	local index = math.max(1, math.min(12, teamId))
	return Define.TeamFlagColor[index]
end
return TeamSettingHelper
