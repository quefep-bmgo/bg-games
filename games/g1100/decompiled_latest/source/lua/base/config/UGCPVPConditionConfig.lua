--胜负条件
--示范数据
--[[
--默认选项 UGCPVPOptionConfig.winCondition
--
--app需要的配置
{
	selectedId = 1
	conditionList = {
		[1] = {
			id = 1,
			displayName = "收集物品达到",
			dec = "",
			optInfo = {
				[1] = {
					id = 1,
					enable = true,
					redPoint = false,
					displayName = "收集物品",
					type = "picture",
					itemInfo = {[1] = {id = 1, itemId = 1234, fileName = "", meta = 1}, [2] = {}, ...}
				},
				[2] = {
					id = 2,
					enable = true,
					redPoint = false,
					displayName = "达成数量",
					type = "progress",
					progressInfo = {values = {1,20}, defValue = 2, unit = "个"}
				}
			}
		},
		[2] = {
			id = 2,
			displayName = "击杀达成数量",
			dec = "",
			optInfo = {
				[1] = {
					id = 1,
					enable = true,
					redPoint = false,
					displayName = "达成数量"
					type = "progress"
					progressInfo = {values = {1,20}, defValue = 2, unit = "人"}
				}
			}
		},
		[3] = {
			id = 3,
			displayName = "最后生存",
			dec = "",
			optInfo = {}
		},
		[4] = {
			id = 4,
			displayName = "游戏时间收集物最高",
			dec = "游戏时间收集物最高说明",
			optInfo = {
				[1] = {
					id = 1,
					enable = true,
					redPoint = false,
					displayName = "收集物品",
					type = "picture",
					itemInfo = {[1] = {id = 1, itemId = 1234, fileName = "", meta = 1}, [2] = {}, ...}
				}
			}
		},
		[5] = {
			id = 5,
			displayName = "游戏时间击杀最高",
			dec = "游戏时间击杀最高说明",
			optInfo = {}
		},
		[6] = {
			id = 6,
			displayName = "破坏标志物",
			dec = "破坏标志物说明",
			optInfo = {
				[1]={
					id = 1,
					enable = true,
					redPoint = false,
					displayName = "队伍1",
					type = "teamFlagChoose",
					teamFlagChooseInfo = {
						id=1,
						itemId=1,
						meta=1,
						position={x=1,y=1,z=1}
					}
				}
			}
		},
		[7] = {
			id = 7,
			displayName = "破坏标志物和击败玩家",
			dec = "破坏标志物和击败玩家说明",
			optInfo = {
				[1]={
					id = 1,
					enable = true,
					redPoint = false,
					displayName = "队伍1",
					type = "teamFlagChoose",
					teamFlagChooseInfo = {
						id=1,
						itemId=1,
						meta=1,
						position={x=1,y=1,z=1}
					}
				}
			}
		}
	}
}
--存档配置 UGCPVPConfig.json
{
	winCondition = {
		type = Define.OverCondition.Survival,
		param = [count, itemId, (meta or 0), itemId, (meta or 0), ...]
	}
}
--]]
--转换函数
local WinConditionHelper = {}
function WinConditionHelper.defaultOptionConfig()
	return TableUtil.copyTable(Global.setting.UGCPVPOptionConfig.winCondition)
