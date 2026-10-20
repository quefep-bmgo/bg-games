---@class AIPlayer : BaseBtTree
AIPlayer = class("AIPlayer", BaseBtTree)

local rakssidIndex = 0
local robotId = 0;
local BtTreeName = "EmptyPlayerAI"

function AIPlayer:ctor(platformId, name, initPos)
    robotId = robotId + 1
    rakssidIndex = rakssidIndex + 1
    if not name or name == "" then
        name = rakssidIndex
    end
    initPos = initPos or VectorUtil.ZERO
    self.initPos = initPos
    AIPlayerManager:addAI(self)
    self.userId = platformId
    EngineWorld:addEntityPlayerAI(initPos, name, rakssidIndex, function(entity)
        self.entity = entity
        entity:sendLogin(platformId)
    end) --entityId
    self.rakssid = self.entity:getRaknetID()

    self.luaPlayer = PlayerManager:getPlayerByUserId(self.userId)
    if not self.luaPlayer then
        AIPlayerManager:subAI(self)
        return
    end
    -- self.luaPlayer:initDBDataFinished()
    self.entity:sendReady()
    if self.luaPlayer.info then
        self.luaPlayer.info:setValue("robotId", robotId)
    end

    self:initBtTree(BtTreeName, 1)

    self.tick = 0
    self.isTpCentre = false
    self.repetitionMovePosCount = 0
    self.retryMoveOverlapCount = 0

    self.tickKey = LuaTimer:scheduleTimer(function()
        self:onTick()
    end, 1000)
end

function AIPlayer:getPosition()
    if not self.entity then
        return
    end
    return self.entity:getPosition()
end

function AIPlayer:onTick()
    self.tick = self.tick + 1
    self:waitPhaseTick()

    local curPos = self:getPosition()
    if self.tick % 60 == 0 and self.initPos.x ~= 0 and self.initPos.y ~= 0 and self.initPos.z ~= 0 then
        curPos.x = self.initPos.x
        curPos.y = self.initPos.y
        curPos.z = self.initPos.z
        if not self.isTpCentre then
            self.luaPlayer:teleportPos(self.initPos)
            self.isTpCentre = true
        end
    else
        local randomX = math.random(-1, 1)
        local randomZ = math.random(-1, 1)
        curPos.x = curPos.x + randomX
        curPos.z = curPos.z + randomZ
    end
    self:moveTo(curPos)
end

function AIPlayer:waitPhaseTick()
    local tailNumber = self.userId % 10
    if tailNumber == 0 then
        tailNumber = 3
    end
    if self.tick % tailNumber == 0 then
        if not self.isMove and self.entity then
            local pos = self.entity:getPosition()
            local randomX = math.random(-10, 10)
            local randomY = math.random(-10, 10)
            local randomZ = math.random(-10, 10)
            self.entity:faceToPos(VectorUtil.newVector3(pos.x + randomX, pos.y + randomY, pos.z + randomZ))
        end
        if not self.waitMoveTime or self.waitMoveTime == 2 then
            self.waitMoveTime = 0
        else
            self.waitMoveTime = self.waitMoveTime + 1
        end
    end
end

function AIPlayer:onRespawn()
end

function AIPlayer:canMove()
    return true
end

function AIPlayer:moveTo(targetPos)
    if not self.entity then
        return
    end
    self:moveToPos1(targetPos)
end

function AIPlayer:setPlayerRotation(yaw, pitch)
    self.entity:sendPlayerRotationChanged(yaw, pitch)
end

function AIPlayer:jump()
    self.entity:sendJumpChanged(true)
    LuaTimer:schedule(function()
        if self.entity then
            self.entity:sendJumpChanged(false)
        end
    end, 100)
end

function AIPlayer:onHurt()

end

---EntityPlayerAI, 引擎层Logout时调用.
function AIPlayer:onLogout()
    self.entity = nil
    LuaTimer:cancel(self.tickKey or 0)
    AIManager:subAI(self)
    self:removeBtTree()
end

function AIPlayer:moveToPos1(pos)
    if not self.entity then
        return
    end

    self.entity:moveToPos(pos)
end

function AIPlayer:getCurClothBlockId()
    return self.luaPlayer:tryItemId2DressId(self.luaPlayer:getClothBlockId(), true)
end
