---@class GUITriggerGiftRewardItemWindow : IGUIWindow
local GUITriggerGiftRewardItemWindow = class("GUITriggerGiftRewardItemWindow", IGUIWindow)
local TriggerGiftRewardGroupConfig
TriggerGiftRewardGroupConfig = Plugins.Require("trigger_gift", "common.config.TriggerGiftRewardGroupConfig")

local BgImage = {
    green = "set:trigger_gift.json image:img_0_grade01",
    blue = "set:trigger_gift.json image:img_0_grade02",
    purple = "set:trigger_gift.json image:img_0_grade03",
    yellow = "set:trigger_gift.json image:img_0_grade04"
}

---@private
function GUITriggerGiftRewardItemWindow:ctor(...)
    self.super.ctor(self, "TriggerGiftRewardItem.json", ...)
end

---@private
function GUITriggerGiftRewardItemWindow:onLoad(json, parent)
    self.parent = parent
    self.llRoot = DynamicCast.dynamicCastWindow(GUIType.Layout, self.root)
    self.siBg = self:getChildWindowByName("TriggerGiftRewardItem-Bg", GUIType.StaticImage)
    self.siReward = self:getChildWindowByName("TriggerGiftRewardItem-Reward", GUIType.StaticImage)
    self.stNum = self:getChildWindowByName("TriggerGiftRewardItem-Num", GUIType.StaticText)
    self:initEvent()
end

function GUITriggerGiftRewardItemWindow:initEvent()
    self.llRoot:registerEvent(GUIEvent.Click, function()
        self.parent:clickItem(self)
    end)
end

---@param data TriggerGiftRewardGroupData
function GUITriggerGiftRewardItemWindow:onDataChanged(data)
    --self.siBg:SetImage(BgImage[data.quality])
    self.siReward:SetImage(data.image)
    if data.num == 1 then
        self.stNum:SetText(" ")
    else
        self.stNum:SetText(data.num)
    end
    data.numLang = data.num
    self.reward = data
end

return GUITriggerGiftRewardItemWindow
