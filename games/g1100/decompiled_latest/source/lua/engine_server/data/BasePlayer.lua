--region *.lua
---@class SBasePlayer : cls
local SBasePlayer = class("SBasePlayer")
---@type SPidPacketSender
local PidPacketSender = T(Global, "PidPacketSender")
---@type table<number, number>
local VipRecord = T(Global, "VipRecord")
---@type table<number, number>
local UserPrivilegeGrade = T(Global, "UserPrivilegeGrade")

---检查未成年人
---@param player SBasePlayer
local function checkMinors(player)
    if not BaseMain:isChina() then
        return
    end
    if player.gameTimeToday < 0 then
        ---成年人
        return
    end
    LogUtil.log("[CheckMinors] [userId]=" .. tostring(player.userId) ..
            " [gameTimeToday]=" .. tostring(player.gameTimeToday), LogUtil.LogLevel.Info)
    local hour = tonumber(os.date("%H"))
    if hour >= 22 or hour < 8 then
        ---每日22点到次日8点，不能给未成年人提供游戏
        HostApi.sendGameover(player.rakssid, 167, GameOverCode.GameOver)
        return
    end
    local userId = player.userId
    LuaTimer:schedule(function()
        if not player:checkReady() then
            return
        end
        HostApi.sendGameover(player.rakssid, 166, GameOverCode.GameOver)
    end, player.gameTimeToday * 1000, nil, userId)
end

function SBasePlayer:initMemberVariables()
    self.clientPeer = nil
    self.entityPlayerMP = nil
    self.userId = 0
    self.rakssid = 0
    self.name = ""
    self.gold = 0
    self.available = 0
    self.hasGet = 0
    self.scorePoints = {}
    self.defaultRank = 10
    self.respawnTimes = -1
    self.isReady = false
    self.isLoginSuccess = false
    self.inGameTime = os.time()
    self.appIntegral = 0
    self.enableIndie = false
    self.gameTimeToday = 0
    self.gameCashCoupon = 0 ---游戏代金券
    self.isKickOut = false
    self.vip = 0

    self.staticAttr = {}
    self.staticAttr.clanId = 0 -- clanId
    self.staticAttr.clanName = "" -- clanName
    self.staticAttr.role = -1 -- role
    self.staticAttr.props = {} --props
    self.staticAttr.region = "SG-HK" -- region

    self.dynamicAttr = {}
    self.dynamicAttr.team = 0

    self.uploadCallback = {}
end

function SBasePlayer:getEntityPlayer()
    return self.entityPlayerMP
end

---@param clientPeer ClientPeer
function SBasePlayer:ctor(clientPeer)
    self:initMemberVariables()
    self:respawn(clientPeer)
    self:initDynamicAttr()
end

---@param clientPeer ClientPeer
function SBasePlayer:respawn(clientPeer)
    self.clientPeer = clientPeer
    self.entityPlayerMP = clientPeer:getEntityPlayer()
    self.userId = clientPeer:getPlatformUserId()
    self.rakssid = clientPeer:getRakssid()
    if not self.name or self.name == "" then
        self.name = clientPeer:getName()
    end
    self.respawnTimes = self.respawnTimes + 1
    self:useAppProps()
end

function SBasePlayer:initStaticAttr(teamId)
    WebService:GetUserAttr(self.userId, function(data, code)
        if data == nil then
            self.isLoginSuccess = false
            self:sendLoginResult(false, teamId or self.dynamicAttr.team, "",
                    PlayerManager:getPlayerCount(), PlayerManager:getMaxPlayer())
        else
            self.isLoginSuccess = true
            UserExpManager:getUserExpCache(self.userId)
            self:sendLoginResult(true, teamId or self.dynamicAttr.team, "",
                    PlayerManager:getPlayerCount(), PlayerManager:getMaxPlayer())
            self:setShowName(self:buildShowName())
            self:useAppProps()
        end
        checkMinors(self)
    end)
end

