--[[iaREwkLsLMY250hSebjlugy56tMvkSlk3ltrwxYspMSeExvkY1RZ13N55zmGv20iNMa]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1556
                          local checkFileName = "ResourcesListener.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[kN8]]local ResourcesListener = {}
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
--[[2klWbQMopb]]