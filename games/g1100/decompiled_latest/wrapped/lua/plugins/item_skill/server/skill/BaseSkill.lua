--[[O6I6vUH27X9zho1b4hKN2qCQsaOBSLMAFEKQXQFav0J2i3Tl3RzKVz0wm04XS]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 8280
                          local checkFileName = "BaseSkill.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[lPqnE1KrnUWLkKGBXiuZ6JZSOLC7XudtrDMOog25aK5guItDoAiFlNtWXaV41yMQxtzEcl09WRE34phOSNIuruljtZOVBY3T0rXnAT]]--require "config.SkillEffectConfig"

---@class BaseSkill
local BaseSkill = class()

BaseSkill.TARGET_OWN = "1"
BaseSkill.TARGET_TEAMMATE = "2"
BaseSkill.TARGET_ENEMY = "3"

---@param config skill_config
function BaseSkill:ctor(config, player, initPos, itemEntityId, params)
    self.uniqueId = nil
    self.id = config.id
    self.itemId = config.itemId
    self.createTime = os.time()
    self.length = config.length
    self.width = config.width
    self.height = config.height
    self.isMoment = config.isMoment
    self.effectNum = config.effectNum
    self.duration = config.duration
    self.effectCd = config.effectCd
    self.type = config.type
    self.potionLevel = config.potionLevel
    self.damage = config.damage
    self.config = config
    self.creatorUid = player.userId
    self.itemEntityId = itemEntityId
    self.initPos = initPos
    self.targets = {}
    self.params = params or {}
    self:initArea()
    self:initTargetPlayers(config.targets)
    self:createSkillEffect(config.hitEffectName, config.hitEffectTime)
    self:onCreate()
    if player.gameDataController then
        player.gameDataController:bw_new_player_use_item(self.itemId)
    end
end

function BaseSkill:getCreator()
    return PlayerManager:getPlayerByUserId(self.creatorUid)
end

function BaseSkill:initArea()
    self.minX = self.initPos.x - self.length
    self.minY = self.initPos.y - self.height
    self.minZ = self.initPos.z - self.width
    self.maxX = self.initPos.x + self.length
    self.maxY = self.initPos.y + self.height
    self.maxZ = self.initPos.z + self.width
end

function BaseSkill:inArea(position)
    return position.x >= self.minX and position.x <= self.maxX
            and position.y >= self.minY and position.y <= self.maxY
            and position.z >= self.minZ and position.z <= self.maxZ
end

function BaseSkill:initTargetPlayers(targets)
    local creator = self:getCreator()
    local players = PlayerManager:getPlayers()
    for i, target in pairs(targets) do
        if target == BaseSkill.TARGET_OWN then
            self.targets[#self.targets + 1] = creator.userId
        end
        if target == BaseSkill.TARGET_TEAMMATE then
            for _, player in pairs(players) do
                if player ~= creator and creator:getTeamId() == player:getTeamId() then
                    self.targets[#self.targets + 1] = player.userId
                end
            end
        end
        if target == BaseSkill.TARGET_ENEMY then
            for _, player in pairs(players) do
                if player:getTeamId() ~= creator:getTeamId() then
                    self.targets[#self.targets + 1] = player.userId
                end
            end
        end
    end
end

function BaseSkill:createSkillEffect(name, time)
    local creator = self:getCreator()
    if #name > 6 and time > 0 then
        EngineWorld:addSimpleEffect(name, self.initPos, creator:getYaw(), time)
    end
end

function BaseSkill:onCreate()
    SkillManager:addSkill(self)
    self:doAction()
    if self.isMoment then
        self:onRemove()
    end
end

function BaseSkill:onTick(frameTime)

end

function BaseSkill:onSecond()

end

function BaseSkill:getLastTime()
    return self.duration - (os.time() - self.createTime)
end

function BaseSkill:getEffectPlayers()
    local maxNum = self.effectNum
    local players = {}
    for _, target in pairs(self.targets) do
        local player = PlayerManager:getPlayerByUserId(target)
        if player ~= nil and (GameType == "g1046" or player.isLife) then
            local position = player:getPosition()
            if self:inArea(position) then
                table.insert(players, player)
            end
        end
    end
    maxNum = math.min(maxNum, #players)
    local deleteNum = #players - maxNum
    while deleteNum > 0 do
        table.remove(players, math.random(1, #players))
        deleteNum = deleteNum - 1
    end
    return players
end

function BaseSkill:doAction()
    local players = self:getEffectPlayers()
    for _, player in pairs(players) do
        self:onPlayerEffected(player)
    end
end

function BaseSkill:onPlayerEffected(player)

end

function BaseSkill:onRemove()
    if self.uniqueId ~= nil then
        self:onDestroy()
        SkillManager:removeSkill(self)
        self.uniqueId = nil
    end
end

function BaseSkill:onDestroy()

end

function BaseSkill:telePos(player)
    local range = 0
    local position = self.initPos
    if player == nil then
        return
    end
    local pos, isAir, tpPos
    pos = VectorUtil.toBlockVector3(position.x, position.y, position.z)
    isAir, tpPos = SkillManager:checkTopAreaIsAir(pos)
    if isAir then
        player:teleportPos(tpPos)
        return
    end
    range = 1
    while not isAir and range <= 5 do
        if not isAir then
            pos = VectorUtil.toBlockVector3(position.x - range, position.y, position.z)
            isAir, tpPos = SkillManager:checkTopAreaIsAir(pos)
            if isAir then
                player:teleportPos(tpPos)
            end
        end
        if not isAir then
            pos = VectorUtil.toBlockVector3(position.x, position.y, position.z + range)
            isAir, tpPos = SkillManager:checkTopAreaIsAir(pos)
            if isAir then
                player:teleportPos(tpPos)
            end
        end
        if not isAir then
            pos = VectorUtil.toBlockVector3(position.x + range, position.y, position.z - range)
            isAir, tpPos = SkillManager:checkTopAreaIsAir(pos)
            if isAir then
                player:teleportPos(tpPos)
            end
        end
        if not isAir then
            pos = VectorUtil.toBlockVector3(position.x - range, position.y, position.z + range)
            isAir, tpPos = SkillManager:checkTopAreaIsAir(pos)
            if isAir then
                player:teleportPos(tpPos)
            end
        end
        if not isAir then
            pos = VectorUtil.toBlockVector3(position.x + range, position.y, position.z + range)
            isAir, tpPos = SkillManager:checkTopAreaIsAir(pos)
            if isAir then
                player:teleportPos(tpPos)
            end
        end
        if not isAir then
            pos = VectorUtil.toBlockVector3(position.x - range, position.y, position.z - range)
            isAir, tpPos = SkillManager:checkTopAreaIsAir(pos)
            if isAir then
                player:teleportPos(tpPos)
            end
        end
        if not isAir then
            range = range + 1
        end
    end
end

function BaseSkill:getYaw(facePos, fromPos)
    local vector = math.atan2(facePos.x - fromPos.x, facePos.z - fromPos.z)
    return vector / math.pi * -180
end

function BaseSkill:knockBackPlayer(player, hurtFromPos, strength)
    local yaw = self:getYaw(player:getPosition(), hurtFromPos)
    local x = math.sin(yaw * MathUtil.DEG2RAD)
    local z = -math.cos(yaw * MathUtil.DEG2RAD)
    if player.entityPlayerMP ~= nil then
        player.entityPlayerMP:knockBack(player.entityPlayerMP, strength, x, z)
    end
end

function BaseSkill:onFailed(lang)
    local player = PlayerManager:getPlayerByUserId(self.creatorUid)
    if not player then
        return
    end
    player.entityPlayerMP:resetSkillItemCd(self.itemId)
    player:sendPacket({
        pid = "ResetItemSkillCd",
        itemId = self.itemId,
        lang = lang
    })
end

return BaseSkill--[[9ilttXhGmpE6]]