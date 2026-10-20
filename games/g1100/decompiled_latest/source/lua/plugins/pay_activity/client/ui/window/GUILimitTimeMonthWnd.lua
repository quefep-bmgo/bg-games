---@class GUILimitTimeMonthWndWindow : IGUIWindow
local GUILimitTimeMonthWndWindow = class("GUILimitTimeMonthWndWindow", IGUIWindow)

---@type LimitedTimeMonthGiftConfig
local LimitedTimeMonthGiftConfig = T(Global, "LimitedTimeMonthGiftConfig")

---@type ReportEvent
local ReportEvent = T(Global, "ReportEvent")

---@private
function GUILimitTimeMonthWndWindow:ctor(...)
	self.super.ctor(self, "LimitTimeMonthWnd.json", ...)
end

---@private
function GUILimitTimeMonthWndWindow:onLoad()
	self.llContentPanel = self:getChildWindowByName("LimitTimeMonthWnd-ContentPanel", GUIType.Layout)
	self.btnHelp = self:getChildWindowByName("LimitTimeMonthWnd-help", GUIType.Button)
	self.stTitle = self:getChildWindowByName("LimitTimeMonthWnd-title", GUIType.StaticText)
	self.llTime = self:getChildWindowByName("LimitTimeMonthWnd-Time", GUIType.Layout)
	self.siTimeIcon = self:getChildWindowByName("LimitTimeMonthWnd-TimeIcon", GUIType.StaticImage)
	self.stTimeText = self:getChildWindowByName("LimitTimeMonthWnd-TimeText", GUIType.StaticText)
	self:initView()
	self:initEvent()
end

---@private
function GUILimitTimeMonthWndWindow:initView()
	self.stTitle:SetText(Lang:getString("gui.limit.time.activity.month.gift"))
	-----@type GUILimitTimeWeekWndWindow[]
	self.gvItems = IGUIGridView.new("LimitTimeMonthWnd-ContentPanel-List", self.llContentPanel)
	self.gvItems:setConfig(60, 0, 3)
	---@type LimitedTimeWeekAdapter
	self.adapter = UIHelper.newGameAdapter("LimitedTimeWeekAdapter")
	self.gvItems:setAdapter(self.adapter)
end

---@private
function GUILimitTimeMonthWndWindow:initEvent()
	self.btnHelp:registerEvent(GUIEvent.ButtonClick, function()
		CustomDialog.builder()
					.setContentText(Lang:getString("gui.limit.time.activity.month.gift.help"))
					.setHideLeftButton()
					.show()
	end)
end

function GUILimitTimeMonthWndWindow:onShow(isTick)
	local countdown = self.activity.info:getValue("MonthNextRoundDate") - os.time()
	self.stTimeText:SetText(DateUtil.getTimeByTwoPara(countdown))
	if not isTick then
		ReportEvent.reportEvent(Game:getPlatformUserId(), "limited_time_month_click")
	end
	LuaTimer:cancel(self.countdownTimer)
	self.countdownTimer = LuaTimer:schedule(function()
		self:onShow(true)
	end, 1000)
	self:addTimer(self.countdownTimer)
end

function GUILimitTimeMonthWndWindow:onHide()
	LuaTimer:cancel(self.countdownTimer)
end

---@param data table
function GUILimitTimeMonthWndWindow:onDataChanged(activity)
	self.activity = activity
	self.activity.info:addKeyObserver("MonthRecord", function()
		self:updateMonthUI()
	end)
	self.activity.info:addKeyObserver("MonthRoundId", function()
		self:updateMonthUI()
	end)
	self:updateMonthUI()
end

function GUILimitTimeMonthWndWindow:updateMonthUI()
	local giftList = {}
	local curRoundId = self.activity.info:getValue("MonthRoundId") or 1
	local cfgs = LimitedTimeMonthGiftConfig:getCfgsByRoundId(curRoundId)
	for _, cfg in pairs(cfgs or {}) do
		local newCfg = TableUtil.copyTable(cfg)
		local data = self.activity.info:getValue("MonthRecord")
		newCfg.boughtCounts = data[cfg.giftKey] or 0
		newCfg.activity = self.activity
		table.insert(giftList, newCfg)
	end
	self.adapter:setData(giftList)
end

return GUILimitTimeMonthWndWindow
