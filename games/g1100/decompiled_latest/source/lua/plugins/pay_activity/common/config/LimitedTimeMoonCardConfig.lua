---@class LimitedTimeMoonCardConfig
local LimitedTimeMoonCardConfig = T(Global, "LimitedTimeMoonCardConfig")

---@type LimitedTimeMoonCardConfigData[]
local SettingList = {}

function LimitedTimeMoonCardConfig:init()
    local config = FileUtil.getGameConfigFromCsv("pay_activity/limited_time_moon_card.csv",3)
    for _, vConfig in pairs(config) do
        ---@class LimitedTimeMoonCardConfigData
        local data = {
            id = tonumber(vConfig.n_id) or 0,
            activityId = tonumber(vConfig.n_activityId) or 0,
            order = tonumber(vConfig.n_order) or 0,
            cardName = vConfig.s_cardName or "",
            img = vConfig.s_img or "",
            icon = vConfig.s_icon or "",
            finalPrice = tonumber(vConfig.n_finalPrice) or 0,
            percent = vConfig.s_percent or "",
            giftContent = tonumber(vConfig.n_giftContent) or 0,
            totalNum = tonumber(vConfig.n_totalNum) or 0,
            dayNum = tonumber(vConfig.n_dayNum) or 0,
        }
        data.giftKey = data.activityId .. "-" .. data.id
        SettingList[data.id] = data
    end
    --print("LimitedTimeMoonCardConfig:init  ")
    --LogUtil.pv(SettingList)
end

---@return LimitedTimeMoonCardConfigData
function LimitedTimeMoonCardConfig:getCfgById(id)
    if not SettingList[id] then
        LogUtil.logError("can not find cfgLimitedTimeGiftSignalConfig, id:", id )
        return
    end
    return SettingList[id]
end

---@return LimitedTimeMoonCardConfigData[]
function LimitedTimeMoonCardConfig:getAllCfgs()
    return SettingList
end

---@return LimitedTimeMoonCardConfigData[]
function LimitedTimeMoonCardConfig:getCfgByActivityId(activityId)
    local result = {}
    for _, val in pairs(SettingList) do
        if val.activityId == activityId then
            table.insert(result, val)
        end
    end
    return result
end


LimitedTimeMoonCardConfig:init()

return LimitedTimeMoonCardConfig

