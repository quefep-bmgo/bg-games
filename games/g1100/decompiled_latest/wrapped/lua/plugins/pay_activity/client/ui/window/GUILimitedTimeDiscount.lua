--[[SYb]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 5184
                          local checkFileName = "GUILimitedTimeDiscount.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[vnTFEFldIRaG2yJlu01ZRy8LSRjHQVvTaRHErWMSzDvnEhFb7QFs]]---@class GUILimitedTimeDiscountWindow : IGUIWindow
local GUILimitedTimeDiscountWindow = class("GUILimitedTimeDiscountWindow", IGUIWindow)

---@type LimitedTimeDiscountStoreConfig
local LimitedTimeDiscountStoreConfig = T(Global, "LimitedTimeDiscountStoreConfig")

---@type ReportEvent
local ReportEvent = T(Global, "ReportEvent")

---@private
function GUILimitedTimeDiscountWindow:ctor(...)
	self.super.ctor(self, "LimitedTimeDiscount.json", ...)
end

---@private
function GUILimitedTimeDiscountWindow:onLoad()
	self.siNpcIcon = self:getChildWindowByName("LimitedTimeDiscount-npc-icon", GUIType.StaticImage)
	self.llContentPanel = self:getChildWindowByName("LimitedTimeDiscount-ContentPanel", GUIType.Layout)
	self.btnHelp = self:getChildWindowByName("LimitedTimeDiscount-help", GUIType.Button)
	self.stTitle = self:getChildWindowByName("LimitedTimeDiscount-title", GUIType.StaticText)
	self.llTime = self:getChildWindowByName("LimitedTimeDiscount-Time", GUIType.Layout)
	self.siTimeIcon = self:getChildWindowByName("LimitedTimeDiscount-TimeIcon", GUIType.StaticImage)
	self.stTimeText = self:getChildWindowByName("LimitedTimeDiscount-TimeText", GUIType.StaticText)
	self.stRefreshTimeText = self:getChildWindowByName("LimitedTimeDiscount-RefreshTimeText", GUIType.StaticText)
	self.stNpcText = self:getChildWindowByName("LimitedTimeDiscount-NpcText", GUIType.StaticText)
	self.llNpc = self:getChildWindowByName("LimitedTimeDiscount-Npc", GUIType.Layout)
	self:initView()
	self:initEvent()
end

---@private
function GUILimitedTimeDiscountWindow:initView()
	self.stTitle:SetText(Lang:getString("gui.limit.time.discount.activity.store.title"))
	self.stRefreshTimeText:SetText("")
	self.stNpcText:SetText(Lang:getString("gui.limit.time.discount.store.npc.txt"))

	-----@type GUILimitTimeWeekWndWindow[]
	self.gvItems = IGUIGridView.new("LimitedTimeDiscount-ContentPanel-List", self.llContentPanel)
	self.gvItems:setConfig(30, 20, 4)
	---@type LimitedTimeWeekAdapter
	self.adapter = UIHelper.newGameAdapter("LimitedTimeDiscountStoreAdapter")
	self.gvItems:setAdapter(self.adapter)
end

---@private
function GUILimitedTimeDiscountWindow:initEvent()
	self.btnHelp:registerEvent(GUIEvent.ButtonClick, function()
		CustomDialog.builder()
					.setContentText(Lang:getString("gui.limit.time.discount.store.help.txt"))
					.setHideLeftButton()
					.show()
	end)
end

local function countdownFormat(countdown)
	local h = math.floor(countdown / 3600)
	local m = math.floor(countdown % 3600 / 60)
	local s = countdown % 3600 % 60
	return string.format("%dh %dm %ds", h, m, s)
end

function GUILimitedTimeDiscountWindow:onShow(isTick)
	local countdown = self.activity.info:getValue("DiscountNextRoundDate") - os.time()
	self.stRefreshTimeText:SetText(string.format(Lang:getString("gui.limit.time.discount.store.refresh.time"), countdownFormat(countdown)))
	local endCountdown = self.activity.cfg.endDate - os.time()
	self.stTimeText:SetText(DateUtil.getTimeByTwoPara(endCountdown))
	if not isTick then
		ReportEvent.reportEvent(Game:getPlatformUserId(), "limited_time_discount_store_click")
	end
	LuaTimer:cancel(self.countdownTimer)
	self.countdownTimer = LuaTimer:schedule(function()
		self:onShow(true)
	end, 1000)
	self:addTimer(self.countdownTimer)
	self.llTime:SetVisible(self.activity.cfg.hideTimeUI~=1)
end

function GUILimitedTimeDiscountWindow:onHide()
	LuaTimer:cancel(self.countdownTimer)
end

---@param activity GUILimitedTimeDiscountWindow
function GUILimitedTimeDiscountWindow:onDataChanged(activity)
	self.activity = activity
	self.activity.info:addKeyObserver("DiscountRecord", function()
		self:updateUIData()
	end)
	self.activity.info:addKeyObserver("DiscountRoundId", function()
		self:updateUIData()
	end)
	self:updateUIData()
end

function GUILimitedTimeDiscountWindow:updateUIData()
	local giftList = {}
	local curRoundId = self.activity.info:getValue("DiscountRoundId") or 1
	local cfgs = LimitedTimeDiscountStoreConfig:getCfgsByRoundId(curRoundId)
	for _, cfg in pairs(cfgs or {}) do
		local newCfg = TableUtil.copyTable(cfg)
		local data = self.activity.info:getValue("DiscountRecord")
		newCfg.boughtCounts = data[cfg.giftKey] or 0
		newCfg.activity = self.activity
		table.insert(giftList, newCfg)
	end
	self.adapter:setData(giftList)
end

return GUILimitedTimeDiscountWindow
--[[i9Qfnk5GlamO2mWD3ZaBfefklghVtmUDcwtVaOgLblQFfT1tCaCiXDA7z3NmkGyw3qQg6k3PLQGVjx6b0RzP]]