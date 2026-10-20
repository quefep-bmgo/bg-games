---@class UIItemSkillMainLayout : IGUILayout
local UIItemSkillMainLayout = class("UIItemSkillMainLayout", IGUILayout)

local TeamBtnIconMap = {
    "set:bed_war_battle_info.json image:tab_red",
    "set:bed_war_battle_info.json image:tab_blue",
    "set:bed_war_battle_info.json image:tab_green",
    "set:bed_war_battle_info.json image:tab_yellow",
}

---@private
function UIItemSkillMainLayout:ctor(parent)
    self.super.ctor(self, "ItemSkillMain.json", parent)
end

---@private
function UIItemSkillMainLayout:onCreate()
    self:initCreateEvent()
end

---@private
function UIItemSkillMainLayout:initCreateEvent()

end

function UIItemSkillMainLayout:isMainControl()
    return true
end

---@private
function UIItemSkillMainLayout:onLoad()
    self.llEffect = self:getChildWindow("ItemSkillMain-Effect", GUIType.Layout)
    self.llSkillChoiceTeamLayout = self:getChildWindow("ItemSkillMain-Skill-Choice-Team-Layout", GUIType.Layout)
    self.btnSkillRelease = self:getChildWindow("ItemSkillMain-Skill-Release-btn", GUIType.Button)

    ---@type GUIWindow[]
    self.teamBtnList = {}
    table.insert(self.teamBtnList, self:getChildWindow("ItemSkillMain-Skill-Team1", GUIType.Button))
    table.insert(self.teamBtnList, self:getChildWindow("ItemSkillMain-Skill-Team2", GUIType.Button))
    table.insert(self.teamBtnList, self:getChildWindow("ItemSkillMain-Skill-Team3", GUIType.Button))

    local btnSkillRelease = GUIManager:getWindowByName("Main-Skill-Release-btn", GUIType.Button)
    self.btnSkillRelease:SetArea(btnSkillRelease:GetXPosition(), btnSkillRelease:GetYPosition(), { 0, 120 }, { 0, 120 })

    if Plugins.IsLoaded("custom_control") then
        Plugins.CallTargetPluginFunc("custom_control", "updateControlUi", {"Skill"})
    end

    self:initView()
    self:initEvent()
end

---@private
function UIItemSkillMainLayout:initView()

end

---@private
function UIItemSkillMainLayout:initEvent()
    self.btnSkillRelease:registerEvent(GUIEvent.ButtonClick, function()
        self:clickSkillBtn()
    end)

    for index, button in pairs(self.teamBtnList) do
        button:registerEvent(GUIEvent.ButtonClick, function()
            self:clickTeamBtn(index)
        end)
    end
end
function UIItemSkillMainLayout:clickSkillBtn()
    local lua_player = PlayerManager:getClientPlayer()
    local holdId = lua_player:getHeldItemId()
    local skill = SkillConfig:getSkill(holdId)
    if not skill then
        return
    end
    if skill.isChoiceTeam then
        self:showChoiceTeam()
    else
        self:sendReleaseSkill()
    end
end

function UIItemSkillMainLayout:getTeamId(index)
    ---@type ClientPlayer
    local clientPlayer = PlayerManager:getClientPlayer()
    local selfTeamId = clientPlayer:getTeamId()
    if index < selfTeamId then
        return index
    else
        return index + 1
    end
end

function UIItemSkillMainLayout:clickTeamBtn(index)
    local lua_player = PlayerManager:getClientPlayer()
    self.llSkillChoiceTeamLayout:SetVisible(false)
    lua_player:sendPacket({
        pid = "UpdateSkillParam",
        teamId = self:getTeamId(index)
    })
    self:sendReleaseSkill()
end

function UIItemSkillMainLayout:showChoiceTeam()
    if self.llSkillChoiceTeamLayout:IsVisible() then
        self.llSkillChoiceTeamLayout:SetVisible(false)
        return
    end
    self.llSkillChoiceTeamLayout:SetVisible(true)

    for index, button in pairs(self.teamBtnList) do
        local icon = TeamBtnIconMap[self:getTeamId(index)]
        local teamImage = DynamicCast.dynamicCastWindow(GUIType.StaticImage, button:GetChildByIndex(0))
        teamImage:SetImage(icon)
    end
end

function UIItemSkillMainLayout:sendReleaseSkill()
    local lua_player = PlayerManager:getClientPlayer()
    Blockman.Instance().m_playerControl:useItem(lua_player.Player, EngineWorld:getWorld(), lua_player.Player:getHeldItem())
end

function UIItemSkillMainLayout:onTick()
    if self.mainBtnSkillRelease == nil then
        self.mainBtnSkillRelease = GUIManager:getWindowByName("Main-Skill-Release-btn", GUIType.Button)
    end
    self.mainBtnSkillRelease:SetVisible(false)

    local lua_player = PlayerManager:getClientPlayer()
    local holdId = lua_player:getHeldItemId()
    local skill = SkillConfig:getSkill(holdId)
    self.btnSkillRelease:SetVisible(skill and not skill.isPlaceBlock and not skill.isLongTouch and not skill.isFood)
    if self.llSkillChoiceTeamLayout:IsVisible() and (not skill or not skill.isChoiceTeam) then
        self.llSkillChoiceTeamLayout:SetVisible(false)
    end
end

---@param size Vector2
---@return number
function UIItemSkillMainLayout:setScreenEffect(effect, size, seconds)
    LuaTimer:cancel(self.effectKey or 0)
    seconds = seconds or 3
    size = size or VectorUtil.newVector2(300, 300)
    self.llEffect:SetVisible(true)
    self.llEffect:PlayEffect1("")
    self.llEffect:SetEffectName(effect)
    self.llEffect:SetWidth({ 0, size.x })
    self.llEffect:SetHeight({ 0, size.y })
    self.llEffect:SetYPosition({ 0, -size.y / 2 })
    self.effectKey = LuaTimer:scheduleWithEnd(function()
        self.llEffect:SetVisible(false)
    end, function()
        self.llEffect:SetVisible(false)
    end, seconds * 1000)
    return self.effectKey
end

return UIItemSkillMainLayout
