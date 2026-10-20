ChestListener = {}

function ChestListener:init()
    CEvents.ChestOpenEvent:registerCallBack(self.onChestOpen)
end

function ChestListener.onChestOpen(vec3, inv, rakssid)
    local customGame = T(Global, "customGame")
    customGame:onChestOpen(vec3, inv, rakssid)
end

ChestListener:init()

return ChestListener