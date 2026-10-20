---@class TriggerGiftDescConfig
local TriggerGiftDescConfig = T(Global, "TriggerGiftDescConfig")
---@type TriggerGiftDescConfigData[]
local Settings = {}

function TriggerGiftDescConfig:init()
	local config = FileUtil.getConfigFromCsv("common/TriggerGiftDesc.csv", 2, true, true)
	for _, item in pairs(config) do
		---@class TriggerGiftDescConfigData
		local data = {
			index = item.index,
			giftId = item.giftId,
			duration = item.duration,
			topImage = item.topImage,
			price = tonumber(item.price),
			value = item.value,
			name = item.name,
			desc = item.desc,
			image = item.image,
			tabImage = item.tabImage,
			rewardGroupId = item.rewardGroupId
		}
		Settings[data.giftId] = data
	end
end

function TriggerGiftDescConfig:getAllCfg()
	return Settings
end

---@return TriggerGiftDescConfigData
function TriggerGiftDescConfig:getCfgById(id)
	return Settings[id]
end

TriggerGiftDescConfig:init()

return TriggerGiftDescConfig