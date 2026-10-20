--[[xYG5Mx9aAdYUzh0js8JkrntgbDAmfklqmkg9NAX7d1oHpE0cgANz]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 9885
                          local checkFileName = "GUILimitedTimeOptionalGift.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[jJ]]---@class GUILimitedTimeOptionalGiftWindow : IGUIWindow
local GUILimitedTimeOptionalGiftWindow = class("GUILimitedTimeOptionalGiftWindow", IGUIWindow)

---@type LimitedTimeOptionalGiftConfig
local LimitedTimeOptionalGiftConfig = T(Global, "LimitedTimeOptionalGiftConfig")

---@type PayActivityRewardConfig
local PayActivityRewardConfig = T(Global, "PayActivityRewardConfig")

---@type ReportEvent
local ReportEvent = T(Global, "ReportEvent")

---@private
function GUILimitedTimeOptionalGiftWindow:ctor(...)
	self.super.ctor(self, "LimitedTimeOptionalGift.json", ...)
end

---@private
function GUILimitedTimeOptionalGiftWindow:onLoad()
	self.llContentPanel = self:getChildWindowByName("LimitedTimeOptionalGift-ContentPanel", GUIType.Layout)
	self.btnHelp = self:getChildWindowByName("LimitedTimeOptionalGift-help", GUIType.Button)
	self.stTitle = self:getChildWindowByName("LimitedTimeOptionalGift-title", GUIType.StaticText)
	self.llTime = self:getChildWindowByName("LimitedTimeOptionalGift-Time", GUIType.Layout)
	self.siTimeIcon = self:getChildWindowByName("LimitedTimeOptionalGift-TimeIcon", GUIType.StaticImage)
	self.stTimeText = self:getChildWindowByName("LimitedTimeOptionalGift-TimeText", GUIType.StaticText)
	self.llBigGift = self:getChildWindowByName("LimitedTimeOptionalGift-BigGift", GUIType.Layout)
	self.llInfo = self:getChildWindowByName("LimitedTimeOptionalGift-Info", GUIType.Layout)
	self.siAdd = self:getChildWindowByName("LimitedTimeOptionalGift-Add", GUIType.StaticImage)
	self.siItemIcon = self:getChildWindowByName("LimitedTimeOptionalGift-ItemIcon", GUIType.StaticImage)
	self.siItemIconBg = self:getChildWindowByName("LimitedTimeOptionalGift-ItemIconBg", GUIType.StaticImage)
	self.siRefresh = self:getChildWindowByName("LimitedTimeOptionalGift-Refresh", GUIType.StaticImage)
	self.btnBigBuy = self:getChildWindowByName("LimitedTimeOptionalGift-BigBuy", GUIType.Button)
	self.siRedDot = self:getChildWindowByName("LimitedTimeOptionalGift-BuyRedDot", GUIType.StaticImage)
	self.stBigDesc = self:getChildWindowByName("LimitedTimeOptionalGift-BigDesc", GUIType.StaticText)
	self.stBigLimitNum = self:getChildWindowByName("LimitedTimeOptionalGift-BigLimitNum", GUIType.StaticText)
	self:initView()
	self:initEvent()
end

---@private
function GUILimitedTimeOptionalGiftWindow:initView()
	self.stTitle:SetText(Lang:getString("gui.limit.time.optional.gift.title"))
	self.stBigDesc:SetText(Lang:getString("gui.limit.time.optional.gift.desc"))
	self.siItemIcon:SetTouchParent(false)
	self.stBigLimitNum:SetText("")
	self.stTimeText:SetText("")

	-----@type GUILimitedTimeOptionalGiftWindow[]
	self.lvItems = IGUIListView.new("LimitedTimeOptionalGift-ContentPanel-List", self.llContentPanel, nil, Orientation.Vertical)
	self.lvItems:setItemSpace(10)
	---@type LimitedTimeOptionalGiftAdapter
	self.adapter = UIHelper.newGameAdapter("LimitedTimeOptionalGiftAdapter")
	self.lvItems:setAdapter(self.adapter)
end

---@private
function GUILimitedTimeOptionalGiftWindow:initEvent()
	self.btnHelp:registerEvent(GUIEvent.ButtonClick, function()

	end)

	self.btnBigBuy:registerEvent(GUIEvent.ButtonClick, function()
		if not self.data  then return end

		if not self.advancedAwardConfig or self.data.buyTimes < self.data.openCondition then
			self:openSelectView()
			return
		end

		if self.data.boughtCounts >= self.data.limitCounts or self.data.buyTimes < self.data.openCondition then
			return
		end
		self.data.activity = self.activity
		self.data.items = { self.advancedAwardConfig.id }
		UIHelper.showGameGUILayout("GUILimitedTimeOptionalGiftConfirm", self.data)
	end)

	self.siItemIcon:registerEvent(GUIEvent.TouchUp, function()
		--TODO 物品详情
		--if self.advancedAwardConfig then
		--	UIHelper.showGameGUILayout("GUIPayActivityRewardDetail", self.advancedAwardConfig.id)
		--end
		self:openSelectView()
	end)

	self.siRefresh:registerEvent(GUIEvent.TouchUp, function()
		self:openSelectView()
	end)

	self.siAdd:registerEvent(GUIEvent.TouchUp, function()
		self:openSelectView()
	end)
end

function GUILimitedTimeOptionalGiftWindow:onShow(isTick)
	local endCountdown = self.activity.cfg.endDate - os.time()
	self.stTimeText:SetText(DateUtil.getTimeByTwoPara(endCountdown))
	if not isTick then
		ReportEvent.reportEvent(Game:getPlatformUserId(), "limited_time_optional_gift_click")
	end
	LuaTimer:cancel(self.countdownTimer)
	self.countdownTimer = LuaTimer:schedule(function()
		self:onShow(true)
	end, 1000)
	self:addTimer(self.countdownTimer)
	self.llTime:SetVisible(self.activity.cfg.hideTimeUI~=1)
end

function GUILimitedTimeOptionalGiftWindow:onHide()
	LuaTimer:cancel(self.countdownTimer)
end

---@param data table
function GUILimitedTimeOptionalGiftWindow:onDataChanged(activity)
	self.activity = activity
	self.activity.info:addKeyObserver("OptionalGiftRecord", function()
		UIHelper.hideGameGUILayout("GUILimitedTimeOptionalGiftSelect")
		self:refreshUI()
	end)
	self:refreshUI()
end

function GUILimitedTimeOptionalGiftWindow:refreshUI()
	local giftList = {}
	local configs = LimitedTimeOptionalGiftConfig:getCfgsByType(1)
	for _, cfg in pairs(configs or {}) do
		local newCfg = TableUtil.copyTable(cfg)
		local data = self.activity.info:getValue("OptionalGiftRecord")
		newCfg.boughtCounts = data[cfg.giftKey] or 0
		newCfg.nextRefreshTime = data[cfg.giftKey .. "-refresh-time"] or 0
		newCfg.activity = self.activity
		table.insert(giftList, newCfg)
	end
	self.adapter:setData(giftList)
	local _config = LimitedTimeOptionalGiftConfig:getAdvancedAward()
	if _config then
		local _data = self.activity.info:getValue("OptionalGiftRecord")
		_config.boughtCounts = _data[_config.giftKey] or 0
		_config.buyTimes = _data["buy-times"] or 0
		local limitCounts = _data["limit-times"] or 0
		_config.nextCount = _config.openCondition * (math.min(limitCounts + 1, _config.limitCounts))
		_config.limitCounts = limitCounts
		self.data = _config
		local uiData = self.activity.info:getValue("OptionalGiftUIData")
		if uiData[self.data.giftKey] then
			local id = uiData[self.data.giftKey]["1"]
			local rewardConfig = PayActivityRewardConfig:getCfgById(id)
			self:refreshAdvancedAwardData(rewardConfig)
		else
			self:refreshAdvancedAwardData(nil)
		end
	end
end

function GUILimitedTimeOptionalGiftWindow:refreshAdvancedAwardData(awardCfg)
	if awardCfg ~= nil then
		self.advancedAwardConfig = awardCfg
	end
	self.stBigDesc:SetText(string.format(Lang:getString("gui.limit.time.optional.gift.desc"), self.data.openCondition))
	self.stBigLimitNum:SetText(string.format("%d/%d", self.data.buyTimes, self.data.nextCount))
	self.btnBigBuy:SetEnabled(self.data.boughtCounts < self.data.limitCounts)
	self.siRefresh:SetVisible(self.data.boughtCounts < self.data.limitCounts and self.advancedAwardConfig ~= nil)

	if self.data.boughtCounts >= self.data.limitCounts and self.data.limitCounts > 0 then
		self.btnBigBuy:SetNormalImage("set:limited_time_optional_gift.json image:btn_0_gift_pack03")
		self.btnBigBuy:SetPushedImage("set:limited_time_optional_gift.json image:btn_0_gift_pack03")
		self.btnBigBuy:SetTextColor({121/255, 60/255, 42/255, 1})
		self.btnBigBuy:SetText(Lang:getString("gui.limit.time.optional.gift.btn.ok.buy"))
	else
		if self.advancedAwardConfig and self.data.buyTimes >= self.data.openCondition then
			self.btnBigBuy:SetNormalImage("set:limited_time_optional_gift.json image:btn_0_gift_pack03")
			self.btnBigBuy:SetPushedImage("set:limited_time_optional_gift.json image:btn_0_gift_pack03")
			self.btnBigBuy:SetText(Lang:getString("gui.limit.time.optional.gift.btn.ok.not.buy"))
			self.btnBigBuy:SetTextColor({121/255, 60/255, 42/255, 1})
		else
			self.btnBigBuy:SetText(Lang:getString("gui.limit.time.optional.gift.btn.ok"))
			self.btnBigBuy:SetNormalImage("set:limited_time_optional_gift.json image:btn_0_gift_pack05")
			self.btnBigBuy:SetPushedImage("set:limited_time_optional_gift.json image:btn_0_gift_pack05")
			self.btnBigBuy:SetTextColor({240/255, 189/255, 118/255, 1})
		end
	end
	self.siRedDot:SetVisible(self.activity:isShowRedAdvancedAwardDot())
	self.siItemIcon:SetVisible(self.advancedAwardConfig ~= nil)
	self.siItemIconBg:SetVisible(self.advancedAwardConfig ~= nil)
	PayActivityRewardConfig:setRewardImage(self.siItemIcon, self.advancedAwardConfig)
	if self.advancedAwardConfig then
		local quality = self.advancedAwardConfig.quality or 1
		self.siItemIconBg:SetImage("set:limited_time_activity.json image:img_frame_quality0".. quality)
	else
		self.siItemIconBg:SetImage("")
	end
end

function GUILimitedTimeOptionalGiftWindow:onItemClick(config)
	self.activity:onItemClick(self.data.giftKey, 1, config.id)
	self:refreshAdvancedAwardData(config)
end

function GUILimitedTimeOptionalGiftWindow:openSelectView()
	local selectId = self.advancedAwardConfig and self.advancedAwardConfig.id or -1
	UIHelper.showGameGUILayout("GUILimitedTimeOptionalGiftSelect",
			Lang:getString("gui.limit.time.optional.gift.advanced.award"), self.data.optional1, selectId, self)
end

return GUILimitedTimeOptionalGiftWindow
--[[WgxgYMuKTjiKKnojRSoA7SkCZ0KieLGwgaBsHRHzYU3ab910OzWiBOABFapX0HLzjs2FWXB9vQMQKRm5v08xNA6fKESU9WlJgQwcPNjVh]]---