---@class UIPayActivityMainLayout : IGUILayout
local UIPayActivityMainLayout = class("UIPayActivityMainLayout", IGUILayout)
---@type PayActivityConfig
local PayActivityConfig = T(Global, "PayActivityConfig")

---@private
function UIPayActivityMainLayout:ctor()
    self.super.ctor(self, "PayActivityMain.json", GUIManager:getMainControl())
end

---@private
function UIPayActivityMainLayout:isDelayLoad()
    return true
end

---@private
function UIPayActivityMainLayout:onCreate()
    self:initCreateEvent()
end

---@private
function UIPayActivityMainLayout:initCreateEvent()

end

---@private
function UIPayActivityMainLayout:onLoad()
    self:initView()
    self:initEvent()
end

---@private
function UIPayActivityMainLayout:initView()
    self.buttons = {}
end

---@private
function UIPayActivityMainLayout:initEvent()

end

function UIPayActivityMainLayout:createButton(index, cfg)
    local button = self.buttons[index]
    if button then
        return
    end
    button = GUIManager:createGUIWindow(GUIType.Button, "PayActivityMain-Button" .. index)
    button:SetNormalImage(cfg.image)
    button:SetPushedImage(cfg.image)
    button:SetProperty("Material", "CullBackLinear")
    button:SetArea(cfg.xPos or { 0, 0 }, cfg.yPos or { 0, 0 }, cfg.width or { 0, 50 }, cfg.height or { 0, 50 })
    button:SetHorizontalAlignment(cfg.hAlignment or HorizontalAlignment.Left)
    button:SetVerticalAlignment(cfg.vAlignment or VerticalAlignment.Top)
    button:registerEvent(GUIEvent.ButtonClick, function()
        UIHelper.showGameGUILayout(cfg.openUI)
    end)
    self.root:AddChildWindow(button)
    if cfg.redDot then
        Plugins.CallTargetPluginFunc("red_dot", "redDotBuild", button, cfg.redDot, nil, {
            customImage = "set:limited_time_activity.json image:img_0_red_dot",
            offset = { x = 4, y = -5 }
        })
    end
    if cfg.buttonLang then
        local text = GUIManager:createGUIWindow(GUIType.StaticText, "PayActivityMain-ButtonText" .. index)
        text:SetTextHorzAlign(HorizontalAlignment.Center)
        text:SetArea({ 0, 0 }, { 1, -5 }, { 1, 0 }, { 0, 30 })
        text:SetText(Lang:getString(cfg.buttonLang))
        text:SetBordered(true)
        text:SetProperty("Font", "HT14")
        button:AddChildWindow(text)
    end
    self.buttons[index] = button
end

function UIPayActivityMainLayout:removeButton(index)
    local button = self.buttons[index]
    if not button then
        return
    end
    GUIManager:destroyGUIWindow(button)
    self.buttons[index] = nil
end

function UIPayActivityMainLayout:onTick()
    local time = os.time()
    for index, cfg in pairs(PayActivityConfig.config.mainButton) do
        if time >= cfg.startDate and time < cfg.endDate then
            self:createButton(index, cfg)
        else
            self:removeButton(index)
        end
    end
end

return UIPayActivityMainLayout
