---@class GUILimitedTimeOptionalGiftItemWindow : IGUIWindow
local GUILimitedTimeOptionalGiftItemWindow = class("GUILimitedTimeOptionalGiftItemWindow", IGUIWindow)

---@type PayActivityRewardConfig
local PayActivityRewardConfig = T(Global, "PayActivityRewardConfig")

---@private
function GUILimitedTimeOptionalGiftItemWindow:ctor(...)
	self.super.ctor(self, "LimitedTimeOptionalGiftItem.json", ...)
end

---@private
function GUILimitedTimeOptionalGiftItemWindow:onLoad()
	self.llView = self:getChildWindowByName("LimitedTimeOptionalGiftItem", GUIType.Layout)
	self.stNameText = self:getChildWindowByName("LimitedTimeOptionalGiftItem-NameText", GUIType.StaticText)
	self.siPriceIcon = self:getChildWindowByName("LimitedTimeOptionalGiftItem-PriceIcon", GUIType.StaticImage)
	self.stPriceText = self:getChildWindowByName("LimitedTimeOptionalGiftItem-PriceText", GUIType.StaticText)
	self.llGoodsPanel = self:getChildWindowByName("LimitedTimeOptionalGiftItem-GoodsPanel", GUIType.Layout)
	self.llContentPanel = self:getChildWindowByName("LimitedTimeOptionalGiftItem-ContentPanel", GUIType.Layout)
	self.btnBuyBtn = self:getChildWindowByName("LimitedTimeOptionalGiftItem-BuyBtn", GUIType.Button)
	self.btnBtnSelect = self:getChildWindowByName("LimitedTimeOptionalGiftItem-BtnSelect", GUIType.Button)
	self.stLimitText = self:getChildWindowByName("LimitedTimeOptionalGiftItem-LimitText", GUIType.StaticText)
	self.siSoulMask = self:getChildWindowByName("LimitedTimeOptionalGiftItem-SoulMask", GUIType.StaticImage)
	self.siSoulIcon = self:getChildWindowByName("LimitedTimeOptionalGiftItem-SoulIcon", GUIType.StaticImage)
	self.stSoulText = self:getChildWindowByName("LimitedTimeOptionalGiftItem-SoulText", GUIType.StaticText)

	self.goodsItemList = {}
	self.goodsRefreshList = {}
	self.goodsIconList = {}
	self.goodsNumList = {}
	self.goodsAddList = {}

	for i = 1, 4 do
		self.goodsItemList[i] = self:getChildWindowByName("LimitedTimeOptionalGiftItem-GoodsItem" .. i, GUIType.Layout)
		self.goodsRefreshList[i] = self:getChildWindowByName("LimitedTimeOptionalGiftItem-GoodsRefresh" .. i, GUIType.StaticImage)
		self.goodsIconList[i] = self:getChildWindowByName("LimitedTimeOptionalGiftItem-GoodsIcon" .. i, GUIType.StaticImage)
		self.goodsNumList[i] = self:getChildWindowByName("LimitedTimeOptionalGiftItem-GoodsNum" .. i, GUIType.StaticText)
		self.goodsAddList[i] = self:getChildWindowByName("LimitedTimeOptionalGiftItem-GoodsAdd" .. i, GUIType.StaticImage)
	end
	self:initView()
	self:initEvent()
end

---@private
function GUILimitedTimeOptionalGiftItemWindow:initView()
	self.stNameText:SetText("")
	self.stPriceText:SetText("")
	self.stLimitText:SetText("")
	self.stSoulText:SetText(Lang:getString("gui.limit.time.activity.soul.out"))
	self.btnBuyBtn:SetText(Lang:getString("shop_btn_buy"))
	self.btnBtnSelect:SetText(Lang:getString("gui.limit.time.optional.gift.btn.ok"))
end

---@private
function GUILimitedTimeOptionalGiftItemWindow:initEvent()
	self.btnBuyBtn:registerEvent(GUIEvent.ButtonClick, function()
		if not self.data then return end
		local ids = {}
		for _, v in pairs(self.data.selectData) do
			if v then
				table.insert(ids, v)
			end
		end
		self.data.items = ids
		UIHelper.showGameGUILayout("GUILimitedTimeOptionalGiftConfirm", self.data)
	end)

	self.btnBtnSelect:registerEvent(GUIEvent.ButtonClick, function()
		for i = 1, 4 do
			if self.goodsItemList[i]:IsVisible() and not self.data.selectData[i] then
				self:selectItem(i)
				break
			end
		end
	end)

	for i = 1, 4 do
		self.goodsRefreshList[i]:SetTouchParent(false)
		self.goodsAddList[i]:SetTouchParent(false)
		self.goodsItemList[i]:registerEvent(GUIEvent.TouchUp, function()
			if #(self.data["optional" .. i] or {})> 0 then
				self:selectItem(i)
			else
				if self.data.selectData[i] then
					UIHelper.showGameGUILayout("GUIPayActivityRewardDetail", self.data.selectData[i])
				end
			end
		end)

		self.goodsRefreshList[i]:registerEvent(GUIEvent.TouchUp, function()
			self:selectItem(i)
		end)

		self.goodsAddList[i]:registerEvent(GUIEvent.TouchUp, function()
			self:selectItem(i)
		end)
	end
