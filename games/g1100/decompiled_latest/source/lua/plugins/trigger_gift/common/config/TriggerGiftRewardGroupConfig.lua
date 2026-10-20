---@class TriggerGiftRewardGroupConfig
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
