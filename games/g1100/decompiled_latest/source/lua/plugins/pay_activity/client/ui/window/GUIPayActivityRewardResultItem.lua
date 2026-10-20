---@class GUIPayActivityRewardResultItemWindow : IGUIWindow
local GUIPayActivityRewardResultItemWindow = class("GUIPayActivityRewardResultItemWindow", IGUIWindow)
---@type PayActivityRewardConfig
local PayActivityRewardConfig = T(Global, "PayActivityRewardConfig")

---@private
function GUIPayActivityRewardResultItemWindow:ctor(...)
    self.super.ctor(self, "PayActivityRewardResultItem.json", ...)
end

---@private
function GUIPayActivityRewardResultItemWindow:onLoad()
    self.llRoot = DynamicCast.dynamicCastWindow(GUIType.Layout, self.root)
    self.siIcon = self:getChildWindowByName("PayActivityRewardResultItem-Icon", GUIType.StaticImage)
    self.stCount = self:getChildWindowByName("PayActivityRewardResultItem-Count", GUIType.StaticText)
    self.stName = self:getChildWindowByName("PayActivityRewardResultItem-Name", GUIType.StaticText)
    self:initView()
    self:initEvent()
end

---@private
function GUIPayActivityRewardResultItemWindow:initView()
    self.stCount:SetText()
    self.stName:SetText()
end

---@private
function GUIPayActivityRewardResultItemWindow:initEvent()

end

---@param data PayActivityRewardConfigData
function GUIPayActivityRewardResultItemWindow:onDataChanged(data)
    PayActivityRewardConfig:setRewardQuality(self.llRoot, data, true)
    PayActivityRewardConfig:setRewardImage(self.siIcon, data)
    PayActivityRewardConfig:setRewardName(self.stName, data)
    if data.count > 1 then
        self.stCount:SetText("x" .. data.count)
    else
        self.stCount:SetText("")
    end
end

return GUIPayActivityRewardResultItemWindow
