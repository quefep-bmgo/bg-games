--[[O3bJSklb9s0DwCoKThfEsvZnhW7EYMWunwmavOftqFNguVOQhpGqBpkApwYVp24W0PQEUdxgim1r7Lp]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 2647
                          local checkFileName = "FireBombSkill.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[Bt5fvdKVtcYtNyKxIKGZccOa2ONkhcrDVXrKYsOiUGp]]---@class FireBombSkill : BaseSkill
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

return FireBombSkill--[[9f35QoAoo74NDg4Y39GWWsmAitM0sPO5CoS7VbDNiF3HuAJLrcK6R7zYgoJ3ODMxGHbk9Jc1JoF0VLaTggmHTQUN2TCnbR53BX8VYSyX3gOw15e9MhY]]---