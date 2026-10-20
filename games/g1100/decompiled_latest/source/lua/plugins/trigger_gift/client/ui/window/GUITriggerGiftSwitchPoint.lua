---@class GUITriggerGiftSwitchPointWindow : IGUIWindow
local GUITriggerGiftSwitchPointWindow = class("GUITriggerGiftSwitchPointWindow", IGUIWindow)

---@private
function GUITriggerGiftSwitchPointWindow:ctor(...)
    self.super.ctor(self, "TriggerGiftSwitchPoint.json", ...)
end

---@private
function GUITriggerGiftSwitchPointWindow:onLoad()
    self.checkBox = self:getChildWindowByName("TriggerGiftSwitchPoint", GUIType.CheckBox)
    self.siImg = self:getChildWindowByName("TriggerGiftSwitchPoint-Img", GUIType.StaticImage)
    self.siTabImg = self:getChildWindowByName("TriggerGiftSwitchPoint-Tab-Image", GUIType.StaticImage)
    self:initEvent()
end

---@private
function GUITriggerGiftSwitchPointWindow:initEvent()

end

function GUITriggerGiftSwitchPointWindow:showIsSwitching(isSwitching)
    if isSwitching then
        self.siImg:SetImage("set:trigger_gift.json image:chb_0_select")
    else
        self.siImg:SetImage("set:trigger_gift.json image:chb_0_normal")
    end
end

return GUITriggerGiftSwitchPointWindow