end
function WinConditionHelper.updateRunConfig(opWinCondition, runWinCondition, teamCount)
	local winType = opWinCondition.selectedId or Define.OverCondition.Survival
	runWinCondition.type = winType
	runWinCondition.param = {}

	local optInfo = opWinCondition.conditionList[winType].optInfo
	if winType == Define.OverCondition.CollectNum or winType == Define.OverCondition.Collect then
		local count = 0
		if optInfo[2] then
			count = optInfo[2].progressInfo.defValue or 0
		end
		local index = 1
		runWinCondition.param[index] = count
		index = index + 1
		for  _, v in ipairs(optInfo[1].itemInfo) do
			runWinCondition.param[index] = v.itemId
			index = index + 1
			runWinCondition.param[index] = v.meta or 0
			index = index + 1
		end
	elseif winType == Define.OverCondition.KillNum or winType == Define.OverCondition.Kill then
		if optInfo[1] then
			runWinCondition.param[1] = optInfo[1].progressInfo.defValue or 0
		end
	elseif winType == Define.OverCondition.Survival then
	elseif winType == Define.OverCondition.Marker or winType == Define.OverCondition.MarkerAndKill then
		for i = 1, teamCount do
			if not optInfo[i] then
				optInfo[i] = {
					teamFlagChooseInfo = {itemId=0,meta=0,position={x=0,y=0,z=0}}
				}
			end
			local marker = optInfo[i].teamFlagChooseInfo
			table.insert(runWinCondition.param, i)
			table.insert(runWinCondition.param, marker.itemId)
			table.insert(runWinCondition.param, marker.meta)
			table.insert(runWinCondition.param, marker.position.x)
			table.insert(runWinCondition.param, marker.position.y)
			table.insert(runWinCondition.param, marker.position.z)
		end
	end

	optInfo = opWinCondition.conditionList[Define.OverCondition.Marker].optInfo
	for i = 1, teamCount do
		if not optInfo[i] then
			optInfo[i] = {
				teamFlagChooseInfo = {itemId=0,meta=0,position={x=0,y=0,z=0}}
			}
		end
	end
	for i = teamCount + 1, #optInfo do
		optInfo[i] = nil
	end
	optInfo = opWinCondition.conditionList[Define.OverCondition.MarkerAndKill].optInfo
	for i = 1, teamCount do
		if not optInfo[i] then
			optInfo[i] = {
				teamFlagChooseInfo = {itemId=0,meta=0,position={x=0,y=0,z=0}}
			}
		end
	end
	for i = teamCount + 1, #optInfo do
		optInfo[i] = nil
	end
end
function WinConditionHelper.toAppConfig(opWinCondition, runWinCondition, teamCount)
	local winType = runWinCondition.type
    opWinCondition.selectedId = winType
	local optInfo = opWinCondition.conditionList[winType].optInfo

	if winType == Define.OverCondition.CollectNum or winType == Define.OverCondition.Collect then
		if optInfo[2] then
			optInfo[2].progressInfo.defValue = runWinCondition.param[1] or 0
		end
		optInfo[1].itemInfo = {}
		for i = 2, #runWinCondition.param, 2 do
			local itemId = runWinCondition.param[i]
			local meta = runWinCondition.param[i + 1]
			if itemId then
				table.insert(optInfo[1].itemInfo, {
					itemId = itemId,
					meta = meta
				})
			end
		end
	elseif winType == Define.OverCondition.KillNum or winType == Define.OverCondition.Kill then
		if optInfo[1] then
			optInfo[1].progressInfo.defValue = runWinCondition.param[1] or 0
		end
	elseif winType == Define.OverCondition.Survival then
	elseif winType == Define.OverCondition.Marker or winType == Define.OverCondition.MarkerAndKill then
		local index = 1
		for i = 1, teamCount do
			optInfo[i] = optInfo[i] or {}
			optInfo[i].teamFlagChooseInfo = optInfo[i].teamFlagChooseInfo or {}
			local marker = optInfo[i].teamFlagChooseInfo
			local teamId = runWinCondition.param[index] or i
			index = index + 1
			marker.itemId = runWinCondition.param[index] or 0
			index = index + 1
			marker.meta = runWinCondition.param[index] or 0
			index = index + 1
			local x = runWinCondition.param[index] or 0
			index = index + 1
			local y = runWinCondition.param[index] or 0
			index = index + 1
			local z = runWinCondition.param[index] or 0
			index = index + 1
			marker.position = VectorUtil.newVector3i(x, y, z)
		end
	end

	optInfo = opWinCondition.conditionList[Define.OverCondition.Marker].optInfo
	for i = 1, teamCount do
		if not optInfo[i] then
			optInfo[i] = {
				teamFlagChooseInfo = {itemId=0,meta=0,position={x=0,y=0,z=0}}
			}
		end
	end
	for i = teamCount + 1, #optInfo do
		optInfo[i] = nil
	end
	optInfo = opWinCondition.conditionList[Define.OverCondition.MarkerAndKill].optInfo
	for i = 1, teamCount do
		if not optInfo[i] then
			optInfo[i] = {
				teamFlagChooseInfo = {itemId=0,meta=0,position={x=0,y=0,z=0}}
			}
		end
	end
	for i = teamCount + 1, #optInfo do
		optInfo[i] = nil
	end

	return opWinCondition
