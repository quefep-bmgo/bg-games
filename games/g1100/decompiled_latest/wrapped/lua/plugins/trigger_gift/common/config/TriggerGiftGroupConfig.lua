--[[O3bJSklb9s0DwCoKThfEsvZnhW7EYMWunwmavOftqFNguVOQhpGqBpkApwYVp24W0PQEUdxgim1r7Lp]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 2158
                          local checkFileName = "TriggerGiftGroupConfig.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[VPeLqNSF3qEQIOSN6C]]---@class TriggerGiftGroupConfig
local TriggerGiftGroupConfig = T(Global, "TriggerGiftGroupConfig")
---@type TriggerGiftGroupData[]
local Settings = {}

function TriggerGiftGroupConfig:init()
    local config = FileUtil.getConfigFromCsv("common/TriggerGiftGroup.csv", 2, true, true)
    for _, item in pairs(config) do
        ---@class TriggerGiftGroupData
        local data = {
            index = item.index,
            giftGroupId = item.giftGroupId,
            giftId = item.giftId,
        }
        if not Settings[data.giftGroupId] then
            Settings[data.giftGroupId] = {}
        end
        table.insert(Settings[data.giftGroupId], {
            rechargePoints = data.rechargePoints,
            giftId = data.giftId
        })
    end
end

function TriggerGiftGroupConfig:getAllCfg()
    return Settings
end

---@return TriggerGiftGroupData
function TriggerGiftGroupConfig:getCfgById(id)
    return Settings[id]
end

---@return number
function TriggerGiftGroupConfig:getGiftIdList(groupId)
    if not Settings[tostring(groupId)] then
        return {}
    end
    return Settings[tostring(groupId)]
end

TriggerGiftGroupConfig:init()

return TriggerGiftGroupConfig
--[[aDjW2tDLpeOOMZbr3kxrN3qbf54Xp3Jwki1hSomQmihJAtaoUdTVKzlxOZCJ1AmyRhmnDt9eEABYJj1LKva9xzFNT6IcAGqhsuGe4Bwg01CQJ2i9e87sNtpaE]]