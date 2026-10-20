--[[JWPv0lMgrX3iICVcfSCFGSE4JFsYWinRqDu7Y0z]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1871
                          local checkFileName = "ResourcesListener.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[wtvBZxSs9yHwv3V8vrLIKeEgFs20yN8fsyzNtcG1S4bdJVhMtWxJUvLxLx0IX0noUH9kLAPVnXiIA44ywRZUbWILfWf9xaza4BOxDdP8SC57kXXBhoQfeOcWHfR4dbElvrpe5PsGoAPu7d7DjeB]]local ResourcesListener = {}
---@type SResourcesMgr
local SResourcesMgr = T(Global, "SResourcesMgr")

function ResourcesListener:init()
    CEvents.PlayerPlaceBlockEvent:registerCallBack(self.onPlayerBlockPlace)
end

function ResourcesListener.onPlayerBlockPlace(rakssid, itemId, meta, toPlacePos)
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if not player then
        return false, false
    end
    if itemId == Define.ResourceItemId then
        local customGame = T(Global, "customGame")
        if customGame:getGameMode() ~= Define.CustomGameMode.RUN then
            local pos = VectorUtil.add3(toPlacePos, VectorUtil.newVector3(0.5, 0, 0.5))
            SResourcesMgr:tryPlaceResources(player.userId, pos)
        end
        return false, true
    end
    if not SResourcesMgr:canPlaceBlock(toPlacePos) then
        return false, true
    end
    return false, false
end

ResourcesListener:init()
--[[2klWbQMopb]]---