end
function WinConditionHelper.coverOptionConfig(opWinCondition, runWinCondition, newWinCondition, teamCount)
	local winType = newWinCondition.selectedId
	opWinCondition.selectedId = winType

	local oldOptInfo = opWinCondition.conditionList[winType].optInfo
	local newOptInfo = newWinCondition.conditionList[winType].optInfo

	if winType == Define.OverCondition.CollectNum or winType == Define.OverCondition.Collect then
		oldOptInfo[1].itemInfo = {}
		for  _, v in ipairs(newOptInfo[1].itemInfo) do
			table.insert(oldOptInfo[1].itemInfo, {itemId = v.itemId, meta = v.meta})
		end
		if oldOptInfo[2] and newOptInfo[2] then
			oldOptInfo[2].progressInfo.defValue = newOptInfo[2].progressInfo.defValue
		end
	elseif winType == Define.OverCondition.KillNum or winType == Define.OverCondition.Kill then
		if oldOptInfo[1] then
			oldOptInfo[1].progressInfo.defValue = newOptInfo[1].progressInfo.defValue
		end
	elseif winType == Define.OverCondition.Survival then
	elseif winType == Define.OverCondition.Marker or winType == Define.OverCondition.MarkerAndKill then
		TableUtil.clearTable(oldOptInfo)
		newOptInfo = newOptInfo or {}
		for _, v in ipairs(newOptInfo) do
			table.insert(oldOptInfo, {
				teamFlagChooseInfo = {
					itemId = v.teamFlagChooseInfo.itemId,
					meta = v.teamFlagChooseInfo.meta,
					position = VectorUtil.toVector3i(v.teamFlagChooseInfo.position)
				}
			})
		end
	end

	WinConditionHelper.updateRunConfig(opWinCondition, runWinCondition, teamCount)
end
function WinConditionHelper.loadComponentField(opWinCondition, opConfig)
	local clientInfoStr = HostApi.getClientInfo()
	local clientInfo = json.decode(clientInfoStr)
	if clientInfo.version_code <= 5571 then
		opWinCondition.conditionList[Define.OverCondition.Marker] = nil
		opWinCondition.conditionList[Define.OverCondition.MarkerAndKill] = nil
	end

	local configMgr = require "base.config.UGCPVPConfigMgr"
	for id, condition in ipairs(opWinCondition.conditionList) do
		condition.id = id
		for op_id, opt in ipairs(condition.optInfo) do
			opt.id = op_id
			opt.enable = true
			opt.redPoint = false
			if opt.itemInfo then
				opt.type = "picture"
				for _, item in ipairs(opt.itemInfo) do
					if item.itemId and item.itemId ~= 0 then
						local id, fileName = configMgr:getItemUrl(item.itemId, item.meta)
						item.id = id
						item.fileName = fileName
					else
						item.id = 0
						item.fileName = ""
					end
				end
			elseif opt.progressInfo then
				opt.type = "progress"
				opt.progressInfo.values = {1, 100}
			elseif opt.teamFlagChooseInfo then
				opt.type = "teamFlagChoose"
				if opt.teamFlagChooseInfo.itemId and opt.teamFlagChooseInfo.itemId ~= 0 then
					local id, fileName = configMgr:getItemUrl(opt.teamFlagChooseInfo.itemId, opt.teamFlagChooseInfo.meta)
					opt.teamFlagChooseInfo.id = id
					opt.teamFlagChooseInfo.fileName = fileName
				else
					opt.teamFlagChooseInfo.id = 0
					opt.teamFlagChooseInfo.fileName = ""
				end
			end
		end
	end

	if opWinCondition.selectedId == Define.OverCondition.CollectNum 
		or opWinCondition.selectedId == Define.OverCondition.Collect
		or opWinCondition.selectedId == Define.OverCondition.Marker
		or opWinCondition.selectedId == Define.OverCondition.MarkerAndKill then
		
		if opWinCondition.conditionList[opWinCondition.selectedId] then
			local optInfo = opWinCondition.conditionList[opWinCondition.selectedId].optInfo
			for _, opt in ipairs(optInfo) do
				if opt.type == "picture" then
					if not opt.itemInfo or not opt.itemInfo[1] then
						opt.redPoint = true
					end
				elseif opt.type == "teamFlagChoose" then
					if opt.teamFlagChooseInfo.itemId == 0 then
						opt.redPoint = true
					end
				end
			end
		end
	end
