--[[041vrTTeWYEY0SorSQSR7Nz4gJvaqUnqqsWzYX]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 2948
                          local checkFileName = "limitedTimeDrawConfig.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[7OOAoKeoSoI0e2DdWy7LtrBAQXPmCoJxnGf]]---@class LimitedTimeDrawConfig
local LimitedTimeDrawConfig = T(Global, "LimitedTimeDrawConfig")

---@type LimitedTimeDrawConfigData[]
local settings = {}
local sameActivitySettings = {}

function LimitedTimeDrawConfig:init()
    local config = FileUtil.getGameConfigFromCsv("pay_activity/limited_time_draw.csv",2)
    for _, vConfig in pairs(config) do
        ---@class LimitedTimeDrawConfigData
        local data = {
            id = tonumber(vConfig.n_id) or 0,
            activityId = tonumber(vConfig.n_activityId) or 0,
            sequence = tonumber(vConfig.n_sequence) or 0,
            pondId = tonumber(vConfig.n_pondId) or 0,
            awardsModel = vConfig.s_awardsModel ~= "" and vConfig.s_awardsModel,
            awardsIcon = vConfig.s_awardsIcon ~= "" and vConfig.s_awardsIcon,
            guaranteeCount = tonumber(vConfig.n_guaranteeCount) or 0,
            singlePrice = tonumber(vConfig.n_singlePrice) or 0,
            tenPrice = tonumber(vConfig.n_tenPrice) or 0,
        }
        settings[data.id] = data
        if not sameActivitySettings[data.activityId] then
            sameActivitySettings[data.activityId] = {}
        end
        table.insert(sameActivitySettings[data.activityId], data)
    end
    --print("-----------------  LimitedTimeDrawConfig:init:")
    --LogUtil.pv(settings)
end

---@return LimitedTimeDrawConfigData
function LimitedTimeDrawConfig:getCfgById(id)
    if not settings[id] then
        LogUtil.logError("can not find cfgLimitedTimeDrawConfig, id:", id )
        return
    end
    return TableUtil.copyTable(settings[id])
end

---@return LimitedTimeDrawConfigData[]
function LimitedTimeDrawConfig:getAllCfgs()
    return TableUtil.copyTable(settings)
end

---@return LimitedTimeDrawConfigData
function LimitedTimeDrawConfig:getSameActivityCfgByActivityId(activityId)
    if not sameActivitySettings[activityId] then
        LogUtil.logError("can not find getSameActivityCfgByActivityId, activityId:", activityId )
    end
    return TableUtil.copyTable(sameActivitySettings[activityId])
end

LimitedTimeDrawConfig:init()

return LimitedTimeDrawConfig

--[[LBX4gBKk5]]