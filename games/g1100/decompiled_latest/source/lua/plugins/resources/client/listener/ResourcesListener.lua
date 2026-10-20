local ResourcesListener = {}
---@type CResourcesMgr
local CResourcesMgr = T(Global, "CResourcesMgr")

function ResourcesListener:init()
    CEvents.AttackActorNpcEvent:registerCallBack(self.onAttackActorNpc)
end

function ResourcesListener.onAttackActorNpc(entityId)
    local entity = EntityCache:getEntity(entityId)
    if not entity then
        return false
    end
    local customGame = T(Global, "customGame")
    local resourcesId = CResourcesMgr:getResourcesIdByEntityId(entityId)
    if resourcesId and customGame.gameMode ~= Define.CustomGameMode.RUN then
        UIHelper.showGameGUILayout("GUICustomResourceEdit", resourcesId)
        return false, true
    end
    return true, false
end

ResourcesListener:init()
