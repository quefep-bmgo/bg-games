--[[m4rUUna]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 2687
                          local checkFileName = "LimitedTimeGoldWheelConfig.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[ZuMoxeAvUeTG1KWhwb8VZ6eyEgrKITQZvsgmVldjW1g0q]]---@class LimitedTimeGoldWheelConfig
local LimitedTimeGoldWheelConfig = T(Global, "LimitedTimeGoldWheelConfig")

---@type LimitedTimeGoldWheelConfigData[]
local SettingList = {}

function LimitedTimeGoldWheelConfig:init()
    local config = FileUtil.getGameConfigFromCsv("pay_activity/limited_time_gold_wheel.csv",3)
    for _, vConfig in pairs(config) do
        ---@class LimitedTimeGoldWheelConfigData
        local data = {
            id = tonumber(vConfig.n_id) or 0,
            activityId = tonumber(vConfig.n_activityId) or 0,
            order = tonumber(vConfig.n_order) or 0,
            pondId = tonumber(vConfig.n_pondId) or 0,
            weight = tonumber(vConfig.n_weight) or 0,
            param = tonumber(vConfig.n_param) or 0,
            finalPrice = tonumber(vConfig.n_finalPrice) or 0,
            percent = vConfig.s_percent or "",
            giftContent = tonumber(vConfig.n_giftContent) or 0,
        }
        data.giftKey = data.activityId .. "-" .. data.id
        SettingList[data.id] = data
    end
    --print("LimitedTimeGoldWheelConfig:init  ")
    --LogUtil.pv(SettingList)
end

---@return LimitedTimeGoldWheelConfigData
function LimitedTimeGoldWheelConfig:getCfgById(id)
    if not SettingList[id] then
        LogUtil.logError("can not find cfgLimitedTimeGiftSignalConfig, id:", id )
        return
    end
    return SettingList[id]
end

---@return LimitedTimeGoldWheelConfigData[]
function LimitedTimeGoldWheelConfig:getAllCfgs()
    return SettingList
end

---@return LimitedTimeGoldWheelConfigData[]
function LimitedTimeGoldWheelConfig:getCfgByActivityId(activityId)
    local result = {}
    for _, val in pairs(SettingList) do
        if val.activityId == activityId then
            table.insert(result, val)
        end
    end
    return result
end


LimitedTimeGoldWheelConfig:init()

return LimitedTimeGoldWheelConfig

--[[LBX4gBKk5]]---