---@class LimitedTimeDrawAwardsConfig
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

