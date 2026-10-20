--[[4ZKp2H4O2yCyC8Pd4uGPVGx9zzKeWMdcaXcehnaRdbRxwufP6Oc8nLcidiKkX6xmqx]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 2530
                          local checkFileName = "LimitedTimeGiftCombinedConfig.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[MIRtPaJkNGlYQFcpJd2l7Cc8GY9rVCz4g4I0BgInyucShsQjPpdmc]]
---@class LimitedTimeGiftCombinedConfig
local LimitedTimeGiftCombinedConfig = T(Global, "LimitedTimeGiftCombinedConfig")
---@type LimitedTimeGiftCombinedConfigData[]
local SettingList = {}

---@private
function LimitedTimeGiftCombinedConfig:init()
    local config = FileUtil.getGameConfigFromCsv("pay_activity/limited_time_gift_combined.csv",3)
    for _, vConfig in pairs(config or {}) do
        ---@class LimitedTimeGiftCombinedConfigData
        local data = {
            id = tonumber(vConfig.n_id) or 0,
            activityId = tonumber(vConfig.n_activityId) or 0,
            giftName =  vConfig.s_giftName or "",
            initPrice = tonumber(vConfig.n_initPrice) or 0,
            finalPrice = tonumber(vConfig.n_finalPrice) or 0,
            percent = vConfig.s_percent or "",
        }
        data.giftKey = data.activityId .. "-" .. data.id
        data.giftContent = StringUtil.split(vConfig.s_giftContent or "", "#",false, true)
        SettingList[data.id] = data
    end
    --LogUtil.pv(SettingList)
end

---@return LimitedTimeGiftCombinedConfigData[]
function LimitedTimeGiftCombinedConfig:getAllCfgs()
    return SettingList
end

---@return LimitedTimeGiftCombinedConfigData
function LimitedTimeGiftCombinedConfig:getCfgById(id)
    return SettingList[id]
end

---@return LimitedTimeGiftCombinedConfigData
function LimitedTimeGiftCombinedConfig:getCfgByActivityId(activityId)
    for _, val in pairs(SettingList) do
        if val.activityId == activityId then
            return val
        end
    end
end

LimitedTimeGiftCombinedConfig:init()

return LimitedTimeGiftCombinedConfig

--[[aAKw7N8SvG8vqJ6JspdZ19bGLwXd17cRp7x3Fmb]]