function SBasePlayer:testInitStaticAttr(teamId)
    local this = self
    LuaTimer:scheduleTimer(
            function()
                this.isLoginSuccess = true
                UserExpManager:getUserExpCache(this.userId)
                this:sendLoginResult(true, teamId or this.dynamicAttr.team, "",
                        PlayerManager:getPlayerCount(), PlayerManager:getMaxPlayer())
                this:setShowName(this:buildShowName())
                this:useAppProps()
                checkMinors(this)
            end, 1000, 1)
end

function SBasePlayer:sendLoginResult(isSuccess, teamId, teamName, playerNum, maxPlayer)
    if self.clientPeer ~= nil then
        self.clientPeer:sendLoginResult(isSuccess, teamId, teamName, playerNum, maxPlayer)
    end
    if not isSuccess then
        return
    end
    --if self.colorfulNickName then
    LogUtil.logInfo("[SyncPlayerName] userId=" .. tostring(self.userId) .. " name=" .. self.name)
    PacketSender:broadCastLuaCommonData("SyncPlayerName", json.encode({ userId = self.userId, name = self.name }))
    --end
    if self.personalityItems and next(self.personalityItems) ~= nil then
        LogUtil.logInfo("[SyncPlayerPersonalityItems] userId=" .. tostring(self.userId) .. " personalityItems=" .. json.encode(self.personalityItems))
        self:broadCastPacket({
            pid = "SyncPlayerPersonalityItems",
            userId = self.userId,
            personalityItems = self.personalityItems,
            isEnter = true,
        })
    end
    local players = PlayerManager:getPlayers()
    for _, player in pairs(players) do
        if player ~= self then
            PacketSender:sendLuaCommonData(self.rakssid, "SyncPlayerName",
                    json.encode({ userId = player.userId, name = player.name }))
        end
        if player ~= self and player.personalityItems and next(player.personalityItems) ~= nil then
            self:sendPacket({
                pid = "SyncPlayerPersonalityItems",
                userId = player.userId,
                personalityItems = player.personalityItems,
            })
        end
    end
end

function SBasePlayer:onPlayerLogout()
    self.clientPeer = nil
    self.entityPlayerMP = nil
    self.isReady = false
    ReportManager:onPlayerLogout(self)
end

function SBasePlayer:getDisplayName()
    return self.name
end

function SBasePlayer:checkReady()
    return self.isReady
end

function SBasePlayer:addNightVisionPotionEffect(seconds)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:addNightVisionPotionEffect(seconds)
    end
end

function SBasePlayer:useAppProps()
    AppProps:useAppProps(self, self.respawnTimes == 0)
end

function SBasePlayer:onUseCustomProp(propId, itemId)

end

function SBasePlayer:haveItemCount(id, maxSize)
    maxSize = maxSize or 36
    local inventory = self:getInventory()
    local count = 0
    for i = 0, maxSize - 1 do
        local info = inventory:getItemStackInfo(i)
        if info.id == id then
            count = count + info.num
        end
    end
    return count
end

function SBasePlayer:addItem(id, num, damage, isReverse, maxDamage, stackIndex)
    if not self.entityPlayerMP then
        return
    end
    if stackIndex then
        return self:replaceItem(id, num, damage, stackIndex)
    else
        return self.entityPlayerMP:addItem(id, num, damage, isReverse or false, maxDamage or 0)
    end
end

function SBasePlayer:addGunItem(id, num, damage, bullets, isReverse)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:addGunItem(id, num, damage, bullets, isReverse or false)
    end
end

function SBasePlayer:addItemToEnderChest(slot, id, num, damage, enchantList)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:addItemToEnderChest(slot, id, num, damage, enchantList)
    end
end

function SBasePlayer:addGunItemToEnderChest(slot, id, num, damage, bullets)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:addGunItemToEnderChest(slot, id, num, damage, bullets)
    end
end

function SBasePlayer:addGunDamage(gunId, damage)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:addGunDamage(gunId, damage)
    end
end