end

function GUILimitedTimeOptionalGiftItemWindow:selectItem(index)
	self.curIndex = index
	local selectId = self.data.selectData[index] or -1
	local count = index - #self.data.fixedGift
	local canNext = false
	for nextIndex = 1, 4 do
		if nextIndex ~= self.curIndex then
			if self.data.selectData[nextIndex] == nil and #(self.data["optional"..nextIndex] or {}) > 0 then
				canNext = true
				break
			end
		end
	end
	local title = string.format(Lang:getString("gui.limit.time.optional.gift.select.title"), count)
	UIHelper.showGameGUILayout("GUILimitedTimeOptionalGiftSelect",
			title, self.data["optional" .. index], selectId, self, canNext)
end

---@param data LimitedTimeOptionalGiftConfigData
function GUILimitedTimeOptionalGiftItemWindow:onDataChanged(data)
	self.data = data
	if not self.data.selectData then
		self.data.selectData = {}
	end
	self.curIndex = nil
	self:refreshUI()
end

function GUILimitedTimeOptionalGiftItemWindow:onItemClick(config)
	self.data.activity:onItemClick(self.data.giftKey, self.curIndex, config.id)
	self.data.selectData[self.curIndex] = config.id
	self:refreshUI()
	for nextIndex = 1, 4 do
		if nextIndex ~= self.curIndex then
			if self.data.selectData[nextIndex] == nil and #(self.data["optional"..nextIndex] or {}) > 0 then
				self:selectItem(nextIndex)
				break
			end
		end
	end
end

function GUILimitedTimeOptionalGiftItemWindow:onHide()
	LuaTimer:cancel(self.countdownTimer)
end

local function countdownFormat(countdown)
	local h = math.floor(countdown / 3600)
	local m = math.floor(countdown % 3600 / 60)
	local s = countdown % 3600 % 60
	return string.format("%dh %dm %ds", h, m, s)
end

function GUILimitedTimeOptionalGiftItemWindow:changeTime()
	LuaTimer:cancel(self.countdownTimer)
	if self.data.boughtCounts >= self.data.limitCounts then
		self.btnBuyBtn:SetEnabled(false)
		self.btnBuyBtn:SetText(Lang:getString("gui.limit.time.optional.gift.btn.ok.buyed"))
		local leftTime = self.data.nextRefreshTime - os.time()
		self.stLimitText:SetText(countdownFormat(leftTime))
		self.countdownTimer = LuaTimer:schedule(function()
			self:changeTime()
		end, 1000)
	else
		self.btnBuyBtn:SetEnabled(true)
		local leftCount = self.data.limitCounts - self.data.boughtCounts
		self.btnBuyBtn:SetText(Lang:getString("shop_btn_buy"))
		self.stLimitText:SetText(string.format(Lang:getString("gui.limit.time.optional.gift.day.limit"), leftCount))
	end
end

function GUILimitedTimeOptionalGiftItemWindow:refreshUI()
	for k, v in pairs(self.data.fixedGift or {}) do
		self.data.selectData[k] = v
	end
	local uiData = self.data.activity.info:getValue("OptionalGiftUIData")
	for k, v in pairs(uiData[self.data.giftKey] or {}) do
		self.data.selectData[tonumber(k)] = v
	end
	self.stNameText:SetText(Lang:getString(self.data.giftName))
	self.stPriceText:SetText(tostring(self.data.price))
	self.stLimitText:SetText(string.format("%d/%d", self.data.boughtCounts, self.data.limitCounts))
	if self.data.refreshTime > 0 then
		self.llView:SetBackImage("set:limited_time_optional_gift.json image:img_0_gift_pack")
		self.stPriceText:SetTextColor({240/255, 189/255, 118/255, 1})
	else
		self.llView:SetBackImage("set:limited_time_optional_gift.json image:img_0_gift_pack02")
		self.stPriceText:SetTextColor({121/255, 60/255, 42/255, 1})
	end

	LuaTimer:cancel(self.countdownTimer)

	self:changeItems()
