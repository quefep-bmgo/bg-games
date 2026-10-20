--[[ZX]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 4837
                          local checkFileName = "GUICustomGameMain.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[6IYeYAsgeuLtDjWiH9UKfHpZJxZ8rzQGbBrDxQaOrxSjgu2nEnSwkqYXKsxQvGlm0mhzTTFWhI43xDzBtZvo4R7iiCTgVUqgALbEIsJMN85rGlz1x1t2YGnchc60DaDeJPUcyzmeZSgU9QponDtCCjtZLXfSOa2okMHvJBDESmt9wgHzykAN1FXKy8pBY3lOWtLngLtPsz0avAjMSWGa1uTfFgDui5RQHf2wuvvDzO1sUCtz8qRLCG2ZW13]]---@class UICustomGameMainLayout : IGUILayout
local UICustomGameMainLayout = class("UICustomGameMainLayout", IGUILayout)

---@private
function UICustomGameMainLayout:ctor(...)
    local main = GUIManager:getMainControl()
    local screenW = GUISystem.Instance():GetScreenWidth()
    local screenH = GUISystem.Instance():GetScreenHeight()
    if screenW / screenH >= 2 then
        main:SetHorizontalAlignment(HorizontalAlignment.Center)
        main:SetWidth({ 1, -28 })
    end
    self.super.ctor(self, "CustomGameMain.json", main)
end

---@private
function UICustomGameMainLayout:isDelayLoad()
    return true
end

---@private
function UICustomGameMainLayout:onCreate()
    self:initCreateEvent()
end

---@private
function UICustomGameMainLayout:initCreateEvent()

end

---@private
function UICustomGameMainLayout:onLoad()
    self.llRank = self:getChildWindow("CustomGameMain-Rank", GUIType.Layout)
    self.llRankContent = self:getChildWindow("CustomGameMain-RankContent", GUIType.Layout)
    self.llRankTop = self:getChildWindow("CustomGameMain-Rank-Top", GUIType.Layout)
    self.stRankRank = self:getChildWindow("CustomGameMain-Rank-Rank", GUIType.StaticText)
    self.stRankTeam = self:getChildWindow("CustomGameMain-Rank-Team", GUIType.StaticText)
    self.stRankPlayerNum = self:getChildWindow("CustomGameMain-Rank-PlayerNum", GUIType.StaticText)
    self.stRankScore = self:getChildWindow("CustomGameMain-Rank-Score", GUIType.StaticText)
    self:initView()
    self:initEvent()
end

---@private
function UICustomGameMainLayout:initView()
    self.llRank:SetVisible(false)
    self.stRankRank:SetText(Lang:getString("final.summary.rank"))
    self.stRankTeam:SetText(Lang:getString("gui.text.team"))
    self.stRankPlayerNum:SetText(Lang:getString("gui.text.player.num"))
    self.stRankScore:SetText(Lang:getString("gui.text.score"))

    self.gvRankList = IGUIGridView.new("CustomGameMain-Rank-List", self.llRankContent)
    self.gvRankList:setConfig(0, 0, 1)
    ---@type RankItemAdapter
    self.rankAdapter = UIHelper.newGameAdapter("RankItemAdapter")
    self.gvRankList:setAdapter(self.rankAdapter)
end

---@private
function UICustomGameMainLayout:initEvent()
    self:registerEvent(Events.ShowFrontPlaceBlockEvent, function()
        if not isGameStart then
            return false
        end
        local heldItemId = PlayerManager:getClientPlayer():getHeldItemId()
        ---过滤有技能的方块
        local skill = SkillConfig:getSkill(heldItemId)
        if skill then
            return false
        end
        ---过滤保护墙和防御
        if heldItemId == 2418 or heldItemId == 2417 then
            return false
        end
        return true
    end)
end

function UICustomGameMainLayout:onRankBtnClick()
    local status = self.llRank:IsVisible()
    self.llRank:SetVisible(not status)
end

function UICustomGameMainLayout:updateTeamRank(data)
    -- self.stRankRank:SetText(Lang:getString("final.summary.rank"))
    if data.isTeamMatch then
        self.stRankTeam:SetText(Lang:getString("gui.text.team"))
    else
        self.stRankTeam:SetText(Lang:getString("gui.text.player"))
    end
    -- self.stRankPlayerNum:SetText(Lang:getString("gui.text.player.num"))
    if data.conditionType == Define.OverCondition.Marker or data.conditionType == Define.OverCondition.MarkerAndKill then
        self.stRankScore:SetText(Lang:getString("gui.text.marker"))
    else
        self.stRankScore:SetText(Lang:getString("gui.text.score"))
    end
    for _, v in ipairs(data.info) do
        v.isTeamMatch = data.isTeamMatch
        v.conditionType = data.conditionType
    end
    self.rankAdapter:setData(data.info)
    self.llRank:SetVisible(true)
end

function UICustomGameMainLayout:hideRank()
    self.llRank:SetVisible(false)
end

return UICustomGameMainLayout
--[[LDFs8vtC4gFAhG1JGEijF0IK1f]]---