end
function WinConditionHelper.unloadComponentField(opWinCondition, opConfig)
	for id, condition in ipairs(opWinCondition.conditionList) do
		condition.id = nil
		for op_id, opt in ipairs(condition.optInfo) do
			opt.id = nil
			opt.enable = nil
			opt.redPoint = nil
			opt.type = nil
			if opt.progressInfo then
				opt.progressInfo.values = nil
			elseif opt.itemInfo then
				for _, item in ipairs(opt.itemInfo) do
					item.id = nil
					item.fileName = nil
				end
			elseif opt.teamFlagChooseInfo then
				opt.teamFlagChooseInfo.id = nil
				opt.teamFlagChooseInfo.fileName = nil
			end
		end
	end
end
function WinConditionHelper.checkToSaveRunConfig(runWinCondition, runConfig)
	if runWinCondition.type == Define.OverCondition.CollectNum or runWinCondition.type == Define.OverCondition.Collect then
		if runWinCondition.param[2] == nil then
			return Define.RunningConfigErrorCode.None
		end
	end
	return Define.RunningConfigErrorCode.None
end
function WinConditionHelper.loadLang(opWinCondition)
	local conditionList = opWinCondition.conditionList
	for i, condition in ipairs(conditionList) do
		condition.dec = Lang:getString("custom_room_ugc_condition_dec_" .. i)
		condition.displayName = Lang:getString("custom_room_ugc_condition_name_" .. i)
		if i == Define.OverCondition.CollectNum or i == Define.OverCondition.Collect then
			condition.optInfo[1].displayName = Lang:getString("custom_room_ugc_condition_option_name_1")
			if condition.optInfo[2] then
				condition.optInfo[2].displayName = Lang:getString("custom_room_ugc_condition_option_name_2")
				condition.optInfo[2].progressInfo.unit = Lang:getString("custom_room_ugc_condition_option_unit_1")
			end
		elseif i == Define.OverCondition.KillNum or i == Define.OverCondition.Kill then
			if condition.optInfo[1] then
				condition.optInfo[1].displayName = Lang:getString("custom_room_ugc_condition_option_name_2")
				condition.optInfo[1].progressInfo.unit = Lang:getString("custom_room_ugc_condition_option_unit_2")
			end
		elseif i == Define.OverCondition.Marker or i == Define.OverCondition.MarkerAndKill then
			for teamId, op in ipairs(condition.optInfo) do
				op.displayName = Lang:getString("gui.text.team") .. tostring(teamId)
			end
		end		
	end
end
function WinConditionHelper.unloadLang(opWinCondition)
	local conditionList = opWinCondition.conditionList
	for i, condition in ipairs(conditionList) do
		condition.dec = nil
		condition.displayName = nil
		if i == Define.OverCondition.CollectNum or i == Define.OverCondition.Collect then
			condition.optInfo[1].displayName = nil
			if condition.optInfo[2] then
				condition.optInfo[2].displayName = nil
				condition.optInfo[2].progressInfo.unit = nil
			end
		elseif i == Define.OverCondition.KillNum or i == Define.OverCondition.Kill then
			if condition.optInfo[1] then
				condition.optInfo[1].displayName = nil
				condition.optInfo[1].progressInfo.unit = nil
			end
		elseif i == Define.OverCondition.Marker or i == Define.OverCondition.MarkerAndKill then
			for teamId, op in ipairs(condition.optInfo) do
				op.displayName = nil
			end
		end		
	end
end
return WinConditionHelper
