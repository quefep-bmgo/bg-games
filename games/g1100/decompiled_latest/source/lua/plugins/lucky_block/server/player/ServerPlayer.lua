---@type SBasePlayer
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

return BasePlayer