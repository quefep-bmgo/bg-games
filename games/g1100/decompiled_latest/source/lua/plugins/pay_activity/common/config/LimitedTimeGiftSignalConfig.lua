---@class LimitedTimeGiftSignalConfig
local LimitedTimeGiftSignalConfig = T(Global, "LimitedTimeGiftSignalConfig")

---@type LimitedTimeGiftSignalConfigData[]
local SettingList = {}

function LimitedTimeGiftSignalConfig:init()
    local config = FileUtil.getGameConfigFromCsv("pay_activity/limited_time_gift_signal.csv",3)
    for _, vConfig in pairs(config) do
        ---@class LimitedTimeGiftSignalConfigData
        local data = {
            id = tonumber(vConfig.n_id) or 0,
            activityId = tonumber(vConfig.n_activityId) or 0,
            order = tonumber(vConfig.n_order) or 0,
            giftName = vConfig.s_giftName or "",
            initPrice = tonumber(vConfig.n_initPrice) or 0,
            finalPrice = tonumber(vConfig.n_finalPrice) or 0,
            percent = vConfig.s_percent or "",
            giftIcon = vConfig.s_giftIcon or "",
            giftNum = tonumber(vConfig.n_giftNum) or 0,
            repeatBuy = tonumber(vConfig.n_repeatBuy) or 0,
        }
        data.giftKey = data.activityId .. "-" .. data.id
        data.giftContent = StringUtil.split(vConfig.s_giftContent or "", "#", false,true)
        SettingList[data.id] = data
    end
    --print("LimitedTimeGiftSignalConfig:init  ")
    --LogUtil.pv(SettingList)
end

---@return LimitedTimeGiftSignalConfigData
function LimitedTimeGiftSignalConfig:getCfgById(id)
    if not SettingList[id] then
        LogUtil.logError("can not find cfgLimitedTimeGiftSignalConfig, id:", id )
        return
    end
    return SettingList[id]
end

---@return LimitedTimeGiftSignalConfigData[]
function LimitedTimeGiftSignalConfig:getAllCfgs()
    return SettingList
end

---@return LimitedTimeGiftSignalConfigData[]
function LimitedTimeGiftSignalConfig:getCfgByActivityId(activityId)
    local result = {}
    for _, val in pairs(SettingList) do
        if val.activityId == activityId then
            table.insert(result, val)
        end
    end
    return result
end

function LimitedTimeGiftSignalConfig:canRepeatBuy(id)
    local data=self:getCfgById(id)
    if data then
        return data.repeatBuy==1
    end
    return false
end

LimitedTimeGiftSignalConfig:init()

return LimitedTimeGiftSignalConfig

