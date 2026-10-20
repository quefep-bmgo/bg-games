---@class GUILimitTimeWeekItemWindow : IGUIWindow
local GUILimitTimeWeekItemWindow = class("GUILimitTimeWeekItemWindow", IGUIWindow)

local PayActivityRewardConfig = T(Global, "PayActivityRewardConfig")

---@private
function GUILimitTimeWeekItemWindow:ctor(...)
	self.super.ctor(self, "LimitTimeWeekItem.json", ...)
end

---@private
function GUILimitTimeWeekItemWindow:onLoad()
	self.siView = self:getChildWindowByName("LimitTimeWeekItem", GUIType.StaticImage)
	self.llContentPanel = self:getChildWindowByName("LimitTimeWeekItem-ContentPanel", GUIType.Layout)
	self.llClickPanel = self:getChildWindowByName("LimitTimeWeekItem-ClickPanel", GUIType.Layout)
	self.stNameText = self:getChildWindowByName("LimitTimeWeekItem-NameText", GUIType.StaticText)
	self.llGoodsPanel = self:getChildWindowByName("LimitTimeWeekItem-GoodsPanel", GUIType.Layout)
	self.btnFreeBtn = self:getChildWindowByName("LimitTimeWeekItem-FreeBtn", GUIType.Button)
	self.siRedIcon = self:getChildWindowByName("LimitTimeWeekItem-RedIcon", GUIType.StaticImage)
	self.btnBuyBtn = self:getChildWindowByName("LimitTimeWeekItem-BuyBtn", GUIType.Button)
	self.siDiaIcon = self:getChildWindowByName("LimitTimeWeekItem-DiaIcon", GUIType.StaticImage)
	self.stInitPrice = self:getChildWindowByName("LimitTimeWeekItem-InitPrice", GUIType.StaticText)
	self.siLine = self:getChildWindowByName("LimitTimeWeekItem-Line", GUIType.StaticImage)
	self.stFinalPrice = self:getChildWindowByName("LimitTimeWeekItem-finalPrice", GUIType.StaticText)
	self.siPerIcon = self:getChildWindowByName("LimitTimeWeekItem-PerIcon", GUIType.StaticImage)
	self.stPerText1 = self:getChildWindowByName("LimitTimeWeekItem-PerText1", GUIType.StaticText)
	self.stPerText2 = self:getChildWindowByName("LimitTimeWeekItem-PerText2", GUIType.StaticText)
	self.stLimitText = self:getChildWindowByName("LimitTimeWeekItem-LimitText", GUIType.StaticText)
	self.siSoulMask = self:getChildWindowByName("LimitTimeWeekItem-SoulMask", GUIType.StaticImage)
	self.siSoulIcon = self:getChildWindowByName("LimitTimeWeekItem-SoulIcon", GUIType.StaticImage)
	self.stSoulText = self:getChildWindowByName("LimitTimeWeekItem-SoulText", GUIType.StaticText)

	self.lytGoodsItemList = {}
	self.imgGoodsIconList = {}
	self.txtGoodsNumList = {}
	self.txtGoodsBgList = {}

	for i = 1, 3 do
		self.lytGoodsItemList[i] = self:getChildWindowByName("LimitTimeWeekItem-GoodsItem" .. i, GUIType.Layout)
		self.imgGoodsIconList[i] = self:getChildWindowByName("LimitTimeWeekItem-GoodsIcon" .. i, GUIType.StaticImage)
		self.txtGoodsNumList[i] = self:getChildWindowByName("LimitTimeWeekItem-GoodsNum" .. i, GUIType.StaticText)
		self.txtGoodsBgList[i] = self:getChildWindowByName("LimitTimeWeekItem-GoodsBg" .. i, GUIType.StaticImage)
	end

	self:initView()
	self:initEvent()
end

---@private
function GUILimitTimeWeekItemWindow:initView()
	self.stNameText:SetText("")
	self.stInitPrice:SetText("")
	self.stFinalPrice:SetText("")
	self.stPerText1:SetText("")
	self.stPerText2:SetText("")
	self.stLimitText:SetText("")
	self.stSoulText:SetText("")


	self.stPerText2:SetText(Lang:getString("gui.limit.time.combined.off"))
	self.btnFreeBtn:SetText(Lang:getString("gui.limit.time.activity.free.bought"))
	self.stSoulText:SetText(Lang:getString("gui.limit.time.activity.soul.out"))
end