function SBasePlayer:addGunBulletNum(gunId, bulletNum)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:addGunBulletNum(gunId, bulletNum)
    end
end

function SBasePlayer:subGunRecoil(gunId, recoil)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:subGunRecoil(gunId, recoil)
    end
end

function SBasePlayer:getBulletNum(stackIndex)
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:getBulletNum(stackIndex)
    end
    return 0
end

function SBasePlayer:removeItem(id, num, meta)
    if self.entityPlayerMP ~= nil then
        local inv = self.entityPlayerMP:getInventory()
        if inv then
            inv:removeItem(id, num, meta or -1)
        end
    end
end

function SBasePlayer:decrStackSize(slot, count)
    if self.entityPlayerMP ~= nil then
        local inv = self.entityPlayerMP:getInventory()
        if inv then
            inv:decrStackSize(slot, count)
        end
    end
end

function SBasePlayer:equipArmor(id, damage)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:equipArmor(id, damage)
    end
end

function SBasePlayer:replaceItem(id, num, damage, stackIndex, clipBullet)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:replaceItem(id, num, damage, stackIndex, clipBullet)
    end
end

function SBasePlayer:replaceEchantmentItem(id, num, damage, enchantmentList, stackIndex)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:replaceEchantmentItem(id, num, damage, enchantmentList, stackIndex)
    end
end

function SBasePlayer:addEnchantmentItem(id, num, damage, enchantmentId, enchantmentLevel)
    local enchantments = { { enchantmentId, enchantmentLevel } }
    self:addEnchantmentsItem(id, num, damage, enchantments)
end

function SBasePlayer:addEnchantmentsItem(id, num, damage, enchantmentList, stackIndex)
    if not self.entityPlayerMP then
        return
    end
    if stackIndex then
        self:replaceEchantmentItem(id, num, damage, enchantmentList, stackIndex)
    else
        self.entityPlayerMP:addEchantmentItem(id, num, damage, enchantmentList)
    end
end

function SBasePlayer:getItemEnchantList(stackId)
    local inv = self:getInventory()
    if not inv then
        return nil
    end
    local stack = inv:getStackInSlot(stackId):get()
    local enchantList = nil
    if stack then
        local enchantmentCount = stack:getItemStackEnchantmentCount()
        --print("enchantmentCount ===", enchantmentCount)
        if enchantmentCount > 0 then
            enchantList = {}
            for i = 1, enchantmentCount do
                local enchantmentInfo = stack:getItemStackEnchantmentInfoByIndex(i - 1)
                table.insert(enchantList, { enchantmentInfo.id, enchantmentInfo.level })
            end
            --LogUtil.pv(enchantList)
        end
    end

    return enchantList
end

function SBasePlayer:getHealth()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:getHealth()
    end
    return 20
end

function SBasePlayer:setHealth(health)
    if health == nil then
        return
    end
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:setEntityHealth(health)
    end
end

function SBasePlayer:addHealth(hp)
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:heal(hp)
    end
end

function SBasePlayer:subHealth(hp)
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:heal(-hp)
    end
end

function SBasePlayer:setEntityHealth(hp)
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:setEntityHealth(hp)
    end
end

function SBasePlayer:updateExp(level, exp, maxExp)
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:updateExp(level, exp, maxExp)
    end
end

function SBasePlayer:getPosition()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:getPosition()
    end
    return VectorUtil.newVector3(0, 0, 0)
end

function SBasePlayer:getYaw()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:getYaw()
    end
    return 0
end

function SBasePlayer:getPitch()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:getPitch()
    end
    return 0
end

function SBasePlayer:setPositionAndRotation(vec, yaw, pitch)
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:setPositionAndRotation(vec, yaw, pitch)
    end
end

function SBasePlayer:getSex()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:getSex()
    end
    return 1
end

function SBasePlayer:getRotationYaw()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP.rotationYaw % 360
    end
    return 0
end

function SBasePlayer:getWidth()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:getWidth()
    end
    return 1
