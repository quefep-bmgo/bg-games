local ResourcesListener = {}
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
