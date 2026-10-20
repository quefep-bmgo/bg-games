--[[866fZoOROtr1GuDnfBP5ms2W354Rj6fcdgSSt95ttp4gVfCCC1YyvvBUmkiYY]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 3639
                          local checkFileName = "limitedTimeDrawAwardsConfig.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[Jus93iokkfK4M1y782tNS26hcEoZSBXGlcLeSV3lbeO0R8i5WkJL9cJtow6p0y1iBGwdUdA0eWUQw2iy5JHUqsVnApz5cl6slkZPOJuqJCbrLkfRrxi91huLwoOCu4aCfEOMOPgruU0GzLQSMUUYebj64maDOnWq03BOAF0a1y664wDC2EkfOsQe08AtN5ib4OzrRwJxbqkHUEjdjbbX34ltM4ZG1hhC3I77cc7LcFrlUBRVli7SFKlftektrmZNLMKuHyYRcryMEn1bhUZFwMjVgOn6QwLt0vGrMvJ]]---@class LimitedTimeDrawAwardsConfig
local LimitedTimeDrawAwardsConfig = T(Global, "LimitedTimeDrawAwardsConfig")

---@type LimitedTimeDrawAwardsConfigData[]
local settings = {}
local infallible = {}

function LimitedTimeDrawAwardsConfig:init()
    local config = FileUtil.getGameConfigFromCsv("pay_activity/limited_time_draw_awards.csv",2)
    for _, vConfig in pairs(config or {}) do
        ---@class LimitedTimeDrawAwardsConfigData
        local data = {
            id = tonumber(vConfig.n_id) or 0,
            pondId = tonumber(vConfig.n_pondId) or 0,
            infallible = StringUtil.split(vConfig.s_infallible or "", "#", false,true),
            giftContent = StringUtil.split(vConfig.s_giftContent, "#", false,true),
            weight = tonumber(vConfig.n_weight) or 0,
            quality = tonumber(vConfig.n_quality) or 0,
            isBigPrize = tonumber(vConfig.n_isBigPrize) == 1,
        }
        if not settings[data.pondId] then
            settings[data.pondId] = {}
        end
        table.insert(settings[data.pondId],data)
        if not infallible[data.pondId] then
            infallible[data.pondId] = {}
        end
        if #data.infallible > 0 then
            local info = TableUtil.copyTable(data)
            info.weight = 1
            for _, v in pairs(data.infallible) do
                if not infallible[data.pondId][v] then
                    infallible[data.pondId][v] = {}
                end
                table.insert(infallible[data.pondId][v],info)
            end
        end
    end
    --print("-----------------  LimitedTimeDrawAwardsConfig:init:")
    --LogUtil.pv(settings,5)
end

---@return LimitedTimeDrawAwardsConfigData[]
function LimitedTimeDrawAwardsConfig:getCfgByPondId(pondId)
    if not settings[pondId] then
        LogUtil.logError("can not find cfgLimitedTimeDrawAwardsConfig, pondId:", pondId )
        return
    end
    return TableUtil.copyTable(settings[pondId])
end

---@return LimitedTimeDrawAwardsConfigData[]
function LimitedTimeDrawAwardsConfig:getAllCfgs()
    return TableUtil.copyTable(settings)
end

---@return LimitedTimeDrawAwardsConfigData
function LimitedTimeDrawAwardsConfig:getPondInfallibleByPondIdAndCount(pondId, count)
    if not infallible[pondId] or not infallible[pondId][count] then
        return
    end
    return TableUtil.copyTable(infallible[pondId][count])
end

LimitedTimeDrawAwardsConfig:init()

return LimitedTimeDrawAwardsConfig

--[[1hh9DCmSuTZfmquvTOz23IJNTCT5vmNXpJ2Rn0llnPMzd2ltn0sPwiJc8GcZ3A5iEKpOL3zp85vBSV]]---