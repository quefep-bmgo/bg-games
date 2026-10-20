--[[qaDj3pq8CPJE45KdUJLXj6gDgjolV1QmKqLAsbBuuk0i9DetLqNE6hYZXgUnT]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1977
                          local checkFileName = "ShopListener.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[ouXGLK3WFKmDSEKVJ43ps4ms0AA50i79WTYj9]]local ShopListener = {}
---@type SShopMgr
local SShopMgr = T(Global, "SShopMgr")

local function getItemYaw(yaw)
    yaw = yaw % 360
    yaw = yaw < 0 and 360 + yaw or yaw
    if yaw > 315 or yaw <= 45 then
        return 0
    elseif yaw > 45 and yaw <= 135 then
        return 90
    elseif yaw > 135 and yaw <= 225 then
        return 180
    elseif yaw > 225 and yaw <= 315 then
        return 270
    end
end

function ShopListener:init()
    CEvents.PlayerPlaceBlockEvent:registerCallBack(self.onPlayerBlockPlace)
end

function ShopListener.onPlayerBlockPlace(rakssid, itemId, meta, toPlacePos)
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if not player then
        return false, false
    end
    if itemId == Define.NpcItemId then
        local yaw = VectorUtil.getDirection(toPlacePos, player:getPosition())
        yaw = getItemYaw(yaw)
        local pos = VectorUtil.add3(toPlacePos, VectorUtil.newVector3(0.5, 0, 0.5))
        SShopMgr:tryPlaceShopNpc(player.userId, pos, yaw)
        return false, true
    end
    return false, false
end

ShopListener:init()
--[[qBCAwpZWcdYa3qBQrHCzW4MrHX7KeLAFt0NpU2LOj8]]---