end

function GUILimitedTimeOptionalGiftItemWindow:changeItems()

	local tempData = { false, false, false, false}
	local count = #self.data.fixedGift or 0

	for i = 1, count do
		tempData[i] = true
	end

	if #self.data.optional1 > 0 and not tempData[1] then
		count = count + 1
		tempData[1] = true
	end

	if #self.data.optional2 > 0 and not tempData[2] then
		count = count + 1
		tempData[2] = true
	end

	if #self.data.optional3 > 0 and not tempData[3]  then
		count = count + 1
		tempData[3] = true
	end

	if #self.data.optional4 > 0 and not tempData[4] then
		count = count + 1
		tempData[4] = true
	end

	local hasNum = 0
	for i , v in pairs(tempData) do
		if v then
			self.goodsItemList[i]:SetVisible(true)
			local config = PayActivityRewardConfig:getCfgById(self.data.selectData[i])
			self.goodsRefreshList[i]:SetVisible((i > #self.data.fixedGift) and config ~= nil)
			self.goodsAddList[i]:SetVisible(config == nil)
			if config then
				hasNum = hasNum + 1
				local quality = config.quality or 1
				self.goodsItemList[i]:SetBackImage("set:limited_time_activity.json image:img_frame_quality0" .. quality)
			else
				self.goodsItemList[i]:SetBackImage("set:limited_time_activity.json image:img_frame_quality01")
			end
			if config and config.count > 1 then
				self.goodsNumList[i]:SetText("X" .. config.count)
			else
				self.goodsNumList[i]:SetText("")
			end
			PayActivityRewardConfig:setRewardImage(self.goodsIconList[i], config)
		else
			self.goodsItemList[i]:SetVisible(false)
			self.goodsRefreshList[i]:SetVisible(true)
			self.goodsAddList[i]:SetVisible(true)
			self.goodsNumList[i]:SetText("")
			self.goodsIconList[i]:SetImage("")
			PayActivityRewardConfig:setRewardImage(self.goodsIconList[i], nil)
			self.goodsItemList[i]:SetBackImage("set:limited_time_activity.json image:img_frame_quality01")
		end
	end

	if self.data.refreshTime > 0 then
		self.siSoulMask:SetVisible(false)
		self:changeTime()

		if self.data.boughtCounts >= self.data.limitCounts then
			self.btnBuyBtn:SetEnabled(false)
			self.btnBtnSelect:SetVisible(hasNum < count)
			self.btnBuyBtn:SetVisible(hasNum >= count)
			self.btnBuyBtn:SetText(Lang:getString("gui.limit.time.optional.gift.btn.ok.buyed"))
			local leftTime = self.data.nextRefreshTime - os.time()
			self.stLimitText:SetText(countdownFormat(leftTime))
			self.countdownTimer = LuaTimer:schedule(function()
				self:changeTime()
			end, 1000)
		else
			self.btnBuyBtn:SetEnabled(true)
			self.btnBtnSelect:SetVisible(hasNum < count)
			self.btnBuyBtn:SetVisible(hasNum >= count)
			local leftCount = self.data.limitCounts - self.data.boughtCounts
			self.btnBuyBtn:SetText(Lang:getString("shop_btn_buy"))
			self.stLimitText:SetText(string.format(Lang:getString("gui.limit.time.optional.gift.day.limit"), leftCount))
		end

	else
		if self.data.boughtCounts < self.data.limitCounts then
			self.btnBuyBtn:SetText(Lang:getString("shop_btn_buy"))
			self.stLimitText:SetText(string.format(Lang:getString("gui.limit.time.optional.gift.limit"), self.data.limitCounts - self.data.boughtCounts))
			self.siSoulMask:SetVisible(false)
			self.btnBuyBtn:SetEnabled(true)
			self.btnBtnSelect:SetVisible(hasNum < count)
			self.btnBuyBtn:SetVisible(hasNum >= count)
		else
			self.stLimitText:SetText("")
			self.btnBuyBtn:SetVisible(false)
			self.btnBtnSelect:SetVisible(false)
			self.siSoulMask:SetVisible(true)
			self.btnBuyBtn:SetEnabled(true)
			self.btnBtnSelect:SetVisible(false)
			self.btnBuyBtn:SetVisible(false)
			self.btnBuyBtn:SetText(Lang:getString("gui.limit.time.optional.gift.btn.ok.buyed"))
		end
	end
end

return GUILimitedTimeOptionalGiftItemWindow