end

function SBasePlayer:isWatchMode()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:isWatchMode()
    end
    return true
end

function SBasePlayer:setAllowFlying(flying, noSync)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:setAllowFlying(flying, noSync)
    end
end

function SBasePlayer:getIsFlying()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:getIsFlying()
    end

    return false
end

function SBasePlayer:setFoodLevel(value)
    if value == nil then
        return
    end
    if self.entityPlayerMP ~= nil and self.entityPlayerMP:getFoodStats() then
        self.entityPlayerMP:getFoodStats():setFoodLevel(value)
    end
end

function SBasePlayer:getFoodLevel()
    if self.entityPlayerMP ~= nil and self.entityPlayerMP:getFoodStats() then
        return self.entityPlayerMP:getFoodStats():getFoodLevel()
    end
    return 20
end

function SBasePlayer:setSpeedAddition(level)
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:setSpeedAdditionLevel(level)
    end
end

function SBasePlayer:getItemNumById(id, meta)
    if self.entityPlayerMP ~= nil then
        local inv = self.entityPlayerMP:getInventory()
        return inv:getItemNum(id, meta or -1)
    end
    return 0
end

function SBasePlayer:clearInv()
    if self.entityPlayerMP ~= nil then
        local inv = self.entityPlayerMP:getInventory()
        inv:clear()
    end
end

---@return InventoryPlayer
function SBasePlayer:getInventory()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:getInventory()
    end
end

function SBasePlayer:getWallet()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:getWallet()
    end
end

function SBasePlayer:setExtraInventoryCount(count)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:setExtraInventoryCount(count)
    end
end

function SBasePlayer:changeMaxHealth(health, unChangeCurrent)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:changeMaxHealth(health, unChangeCurrent or false)
    end
end

function SBasePlayer:changeMaxHealthSingle(health)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:changeMaxHealthSingle(health)
    end
end

function SBasePlayer:getMaxHealth()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:getMaxHealth()
    end
    return 0
end

function SBasePlayer:getHeldItemId()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:getHeldItemId()
    end
    return 0
end

function SBasePlayer:setCurrency(currency)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:setCurrency(currency)
    end
end

function SBasePlayer:addCurrency(currency)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:addCurrency(currency)
    end
end

function SBasePlayer:subCurrency(currency)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:subCurrency(currency)
    end
end

function SBasePlayer:setUnlockedCommodities(unlockedCommodities)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:setUnlockedCommodities(unlockedCommodities)
    end
end

function SBasePlayer:getCurrency()
    if self.entityPlayerMP ~= nil then
        return tonumber(tostring(self.entityPlayerMP:getCurrency()))
    end
    return 0
end

function SBasePlayer:addBackpackCapacity(capacity)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:addBackpackCapacity(capacity)
    end
end

function SBasePlayer:subBackpackCapacity(capacity)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:subBackpackCapacity(capacity)
    end
end

function SBasePlayer:resetBackpack(capacity, maxCapacity)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:resetBackpack(capacity, maxCapacity)
    end
end

function SBasePlayer:setArmItem(itemId)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:setArmItem(itemId)
    end
end

function SBasePlayer:fillInvetory(inventory)
    self:clearInv()
    if inventory == nil then
        return
    end
    for _, armor in pairs(inventory.armor or {}) do
        if armor.id > 0 and armor.id < 10000 and armor.num > 0 then
            self:equipArmor(armor.id, armor.meta)
        end
    end
    for _, gun in pairs(inventory.gun or {}) do
        if gun.num > 0 then
            self:addGunItem(gun.id, gun.num, gun.meta, gun.bullets)
        end
    end
    for _, item in pairs(inventory.item or {}) do
        if item.id > 0 and item.id < 10000 and item.num > 0 then
            self:addItem(item.id, item.num, item.meta)
        end
    end
end

