--[[KZtrLR2vi1lNCIh0fKWz88MN4fAH4Y1f6haFZ5uYsMW1lQ6he2WUxdwgY9jmg0vPVy13aU6bbPsR7u38LlPWhfTux2Bcyw8gj96eouJmTiYxw3CXmLCryB9K1z5r8iuOYstr1zATppHfe2alVbhNii4gBbL9mAPU]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1447
                          local checkFileName = "ShopListener.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[rIOCCU]]local ShopListener = {}
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
--[[9ilttXhGmpE6]]---