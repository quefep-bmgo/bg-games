--[[V]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1409
                          local checkFileName = "ServerPlayer.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[kN8]]---@type SBasePlayer
local BasePlayer = BasePlayer
---@type LuckyBlockConfig
local LuckyBlockConfig = T(Global, "LuckyBlockConfig")

function BasePlayer:getLuckyBlock(blockId, pos)
    local block = LuckyBlockConfig:getBlockById(blockId)
    if block == nil then
        -- print("can't find luck block [blockId]:" .. blockId)
        return
    end
    local items = LuckyBlockConfig:randomGoods(block.poolId, 1)
    pos = VectorUtil.newVector3(pos.x + 0.5, pos.y, pos.z + 0.5)
    for _, item in pairs(items) do
        EngineWorld:addEntityItem(item.itemId, item.count, item.itemMeta, 10000, pos)
    end
end

return BasePlayer--[[HgAp685chSirR8USFvEAAMqc5eWuj3Gs]]---