---@private
function GUILimitTimeWeekItemWindow:initEvent()
	self.btnFreeBtn:registerEvent(GUIEvent.ButtonClick, function()
		if not self.data then
			return
		end
		self.data.activity:tryBuy(self.data.id)
	end)
	self.btnBuyBtn:registerEvent(GUIEvent.ButtonClick, function()
		if not self.data then
			return
		end
		UIHelper.showGameGUILayout("GUILimitedTimeWeekConfirm", self.data)
	end)

	for i = 1, 3 do
		self.imgGoodsIconList[i]:registerEvent(GUIEvent.TouchUp, function()
			if not self.data then return end
			local giftId = tonumber(self.data.giftContent[i])
			if giftId then
				local rewardConfig = PayActivityRewardConfig:getCfgById(giftId)
				if rewardConfig then
					UIHelper.showGameGUILayout("GUIPayActivityRewardDetail", rewardConfig.id)
				end
			end
		end)
	end
end

---@param data LimitedTimeWeekGiftConfigData
function GUILimitTimeWeekItemWindow:onDataChanged(data)
	self.data = data
	if data.dataType == "week" then
		self.siView:SetImage("set:limit_time_week_month.json image:img_0_gift_packages01")
	else
		self.siView:SetImage("set:limit_time_week_month.json image:img_0_gift_packages02")
	end
	if data.finalPrice <= 0 then
		self.btnFreeBtn:SetVisible(true)
		self.btnBuyBtn:SetVisible(false)
		self.stInitPrice:SetText(tostring(0))
		self.stFinalPrice:SetText(tostring(0))
	else
		self.btnFreeBtn:SetVisible(false)
		self.btnBuyBtn:SetVisible(true)
		self.stInitPrice:SetText(tostring(data.initPrice))
		self.stFinalPrice:SetText(tostring(data.finalPrice))
	end

	local limitCount = data.limitCounts - (data.boughtCounts or 0)

	self.stNameText:SetText(Lang:getString(data.giftName))
	self.stPerText1:SetText(Lang:getString(data.percent))
	self.stLimitText:SetText(string.format(Lang:getString("gui.limit.time.activity.limit.counts"),  limitCount))

	if limitCount <= 0 then
		self.siSoulMask:SetVisible(true)
		self.siPerIcon:SetVisible(false)
		self.siRedIcon:SetVisible(false)

		self.btnFreeBtn:SetEnabled(false)
		self.btnFreeBtn:SetTouchable(false)
		self.btnBuyBtn:SetEnabled(false)
		self.btnBuyBtn:SetTouchable(false)
	else
		self.siSoulMask:SetVisible(false)
		self.siPerIcon:SetVisible(true)
		self.siRedIcon:SetVisible(true)

		self.btnFreeBtn:SetEnabled(true)
		self.btnFreeBtn:SetTouchable(true)
		self.btnBuyBtn:SetEnabled(true)
		self.btnBuyBtn:SetTouchable(true)
	end

	for i = 1, 3 do
		local giftId = tonumber(data.giftContent[i])
		if giftId then
			local rewardConfig = PayActivityRewardConfig:getCfgById(giftId)
			if rewardConfig then
				self.lytGoodsItemList[i]:SetVisible(true)
				self.imgGoodsIconList[i]:SetImage(rewardConfig.image or "")
				if rewardConfig.count <= 1 then
					self.txtGoodsNumList[i]:SetText("")
				else
					self.txtGoodsNumList[i]:SetText("X" .. rewardConfig.count)
				end

				local quality = rewardConfig.quality or 1
				self.txtGoodsBgList[i]:SetImage("set:limited_time_activity.json image:img_frame_quality0".. quality)
			else
				self.lytGoodsItemList[i]:SetVisible(false)
			end
		else
			self.lytGoodsItemList[i]:SetVisible(false)
		end
	end

	local size = #data.giftContent
	if size == 1 then
		self.lytGoodsItemList[1]:SetProperty("Area", "{{0,0},{0,0},{0,65},{1,0}}")
		self.lytGoodsItemList[2]:SetProperty("Area", "{{0,0},{0,0},{0,65},{1,0}}")
		self.lytGoodsItemList[3]:SetProperty("Area", "{{0,0},{0,0},{0,65},{1,0}}")
	elseif size == 2 then
		self.lytGoodsItemList[1]:SetProperty("Area", "{{0,-35},{0,0},{0,30},{1,0}}")
		self.lytGoodsItemList[2]:SetProperty("Area", "{{0,35},{0,0},{0,100},{1,0}}")
		self.lytGoodsItemList[3]:SetProperty("Area", "{{0,0},{0,0},{0,65},{1,0}}")
	elseif size == 3 then
		self.lytGoodsItemList[1]:SetProperty("Area", "{{0,-70},{0,0},{0,-5},{1,0}}")
		self.lytGoodsItemList[2]:SetProperty("Area", "{{0,0},{0,0},{0,65},{1,0}}")
		self.lytGoodsItemList[3]:SetProperty("Area", "{{0,70},{0,0},{0,135},{1,0}}")
	end
end

return GUILimitTimeWeekItemWindow
