--[[l2SuZIW6rSgA2KWVs]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 8056
                          local checkFileName = "GUIMonsterMain.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[6IFR0tO6ccSbzLnzt77TqESCV3q5nyHW3TP3XRA7wiO7US97aPCQ1zoIHxSQYDs2QYoQNvzyllHxcrTgBkiGV]]---@class UIMonsterMainLayout : IGUILayout
local UIMonsterMainLayout = class("UIMonsterMainLayout", IGUILayout)

---@private
function UIMonsterMainLayout:ctor(parent)
    self.super.ctor(self, "MonsterMain.json", GUIManager:getMainControl())
end

---@private
function UIMonsterMainLayout:isDelayLoad()
    return true
end

---@private
function UIMonsterMainLayout:onCreate()
    self:initCreateEvent()
    self.curBloodBarRecord = nil
    self.allBloodBarRecord = {}
end

---@private
function UIMonsterMainLayout:initCreateEvent()

end

---@private
function UIMonsterMainLayout:onLoad()
    self.battle = PlayerManager:getClientPlayer().battle
    self.llBloodBar = self:getChildWindow("MonsterMain-BloodBar", GUIType.Layout)
    self.pbBloodBarValue = self:getChildWindow("MonsterMain-BloodBarValue", GUIType.ProgressBar)
    self.stBloodBarCount = self:getChildWindow("MonsterMain-BloodBarCount", GUIType.StaticText)
    self.siBloodBarHead = self:getChildWindow("MonsterMain-BloodBarHead", GUIType.StaticImage)
    self.stBloodBarBoss = self:getChildWindow("MonsterMain-BloodBarBoss", GUIType.StaticText)
    self.llDamageRank = self:getChildWindow("MonsterMain-DamageRank", GUIType.Layout)
    self.stTitleText = self:getChildWindow("MonsterMain-TitleText", GUIType.StaticText)
    self:initView()
    self:initEvent()
end

---@private
function UIMonsterMainLayout:initView()
    self.stBloodBarCount:SetText("")
    self.stBloodBarBoss:SetText("BOSS")
    self.llBloodBar:SetVisible(false)
    self.llDamageRank:SetVisible(false)
    self.lvDamageRank = IGUIListView.new("MonsterMain-DamageRankList", self.llDamageRank)
    self.lvDamageRank:setArea({ 0, 0 }, { 0, 48 }, { 1, 0 }, { 1, -48 })
    self.lvDamageRank.root:SetTouchable(false)
    ---@type DamageRankAdapter
    self.rankAdapter = UIHelper.newGameAdapter("DamageRankAdapter")
    self.lvDamageRank:setAdapter(self.rankAdapter)
    self.stTitleText:SetText(Lang:getString("gui.boss.damage.rank"))
end

---@private
function UIMonsterMainLayout:initEvent()

end

function UIMonsterMainLayout:onTick()
    self:updateBloodBar()
    self:updateDamageRank()
end

function UIMonsterMainLayout:updateBloodBar()
    if not self.curBloodBarRecord then
        self.llBloodBar:SetVisible(false)
        return
    end
    self.llBloodBar:SetVisible(true)
    local diff = self.curBloodBarRecord.varHp - self.curBloodBarRecord.curHp
    local speed = math.max(1, diff / 50)
    if speed > 0 then
        self.curBloodBarRecord.varHp = math.max(self.curBloodBarRecord.varHp - speed, self.curBloodBarRecord.curHp)
    end
    local count = 0
    if self.curBloodBarRecord.overflow ~= 0 then
        count = math.floor((self.curBloodBarRecord.varHp - self.curBloodBarRecord.overflow) / 100) + 1
    else
        count = math.floor(self.curBloodBarRecord.varHp / 100)
    end
    if count > 0 then
        self.stBloodBarCount:SetText("x" .. count)
    else
        self.stBloodBarCount:SetText("")
    end
    local index = (count % 5) + 1
    self.pbBloodBarValue:SetProgressImage("set:boss_damage_rank.json image:boss_hp_" .. index)
    if count < 1 then
        self.pbBloodBarValue:SetBackImage("")
    else
        local backIndex = index % 5 + 1
        self.pbBloodBarValue:SetBackImage("set:boss_damage_rank.json image:boss_hp_" .. backIndex)
    end
    if self.curBloodBarRecord.varHp > self.curBloodBarRecord.overflow then
        local value = 1 - ((self.curBloodBarRecord.maxHp - self.curBloodBarRecord.varHp) % 100) / 100
        self.pbBloodBarValue:SetProgress(value)
    else
        if self.curBloodBarRecord.overflow ~= 0 then
            self.pbBloodBarValue:SetProgress(self.curBloodBarRecord.varHp / self.curBloodBarRecord.overflow)
        else
            self.pbBloodBarValue:SetProgress(self.curBloodBarRecord.varHp / 100)
        end
    end
    if os.time() >= self.curBloodBarRecord.delete then
        self:clearMonsterBloodBar(self.curBloodBarRecord.entityId)
    end
end

function UIMonsterMainLayout:updateDamageRank()
    if not self.curBloodBarRecord then
        self.llDamageRank:SetVisible(false)
        return
    end
    local key = "monster_damage:" .. self.curBloodBarRecord.gid
    local isShowRank = self.battle:getValue(key) ~= nil
    if not isShowRank then
        self.llDamageRank:SetVisible(false)
        return
    end
    self.llDamageRank:SetVisible(true)
    local players = PlayerManager:getPlayers()
    local ranks = {}
    for _, player in pairs(players) do
        if player.battle then
            local damage = math.floor(player.battle:getValue(key) or 0)
            table.insert(ranks, { player.userId, damage })
        end
    end
    if #ranks > 1 then
        table.sort(ranks, function(a, b)
            return a[2] > b[2]
        end)
    end
    local selfRank
    for rank, item in pairs(ranks) do
        item[3] = rank
        if item[1] == Game:getPlatformUserId() then
            selfRank = TableUtil.copyTable1(item)
        end
    end
    while #ranks > 5 do
        ranks[#ranks] = nil
    end
    while #ranks < 5 do
        table.insert(ranks, {})
    end
    selfRank[4] = true
    table.insert(ranks, selfRank)
    self.rankAdapter:setData(ranks)
end

function UIMonsterMainLayout:showMonsterBloodBar(entityId, gid, curHp, maxHp, distance, icon)
    if UIHelper.isGameGUILayoutShow("GUIDefendBattleMain") then
        self:hide()
        return
    end
    local record = self.allBloodBarRecord[entityId]
    if not record then
        record = {
            entityId = entityId,
            gid = gid,
            varHp = curHp,
            curHp = curHp,
            maxHp = maxHp,
            overflow = maxHp % 100,
            distance = distance,
            delete = os.time() + 999999999,
            icon = icon,
        }
        self.allBloodBarRecord[entityId] = record
    else
        record.curHp = curHp
        record.maxHp = maxHp
        record.distance = distance
    end
    if self.curBloodBarRecord == nil or self.curBloodBarRecord.distance > record.distance then
        self.curBloodBarRecord = record
        self:show()
        self.siBloodBarHead:SetImage(self.curBloodBarRecord.icon)
    end
    if self.curBloodBarRecord ~= record then
        record.varHp = curHp
    end
end

function UIMonsterMainLayout:hideMonsterBloodBar(entityId)
    local time = os.time()
    local remove = self.allBloodBarRecord[entityId]
    if remove and remove.delete > time + 5 then
        remove.delete = time + 5
    end
end

function UIMonsterMainLayout:clearMonsterBloodBar(entityId)
    local remove = self.allBloodBarRecord[entityId]
    if remove then
        self.allBloodBarRecord[entityId] = nil
    end
    if remove == self.curBloodBarRecord then
        self.curBloodBarRecord = nil
    end
    for _, record in pairs(self.allBloodBarRecord) do
        if self.curBloodBarRecord == nil then
            self.curBloodBarRecord = record
        elseif self.curBloodBarRecord.distance > record.distance then
            self.curBloodBarRecord = record
        end
    end
    if self.curBloodBarRecord then
        self.siBloodBarHead:SetImage(self.curBloodBarRecord.icon)
    else
        self:hide()
    end
end

return UIMonsterMainLayout
--[[i9jsK]]