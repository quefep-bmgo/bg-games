--[[iaREwkLsLMY250hSebjlugy56tMvkSlk3ltrwxYspMSeExvkY1RZ13N55zmGv20iNMa]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1894
                          local checkFileName = "TriggerGiftDescConfig.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[kN8]]---@class TriggerGiftDescConfig
local TriggerGiftDescConfig = T(Global, "TriggerGiftDescConfig")
---@type TriggerGiftDescConfigData[]
local Settings = {}

function TriggerGiftDescConfig:init()
	local config = FileUtil.getConfigFromCsv("common/TriggerGiftDesc.csv", 2, true, true)
	for _, item in pairs(config) do
		---@class TriggerGiftDescConfigData
		local data = {
			index = item.index,
			giftId = item.giftId,
			duration = item.duration,
			topImage = item.topImage,
			price = tonumber(item.price),
			value = item.value,
			name = item.name,
			desc = item.desc,
			image = item.image,
			tabImage = item.tabImage,
			rewardGroupId = item.rewardGroupId
		}
		Settings[data.giftId] = data
	end
end

function TriggerGiftDescConfig:getAllCfg()
	return Settings
end

---@return TriggerGiftDescConfigData
function TriggerGiftDescConfig:getCfgById(id)
	return Settings[id]
end

TriggerGiftDescConfig:init()

return TriggerGiftDescConfig--[[5BOdKVS8LJqVVmyEFl7Gn5Wl53R3OaupWaGm9HU4lKDdl60cqoclCv83P1RIDCFokoDZFCovCS4bUvmbALhQEEyr5BSvemQi9lCnCOU3zH59MKgPDMIbmWia5JQBG7yKwnpqO]]