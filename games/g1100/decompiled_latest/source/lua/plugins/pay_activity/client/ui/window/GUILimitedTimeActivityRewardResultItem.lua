---@class GUILimitedTimeActivityRewardResultItemWindow : IGUIWindow
local GUILimitedTimeActivityRewardResultItemWindow = class("GUILimitedTimeActivityRewardResultItemWindow", IGUIWindow)
---@type PayActivityRewardConfig
local PayActivityRewardConfig = T(Global, "PayActivityRewardConfig")

---@private
function GUILimitedTimeActivityRewardResultItemWindow:ctor(...)
    self.super.ctor(self, "LimitedTimeActivityRewardResultItem.json", ...)
end

---@private
function GUILimitedTimeActivityRewardResultItemWindow:onLoad()
    self.llRoot = DynamicCast.dynamicCastWindow(GUIType.Layout, self.root)
    self.siIcon = self:getChildWindowByName("LimitedTimeActivityRewardResultItem-Icon", GUIType.StaticImage)
    self.stCount = self:getChildWindowByName("LimitedTimeActivityRewardResultItem-Count", GUIType.StaticText)
    self.stName = self:getChildWindowByName("LimitedTimeActivityRewardResultItem-Name", GUIType.StaticText)
    self.siEffect = self:getChildWindowByName("LimitedTimeActivityRewardResultItem-Effect", GUIType.StaticImage)
    self:initView()
    self:initEvent()
end

---@private
function GUILimitedTimeActivityRewardResultItemWindow:initView()
    self.stCount:SetText()
    self.stName:SetText()
end

---@private
function GUILimitedTimeActivityRewardResultItemWindow:initEvent()

end

---@param data PayActivityRewardConfigData
function GUILimitedTimeActivityRewardResultItemWindow:onDataChanged(data)
    PayActivityRewardConfig:setRewardImage(self.siIcon, data)
    PayActivityRewardConfig:setRewardName(self.stName, data)
    local quality = data.quality or 1
    self.llRoot:SetBackImage("set:limited_time_activity.json image:img_frame_quality0".. quality)
    if data.count > 1 then
        self.stCount:SetText("x" .. data.count)
    else
        self.stCount:SetText("")
    end
    PayActivityRewardConfig:setRewardEffect(self.siEffect, data)
end

return GUILimitedTimeActivityRewardResultItemWindow