function SBasePlayer:fillEnderInvetory(enderInv)
    if enderInv == nil then
        return
    end
    local inv = self:getEnderInventory()
    if not inv then
        return
    end
    inv:clear()
    local slot = 0
    for _, gun in pairs(enderInv.gun or {}) do
        if gun.num > 0 then
            self:addGunItemToEnderChest(slot, gun.id, gun.num, gun.meta, gun.bullets)
            slot = slot + 1
        end
    end
    for _, item in pairs(enderInv.item or {}) do
        if item.id > 0 and item.id < 10000 and item.num > 0 then
            if item.enchantList == nil then
                item.enchantList = {}
            end
            self:addItemToEnderChest(slot, item.id, item.num, item.meta, item.enchantList)
            slot = slot + 1
        end
    end
end

function SBasePlayer:getEnderInventory()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:getInventoryEnderChest()
    end
end

function SBasePlayer:addEffect(id, time, level)
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:addEffect(id, time, level)
    end
end

function SBasePlayer:removeEffect(id)
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:removeEffect(id)
    end
end

function SBasePlayer:clearEffects()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:clearEffects()
    end
end

function SBasePlayer:setRespawnPos(pos)
    if self.clientPeer ~= nil then
        self.clientPeer:setRespawnPos(VectorUtil.newVector3i(pos.x, pos.y + 0.5, pos.z))
    end
end

function SBasePlayer:teleportPos(pos)
    if not pos then
        return
    end
    HostApi.resetPos(self.rakssid, pos.x, pos.y + 0.5, pos.z)
end

function SBasePlayer:teleportPosWithYaw(pos, yaw)
    HostApi.resetPosWithYaw(self.rakssid, pos.x, pos.y + 0.5, pos.z, yaw)
end

function SBasePlayer:teleportPosWithYaw1(pos)
    HostApi.resetPosWithYaw(self.rakssid, pos.x, pos.y + 0.5, pos.z, pos.w)
end

function SBasePlayer:changeClothes(partName, actorId)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:changeClothes(partName, actorId)
    end
end

function SBasePlayer:resetClothes()
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:resetClothes(self.userId)
    end
end

function SBasePlayer:playSkillEffect(name, duration, range, color)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:playSkillEffect(name, duration, range, color)
    end
end

function SBasePlayer:sendSkillEffect(effectId)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:sendSkillEffect(effectId)
    end
end

function SBasePlayer:buildShowName()
    local nameList = {}
    if self.staticAttr.role ~= -1 then
        table.insert(nameList, self:getClanName())
    end
    PlayerIdentityCache:buildNameList(self, nameList, self.name)
    return nameList
end

function SBasePlayer:initDynamicAttr()
    local manager = GameServer:getRoomManager()
    if not manager:isUserAttrExisted(self.userId) then
        return
    end
    local attr = manager:getUserAttrInfo(self.userId)
    self.dynamicAttr = attr
    ---跟随通知
    local name = attr.name
    name = name:gsub(TextFormat.colorStart, "")
    name = name:gsub("\n", " ")
    if attr.followEnterType == 1 then
        ---跟随进入游戏，一起玩
        local follower = PlayerManager:getPlayerByUserId(attr.targetUserId)
        if follower then
            PacketSender:sendFollowerInfo(follower.rakssid, name)
            ---再次 进入游戏上报加入游戏成功
            for pos, userId in pairs(follower.watchList or {}) do
                if userId == tostring(self.userId) then
                    PacketSender:sendDataReport(self.rakssid, "follow_game_enter_suc", "")
                    table.remove(follower.watchList, pos)
                    break
                end
            end
        end
    elseif attr.followEnterType == 2 then
        ---进入观战模式
        local follower = PlayerManager:getPlayerByUserId(attr.targetUserId)
        Events.WatcherPlayerInitEvent:invoke(self)
        if follower then
            PacketSender:sendWatcherInfo(follower.rakssid, name)
            ---记录 跟随进入的观战标志.
            follower.watchList = follower.watchList or {}
            for _, userId in pairs(follower.watchList) do
                if userId == tostring(self.userId) then
                    return
                end
            end
            table.insert(follower.watchList, tostring(self.userId))
        end
    end
