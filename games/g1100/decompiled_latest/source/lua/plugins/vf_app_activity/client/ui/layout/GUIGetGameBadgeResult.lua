---@class UIGetGameBadgeResultLayout : IGUILayout
local UIGetGameBadgeResultLayout = class("UIGetGameBadgeResultLayout", IGUILayout)

---@private
function UIGetGameBadgeResultLayout:ctor(parent)
    self.super.ctor(self, "GetGameBadgeResult.json", parent)
end

---@private
function UIGetGameBadgeResultLayout:isDelayLoad()
    return true
end

---@private
function UIGetGameBadgeResultLayout:onCreate()
    self:initCreateEvent()
end

---@private
function UIGetGameBadgeResultLayout:initCreateEvent()

end

---@private
function UIGetGameBadgeResultLayout:onLoad()
    self.siTitle = self:getChildWindow("GetGameBadgeResult-Title", GUIType.StaticImage)
    self.siRewardBG = self:getChildWindow("GetGameBadgeResult-RewardBG", GUIType.StaticImage)
    self.uivRewardImage = self:getChildWindow("GetGameBadgeResult-RewardImage", GUIType.UrlImage)
    self.btnConfirm = self:getChildWindow("GetGameBadgeResult-Confirm", GUIType.Button)
    self.siClose = self:getChildWindow("GetGameBadgeResult-Close", GUIType.StaticImage)
    self:initView()
    self:initEvent()
end

---@private
function UIGetGameBadgeResultLayout:initView()
    self.uivRewardImage:setChildMaterial(0)
    self.uivRewardImage:setDefaultImage("")
    self.btnConfirm:SetText(Lang:getString("gui.sure"))
    self.root:SetLevel(0)
end

---@private
function UIGetGameBadgeResultLayout:initEvent()
    self.btnConfirm:registerEvent(GUIEvent.ButtonClick, function()
        self:showDesc()
        self:hide()
    end)
    self.siClose:registerEvent(GUIEvent.Click, function()
        self:showDesc()
        self:hide()
    end)
    self.uivRewardImage:registerEvent(GUIEvent.Click, function()
        self:showDesc()
        self:hide()
    end)
end

function UIGetGameBadgeResultLayout:showDesc()
    ---@type UIGameBadgeDescLayout
    local layout = GUIManager:getLayout("GameBadgeDesc.json")
    if not layout then
        layout = UIHelper.newGameGUILayout("GUIGameBadgeDesc")
    end
    layout:showDesc(self.reward)
end

function UIGetGameBadgeResultLayout:showReward(reward)
    self:show()
    self.reward = reward
    self.uivRewardImage:setUrl(reward.badgeIcon)
end

return UIGetGameBadgeResultLayout
