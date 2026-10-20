--[[F1PDMCCROPwYNtfZS3i8hbcKqUAXxq8ObGEcnjqNVLxuL6TYDkoBWv47R4py0AP8NMA1zhRdDCqQU1IOdgAreIn84Je2t9DG9RgoIVBM5bY7ggsvKpGHbdw1gCe2EiU8SEfAWUi0oqmvRJuvnsyc18NbJfLJZ5WBCDSrCD56WdzwS6hPuTx0CyfHCxxhvv98qYskqQC7wzKrgDy8nPNFytcNDQXV6PcqsbqrZbm]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 4927
                          local checkFileName = "SkillConfig.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[wqXdcTNzDY]]---
--- Created by Jimmy.
--- DateTime: 2018/6/13 0013 11:00
---
SkillConfig = {}
---@type skill_config[]
local skill_config_list = {}

function SkillConfig:init()
    local skills = FileUtil.getGameConfigFromCsv("skill/SkillConfig.csv", nil, true)
    for id, skill in pairs(skills) do
        ---@class skill_config
        local item = {}
        item.id = id
        item.type = skill.Type
        item.itemId = tonumber(skill.ItemId)
        item.atlasName = tostring(skill.AtlasName)
        item.iconName = tostring(skill.IconName)
        item.isParabola = tonumber(skill.IsParabola)
        item.moveSpeed = tonumber(skill.MoveSpeed)
        item.dropSpeed = tonumber(skill.DropSpeed)
        item.distance = tonumber(skill.Distance)
        item.freeCd = tonumber(skill.FreeCd)
        item.length = tonumber(skill.Length)
        item.width = tonumber(skill.Width)
        item.height = tonumber(skill.Height)
        item.duration = tonumber(skill.Duration)
        item.damage = tonumber(skill.Damage)
        item.targets = StringUtil.split(skill.targets, "#")
        item.effectNum = tonumber(skill.effectNum)
        item.isMoment = tonumber(skill.isMoment or "0") == 1
        item.effectCd = tonumber(skill.effectCd)
        item.effectName = tostring(skill.EffectName)
        item.hitEffectName = tostring(skill.HitEffectName)
        item.hitEffectTime = tonumber(skill.HitEffectTime)
        item.canFallNoUse = tonumber(skill.CanFallNoUse)
        item.canFallNoUseTip = tonumber(skill.CanFallNoUseTip)
        item.isConsume = tonumber(skill.isConsume or "0") == 1
        item.param = StringUtil.split(skill.param or "", "#")
        item.HallRelease = tonumber(skill.HallRelease or "0") == 1
        local useType = skill.UseType
        item.isLongTouch = useType == "0"
        item.isPlaceBlock = useType == "2"
        item.isFood = useType == "3"
        item.isChoiceTeam = useType == "4"
        item.isBlockSkill = useType == "5"
        if GameType == "g1046" then
            if item.HallRelease then
                skill_config_list[id] = item
            end
        else
            skill_config_list[id] = item
        end
    end
    if not isClient then
        self:prepareSkills()
    end
end

function SkillConfig:prepareSkills()
    for id, skill in pairs(skill_config_list) do
        if not skill.isFood then
            HostApi.addSkillItem(SkillConfig.newSkillItem(skill))
        end
    end
end

function SkillConfig.newSkillItem(item)
    local setting = SkillItem.new()
    setting.SkillId = tonumber(item.id)
    setting.Occupation = 0
    setting.ItemId = item.itemId
    setting.ItemSkillCd = item.freeCd
    setting.ItemSkillDistace = item.distance
    setting.MoveSpeed = item.moveSpeed
    setting.DropSpeed = item.dropSpeed
    setting.AtlasName = item.atlasName
    setting.ItemIconName = item.iconName
    setting.EffectName = item.effectName
    setting.Parabola = item.isParabola > 0
    setting.CanFallNoUse = item.canFallNoUse > 0
    setting.CanFallNoUseTip = item.canFallNoUseTip
    setting.SkillDuration = item.duration
    setting.IsLongTouch = item.isLongTouch
    return setting
end

---@return skill_config
function SkillConfig:getSkill(itemId)
    for _, skill in pairs(skill_config_list) do
        if skill.itemId == itemId then
            return skill
        end
    end
    return nil
end

function SkillConfig:getSkillByType(type)
    for _, skill in pairs(skill_config_list) do
        if skill.type == type then
            return skill
        end
    end
    return nil
end

function SkillConfig:getSkillById(id)
    return skill_config_list[tostring(id)]
end

function SkillConfig:getAllSkillConfig()
    return skill_config_list
end

SkillConfig:init()

return SkillConfig--[[9iSgLHFjlWNrluX5G7botj0U12vvgL5Y5QXlieOotnw2YIU1Zro51NS5ayJ6c8YX2sre092ySjfppZXPI3LCNUaUWBccfUh5z0O26cnzDYlyqun41nt6maWmtKVqq5SSjgZepmgMQXaAnyJX26Ad42HCEbAgqVmUioRJzF3hq03AJXFrNa2Nr]]---