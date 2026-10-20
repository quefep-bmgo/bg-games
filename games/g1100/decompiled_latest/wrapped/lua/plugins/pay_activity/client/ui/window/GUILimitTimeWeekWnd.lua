--[[KcaeoBaNhkv6ztyHGIB7J3y2FlREyXsuZ085B7UFy7SOZ]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 4073
                          local checkFileName = "GUILimitTimeWeekWnd.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[Io1doY4cwlMvwiGCuHGMCVl3Vdyw7PdYXXYqFNzmwDqRkE3e1P8w2gXV3NTggFPjNj4R2j7m7Iz6MhJhy]]---@class GUILimitTimeWeekWndWindow : IGUIWindow
local GUILimitTimeWeekWndWindow = class("GUILimitTimeWeekWndWindow", IGUIWindow)

---@type LimitedTimeWeekGiftConfig
local LimitedTimeWeekGiftConfig = T(Global, "LimitedTimeWeekGiftConfig")

---@type ReportEvent
local ReportEvent = T(Global, "ReportEvent")

---@private
function GUILimitTimeWeekWndWindow:ctor(...)
	self.super.ctor(self, "LimitTimeWeekWnd.json", ...)
end

---@private
function GUILimitTimeWeekWndWindow:onLoad()
	self.llContentPanel = self:getChildWindowByName("LimitTimeWeekWnd-ContentPanel", GUIType.Layout)
	self.btnHelp = self:getChildWindowByName("LimitTimeWeekWnd-help", GUIType.Button)
	self.stTitle = self:getChildWindowByName("LimitTimeWeekWnd-title", GUIType.StaticText)

	self.llTime = self:getChildWindowByName("LimitTimeWeekWnd-Time", GUIType.Layout)
	self.siTimeIcon = self:getChildWindowByName("LimitTimeWeekWnd-TimeIcon", GUIType.StaticImage)
	self.stTimeText = self:getChildWindowByName("LimitTimeWeekWnd-TimeText", GUIType.StaticText)

	self:initView()
	self:initEvent()
end

---@private
function GUILimitTimeWeekWndWindow:initView()
	self.stTitle:SetText(Lang:getString("gui.limit.time.activity.week.gift"))
	-----@type GUILimitTimeWeekWndWindow[]
	self.gvItems = IGUIGridView.new("LimitTimeWeekWnd-ContentPanel-List", self.llContentPanel)
	self.gvItems:setConfig(60, 0, 3)
	---@type LimitedTimeWeekAdapter
	self.adapter = UIHelper.newGameAdapter("LimitedTimeWeekAdapter")
	self.gvItems:setAdapter(self.adapter)
end

---@private
function GUILimitTimeWeekWndWindow:initEvent()
	self.btnHelp:registerEvent(GUIEvent.ButtonClick, function()
		CustomDialog.builder()
					.setContentText(Lang:getString("gui.limit.time.activity.week.gift.help"))
					.setHideLeftButton()
					.show()
	end)
end

function GUILimitTimeWeekWndWindow:onShow(isTick)
	local countdown = self.activity.info:getValue("WeekNextRoundDate") - os.time()
	self.stTimeText:SetText(DateUtil.getTimeByTwoPara(countdown))
	if not isTick then
		ReportEvent.reportEvent(Game:getPlatformUserId(), "limited_time_week_click")
	end
	LuaTimer:cancel(self.countdownTimer)
	self.countdownTimer = LuaTimer:schedule(function()
		self:onShow(true)
	end, 1000)
	self:addTimer(self.countdownTimer)
end

function GUILimitTimeWeekWndWindow:onHide()
	LuaTimer:cancel(self.countdownTimer)
end

---@param activity LimitedTimeWeekGift
function GUILimitTimeWeekWndWindow:onDataChanged(activity)
	self.activity = activity
	self.activity.info:addKeyObserver("WeekRecord", function()
		self:updateWeekUI()
	end)
	self.activity.info:addKeyObserver("WeekRoundId", function()
		self:updateWeekUI()
	end)
	self:updateWeekUI()
end

function GUILimitTimeWeekWndWindow:updateWeekUI()
	local giftList = {}
	local curRoundId = self.activity.info:getValue("WeekRoundId") or 1
	local cfgs = LimitedTimeWeekGiftConfig:getCfgsByRoundId(curRoundId)
	for _, cfg in pairs(cfgs or {}) do
		local newCfg = TableUtil.copyTable(cfg)
		local data = self.activity.info:getValue("WeekRecord")
		newCfg.boughtCounts = data[cfg.giftKey] or 0
		newCfg.activity = self.activity
		table.insert(giftList, newCfg)
	end
	self.adapter:setData(giftList)
end

return GUILimitTimeWeekWndWindow
--[[8fhVTJ5vsknueRa]]---