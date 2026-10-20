---@class FireBombSkill : BaseSkill
local FireBombSkill = class("FireBombSkill", Plugins.Require("item_skill", "server.skill.BaseSkill"))

function FireBombSkill:doAction()
    local self_player = PlayerManager:getPlayerByUserId(self.creatorUid)
    local entity = EngineWorld:getEntity(self.itemEntityId)
    if not self_player or not entity then
        return
    end
    local pos = VectorUtil.newVector3(self.initPos.x, self.initPos.y, self.initPos.z)
    local damage = self.damage --* (1 + (self_player.propED[tostring(ItemID.FLARE_BOMB)] or 0))
    -- if self_player.extraFireBallDamage[tostring(entity.entityId)] then
    --     damage = self_player.extraFireBallDamage[tostring(entity.entityId)]
    --     self_player.extraFireBallDamage[tostring(entity.entityId)] = nil
    -- end
    --damage = damage * (1 + self_player.info:getValue(Define.BattleAttr.AddFlareBombDamageFactor, true) or 0)
    print(" =================== FireBombSkill:doAction " .. damage)
    if GameType ~= "g1063" then
        EngineWorld:getWorld():newExplosion(entity, self_player:getEntityPlayer(), pos, damage, true, true, self.duration, self.itemId)
        EngineWorld:addSimpleEffect("explosion.effect", pos, self_player:getYaw(), 1000, 0, 1)
        Events.FireBombExplosionEvent:invoke(pos)
    else
        pos = VectorUtil.newVector3(1081, 75, 882.5)
        EngineWorld:getWorld():newExplosion(entity, self_player:getEntityPlayer(), pos, damage, true, true, self.duration, self.itemId)
        self_player:sendPacket({
            pid = "doClientFireBombSkill",
            pos = pos,
            yaw = self_player:getYaw(),
        })
    end
end

return FireBombSkill