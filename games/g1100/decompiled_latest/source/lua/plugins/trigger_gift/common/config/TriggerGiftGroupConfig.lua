---@class TriggerGiftGroupConfig
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
