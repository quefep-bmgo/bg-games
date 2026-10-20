---@class GUIFisherManGiftRewardWindow : IGUIWindow
local GUIFisherManGiftRewardWindow = class("GUIFisherManGiftRewardWindow", IGUIWindow)
---@type PayActivityRewardConfig
local PayActivityRewardConfig = T(Global, "PayActivityRewardConfig")

---@private
function GUIFisherManGiftRewardWindow:ctor(...)
    self.super.ctor(self, "FisherManGiftReward.json", ...)
end

---@private
function GUIFisherManGiftRewardWindow:onLoad()
    self.llRoot = DynamicCast.dynamicCastWindow(GUIType.Layout, self.root)
    self.siImage = self:getChildWindowByName("FisherManGiftReward-Image", GUIType.StaticImage)
    self.siEffect = self:getChildWindowByName("FisherManGiftReward-Effect", GUIType.StaticImage)
    self.stCount = self:getChildWindowByName("FisherManGiftReward-Count", GUIType.StaticText)
    self.llReceived = self:getChildWindowByName("FisherManGiftReward-Received", GUIType.Layout)
    self:initView()
    self:initEvent()
end

---@private
function GUIFisherManGiftRewardWindow:initView()
    self.siEffect:SetVisible(false)
end

---@private
function GUIFisherManGiftRewardWindow:initEvent()
    self.llRoot:registerEvent(GUIEvent.Click, function()
        UIHelper.showGameGUILayout("GUIPayActivityRewardDetail", self.data.id)
    end)
end

---@param data PayActivityRewardConfigData
---@param activity FisherManGift
function GUIFisherManGiftRewardWindow:onDataChanged(data, activity)
    self.data = data
    self.activity = activity
    PayActivityRewardConfig:setRewardQuality(self.llRoot, data, true)
    PayActivityRewardConfig:setRewardImage(self.siImage, data)
    if data.count > 1 then
        self.stCount:SetText("x" .. data.count)
    else
        self.stCount:SetText("")
    end
    self.siEffect:SetVisible(data.quality == 3)
    self:updateState()
end

function GUIFisherManGiftRewardWindow:updateState()
    local record = self.activity.info:getValue("Record")
    if TableUtil.tableContain(record, self.data.id) then
        self.llReceived:SetVisible(true)
    else
        self.llReceived:SetVisible(false)
    end
end

return GUIFisherManGiftRewardWindow
