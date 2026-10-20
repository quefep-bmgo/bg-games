--[[0qnc7SS1VLSwGe5VXVEobSwYs]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 18421
                          local checkFileName = "GUIVideoMain.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[Szi1c]]---@type RecorderUtil
local RecorderUtil = T(Global, "RecorderUtil")
---@type VideoEffectConfig
local VideoEffectConfig = T(Global, "VideoEffectConfig")
---@type Define
local Define = T(Global, "Define")
---@type ReportValue
local ReportValue = T(Global, "ReportValue")
---@type ReportEvent
local ReportEvent = T(Global, "ReportEvent")
---@class UIVideoMainLayout : IGUILayout
local UIVideoMainLayout = class("UIVideoMainLayout", IGUILayout)

local VideoStatus = {
    Stopped = 1,
    Preparing = 2,
    Started = 3,
}

local VideoStatusExtra = {
    ActiveStart = 1,
    ActiveStop = 2,
    AutoStart = 3,
    AutoStop = 4,
    ExitStop = 5,
}

---@private
function UIVideoMainLayout:ctor(parent)
    self.super.ctor(self, "VideoMain.json", parent)
end

---@private
function UIVideoMainLayout:isDelayLoad()
    return true
end

---@private
function UIVideoMainLayout:isAlwaysShow()
    return self.isOpen
end

---@private
function UIVideoMainLayout:isIgnoreLock()
    return true
end

---@private
function UIVideoMainLayout:onCreate()
    RecorderUtil:addHideUiWhiteList({
        "VideoMain",
        "GMMain",
        "GMControlPanel",
    })
    local whiteList = {
        "Main-Control",
        "Main-PoleControl",
        "Main-PoleControl-Move",
        "Main-Main-Skill-Operate",
        "Main-Jump-Controls",
        "Main-Cannon",
    }
    RecorderUtil:addHideUiWhiteList(whiteList)
    RecorderUtil:addAlphaToZeroUiList(whiteList)
    self:initCreateEvent()
end

---@private
function UIVideoMainLayout:initCreateEvent()

end

---@private
function UIVideoMainLayout:onLoad()
    self.llHandleList = self:getChildWindow("VideoMain-HandleList", GUIType.Layout)
    self.siBackImage = self:getChildWindow("VideoMain-BackImage", GUIType.StaticImage)
    self.llHideSettingList = self:getChildWindow("VideoMain-HideSettingList", GUIType.Layout)
    self.btnHideName = self:getChildWindow("VideoMain-HideName", GUIType.Button)
    self.stHideNameText = self:getChildWindow("VideoMain-HideNameText", GUIType.StaticText)
    self.siHideNameCircle = self:getChildWindow("VideoMain-HideNameCircle", GUIType.StaticImage)
    self.btnHideOtherPlayer = self:getChildWindow("VideoMain-HideOtherPlayer", GUIType.Button)
    self.stHideOtherPlayerText = self:getChildWindow("VideoMain-HideOtherPlayerText", GUIType.StaticText)
    self.siHideOtherPlayerCircle = self:getChildWindow("VideoMain-HideOtherPlayerCircle", GUIType.StaticImage)
    self.btnHideSelf = self:getChildWindow("VideoMain-HideSelf", GUIType.Button)
    self.stHideSelfText = self:getChildWindow("VideoMain-HideSelfText", GUIType.StaticText)
    self.siHideSelfCircle = self:getChildWindow("VideoMain-HideSelfCircle", GUIType.StaticImage)
    self.btnEffect = self:getChildWindow("VideoMain-Effect", GUIType.Button)
    self.btnHideUI = self:getChildWindow("VideoMain-HideUI", GUIType.Button)
    self.btnHideSetting = self:getChildWindow("VideoMain-HideSetting", GUIType.Button)
    self.siHideSettingArrow = self:getChildWindow("VideoMain-HideSettingArrow", GUIType.StaticImage)
    self.btnHide = self:getChildWindow("VideoMain-Hide", GUIType.Button)
    self.btnVideo = self:getChildWindow("VideoMain-Video", GUIType.Button)
    self.siHideArrow = self:getChildWindow("VideoMain-HideArrow", GUIType.StaticImage)
    self.llEffectListPanel = self:getChildWindow("VideoMain-EffectListPanel", GUIType.Layout)
    self.llCloseEffect = self:getChildWindow("VideoMain-CloseEffect", GUIType.Layout)
    self.btnTabFilter = self:getChildWindow("VideoMain-TabFilter", GUIType.Button)
    self.btnTabWeather = self:getChildWindow("VideoMain-TabWeather", GUIType.Button)
    self.btnTabScreenEffect = self:getChildWindow("VideoMain-TabScreenEffect", GUIType.Button)
    self.llTabDataList = self:getChildWindow("VideoMain-TabDataList", GUIType.Layout)
    self.btnExitBtn = self:getChildWindow("VideoMain-ExitBtn", GUIType.Button)
    self:initView()
    self:initEvent()
end

---@private
function UIVideoMainLayout:initView()
    self.stHideNameText:SetText(Lang:getString("gui.new_video.hide.setting.data1"))
    self.stHideOtherPlayerText:SetText(Lang:getString("gui.new_video.hide.setting.data2"))
    self.stHideSelfText:SetText(Lang:getString("gui.new_video.hide.setting.data3"))
    self.btnEffect:SetText(Lang:getString("gui.new_video.handle.tab1"))
    self.btnHideUI:SetText(Lang:getString("gui.new_video.handle.tab2"))
    self.btnHideSetting:SetText(Lang:getString("gui.new_video.handle.tab3"))
    self.btnTabFilter:SetText(Lang:getString("gui.new_video.tab1"))
    self.btnTabWeather:SetText(Lang:getString("gui.new_video.tab2"))
    self.btnTabScreenEffect:SetText(Lang:getString("gui.new_video.tab3"))
    self.curSelectTab = self.btnTabFilter
    self.videoStatus = VideoStatus.Stopped
    self.btnHide:SetTextColor(Color.TRANS)
    self:updateVideoButtonUI()
    self.isHideUI = false
end

---@private
function UIVideoMainLayout:initEvent()
    self.btnHideName:registerEvent(GUIEvent.ButtonClick, function()
        self.siHideNameCircle:SetVisible(not self.siHideNameCircle:IsVisible())
        RecorderUtil:setHideName(self.siHideNameCircle:IsVisible())
    end)
    self.btnHideOtherPlayer:registerEvent(GUIEvent.ButtonClick, function()
        self.siHideOtherPlayerCircle:SetVisible(not self.siHideOtherPlayerCircle:IsVisible())
        RecorderUtil:setHideOtherPlayers(self.siHideOtherPlayerCircle:IsVisible())
        RecorderUtil:setHidePlayerOnly(self.siHideOtherPlayerCircle:IsVisible())
    end)
    self.btnHideSelf:registerEvent(GUIEvent.ButtonClick, function()
        self.siHideSelfCircle:SetVisible(not self.siHideSelfCircle:IsVisible())
        RecorderUtil:setHideSelf(self.siHideSelfCircle:IsVisible())
    end)
    self.btnEffect:registerEvent(GUIEvent.ButtonClick, function()
        self.llEffectListPanel:SetVisible(true)
        self.btnEffect:SetNormalImage("set:plugin_video.json image:btn_9_white_select")
        self.btnEffect:SetPushedImage("set:plugin_video.json image:btn_9_white_select")
        ReportEvent.reportEvent(Game:getPlatformUserId(), "video_press", nil, {
            reason1 = "filter"
        })
        if self.lvEffectList then
            return
        end
        self:changeEffectList(Define.VideoEffectType.Filter)
    end)
    self.btnHideUI:registerEvent(GUIEvent.ButtonClick, function()
        self:setHideUI(not self.isHideUI)
        ReportEvent.reportEvent(Game:getPlatformUserId(), "video_press", nil, {
            reason1 = "hideUI"
        })
    end)
    self.btnHideSetting:registerEvent(GUIEvent.ButtonClick, function()
        self.llHideSettingList:SetVisible(not self.llHideSettingList:IsVisible())
        self.siHideSettingArrow:SetImage(self.llHideSettingList:IsVisible()
                and "set:plugin_video.json image:img_0_arrow1_up" or "set:plugin_video.json image:img_0_arrow1_down")
        if self.llHideSettingList:IsVisible() then
            ReportEvent.reportEvent(Game:getPlatformUserId(), "video_press", nil, {
                reason1 = "hideSetting"
            })
        end
    end)
    self.btnHide:registerEvent(GUIEvent.ButtonClick, function()
        self:setHideHandle(self.llHandleList:GetYPosition()[2] >= -10)
        if self.btnExitBtn:IsVisible() then
            ReportEvent.reportEvent(Game:getPlatformUserId(), "video_press", nil, {
                reason1 = "push"
            })
        else
            ReportEvent.reportEvent(Game:getPlatformUserId(), "video_press", nil, {
                reason1 = "pull"
            })
        end
    end)
    self.btnVideo:registerEvent(GUIEvent.ButtonClick, function()
        if self.videoStatus == VideoStatus.Preparing then
            return
        end
        if self.videoStatus == VideoStatus.Stopped then
            self:changeVideoStatus(VideoStatusExtra.ActiveStart)
        else
            self:changeVideoStatus(VideoStatusExtra.ActiveStop)
        end
    end)
    self.btnTabFilter:registerEvent(GUIEvent.ButtonClick, function()
        if not self:setSelectTab(self.btnTabFilter) then
            return
        end
        self:changeEffectList(Define.VideoEffectType.Filter)

    end)
    self.btnTabWeather:registerEvent(GUIEvent.ButtonClick, function()
        if not self:setSelectTab(self.btnTabWeather) then
            return
        end
        self:changeEffectList(Define.VideoEffectType.Weather)
    end)
    self.btnTabScreenEffect:registerEvent(GUIEvent.ButtonClick, function()
        if not self:setSelectTab(self.btnTabScreenEffect) then
            return
        end
        self:changeEffectList(Define.VideoEffectType.ScreenEffect)
    end)
    self.btnExitBtn:registerEvent(GUIEvent.ButtonClick, function()
        if self.isHideUI then
            self:setHideUI(false)
        end
        self.isOpen = false
        self:hide()
    end)
    self.llCloseEffect:registerEvent(GUIEvent.Click, function()
        self.llEffectListPanel:SetVisible(false)
        self.btnEffect:SetNormalImage("set:plugin_video.json image:btn_9_white")
        self.btnEffect:SetPushedImage("set:plugin_video.json image:btn_9_white")
    end)
end

function UIVideoMainLayout:setHideUI(hide)
    self.isHideUI = hide
    --self.btnHideUI:SetText(Lang:getString("gui.new_video.handle.tab2"))
    self:setHideHandle(self.isHideUI)
    RecorderUtil:setHideUi(self.isHideUI)
end

function UIVideoMainLayout:setHideHandle(hide)
    self.llHandleList:SetYPosition({ 0, hide and -90 or 0 })
    self.siHideArrow:SetImage(hide
            and "set:plugin_video.json image:img_0_arrow2_up" or "set:plugin_video.json image:img_0_arrow2_down")
    if hide then
        self.llHideSettingList:SetVisible(false)
        self.siHideSettingArrow:SetImage("set:plugin_video.json image:img_0_arrow1_down")
        self.btnHide:SetTextColor(Color.WHITE)
        self.siHideArrow:SetVisible(self.videoStatus == VideoStatus.Stopped)
        self.siBackImage:SetImage(self.videoStatus == VideoStatus.Stopped and
                "set:plugin_video.json image:img_0_board" or "set:plugin_video.json image:img_0_board_red")
    else
        if self.isHideUI then
            self:setHideUI(false)
        end
        self.btnHide:SetTextColor(Color.TRANS)
        self.siHideArrow:SetVisible(true)
        self.siBackImage:SetImage("set:plugin_video.json image:img_0_board")
    end
    self.btnExitBtn:SetVisible(not hide)
    --if hide then
    --    self.btnHide:SetNormalImage("set:plugin_video.json image:btn_9_yellow")
    --    self.btnHide:SetPushedImage("set:plugin_video.json image:btn_9_yellow")
    --else
    --    self.btnHide:SetNormalImage("set:plugin_video.json image:btn_0_hide")
    --    self.btnHide:SetPushedImage("set:plugin_video.json image:btn_0_hide")
    --end
end

function UIVideoMainLayout:setSelectTab(btnTab)
    if self.curSelectTab == btnTab then
        return false
    end
    self.curSelectTab = btnTab
    ---@type GUIButton[]
    local tabs = { self.btnTabFilter, self.btnTabWeather, self.btnTabScreenEffect }
    for _, tab in pairs(tabs) do
        if tab == self.curSelectTab then
            tab:SetNormalImage("set:plugin_video.json image:chb_0_eff_click")
            tab:SetPushedImage("set:plugin_video.json image:chb_0_eff_click")
        else
            tab:SetNormalImage("set:plugin_video.json image:chb_0_eff")
            tab:SetPushedImage("set:plugin_video.json image:chb_0_eff")
        end
    end
    return true
end

function UIVideoMainLayout:changeEffectList(tabId)
    local cfgs = VideoEffectConfig:getCfgByTabId(tabId)
    if not self.lvEffectList then
        self.lvEffectList = IGUIListView.new("VideoMain-Effect-List", self.llTabDataList)
        self.lvEffectList:setItemSpace(8)
    else
        self.lvEffectList:clearItems()
    end
    for _, cfg in pairs(cfgs) do
        ---@type GUIVideoEffectItemWindow
        local item = UIHelper.newGameGUIWindow("GUIVideoEffectItem")
        item:onDataChanged(cfg, function(selected)
            ---@param child GUIVideoEffectItemWindow
            for _, child in pairs(self.lvEffectList.items) do
                if child == item then
                    child:setSelected(selected)
                else
                    child:setSelected(false)
                end
            end
        end)
        self.lvEffectList:addItem(item)
    end
end

function UIVideoMainLayout:onShow()
    self.isOpen = true
    self.videoStatus = VideoStatus.Stopped
    self:updateVideoButtonUI()
    self.siHideArrow:SetVisible(true)
    self.btnHide:SetText("")
    self.siBackImage:SetImage("set:plugin_video.json image:img_0_board")

    ---@type GUIVideoEffectItemWindow
    local GUIVideoEffectItemWindow = UIHelper.requireGUIWindow("GUIVideoEffectItem", false)
    GUIVideoEffectItemWindow.restoreAllEffect()
    self.startVideoTime = os.time()
    ReportValue.setValue(Game:getPlatformUserId(), "video_time", 0)
    ReportEvent.reportEvent(Game:getPlatformUserId(), "video_press", nil, {
        reason1 = "entrance"
    })
    if not RecorderUtil:isVideoRecordSupported() then
        ReportEvent.reportEvent(Game:getPlatformUserId(), "error_not_available")
    end
end

function UIVideoMainLayout:onHide()
    Blockman.Instance().m_gameSettings:setLutTextureName("")
    RecorderUtil:setWeather(nil, true)
    RecorderUtil:removeAllUiEffects()
    RecorderUtil:enableTopBottomCover(true)
    RecorderUtil:enablePatternTorch(true)
    RecorderUtil:enableSpeedLine(true)
    self.llHideSettingList:SetVisible(false)
    self.siHideSettingArrow:SetImage("set:plugin_video.json image:img_0_arrow1_down")
    local videoTime = os.time() - self.startVideoTime
    if videoTime > 0 then
        ReportValue.setValue(Game:getPlatformUserId(), "video_time", videoTime)
        ReportEvent.reportEvent(Game:getPlatformUserId(), "video_time")
    end
    ReportEvent.reportEvent(Game:getPlatformUserId(), "video_press", nil, {
        reason1 = "exit"
    })
    LuaTimer:cancel(self.startTimer)
    LuaTimer:cancel(self.preparingTimer)
    if self.videoStatus == VideoStatus.Started then
        self:changeVideoStatus(VideoStatusExtra.ExitStop)
    end
end

function UIVideoMainLayout:onDestroy()

end

function UIVideoMainLayout:updateVideoButtonUI()
    if not RecorderUtil:isVideoRecordSupported() then
        self.btnVideo:SetVisible(false)
        return
    end
    if self.videoStatus == VideoStatus.Stopped then
        self.btnVideo:SetNormalImage("set:plugin_video.json image:btn_0_record")
        self.btnVideo:SetPushedImage("set:plugin_video.json image:btn_0_record")
        self.btnVideo:SetText("")
    elseif self.videoStatus == VideoStatus.Preparing then
        self.btnVideo:SetNormalImage("set:plugin_video.json image:btn_9_white")
        self.btnVideo:SetPushedImage("set:plugin_video.json image:btn_9_white")
        self.btnVideo:SetTextColor({ 1, 94 / 255, 76 / 255, 1 })
        self.btnVideo:SetProperty("Font", "HT18")
    elseif self.videoStatus == VideoStatus.Started then
        self.btnVideo:SetNormalImage("set:plugin_video.json image:btn_0_record_time1")
        self.btnVideo:SetPushedImage("set:plugin_video.json image:btn_0_record_time1")
        self.btnVideo:SetTextColor(Color.WHITE)
        self.btnVideo:SetProperty("Font", "HT14")
    end
end

function UIVideoMainLayout:onTick()
    if self.videoStatus == VideoStatus.Stopped then
        return
    end
    self.btnHide:SetText(self.countdown)
end

function UIVideoMainLayout:changeVideoStatus(extra)
    if self.videoStatus == VideoStatus.Stopped then
        self.videoStatus = VideoStatus.Preparing
        ReportEvent.reportEvent(Game:getPlatformUserId(), "video_start")
    elseif self.videoStatus == VideoStatus.Preparing then
        self.videoStatus = VideoStatus.Started
    elseif self.videoStatus == VideoStatus.Started then
        self.videoStatus = VideoStatus.Stopped
        LuaTimer:cancel(self.startTimer)
        ReportEvent.reportEvent(Game:getPlatformUserId(), "video_end")
    end
    self:updateVideoButtonUI()
    if self.videoStatus == VideoStatus.Stopped then
        self.siHideArrow:SetVisible(true)
        self.btnHide:SetText("")
        self.siBackImage:SetImage("set:plugin_video.json image:img_0_board")
        RecorderUtil:videoRecordStop()
    elseif self.videoStatus == VideoStatus.Preparing then
        local time = 3
        self.countdown = tostring(time)
        self.btnVideo:SetText(self.countdown)
        self.preparingTimer = LuaTimer:scheduleTimerWithEnd(function()
            time = time - 1
            self.countdown = tostring(time)
            self.btnVideo:SetText(self.countdown)
        end, function()
            if time == 0 then
                self:changeVideoStatus(VideoStatusExtra.AutoStart)
            end
        end, 1000, time)
    elseif self.videoStatus == VideoStatus.Started then
        RecorderUtil:videoRecordStart()
        local maxTime = 3600
        local time = 0
        self.countdown = DateUtil.getFormatTime(time, "mm:ss")
        self.btnVideo:SetText(self.countdown)
        self.startTimer = LuaTimer:scheduleTimerWithEnd(function()
            time = time + 1
            self.countdown = DateUtil.getFormatTime(time, "mm:ss")
            self.btnVideo:SetText(self.countdown)
        end, function()
            ReportEvent.reportEvent(Game:getPlatformUserId(), "video_start_time", time)
            ReportEvent.reportEvent(Game:getPlatformUserId(), "error_time")
            if time < maxTime then
                return
            end
            self.startTimer = nil
            self:changeVideoStatus(VideoStatusExtra.AutoStop)
        end, 1000, maxTime)
    end
end

return UIVideoMainLayout
--[[S8teWa8m5WDy2eErQ8Mc1oGUd]]---