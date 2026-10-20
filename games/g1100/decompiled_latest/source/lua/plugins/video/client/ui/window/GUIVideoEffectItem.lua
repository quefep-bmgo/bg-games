---@class GUIVideoEffectItemWindow : IGUIWindow
local GUIVideoEffectItemWindow = class("GUIVideoEffectItemWindow", IGUIWindow)
---@type table<number, number>
local SelectedRecord = {}
---@type RecorderUtil
local RecorderUtil = T(Global, "RecorderUtil")
---@type VideoEffectConfig
local VideoEffectConfig = T(Global, "VideoEffectConfig")
---@type ReportEvent
local ReportEvent = T(Global, "ReportEvent")

function GUIVideoEffectItemWindow.restoreAllEffect()
    for tabId, sortIndex in pairs(SelectedRecord) do
        local cfg = VideoEffectConfig:getCfg(tabId, sortIndex)
        GUIVideoEffectItemWindow.updateEffect({ data = cfg }, true)
    end
end

---@private
function GUIVideoEffectItemWindow:ctor(...)
    self.super.ctor(self, "VideoEffectItem.json", ...)
end

---@private
function GUIVideoEffectItemWindow:onLoad()
    self.siIcon = self:getChildWindowByName("VideoEffectItem-Icon", GUIType.StaticImage)
    self.stTitleDec = self:getChildWindowByName("VideoEffectItem-TitleDec", GUIType.StaticText)
    self.siIconSelected = self:getChildWindowByName("VideoEffectItem-IconSelected", GUIType.StaticImage)
    self:initView()
    self:initEvent()
end

---@private
function GUIVideoEffectItemWindow:initView()
    self.siIconSelected:SetVisible(false)
end

---@private
function GUIVideoEffectItemWindow:initEvent()
    self.root:registerEvent(GUIEvent.Click, function()
        local selected = not self.siIconSelected:IsVisible()
        if selected then
            SelectedRecord[self.data.tabId] = self.data.sortIndex
        else
            SelectedRecord[self.data.tabId] = nil
        end
        if self.selectCallback then
            self.selectCallback(selected)
        end
        self:setSelected(selected)
        self:updateEffect(selected)
        if selected then
            ReportEvent.reportEvent(Game:getPlatformUserId(), "video_select", nil, {
                reason1 = self.data.tabId .. "_" .. self.data.sortIndex
            })
        end
    end)
end

function GUIVideoEffectItemWindow:updateEffect(selected)
    local cfg = self.data
    local type = cfg.eventType
    if type == "FilterLut" then
        Blockman.Instance().m_gameSettings:setLutTextureName(selected and cfg.param or "")
    elseif type == "FilterLightBlur" then
        RecorderUtil:enableFilterLightBlur(not selected)
    elseif type == "Weather" then
        RecorderUtil:setWeather(cfg.param, not selected)
    elseif type == "EffectMovie" then
        RecorderUtil:enableTopBottomCover(not selected)
    elseif type == "EffectTorch" then
        RecorderUtil:enablePatternTorch(not selected)
    elseif type == "EffectSpeed" then
        RecorderUtil:enableSpeedLine(not selected)
    elseif type == "UiEffect" then
        RecorderUtil:playUiEffect(cfg.param, not selected)
    end
end

---@param data VideoEffectConfigData
function GUIVideoEffectItemWindow:onDataChanged(data, selectCallback)
    self.data = data
    self.selectCallback = selectCallback
    self.siIcon:SetImage(data.icon)
    self.stTitleDec:SetText(Lang:getString(data.titleLang))
    local selected = SelectedRecord[self.data.tabId] == self.data.sortIndex
    if selected then
        self:setSelected(true)
        self:updateEffect(true)
    end
end

function GUIVideoEffectItemWindow:setSelected(selected)
    if self.siIconSelected:IsVisible() and not selected then
        self:updateEffect(false)
    end
    self.siIconSelected:SetVisible(selected)
end

return GUIVideoEffectItemWindow
