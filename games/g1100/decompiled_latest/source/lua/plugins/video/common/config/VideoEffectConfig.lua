---@class VideoEffectConfig
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

return VideoEffectConfig