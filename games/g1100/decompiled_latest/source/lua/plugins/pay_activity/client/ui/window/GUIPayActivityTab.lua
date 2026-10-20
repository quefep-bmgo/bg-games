---@class GUIPayActivityTabWindow : IGUIWindow
local GUIPayActivityTabWindow = class("GUIPayActivityTabWindow", IGUIWindow)

---@private
function GUIPayActivityTabWindow:ctor(...)
    self.super.ctor(self, "PayActivityTab.json", ...)
end

---@private
function GUIPayActivityTabWindow:onLoad()
    self.llRoot = DynamicCast.dynamicCastWindow(GUIType.Layout, self.root)
    self.stName = self:getChildWindowByName("PayActivityTab-Name", GUIType.StaticText)
    self.llSelected = self:getChildWindowByName("PayActivityTab-Selected", GUIType.Layout)
    self:initView()
    self:initEvent()
end

---@private
function GUIPayActivityTabWindow:initView()
    ---@type UIPayActivityLayout
    self.parent = UIHelper.newGameGUILayout("GUIPayActivity")
end

---@private
function GUIPayActivityTabWindow:initEvent()
    self.llRoot:registerEvent(GUIEvent.Click, function()
        SoundUtil.clickUI()
        self.parent:setCurSelectActivity(self.activity)
    end)
end

---@param activity IPayActivity
function GUIPayActivityTabWindow:onDataChanged(activity)
    if self.activity ~= activity then
        local key = "pay_activity:" .. activity.cfg.id
        Plugins.CallTargetPluginFunc("red_dot", "redDotBuild", self.llRoot, key, nil, {
            customImage = "set:limited_time_activity.json image:img_0_red_dot",
            offset = { x = -2, y = -6 }
        })
    end
    self.activity = activity
    self.stName:SetText(Lang:getString(activity.cfg.tabName))
    self.llRoot:SetBackImage(activity.cfg.tabImage)
    self.llSelected:SetVisible(activity == self.parent.curSelectActivity)
end

return GUIPayActivityTabWindow
