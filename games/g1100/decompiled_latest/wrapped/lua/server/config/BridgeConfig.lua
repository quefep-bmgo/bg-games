--[[e3mkpQdCvWIAM6c8sCaVAujhU1RyGbDVOXhYZgnXrRb]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 2461
                          local checkFileName = "BridgeConfig.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[Bt5fvdKVtcYtNyKxIKGZccOa2ONkhcrDVXrKYsOiUGp]]---
--- Created by Jimmy.
--- DateTime: 2018/2/26 0026 11:32
---

BridgeConfig = {}
BridgeConfig.bridges = {}

function BridgeConfig:init(config)
    self:initBridge(config)
end

function BridgeConfig:initBridge(config)
    for i, v in pairs(config) do
        local bridge = {}
        local id = tonumber(v.id)
        bridge.id = id
        bridge.blockId = tonumber(v.blockId)
        bridge.len = tonumber(v.len)
        self.bridges[id] = bridge
    end
end

function BridgeConfig:buildBridge(id, yaw, pos)
    local bridge = self.bridges[id]
    if bridge == nil then
        return
    end
    yaw = yaw % 360
    local dx, dz = 0, 0
    if yaw <= 22.5 or yaw > 337.5 then
        dz = 1
        dx = 0
    end
    if yaw > 22.5 and yaw <= 67.5 then
        dz = 1
        dx = -1
    end
    if yaw > 67.5 and yaw <= 112.5 then
        dz = 0
        dx = -1
    end
    if yaw > 112.5 and yaw <= 157.5 then
        dz = -1
        dx = -1
    end
    if yaw > 157.5 and yaw <= 202.5 then
        dz = -1
        dx = 0
    end
    if yaw > 202.5 and yaw <= 247.5 then
        dz = -1
        dx = 1
    end
    if yaw > 247.5 and yaw <= 292.5 then
        dz = 0
        dx = 1
    end
    if yaw > 292.5 and yaw <= 337.5 then
        dz = 1
        dx = 1
    end
    for i = 1, bridge.len do
        local blockPos = VectorUtil.newVector3i(pos.x + dx * i, pos.y, pos.z + dz * i)
        local blockId = EngineWorld:getBlockId(blockPos)
        if blockId == BlockID.AIR then
            EngineWorld:setBlock(blockPos, bridge.blockId)
        end
    end
end

return BridgeConfig--[[qBCAwpZWcdYa3qBQrHCzW4MrHX7KeLAFt0NpU2LOj8]]---