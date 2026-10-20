--[[d34zMi6mxo9PbTLsGEvM]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 3969
                          local checkFileName = "BlockListener.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[jJh3Rc69zIgx6boXurvh4hqUSqdR54YQ6P7SAaXp]]local BlockListener = {}

function BlockListener:init()
    CEvents.PlayerDamageBlockEvent:registerCallBack(self.onBlockBreakWithMeta)
    CEvents.UseItemBucketInBlockEvent:registerCallBack(self.onUseItemBucketInBlock)
    CEvents.ClickToBlockEvent:registerCallBack(self.onClickToBlock)
    CEvents.PlayerPlaceBlockEvent:registerCallBack(self.checkPlaceBlock)
end

function BlockListener.onBlockBreakWithMeta(pos, blockId, damage, curDamage)
    local customGame = T(Global, "customGame")
    local value = customGame:getFastBreakBlock()
    if value then 
        damage.value = 1.0
    else
        damage.value = -1.0
    end
end

local function isSpecialBlock(itemId)
    return itemId == 46 or itemId == 8 or itemId == 10 or itemId == 326 or itemId== 327
end

function BlockListener.onUseItemBucketInBlock(entityId, itemId, vec3i)
    local customGame = T(Global, "customGame")
    if isSpecialBlock(itemId) and not customGame:getPermissionSetting(Define.CustomRoomSettingType.SPECIAL_BLOCK) then
        return false
    end
    return true
end

function BlockListener.onClickToBlock(blockPos, _, activated)
    local player = PlayerManager:getClientPlayer()
    local blockId = EngineWorld:getBlockId(blockPos)
    local blockMeta = EngineWorld:getBlockMeta(blockPos)
    local yaw = player:getYaw()
    local pos = player:getPosition()
    local blockOffset = VectorUtil.newVector3i(0, 0, 0)
    if blockId == BlockID.BED then
        if blockMeta == 0 or blockMeta == 8 then
            yaw = 180
            local offset = blockMeta == 0 and 1 or 0
            pos = VectorUtil.newVector3(blockPos.x + 0.5, blockPos.y + 0.5, blockPos.z + offset)
            blockOffset = VectorUtil.newVector3i(0, 0, blockMeta == 0 and 1 or -1)
        elseif blockMeta == 1 or blockMeta == 9 then
            yaw = 270
            local offset = blockMeta == 1 and 0 or 1
            pos = VectorUtil.newVector3(blockPos.x + offset, blockPos.y + 0.5, blockPos.z + 0.5)
            blockOffset = VectorUtil.newVector3i(blockMeta == 1 and -1 or 1, 0, 0)
        elseif blockMeta == 2 or blockMeta == 10 then
            yaw = 0
            local offset = blockMeta == 2 and 0 or 1
            pos = VectorUtil.newVector3(blockPos.x + 0.5, blockPos.y + 0.5, blockPos.z + offset)
            blockOffset = VectorUtil.newVector3i(0, 0, blockMeta == 2 and -1 or 1)
        elseif blockMeta == 3 or blockMeta == 11 then
            yaw = 90
            local offset = blockMeta == 3 and 1 or 0
            pos = VectorUtil.newVector3(blockPos.x + offset, blockPos.y + 0.5, blockPos.z + 0.5)
            blockOffset = VectorUtil.newVector3i(blockMeta == 3 and 1 or -1, 0, 0)
        end
        player:sendPacket({
            pid = "onPlayerClickBed",
            yaw = yaw,
            pos = pos,
            bedPos = {
                blockPos,
                VectorUtil.add3i(blockPos, blockOffset)
            }
        })
    end
end

function BlockListener.checkPlaceBlock(_, blockId, blockMeta, blockPos, face)
    Plugins.CallTargetPluginFunc("item_skill", "updateSkillParam", blockPos)
    return true
end

BlockListener:init()
--[[yBa69QzsWG3JUhK3S2VVzepeWD0Db0BmGVlSEdp]]---