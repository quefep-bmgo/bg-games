--[[e6RXHBBftDPt8jrPTAFeMqMLe7gvAa4jroDLBfNGxEXMuRkMsrRi3]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 2517
                          local checkFileName = "TriggerGiftRewardGroupConfig.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[6IYeYAsgeuLtDjWiH9UKfHpZJxZ8rzQGbBrDxQaOrxSjgu2nEnSwkqYXKsxQvGlm0mhzTTFWhI43xDzBtZvo4R7iiCTgVUqgALbEIsJMN85rGlz1x1t2YGnchc60DaDeJPUcyzmeZSgU9QponDtCCjtZLXfSOa2okMHvJBDESmt9wgHzykAN1FXKy8pBY3lOWtLngLtPsz0avAjMSWGa1uTfFgDui5RQHf2wuvvDzO1sUCtz8qRLCG2ZW13]]---@class TriggerGiftRewardGroupConfig
local TriggerGiftRewardGroupConfig = T(Global, "TriggerGiftRewardGroupConfig")
---@type TriggerGiftRewardGroupData[]
local Settings = {}

function TriggerGiftRewardGroupConfig:init()
    local config = FileUtil.getConfigFromCsv("common/TriggerGiftRewardGroup.csv", 2, true, true)
    for _, item in pairs(config) do
        ---@class TriggerGiftRewardGroupData
        local data = {
            seq = item.seq,
            rewardGroupId = item.rewardGroupId,
            realId = item.realId,
            num = tonumber(item.num),
            image = item.image,
            quality = item.quality,
            imageScale = tonumber(item.imageScale),
            type = item.type,
            name = item.name or "",
            desc = item.desc or "",
        }
        if data.num > 0 then
            if not Settings[data.rewardGroupId] then
                Settings[data.rewardGroupId] = {}
            end
            table.insert(Settings[data.rewardGroupId], data)
        end
    end
end

function TriggerGiftRewardGroupConfig:getAllCfg()
    return Settings
end

---@return TriggerGiftRewardGroupData
function TriggerGiftRewardGroupConfig:getCfgByGroupId(rewardGroupId)
    return Settings[rewardGroupId]
end

TriggerGiftRewardGroupConfig:init()

return TriggerGiftRewardGroupConfig
--[[PixKFDZsVVU2QD7d3drx0nXleUyhUdxtGgttmsylpDD0x9gH3cWxJH0kdBB5u9FJUVWpY61rueWObrAIYfU6mr9hxHKZOD6aQLIiGQc5fS7aQMlUPddAMUMDAo]]---