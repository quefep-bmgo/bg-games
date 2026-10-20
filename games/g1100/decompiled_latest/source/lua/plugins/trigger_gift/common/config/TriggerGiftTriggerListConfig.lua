---@class TriggerGiftTriggerListConfig
local TriggerGiftTriggerListConfig = T(Global, "TriggerGiftTriggerListConfig")
---@type TriggerGiftTriggerListData[]
local Settings = {}
local activeSetting = {}

--- 每种条件的参数配置初始化
local CHECK_GIFT_CONFIG = {
    ---@param data TriggerGiftTriggerListData
    [Define.TriggerGiftKey.Level] = function(data)
        data.param = tonumber(data.param)
    end,

    ---@param data TriggerGiftTriggerListData
    [Define.TriggerGiftKey.UseDiamonds] = function(data)
        data.param = StringUtil.split(data.param, "~", false, true)
        if data.param2 ~= "#" then
            local _, _, year, month, day, hour, min, sec = string.find(data.param2, "(%d+)-(%d+)-(%d+)-(%d+)-(%d+)-(%d+)")
            data.startDate = DateUtil.date2BeiJingTime({ year = year, month = month, day = day, hour = hour, min = min, sec = sec })
        else
            data.startDate = nil
        end
    end,

    ---@param data TriggerGiftTriggerListData
    [Define.TriggerGiftKey.UseMaxDiamonds] = function(data)
        data.param = StringUtil.split(data.param, "~", false, true)
        if data.param2 ~= "#" then
            local _, _, year, month, day, hour, min, sec = string.find(data.param2, "(%d+)-(%d+)-(%d+)-(%d+)-(%d+)-(%d+)")
            data.startDate = DateUtil.date2BeiJingTime({ year = year, month = month, day = day, hour = hour, min = min, sec = sec })
        else
            data.startDate = nil
        end
    end,
}

function TriggerGiftTriggerListConfig:init()
    local config = FileUtil.getConfigFromCsv("common/TriggerGiftTriggerList.csv", 2, true, true)
    for _, item in pairs(config) do
        ---@class TriggerGiftTriggerListData
        local data = {
            index = item.index,
            triggerId = item.triggerId,
            activityId = tonumber(item.activityId) or -1,
            trigger = tonumber(item.trigger),
            param = item.param,
            param2 = item.param2,
            createTime = tonumber(item.createTime or 0),
            cd = tonumber(item.cd),
            giftId = item.giftId
        }

        CHECK_GIFT_CONFIG[data.trigger](data)
        Settings[data.triggerId] = data
        activeSetting[data.activityId] = activeSetting[data.activityId] or {}
        activeSetting[data.activityId][data.triggerId] = data
    end
end

function TriggerGiftTriggerListConfig:getAllCfg()
    return Settings
end

---@return TriggerGiftTriggerListData
function TriggerGiftTriggerListConfig:getCfgById(triggerId)
    return Settings[triggerId]
end

function TriggerGiftTriggerListConfig:getCfgListByActivityId(activityId)
    return activeSetting[activityId]
end

TriggerGiftTriggerListConfig:init()

return TriggerGiftTriggerListConfig
