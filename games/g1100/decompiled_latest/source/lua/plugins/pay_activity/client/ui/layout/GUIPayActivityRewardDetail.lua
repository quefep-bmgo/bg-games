---@class UIPayActivityRewardDetailLayout : IGUILayout
local UIPayActivityRewardDetailLayout = class("UIPayActivityRewardDetailLayout", IGUILayout)
---@type PayActivityRewardConfig
local PayActivityRewardConfig = T(Global, "PayActivityRewardConfig")

---@private
function UIPayActivityRewardDetailLayout:ctor(parent)
    self.super.ctor(self, "PayActivityRewardDetail.json", parent)
end

---@private
function UIPayActivityRewardDetailLayout:isDelayLoad()
    return true
end

---@private
function UIPayActivityRewardDetailLayout:onCreate()
    self:initCreateEvent()
end

---@private
function UIPayActivityRewardDetailLayout:initCreateEvent()

end

---@private
function UIPayActivityRewardDetailLayout:onLoad()
    self.llClose = self:getChildWindow("PayActivityRewardDetail-Close", GUIType.Layout)
    self.llContent = self:getChildWindow("PayActivityRewardDetail-Content", GUIType.Layout)
    self.stTopTitle = self:getChildWindow("PayActivityRewardDetail-Top-Title", GUIType.StaticText)
    self.awActor = self:getChildWindow("PayActivityRewardDetail-Actor", GUIType.ActorWindow)
    self.siImageBg = self:getChildWindow("PayActivityRewardDetail-Image-Bg", GUIType.StaticImage)
    self.siImage = self:getChildWindow("PayActivityRewardDetail-Image", GUIType.StaticImage)
    self.llDescBg = self:getChildWindow("PayActivityRewardDetail-Desc-Bg", GUIType.Layout)
    self.stDesc = self:getChildWindow("PayActivityRewardDetail-Desc", GUIType.StaticText)
    self.stTip = self:getChildWindow("PayActivityRewardDetail-Tip", GUIType.StaticText)
    self.llActorSlide = self:getChildWindow("PayActivityRewardDetail-Actor-Slide", GUIType.Layout)
    self.btnCloseBtn = self:getChildWindow("PayActivityRewardDetail-Close-Btn", GUIType.Button)
    self:initView()
    self:initEvent()
end

---@private
function UIPayActivityRewardDetailLayout:initView()
    self.stTip:SetText(Lang:getString("gui.pay.activity.reward.detail.tip"))
end

---@private
function UIPayActivityRewardDetailLayout:initEvent()
    self.llClose:registerEvent(GUIEvent.Click, function()
        self:hide()
    end)
    self.btnCloseBtn:registerEvent(GUIEvent.ButtonClick, function()
        self:hide()
    end)
end

function UIPayActivityRewardDetailLayout:onShow(rewardId,dontShowActor)
    local reward = PayActivityRewardConfig:getCfgById(rewardId)
    if not reward then
        self:hide()
        return
    end
    if self.rewardId == rewardId then
        return
    end
    self.root:SetLevel(3)
    self:setAlwaysOnTop(true)
    self.rewardId = rewardId
    if dontShowActor then
        self.awActor:SetVisible(false)
        PayActivityRewardConfig:setRewardDetailUI(reward, self.siImage, self.stTopTitle, self.stDesc, nil, self.llActorSlide)
    else
        self.awActor:SetVisible(true)
        PayActivityRewardConfig:setRewardDetailUI(reward, self.siImage, self.stTopTitle, self.stDesc, self.awActor, self.llActorSlide)
    end
end

function UIPayActivityRewardDetailLayout:onHide()
    self.root:SetLevel(50)
    self:setAlwaysOnTop(false)
end

return UIPayActivityRewardDetailLayout
