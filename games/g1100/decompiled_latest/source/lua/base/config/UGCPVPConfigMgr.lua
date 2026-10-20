-- PVPUGC相关配置模块 暂时将PVPUGC相关配置全部放一起。等以后有时间再拆分为插件
-- 相关数据都是范例，最后都是从配置中加载出来。
-- 配置放在map目录下，配置选项放在插件setting里面，

local TeamSettingHelper = require "base.config.UGCPVPTeamConfig"
local WinConditionHelper = require "base.config.UGCPVPConditionConfig"
local GameSettingHelper = require "base.config.UGCPVPGameConfig"
local OtherSettingHelper = require "base.config.UGCPVPOtherConfig"

---@type PathUtil
local PathUtil = T(Global, "PathUtil")

-- 整个配置
local UGCPVPConfigMgr = {
    runConfig = nil,
    optionConfig = nil
}

local pvpConfigFile = "UGCPVPConfig.json"
local prefabConfigFile = "prefabConfig.json"

--编辑时加载配置
function UGCPVPConfigMgr:loadConfigForEditor(initPos)
	-- print("ole27 ================= " .. StringUtil.v2s(Global.setting.UGCPVPOptionConfig))
    self.optionConfig = nil
    self.optionConfig = self:_loadDefaultOptionConfig()
	-- 设置默认入口
	self.optionConfig.teamSetting.defBirthPosition = VectorUtil.toVector3i(initPos)

	self.runConfig = {}
    local configPath = FileUtil:getMapPath() .. pvpConfigFile
    if PathUtil:isFileExist(configPath) then
        self.runConfig = FileUtil.getConfigFromJson(configPath)
    end

	if not self.runConfig.teamSetting then
        self.runConfig.teamSetting = {}
		TeamSettingHelper.updateRunConfig(self.optionConfig.teamSetting, self.runConfig.teamSetting)
    end
	TeamSettingHelper.toAppConfig(self.optionConfig.teamSetting, self.runConfig.teamSetting)

	local teamCount = self.runConfig.teamSetting.teamCount
	if self.runConfig.teamSetting.teamCount == 0 then
		teamCount = self.runConfig.teamSetting.teamSize
	end

	if not self.runConfig.winCondition then
		self.runConfig.winCondition = {}
		WinConditionHelper.updateRunConfig(self.optionConfig.winCondition, self.runConfig.winCondition, teamCount)
    end
	WinConditionHelper.toAppConfig(self.optionConfig.winCondition, self.runConfig.winCondition, teamCount)
	
	if not self.runConfig.gameSetting then
		self.runConfig.gameSetting = {}
		GameSettingHelper.updateRunConfig(self.optionConfig.gameSetting, self.runConfig.gameSetting)
    end
	GameSettingHelper.toAppConfig(self.optionConfig.gameSetting, self.runConfig.gameSetting)
	
	if not self.runConfig.otherSetting then
		self.runConfig.otherSetting = {}
		OtherSettingHelper.updateRunConfig(self.optionConfig.otherSetting, self.runConfig.otherSetting)
	end
	OtherSettingHelper.toAppConfig(self.optionConfig.otherSetting, self.runConfig.otherSetting)

	return self.runConfig, self.optionConfig
end
--运行时加载配置
function UGCPVPConfigMgr:loadConfigForRunning(initPos)
    local configPath = FileUtil:getMapPath() .. pvpConfigFile
    if not PathUtil:isFileExist(configPath) then
		local runConfig, _ = self:loadConfigForEditor(initPos)
		self.runConfig = runConfig
        return runConfig
    end
    self.runConfig = FileUtil.getConfigFromJson(configPath)
    return self.runConfig
end
--编辑时加载预制体配置
function UGCPVPConfigMgr:loadPrefabConfigForEditor()
    local prefabConfigPath = FileUtil:getMapPath() .. prefabConfigFile
    if PathUtil:isFileExist(prefabConfigPath) then
		local config = FileUtil.getConfigFromJson(prefabConfigPath)
		if not config then
			return nil
		end
		config.fileName = config.fileName or "2026-03-05.csv"
		config.blocks = {}
		local prefabCsvpath = FileUtil:getMapPath() .. config.fileName
		if not PathUtil:isFileExist(prefabCsvpath) then
			return config
		end
		local prefabConfig = CsvUtil.loadCsvFile(prefabCsvpath, 2)
		for _, item in pairs(prefabConfig) do
			local block = {
				blockPos = VectorUtil.newVector3i(item.x, item.y, item.z),
				blockId = tonumber(item.blockId),
				meta = tonumber(item.meta)
			}
			table.insert(config.blocks, block)
		end
		return config
    end
	return nil
end

