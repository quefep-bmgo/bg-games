--[[lqbBklXQnfB]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 11699
                          local checkFileName = "BlockListener.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[eUC0rO4HlgYZOx3dLoGdNUbJn1NzB7yIJw82TAsL3a6srPgA93CUUWEesLtfAmQJW5iiUAFmcYopeU3YiPEzAetr]]local BlockListener = {}
local PlaceTNTInfo = {}
function BlockListener:init()
    CEvents.BlockBreakWithMetaEvent:registerCallBack(self.onBlockBreakWithMeta)
    CEvents.PlayerPlaceBlockEvent:registerCallBack(self.onBlockPlace)
    CEvents.BlockChangeEvent:registerCallBack(self.onBlockChangeEvent)
    CEvents.BlockPlacedByEvent:registerCallBack(self.onBlockPlacedByEvent)
    CEvents.UseItemBucketInBlockEvent:registerCallBack(self.onUseItemBucketInBlock)
    CEvents.PlayerUseThrowableItemEvent:registerCallBack(self.onThrowTnt)
    CEvents.BlockCanHarvestEvent:registerCallBack(self.onHarvestEvent)
    CEvents.BlockTNTExplodeEvent:registerCallBack(self.onBlockTNTExplodeEvent)
    CEvents.BlockTNTExplodeBreakBlockEvent:registerCallBack(self.onBlockTNTExplodeBreakBlock)
    CEvents.BlockTNTExplodeHurtEntityEvent:registerCallBack(self.onBlockTNTExplodeHurtEntity)

    CEvents.OnClickBlockSignEvent:registerCallBack(self.OnClickBlockSignEvent)
    CEvents.EntityItemSpawnEvent:registerCallBack(self.onEntityItemSpawn)
    --CEvents.BlockOreDroppedEvent:registerCallBack(self.onBlockOreDropped)
    CEvents.BlockStationaryNotStationaryEvent:registerCallBack(function() return false end)
    CEvents.PlayerPlaceBlockBoxJudgeEvent:registerCallBack(function() return false end)
end

local function removeBedBlock(pos, meta)
    local blockOffset
    if meta == 0 or meta == 8 then
        blockOffset = VectorUtil.newVector3i(0, 0, meta == 0 and 1 or -1)
    elseif meta == 1 or meta == 9 then
        blockOffset = VectorUtil.newVector3i(meta == 1 and -1 or 1, 0, 0)
    elseif meta == 2 or meta == 10 then
        blockOffset = VectorUtil.newVector3i(0, 0, meta == 2 and -1 or 1)
    elseif meta == 3 or meta == 11 then
        blockOffset = VectorUtil.newVector3i(meta == 3 and 1 or -1, 0, 0)
    end
    if not blockOffset then
        return
    end
    local otherPos = VectorUtil.add3i(pos, blockOffset)
    if EngineWorld:getBlockId(pos) == BlockID.BED then
        EngineWorld:setBlockToAir(pos)
    end
    if EngineWorld:getBlockId(otherPos) == BlockID.BED then
        EngineWorld:setBlockToAir(otherPos)
    end
    EngineWorld:addEntityItem(ItemID.BED, 1, 0, 0, pos, nil, false, true)
end

local breakIcePlayer = nil 
function BlockListener.onBlockBreakWithMeta(rakssid, blockId, blockMeta, vec3, itemID)
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if not player then
        return false
    end
    if blockId == 79 then
        breakIcePlayer = player
    end
    local customGame = T(Global, "customGame")
    if customGame:checkOutsideTheEditingArea(vec3) then
        -- showTip(player, "不能在编辑区域外破坏方块")
        return false
    end
    local isMarker, canBreak = customGame:checkTeamMarker(player, vec3, blockId, blockMeta)
    if isMarker then
        return canBreak
    end
    if player:getPermissionSetting(Define.CustomRoomSettingType.BREAK_BLOCK) then
        if blockId == BlockID.BED then
            removeBedBlock(vec3, blockMeta)
            return false
        end
        if blockId == BlockID.MELON then
            EngineWorld:addEntityItem(BlockID.MELON, 1, 0, 0, vec3, nil, false, true)
        end
        if Plugins.IsLoaded("lucky_block") then
            Plugins.CallTargetPluginFunc("lucky_block", "getLuckyBlock", player, blockId, vec3)
        end
        if blockId == BlockID.ORE_GOLD then
            EngineWorld:addEntityItem(ItemID.INGOT_GOLD, 1, 0, 0, vec3, nil, false, true)
        end
        if blockId == BlockID.ORE_IRON then
            EngineWorld:addEntityItem(ItemID.INGOT_IRON, 1, 0, 0, vec3, nil, false, true)
        end
        if blockId == Define.ResourceItemId - 1000 then
            return false
        end
        return customGame:canBreakBlock(vec3)
    else
        return false
    end
end

local function isSpecialBlock(itemId)
    return itemId == 46 or itemId == 8 or itemId == 10 or itemId == 326 or itemId== 327
end

function BlockListener.onBlockPlace(rakssid, itemId, meta, toPlacePos)
    local player = PlayerManager:getPlayerByRakssid(rakssid)
    if not player then
        return false
    end
    local customGame = T(Global, "customGame")
    if customGame:checkOutsideTheEditingArea(toPlacePos) then
        -- showTip(player, "不能在编辑区域外放置方块")
        return false
    end
    if customGame:checkEditingAreaOverflowMaxCount() then
        return false
    end
    if player.isSelectTeamType 
        and player.isSelectTeam
        and player.isSelectTeam > 0
        and ((player.isSelectTeamType == Define.SelectTeam.Position and TableUtil.include(Define.TeamFlagItem, itemId)) or player.isSelectTeamType == Define.SelectTeam.Marker) then
        if customGame:checkOwner(player.userId) then
            local newMeta = meta
            if player.isSelectTeamType == Define.SelectTeam.Position then
                customGame:onSelectTeamPos(player.isSelectTeam, toPlacePos)
            else
                local ret, retMeta = customGame:onSelectTeamMarker(player, player.isSelectTeam, itemId, meta, toPlacePos)
                if not ret then
                    return false
                end
                newMeta = retMeta
            end
            player:removeItem(itemId, 1)
            player:sendPacket({
                pid = "onSelectTeamPosEnd",
                type = player.isSelectTeamType,
                teamId = player.isSelectTeam,
                itemId = itemId,
                meta = newMeta,
                pos = toPlacePos
            })
        end
        return false
    end
    if isSpecialBlock(itemId) and not player:getPermissionSetting(Define.CustomRoomSettingType.SPECIAL_BLOCK) then 
        return false
    end
    if not customGame:canPlaceBlock(toPlacePos) then
        return false
    end
    return player:getPermissionSetting(Define.CustomRoomSettingType.PLACE_BLOCK) or false
end

function BlockListener.onBlockChangeEvent(pos, blockID, metadata)
    local customGame = T(Global, "customGame")
    customGame:editingAreaBlockChange(pos, blockID, metadata)
end

function BlockListener.onBlockPlacedByEvent(pos, blockID, metadata)
    local customGame = T(Global, "customGame")
    customGame:editingAreaBlockChange(pos, blockID, metadata)
end

function BlockListener.onUseItemBucketInBlock(entityId, itemId, vec3i)
    local player = PlayerManager:getPlayerByEntityId(entityId)
    if player == nil then
        return false
    end

    if isSpecialBlock(itemId) and not player:getPermissionSetting(Define.CustomRoomSettingType.SPECIAL_BLOCK) then
        return false
    end
    return player:getPermissionSetting(Define.CustomRoomSettingType.PLACE_BLOCK) or false
end

function BlockListener.onBlockTNTExplodeEvent(entityId, pos, attr, sourceItemId)
    if sourceItemId == ItemID.FLARE_BOMB then
        attr.isBreakBlock = true
        attr.isCanHurt = true
        attr.isHurtEntityItem = false
        local skill_config = SkillConfig:getSkill(sourceItemId)
        if skill_config ~= nil then
            attr.custom_explosionSize = skill_config.length
            MonsterManager:onExplode(pos, skill_config.length * 4, skill_config.damage)
        end
    else
        attr.isBreakBlock = false
        attr.isCanHurt = false
    end

    local skill_config = SkillConfig:getSkill(sourceItemId)
    if skill_config then
        local tntExplosionSize = skill_config.param[1]
        local tntExplosionRepelDistanceFactor = skill_config.param[2]
        if tntExplosionSize then
            attr.custom_explosionSize = tntExplosionSize
        end
        if tntExplosionRepelDistanceFactor then
            attr.custom_explosionRepelDistanceFactor = tntExplosionRepelDistanceFactor
        end
    end

    return false
end

function BlockListener.onBlockTNTExplodeBreakBlock(blockPos, blockId, sourceItemId, placeEntityId)
    if blockId == BlockID.WHITE_STONE then
        if sourceItemId == ItemID.FLARE_BOMB then
            return false
        end
        if sourceItemId == BlockID.TNT then
            return EngineWorld:isBlockChange(blockPos)
        end
    end
    if blockId == BlockID.OBSIDIAN
        or blockId == BlockID.STAIND_GLASS_PANE
        or blockId == BlockID.STAIND_GLASS
        ---自定义方块 粘土炸弹
        then
        return false
    end
    ---宝箱不能破坏
    if blockId == BlockID.CHEST then
        return false
    end
    local customGame = T(Global, "customGame")
    local player = PlayerManager:getPlayerByEntityId(placeEntityId)
    local blockMeta = EngineWorld:getBlockMeta(blockPos)
    local isMarker, canBreak = customGame:checkTeamMarker(player, blockPos, blockId, blockMeta)
    if isMarker then
        return canBreak
    end
    return EngineWorld:isBlockChange(blockPos)
end

function BlockListener.onBlockTNTExplodeHurtEntity(sourceItemId, hurtEntityId, placeEntityId)
    local hurter = PlayerManager:getPlayerByEntityId(hurtEntityId)
    if hurter == nil then
        return false
    end
    local placer = PlayerManager:getPlayerByEntityId(placeEntityId)
    if placer == nil then
        return false
    end
    if hurtEntityId ~= placeEntityId and (placer.teamId and hurter.teamId and placer.teamId == hurter.teamId) then
        return false
    end
    return true
end

function BlockListener.onThrowTnt(itemId, itemMeta, userId)
    local player = PlayerManager:getPlayerByUserId(userId)
    if player == nil then 
        return false
    end
    if isSpecialBlock(itemId) and not player:getPermissionSetting(Define.CustomRoomSettingType.SPECIAL_BLOCK) then
        return false
    end
    return true
end

function BlockListener.onHarvestEvent(blockId)
    if blockId == 79 and breakIcePlayer and (not breakIcePlayer:getPermissionSetting(Define.CustomRoomSettingType.SPECIAL_BLOCK) )then
        return false
    end
    return true
end
function BlockListener.OnClickBlockSignEvent(entityId, blockPos, txt)
    local player = PlayerManager:getPlayerByEntityId(entityId)
    if not player then
        return
    end

    if not player:getPermissionSetting(Define.CustomRoomSettingType.PLACE_BLOCK) then
        return
    end

    player:sendPacket({
        pid = "showBlockSign",
        data = {
            blockPos = blockPos,
            txt = txt
        }
    })
end

function BlockListener.onEntityItemSpawn(itemId, itemMeta, behavior, discard)
    if itemId == ItemID.MELON then
        return false
    end
    if behavior == "break.block" and ( itemId ==14 or itemId == 15) then 
        return false;
    end
    return true
end

function BlockListener.onBlockOreDropped(blockId)
    if blockId == BlockID.ORE_GOLD or blockId == BlockID.ORE_IRON then
        return false
    end
    return true
end

BlockListener:init()
--[[na5vJgcOwXWDzU4eLkV7TwTZxzp2MxEmy0WqtwPdCafDadSPlL9rdq2vxBIIUASav8i1zwVqOvCpPhDFGWBf6KMndvrH3JMi1RNKCVWl66RP]]---