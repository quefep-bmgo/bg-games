---@class BridgeEggSkill : BaseSkill
local BridgeEggSkill = class("BridgeEggSkill", Plugins.Require("item_skill", "server.skill.BaseSkill"))

function BridgeEggSkill:createSkillEffect(name, time)
    ---@type GamePlayer
    local self_player = PlayerManager:getPlayerByUserId(self.creatorUid)
    if not self_player then
        return
    end
    self_player.useBridgeEggTime = os.time()
end

function BridgeEggSkill:onPlayerEffected(player)

end

function BridgeEggSkill:onDestroy()

end

return BridgeEggSkill