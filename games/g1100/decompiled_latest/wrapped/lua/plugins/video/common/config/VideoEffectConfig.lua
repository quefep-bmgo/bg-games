--[[qaDj3pq8CPJE45KdUJLXj6gDgjolV1QmKqLAsbBuuk0i9DetLqNE6hYZXgUnT]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 2228
                          local checkFileName = "VideoEffectConfig.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[Anxw7B6o5PkUiGsIhWJjZ0fc7tn3GnmlkjbMvjuQudEmdXRrbBxmG9elYjIBiF1Bw0BbH1n5r6ROeFHVg6n7kABHMMvyTBI3aLfjRVi2Wxa9qv3DutrzKZPmFFUZ80kkUyz0MQlrsU0mbu4kz433HTM]]---@class VideoEffectConfig
local VideoEffectConfig = T(Global, "VideoEffectConfig")
---@type VideoEffectConfigData[][]
local Settings = {}

function VideoEffectConfig:init()
    local config = FileUtil.getGameConfigFromCsv("video/VideoEffect.csv", 2)
    config = config or FileUtil.getConfigFromCsv("common/VideoEffect.csv", 2, true, true)
    for _, item in pairs(config) do
        ---@class VideoEffectConfigData
        local data = {
            tabId = tonumber(item.tabId),
            sortIndex = tonumber(item.sortIndex),
            icon = item.icon or "",
            titleLang = item.titleLang or "",
            eventType = item.eventType,
            param = item.param,
        }
        if not Settings[data.tabId] then
            Settings[data.tabId] = {}
        end
        Settings[data.tabId][data.sortIndex] = data
    end
end

function VideoEffectConfig:getAllCfg()
    return Settings
end

---@return VideoEffectConfigData[]
function VideoEffectConfig:getCfgByTabId(tabId)
    return Settings[tabId] or {}
end

---@return VideoEffectConfigData
function VideoEffectConfig:getCfg(tabId, sortIndex)
    return self:getCfgByTabId(tabId)[sortIndex]
end

VideoEffectConfig:init()

return VideoEffectConfig--[[TCJZpGo0x0texkQDTzfLvUOoQP9bsRHNOEc1lCHnsu]]