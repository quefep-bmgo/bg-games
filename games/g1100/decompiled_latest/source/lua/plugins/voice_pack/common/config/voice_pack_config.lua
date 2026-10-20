---@class VoicePackConfig
local VoicePackConfig = T(Global, "VoicePackConfig")
---@type VoicePackConfigItem[]
local settings = {}

---@private
function VoicePackConfig:init()
	local path = FileUtil:getMapPath() .. "plugins/voice_pack/voice_pack.csv"
	local file = io.open(path, "r")
	if not file then
		return
	end
	file:close()
	local csvData = CsvUtil.loadCsvFile(path, 2)
	for _, config in pairs(csvData) do
		---@class VoicePackConfigItem
		local data = {
			id = tonumber(config.n_id), ---序号
			soundType = tonumber(config.n_soundType), ---音效id
			time = tonumber(config.n_time), ---时长
			name = config.s_name, ---名字
		}
		settings[data.id] = data
	end
end

---@return VoicePackConfigItem[]
function VoicePackConfig:getAllCfgs()
	return settings
end

---@return VoicePackConfigItem
function VoicePackConfig:getCfgById(id)
	return settings[id]
end

VoicePackConfig:init()