--覆盖保存配置
function UGCPVPConfigMgr:onCoverOpConfigAndRunConfig(newUGCSetting)
	TeamSettingHelper.coverOptionConfig(self.optionConfig.teamSetting, self.runConfig.teamSetting, newUGCSetting.teamSetting)

	local teamCount = self.runConfig.teamSetting.teamCount
	if self.runConfig.teamSetting.teamCount == 0 then
		teamCount = self.runConfig.teamSetting.teamSize
	end

	WinConditionHelper.coverOptionConfig(self.optionConfig.winCondition, self.runConfig.winCondition, newUGCSetting.winCondition, teamCount)
	GameSettingHelper.coverOptionConfig(self.optionConfig.gameSetting, self.runConfig.gameSetting, newUGCSetting.gameSetting)
	OtherSettingHelper.coverOptionConfig(self.optionConfig.otherSetting, self.runConfig.otherSetting, newUGCSetting.otherSetting)

	return self.runConfig, self.optionConfig
end
-- 保存run配置
function UGCPVPConfigMgr:saveRunConfig()
	if self.runConfig then
		local errorStr = Define.RunningConfigErrorCode.None
		errorStr = TeamSettingHelper.checkToSaveRunConfig(self.runConfig.teamSetting, self.runConfig)
		if errorStr ~= Define.RunningConfigErrorCode.None then return errorStr end
		errorStr = WinConditionHelper.checkToSaveRunConfig(self.runConfig.winCondition, self.runConfig)
		if errorStr ~= Define.RunningConfigErrorCode.None then return errorStr end
		errorStr = GameSettingHelper.checkToSaveRunConfig(self.runConfig.gameSetting, self.runConfig)
		if errorStr ~= Define.RunningConfigErrorCode.None then return errorStr end
		errorStr = OtherSettingHelper.checkToSaveRunConfig(self.runConfig.otherSetting, self.runConfig)
		if errorStr ~= Define.RunningConfigErrorCode.None then return errorStr end

		local filePath = FileUtil:getMapPath() .. pvpConfigFile
		local file = io.open(filePath, "w")
		local text = json.format(json.encode(self.runConfig))
		file:write(text)
		file:close()
		--print("saveRunConfig filePath:" .. filePath .. " json:" .. text)
		return errorStr
	else
		return Define.RunningConfigErrorCode.OtherError0
	end
end
-- 保存prafab配置
function UGCPVPConfigMgr:savePrafabConfig(configData)
	local filePath = FileUtil:getMapPath() .. prefabConfigFile
	local file = io.open(filePath, "w")
	local data = {
		firstEditUserId = configData.firstEditUserId,
		lastEditUserId = configData.lastEditUserId,
		fileName = configData.fileName,
		primaryTag = configData.primaryTag,
		secondaryTag = configData.secondaryTag,
		buildSize = configData.buildSize,
		buildAABB = configData.buildAABB
	}
	local text = json.format(json.encode(data))
	file:write(text)
	file:close()
	
	if configData.saveBlockCsv then
		local size, _ = TableUtil.getTableSize(configData.blockMap)
		if size > 0 then
			local csvFilePath = FileUtil:getMapPath() .. configData.fileName
			local csvFile = io.open(csvFilePath, "w")
			csvFile:write("表索引\t坐标x\t坐标y\t坐标z\t方块Id\t方块meta\n")
			csvFile:write("index\tx\ty\tz\tblockId\tmeta\n")
			
			local strFormat = "%d\t%d\t%d\t%d\t%d\t%d\n"
			local i = 1
			for _, block in pairs(configData.blockMap) do
				csvFile:write(string.format(strFormat, i,
					block.blockPos.x, block.blockPos.y, block.blockPos.z,
					block.blockId, block.meta
				))
				i = i + 1
			end
			csvFile:close()
		end
	end

	return Define.RunningConfigErrorCode.None
end

-- 获取最大可进玩家数
function UGCPVPConfigMgr:getMaxPlayer()
	if self.runConfig and self.runConfig.teamSetting then
		local teamSetting = self.runConfig.teamSetting
		if teamSetting.teamCount == 0 then
			return teamSetting.teamSize
		else
			return teamSetting.teamSize * teamSetting.teamCount
		end
	end
    return 0;
end

--设置多语言字段
function UGCPVPConfigMgr:loadOptionConfigLang(config)
	TeamSettingHelper.loadLang(config.teamSetting)
	WinConditionHelper.loadLang(config.winCondition)
	GameSettingHelper.loadLang(config.gameSetting)
	OtherSettingHelper.loadLang(config.otherSetting)
end
function UGCPVPConfigMgr:loadReturnMsgLang(data)
	if data.args then
		data.msg = Lang:format("custom_room_ugc_error_msg_" .. data.msg, data.args)
	else
		data.msg = Lang:getString("custom_room_ugc_error_msg_" .. data.msg)
	end
