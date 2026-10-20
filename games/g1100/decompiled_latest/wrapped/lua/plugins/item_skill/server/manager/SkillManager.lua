--[[70ywmNAkZg2dbCn72NQDhFJY8ZTnHHa9ssCUF2adKCTTeJe44J7268es0HbQpFq2910JPCf2o6ttSKHHjOemnJ9wz721vkVTyDP2GdWkfXP1dvg2YWjrrGUgLVBrkJSvUnQugFG6FjODeGFQXYncN32si0V]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 4468
                          local checkFileName = "SkillManager.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[Yse0UwcSWwMYGiHOKdTMN90I3aZNOWZKSb9wuj21QGkc1Qo]]---@class SkillManager
SkillManager = {}

---@type ReportValue
local ReportValue = T(Global, "ReportValue")

local SkillMapping = {}
SkillMapping[Define.SkillType.BridgeEgg] = "server.skill.BridgeEggSkill"
SkillMapping[Define.SkillType.FireBomb] = "server.skill.FireBombSkill"

SkillManager.HashCode = 1
SkillManager.Skills = {}

local function getSkillParams(player)
    local params = player.skillParams
    player.skillParams = nil
    return params
end

function SkillManager:init()
    for _, skill_config in pairs(SkillConfig:getAllSkillConfig()) do
        if type(SkillMapping[tostring(skill_config.type)]) == "string" then
            local dir = SkillMapping[tostring(skill_config.type)]
            SkillMapping[tostring(skill_config.type)] = Plugins.Require("item_skill", dir)
        end
    end

    LuaTimer:scheduleTimer(function()
        self:onTick()
    end, 100)
end

---@param config skill_config
---@param player SBasePlayer
function SkillManager:createSkill(config, player, position, itemEntityId)
    if not isGameStart then
        return
    end
    local skill = SkillMapping[config.type]
    if skill ~= nil and type(skill) == "table" then
        skill.new(config, player, position, itemEntityId, getSkillParams(player))
    end
end

function SkillManager:addSkill(skill)
    local uniqueId = tostring(self.HashCode)
    skill.uniqueId = uniqueId
    self.Skills[uniqueId] = skill
    self.HashCode = self.HashCode + 1
end

function SkillManager:onTick()
    for uniqueId, skill in pairs(self.Skills) do
        skill:onTick()
    end
end

function SkillManager:removeSkill(skill)
    if skill.uniqueId then
        self.Skills[skill.uniqueId] = nil
    end
end

function SkillManager:clearSkill()
    for i, skill in pairs(self.Skills) do
        skill = nil
    end
    self.Skills = {}
    self.HashCode = 1
end

function SkillManager:checkTopAreaIsAir(position)
    local first = VectorUtil.newVector3i(position.x, position.y + 1, position.z)
    local second = VectorUtil.newVector3i(position.x, position.y + 2, position.z)
    if EngineWorld:getBlockId(first) == BlockID.AIR and
            EngineWorld:getBlockId(second) == BlockID.AIR then
        return true, first
    end
    return false, first
end

function SkillManager:checkFarm(position, needRemove)
    for i, skill in pairs(self.Skills) do
        if skill.createPos
                and skill.createPos.x == position.x
                and skill.createPos.y == position.y
                and skill.createPos.z == position.z then
            if needRemove then
                skill:onRemove()
            end
            return true
        end
    end
    return false
end

function SkillManager:onSecond()
    for uniqueId, skill in pairs(self.Skills) do
        skill:onSecond()
    end
end

function SkillManager:onPlayerPotionEffectFinished(rakssid, potionId)
    for i, skill in pairs(self.Skills) do
        if skill.onPlayerPotionEffectFinished then
            skill:onPlayerPotionEffectFinished(rakssid, potionId)
        end
    end
end

function SkillManager:onBlockSkillBreak(userId, itemId, position)
    for uniqueId, skill in pairs(self.Skills) do
        if skill.itemId == itemId and skill.onBlockSkillBreak
                and skill.initPos.x == position.x
                and skill.initPos.y == position.y
                and skill.initPos.z == position.z then
            skill:onBlockSkillBreak(userId)
        end
    end
end

return SkillManager--[[rDHXL1AsWkxnMjtEfBCQ1uFplnu9NFizGuzIK55W0TnO0Q151HNqXG4xJ]]