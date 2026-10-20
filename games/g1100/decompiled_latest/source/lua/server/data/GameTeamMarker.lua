---
--- Created by Jimmy.
--- DateTime: 2017/10/19 0019 15:36
---
---@class GameTeamMarker
local GameTeamMarker = class("GameTeamMarker")

---@param config TeamConfigInfo
function GameTeamMarker:ctor(teamId, isTeamMatch)
    self.teamId = teamId
    self.isTeamMatch = isTeamMatch
    self.existence = false
    self.isDestroyed = false
    self.itemId = nil
    self.meta = nil
    self.pos = nil
    self.entityId = nil
end

function GameTeamMarker:CreateMarkerBlockAndActor(player)
    self:DestroyMarkerBlockAndActor(player ~= nil)
    self.isDestroyed = false

    -- player 不为nil时是编辑模式放置了一个方块
    if self.itemId == ItemID.BED then
        local pos1 = self:getBedOtherPos()
        if player then
            self.meta = math.floor((player:getYaw() * 4.0 / 360.0) + 0.5) & 3
            pos1 = self:getBedOtherPos()
            if EngineWorld:getBlockId(self.pos) ~= BlockID.AIR or EngineWorld:getBlockId(pos1) ~= BlockID.AIR then
               return false
            end
        end
        EngineWorld:setBlock(self.pos, BlockID.BED, self.meta, 3)
        EngineWorld:setBlock(pos1, BlockID.BED, self.meta + 8, 3)
    else
        EngineWorld:setBlock(self.pos, self.itemId, self.meta)
    end

    local p = VectorUtil.add3(self.pos, VectorUtil.newVector3(0.5, 1, 0.5))
    self.entityId = EngineWorld:addActorNpc(p, 0, "empty.actor", function(entity)
        entity:setFlying(true)
        
        local showName = nil
        if self.isTeamMatch then
            if BaseMain:isChina() then
                showName = "队伍"
            else
                showName = "Team"
            end
            showName = TextFormat.colorStart .. "FF" .. Define.TeamFlagColor[self.teamId] .. showName .. tostring(self.teamId) .. TextFormat.colorEnd
        else
            showName = "P" .. tostring(self.teamId)
        end
        showName = showName .. "\n \n \n \n \n"
        entity:setHeadName(showName)

        local builder = DataBuilder.new()
        builder:addVector3Param("offset", VectorUtil.newVector3(0, 1, 0))
        if self.isTeamMatch then
            builder:addParam("effectName", Define.MarkerEffect[self.teamId])
        else
            builder:addParam("effectName", "mark_Red.effect")
        end
        entity:addCustomEffect("Effect", builder:getData(), -1, 1.5)
    end)
    return true 
end

function GameTeamMarker:DestroyMarkerBlockAndActor(deleteBlock)
    self.isDestroyed = true
    if self.entityId then
        EngineWorld:removeEntity(self.entityId)
        self.entityId = nil
    end
    if deleteBlock == true then
        if self.itemId == ItemID.BED then
            local pos1 = self:getBedOtherPos()
            EngineWorld:setBlockToAir(pos1)
        end
        EngineWorld:setBlockToAir(self.pos)
    end
end

function GameTeamMarker:IsEqual(vec3)
    if self.isDestroyed then
        return false
    end
    if VectorUtil.equal(vec3, self.pos) then
        return true
    end
    if self.itemId == ItemID.BED then
        local pos1 = self:getBedOtherPos()
        if VectorUtil.equal(vec3, pos1) then
            return true
        end
    end
    return false
end

function GameTeamMarker:getBedOtherPos()
    local offset = VectorUtil.newVector3i(0, 0, 0)
    if self.meta == 0 then
        offset.z = 1
    elseif self.meta == 1 then
        offset.x = -1
    elseif self.meta == 2 then
        offset.z = -1
    elseif self.meta == 3 then
        offset.x = 1
    end
    return VectorUtil.add3i(self.pos, offset)
end

return GameTeamMarker