end
function UGCPVPConfigMgr:unloadOptionConfigLang(config)
	TeamSettingHelper.unloadLang(config.teamSetting)
	WinConditionHelper.unloadLang(config.winCondition)
	GameSettingHelper.unloadLang(config.gameSetting)
	OtherSettingHelper.unloadLang(config.otherSetting)
end
--设置其他字段
function UGCPVPConfigMgr:loadComponentField(opConfig)
	TeamSettingHelper.loadComponentField(opConfig.teamSetting, opConfig)
	WinConditionHelper.loadComponentField(opConfig.winCondition, opConfig)
	GameSettingHelper.loadComponentField(opConfig.gameSetting, opConfig)
	OtherSettingHelper.loadComponentField(opConfig.otherSetting, opConfig)
end
function UGCPVPConfigMgr:unloadComponentField(opConfig)
	TeamSettingHelper.unloadComponentField(opConfig.teamSetting, opConfig)
	WinConditionHelper.unloadComponentField(opConfig.winCondition, opConfig)
	GameSettingHelper.unloadComponentField(opConfig.gameSetting, opConfig)
	OtherSettingHelper.unloadComponentField(opConfig.otherSetting, opConfig)
end
--设置道具列表
function UGCPVPConfigMgr:loadOptionItemConfig(config)
	config.winCondition.itemConfigList = self:loadItemUrlCSV();
end
function UGCPVPConfigMgr:unLoadOptionItemConfig(config)
	config.winCondition.itemConfigList = nil
end
-- 加载队伍颜色
function UGCPVPConfigMgr:loadOptionTeamColorConfig(config)
	config.teamSetting.teamColorList = self:_loadOptionTeamColor()
end
function UGCPVPConfigMgr:unLoadOptionTeamColorConfig(config)
	config.teamSetting.teamColorList = nil
end


-- 加载道具URL配置
local UGCPVPConfigMgrItemList = nil
function UGCPVPConfigMgr:loadItemUrlCSV()
	if not UGCPVPConfigMgrItemList then
		UGCPVPConfigMgrItemList = {}
		local itemUrlConfig = FileUtil.getGameConfigFromCsv("ItemUrl.csv", 1)
		for i, v in pairs(itemUrlConfig) do
			local itemCfg = {
				id = tonumber(v.id),
				itemId = tonumber(v.ItemId),
				meta = tonumber(v.subItemId),
				fileName = v.IconUrl,
				type = tonumber(v.type),
				subtype = tonumber(v.subtype),
				stackSize = 64
			}
			local item = Item.getItemById(itemCfg.itemId)
			if item then
				itemCfg.stackSize = item:getItemStackLimit()
			end
			table.insert(UGCPVPConfigMgrItemList, itemCfg)
		end
		table.sort(UGCPVPConfigMgrItemList, function(a, b)
			return a.id < b.id
		end)
	end
	return UGCPVPConfigMgrItemList
end
local UGCPVPConfigMgrItemMap = nil
function UGCPVPConfigMgr:getItemUrl(itemId, meta)
	if not UGCPVPConfigMgrItemMap then
		UGCPVPConfigMgrItemMap = {}
    	local itemUrlConfig = FileUtil.getGameConfigFromCsv("ItemUrl.csv", 1)
    	for i, v in pairs(itemUrlConfig) do
			local key = tostring(v.ItemId).."_"..tostring(v.subItemId)
        	UGCPVPConfigMgrItemMap[key] = {
				id = tonumber(v.id),
				fileName = v.IconUrl,
				type = tonumber(v.type),
				subtype = tonumber(v.subtype)
			} 
    	end
	end
	local key = tostring(itemId).."_"..tostring(meta)
	local cfg = UGCPVPConfigMgrItemMap[key]
	if not cfg then
		return 0, ""
	end
	return cfg.id, cfg.fileName, cfg.type, cfg.subtype
end
-- 加载默认选项配置
function UGCPVPConfigMgr:_loadDefaultOptionConfig()
	local opConfig = {}
	opConfig.teamSetting = TeamSettingHelper.defaultOptionConfig()
	opConfig.winCondition = WinConditionHelper.defaultOptionConfig()
	opConfig.gameSetting = GameSettingHelper.defaultOptionConfig()
	opConfig.otherSetting = OtherSettingHelper.defaultOptionConfig()
	return opConfig
end
-- 加载队伍颜色配置
function UGCPVPConfigMgr:_loadOptionTeamColor()
	local teamColorList = {}
	for i, v in ipairs(Define.TeamFlagColor) do
		teamColorList[i] = "#" .. v
	end
	return teamColorList
end

return UGCPVPConfigMgr
