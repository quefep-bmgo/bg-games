--[[N]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1274
                          local checkFileName = "BridgeEggSkill.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[FN5JZBViNkg]]---@class BridgeEggSkill : BaseSkill
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

return BridgeEggSkill--[[TE0MH]]