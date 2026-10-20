---@type GameMount[]
local Mounts = {}

MountManager = {}

function MountManager:addMount(entity)
    Mounts[tostring(entity.entityId)] = entity
end

function MountManager:getMount(entityId)
    return Mounts[tostring(entityId)]
end

function MountManager:removeMount(entity)
    Mounts[tostring(entity.entityId)] = nil
end

function MountManager:onTick()
    for _, entity in pairs(Mounts) do
        entity:onTick()
    end
end