end

---@param player SBasePlayer
---@param nameList string[]
---@param target SBasePlayer
local function appendFriendTitle(player, nameList, target)
    if player.familyInfo == nil or player.familyInfo.familyType == 0 then
        return nameList
    end
    local result = TableUtil.copyTable(nameList)
    if Global.setting.disableFamilyName then
        return result
    end
    local colorful = "&$[FD80A8FF-FCCE42FF]$%s$&"
    local title
    if player.familyInfo.familyType <= 4 then
        title = ServerLang:format("family_title_" .. player.familyInfo.familyType, target:getLang(), player.familyInfo.familyName)
    else
        local diyName = StringUtil.subStringUTF8(player.familyInfo.diyName, 1, 12)
        title = player.familyInfo.familyName .. diyName
    end
    local item = string.format(colorful, title)
    table.insert(result, #result, item)
    return result
end

---不允许重写该方法
function SBasePlayer:setShowName(nameList, targetId)
    if nameList == " " or nameList == nil then
        PidPacketSender:sendSetShowName(targetId, self.userId, " ", self.name)
        return
    end
    if type(nameList) == "string" then
        nameList = { nameList }
    end
    targetId = targetId or 0
    if targetId == 0 then
        local targets = PlayerManager:getPlayers()
        for _, target in pairs(targets) do
            local result = appendFriendTitle(self, nameList, target)
            PidPacketSender:sendSetShowName(target.rakssid, self.userId, table.concat(result, "\n"), self.name)
        end
        local name = table.concat(nameList, "\n")
        if self.clientPeer ~= nil then
            self.clientPeer:setShowName(name)
        end
    else
        local target = PlayerManager:getPlayerByRakssid(targetId)
        if not target then
            return
        end
        local result = appendFriendTitle(self, nameList, target)
        PidPacketSender:sendSetShowName(target.rakssid, self.userId, table.concat(result, "\n"), self.name)
    end
end

function SBasePlayer:changeHeart(hp, maxHp)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:changeHeart(hp, maxHp)
    end
end

function SBasePlayer:getEntityId()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:hashCode()
    end
    return -1
end

function SBasePlayer:addVehicles(vehicles)
    if self.entityPlayerMP == nil or vehicles == nil then
        return
    end
    for i, vehicle in pairs(vehicles) do
        self.entityPlayerMP:addOwnVehicle(vehicle)
    end
    self.entityPlayerMP:syncOwnVehicle()
end

function SBasePlayer:leaveVehicle()
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:getOffVehicle()
    end
end

function SBasePlayer:checkDiamondBlues(diamonds)
    if self.clientPeer ~= nil then
        return self.clientPeer:checkDiamondBlues(diamonds)
    end
    return true
end

function SBasePlayer:consumeDiamonds(uniqueId, diamonds, remark, reason, goodsCount)
    if self.isKickOut then
        return
    end
    PayHelper.payMoneySync(self, uniqueId, CurrencyId.GCube, diamonds, function()
        return CEvents.ConsumeDiamondsEvent:invoke(self.rakssid, true, "success", remark)
    end, nil, nil, reason, goodsCount)
end

function SBasePlayer:consumeGolds(uniqueId, diamonds, remark, reason, goodsCount)
    if self.isKickOut then
        return
    end
    PayHelper.payMoneySync(self, uniqueId, CurrencyId.Golds, diamonds, function()
        return CEvents.ConsumeGoldsEvent:invoke(self.rakssid, true, "success", remark)
    end, nil, nil, reason, goodsCount)
end

function SBasePlayer:isVisitor()
    if self.clientPeer ~= nil then
        return self.clientPeer:isVisitor()
    end
    return true
end

function SBasePlayer:setPersonalShopArea(startPos, endPos)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:setPersonalShopArea(startPos, endPos)
    end
end

function SBasePlayer:getDiamond()
    if self.entityPlayerMP ~= nil then
        return tonumber(tostring(self.entityPlayerMP:getDiamond()))
    end
    return 0
end

function SBasePlayer:getGold()
    if self.entityPlayerMP ~= nil then
        return tonumber(tostring(self.entityPlayerMP:getGold()))
    end
    return 0
end

function SBasePlayer:setOnFrozen(frozenTime)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:setOnFrozen(frozenTime)
    end
end

function SBasePlayer:setOnFire(fireTime)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:setOnFire(fireTime)
    end
end

function SBasePlayer:addCustomEffect(name, effectName, duration, scale)
    if self.entityPlayerMP ~= nil then
        scale = scale or 1.0
        self.entityPlayerMP:addCustomEffect(name, effectName, duration, scale)
    end
end

--清除所有特效
function SBasePlayer:clearCustomEffects()
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:clearCustomEffects()
    end
end

function SBasePlayer:getRanch()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:getRanch()
    end
end

function SBasePlayer:getBirdSimulator()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:getBirdSimulator()
    end
end

function SBasePlayer:setBagInfo(curCapacity, maxCapacity)
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:setBagInfo(curCapacity, maxCapacity)
    end
end

function SBasePlayer:setBirdConvert(isConvert)
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:setBirdConvert(isConvert)
    end
end

function SBasePlayer:setGlide(isOpenGlide)
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:setGlide(isOpenGlide)
    end
end

function SBasePlayer:isGlide()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:isGlide()
    end
    return false
end

function SBasePlayer:isParachute()
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:isParachute()
    end
    return false
end

function SBasePlayer:setFlyWing(isEquipWing, glideMoveAddition, glideDropResistance)
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:setFlyWing(isEquipWing, glideMoveAddition, glideDropResistance)
    end
end

function SBasePlayer:isNotFall(isNotFall)
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:isNotFall(isNotFall)
    end
    return false
end

function SBasePlayer:setNotFall(isNotFall)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:setNotFall(isNotFall)
    end
end

function SBasePlayer:getClothesId(partName)
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:getClothesId(partName)
    end
end

function SBasePlayer:placeBlock(vec3, hitPos, face)
    if self.entityPlayerMP ~= nil then
        self.entityPlayerMP:placeBlock(vec3, hitPos, face)
    end
end

function SBasePlayer:getLanguage()
    if self.clientPeer ~= nil then
        return self.clientPeer:getLanguage()
    end
    return "en_US"
end

function SBasePlayer:getLang()
    if self.__lang then
        return self.__lang
    end
    self.__lang = StringUtil.split(self:getLanguage(), "_")[1]
    return self.__lang
end

function SBasePlayer:getClanName()
    local name = TextFormat.colorGreen .. self.staticAttr.clanName
    if BaseMain:isChina() then
        if self.staticAttr.role == 0 then
            name = name .. TextFormat.colorWrite .. "[成员]"
        end
        if self.staticAttr.role == 10 then
            name = name .. TextFormat.colorRed .. "[长老]"
        end
        if self.staticAttr.role == 20 then
            name = name .. TextFormat.colorOrange .. "[酋长]"
        end
    else
        if self.staticAttr.role == 0 then
            name = name .. TextFormat.colorWrite .. "[Member]"
        end
        if self.staticAttr.role == 10 then
            name = name .. TextFormat.colorRed .. "[Elder]"
        end
        if self.staticAttr.role == 20 then
            name = name .. TextFormat.colorOrange .. "[Chief]"
        end
    end
    return name
end

function SBasePlayer:setFlying(isFlying, noSync)
    if self.entityPlayerMP ~= nil then
        return self.entityPlayerMP:setFlying(isFlying, noSync)
    end
end

function SBasePlayer:getTotalArmorValue()
    if self.entityPlayerMP then
        return self.entityPlayerMP:getTotalArmorValue()
    end
    return 0
end

function SBasePlayer:getAttackDamage()
    if self.entityPlayerMP then
        return self.entityPlayerMP:getAttackDamage()
    end
    return 0
end

function SBasePlayer:setScale(coe)
    if self.entityPlayerMP then
        self.entityPlayerMP:setScale(coe)
    end
end

function SBasePlayer:isGrab()
    if self.entityPlayerMP then
        return self.entityPlayerMP:isGrab()
    end
end

function SBasePlayer:isBeGrab()
    if self.entityPlayerMP then
        return self.entityPlayerMP:isBeGrab()
    end
end

function SBasePlayer:unbindParentEntity()
    if self.entityPlayerMP then
        self.entityPlayerMP:unbindParentEntity()
    end
end

function SBasePlayer:unbindAllEntity()
    if self.entityPlayerMP then
        self.entityPlayerMP:unbindAllEntity()
    end
end

function SBasePlayer:getFirstChildrenEntityId()
    if self.entityPlayerMP then
        return self.entityPlayerMP:getFirstChildrenEntityId()
    end
end

function SBasePlayer:isEntityAlive()
    if self.entityPlayerMP then
        return self.entityPlayerMP:isEntityAlive()
    end
end

function SBasePlayer:isFlyingByPulled()
    if self.entityPlayerMP then
        return self.entityPlayerMP.m_flyingByPulled
    end
end

function SBasePlayer:setConcealPower(value)
    if self.entityPlayerMP then
        self.entityPlayerMP:setConcealPower(value)
    end
end

function SBasePlayer:changeActor(actor)
    if self.entityPlayerMP then
        EngineWorld:changePlayerActor(self, actor)
    end
end

function SBasePlayer:recoverActor()
    local sex = self:getSex()
    if sex == 2 then
        self:changeActor("girl.actor")
    else
        self:changeActor("boy.actor")
    end
end

function SBasePlayer:isDead()
    if not self.entityPlayerMP then
        return false
    end
    return self.entityPlayerMP.isDead
end

function SBasePlayer:onTick(ticks)
    --TODO
end

---检查玩家能否接受通用活动的奖励
function SBasePlayer:checkCanReceiveCommonReward(rewardNum)
    return true
end

function SBasePlayer:getCurrencyBalance()
    local balance = {
        [CurrencyId.GCube] = self:getDiamond(),
        [CurrencyId.Diamonds] = self:getDiamond(),
        [CurrencyId.Golds] = self:getGold(),
        [CurrencyId.Currency] = self:getCurrency(),
    }
    return balance
end

function SBasePlayer:getRespawnPos()
    if self.clientPeer then
        return self.clientPeer:getRespawnPos()
    end
    return VectorUtil.ZERO
end

---@param func function
function SBasePlayer:uploadTotalRecharge(func)
    if type(func) ~= "function" then
        func = function()
        end
    end
    if #self.uploadCallback == 0 then
        WebService:GetSumRechargeGCube(self.userId, function(gcube)
            for _, _func in pairs(self.uploadCallback) do
                _func(gcube)
            end
            self.uploadCallback = {}
            if gcube and self.total_recharge_cube ~= gcube then
                self.total_recharge_cube = gcube
                self:sendPacket({
                    pid = "TotalRechargeCube",
                    gcube = gcube,
                })
            end
        end)
    end
    table.insert(self.uploadCallback, func)
end

function SBasePlayer:getTotalRecharge()
    return self.total_recharge_cube or 0
end

function SBasePlayer:ifOnMount()
    if not self.entityPlayerMP then
        return false
    end
    return self.entityPlayerMP:isOnFlyingMount() or self.entityPlayerMP:isOnFloatingMount()
end

function SBasePlayer:isVip()
    local vip = VipRecord[self.userId]
    return vip and vip ~= 0
end

---@param grade number 特权档位
function SBasePlayer:isPrivilegeGrade(grade)
    local vip = UserPrivilegeGrade[self.userId]
    return vip and vip >= grade
end

BasePlayer = SBasePlayer

return BasePlayer
--endregion
