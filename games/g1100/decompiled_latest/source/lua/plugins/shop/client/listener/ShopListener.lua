local ShopListener = {}
---@type CShopMgr
local CShopMgr = T(Global, "CShopMgr")

function ShopListener:init()
    CEvents.AttackActorNpcEvent:registerCallBack(self.onAttackActorNpc)
end

function ShopListener.onAttackActorNpc(entityId)
    local entity = EntityCache:getEntity(entityId)
    if not entity then
        return false
    end
    local shopId = CShopMgr:getShopIdByEntityId(entityId)
    if shopId then
        UIHelper.showGameGUILayout("GUICustomShop", shopId)
    end
    return true
end

ShopListener:init()
