---
--- Created by Jimmy.
--- DateTime: 2017/10/19 0019 15:36
---
---@class GameTeam
local GameTeam = class("GameTeam")

---@param config TeamConfigInfo
function GameTeam:ctor(config)
    self.id = config.id or 0
    self.score = 0
    self.initPos = config.pos or VectorUtil.ZERO
    self.initEquipmentList = config.equipments or {}
    self.initItemList = config.items or {}
    self.marker = config.marker
    self.marker.teamId = self.id
    if self.marker.existence == true then
        self.marker:CreateMarkerBlockAndActor()
    end
    ---@type GamePlayer[]
    self.playerList = {}
end

function GameTeam:reset()
    self.score = 0
    self.playerList = {}
    if self.marker.existence == true then
        self.marker:CreateMarkerBlockAndActor()
    end
end

function GameTeam:addPlayer(player)
    player:setTeamId(self.id)
    self:setRespawnPos(player, self.initPos)
    self.playerList[player.userId] = player
    self:initEquipmentsAndItems(player)
end

function GameTeam:subPlayer(userId)
    self.playerList[userId] = nil
end

function GameTeam:getCurPlayers()
    return self.playerList
end

function GameTeam:addScore(score)
    self.score = self.score + score
end

function GameTeam:getScore()
    return self.score
end

function GameTeam:getLifeCount()
    return TableUtil.getTableSize(self.playerList)
end

function GameTeam:updateCollectScore()
    local item = GameConfig.winCondition.param
    local total = 0
    for _, player in pairs(self.playerList) do
        local count = player:getItemNumById(item[2], item[3] or 0)
        player.score = count
        total = total + count
    end
    self.score = total
end

function GameTeam:setRespawnPos(player, pos)
    local pos1 = VectorUtil.toVector3(pos)
    pos1.y = pos1.y - 0.5
    player:setRespawnPos(pos1)
end

-- 初始化装备和道具
function GameTeam:initEquipmentsAndItems(player)
    self:initEquipments(player)
    self:initItems(player)
end
-- 初始化装备
function GameTeam:initEquipments(player)
    for index, info in ipairs(self.initEquipmentList) do
        local itemId = info.itemId or 0
        local meta   = info.meta or 0
        if itemId ~= 0 then
            player:equipArmor(itemId, meta)
        end
    end
end
-- 初始化道具
function GameTeam:initItems(player)
    for index, info in ipairs(self.initItemList) do
        local itemId = info.itemId or 0
        local meta = info.meta or 0
        local count = info.count or 0
        if itemId ~= 0 and count ~= 0 then
            player:addItem(itemId, count, meta)
        end
    end
end

-- 获取标志物
function GameTeam:findMarkerByPos(vec3)
    if self.marker:IsEqual(vec3) then
        if self.marker.isDestroyed then
            return nil
        end
        return self.marker
    end
    return nil
end
function GameTeam:getMarkerIsDestroyed()
    return self.marker.isDestroyed
end
function GameTeam:getMarkerState()
    if self.marker.existence == true then
        if self.marker.isDestroyed then
            return Define.MarkerState.Destroyed
        else
            return Define.MarkerState.Alive
        end
    else
        return Define.MarkerState.None
    end
end

return GameTeam