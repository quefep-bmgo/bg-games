---@class GUILimitTimeSignalItemWindow : IGUIWindow
local GUILimitTimeSignalItemWindow = class("GUILimitTimeSignalItemWindow", IGUIWindow)

---@type PayActivityRewardConfig
local PayActivityRewardConfig = T(Global, "PayActivityRewardConfig")

---@type LimitedTimeGiftSignalConfig
local LimitedTimeGiftSignalConfig = T(Global, "LimitedTimeGiftSignalConfig")

---@private
function GUILimitTimeSignalItemWindow:ctor(...)
	self.super.ctor(self, "LimitTimeSignalItem.json", ...)
end

---@private
function GUILimitTimeSignalItemWindow:onLoad()
	self.llContentPanel = self:getChildWindowByName("LimitTimeSignalItem-ContentPanel", GUIType.Layout)
	self.siBG = self:getChildWindowByName("LimitTimeSignalItem-BG", GUIType.StaticImage)
	self.stTitleText = self:getChildWindowByName("LimitTimeSignalItem-TitleText", GUIType.StaticText)
	self.btnBuyBtn = self:getChildWindowByName("LimitTimeSignalItem-BuyBtn", GUIType.Button)
	self.siFinalDiaIcon = self:getChildWindowByName("LimitTimeSignalItem-FinalDiaIcon", GUIType.StaticImage)
	self.stFinalPrice = self:getChildWindowByName("LimitTimeSignalItem-FinalPrice", GUIType.StaticText)
	self.siInitDiaIcon = self:getChildWindowByName("LimitTimeSignalItem-InitDiaIcon", GUIType.StaticImage)
	self.stInitPrice = self:getChildWindowByName("LimitTimeSignalItem-InitPrice", GUIType.StaticText)
	self.siInitLine = self:getChildWindowByName("LimitTimeSignalItem-InitLine", GUIType.StaticImage)
	self.siGoodsBg = self:getChildWindowByName("LimitTimeSignalItem-GoodsBg", GUIType.StaticImage)
	self.siGoodsIcon = self:getChildWindowByName("LimitTimeSignalItem-GoodsIcon", GUIType.StaticImage)
	self.stGoodsNum = self:getChildWindowByName("LimitTimeSignalItem-GoodsNum", GUIType.StaticText)
	self.siBubbleIcon = self:getChildWindowByName("LimitTimeSignalItem-BubbleIcon", GUIType.StaticImage)
	self.stOFFText = self:getChildWindowByName("LimitTimeSignalItem-OFFText", GUIType.StaticText)
	self.stPerText = self:getChildWindowByName("LimitTimeSignalItem-PerText", GUIType.StaticText)
	self:initView()
	self:initEvent()
end

---@private
function GUILimitTimeSignalItemWindow:initView()
	self.stTitleText:SetText()
	self.stFinalPrice:SetText()
	self.stInitPrice:SetText()
	self.stGoodsNum:SetText()
	self.stPerText:SetText()
	self.stOFFText:SetText("OFF")
end

---@private
function GUILimitTimeSignalItemWindow:initEvent()
	self.btnBuyBtn:registerEvent(GUIEvent.ButtonClick, function()
		if self.data  then
			local activity=PlayerManager:getClientPlayer().payActivity.activities[self.data.activityId]
			if activity then
				activity:tryBuyGiftBag(self.data.id)
			end
		end
	end)

	self.siGoodsBg:registerEvent(GUIEvent.Click, function()
		if self.data and self.data.giftContent and #self.data.giftContent ==1 then
			local rewardData = PayActivityRewardConfig:getCfgById(self.data.giftContent[1])
			if rewardData then
				UIHelper.showGameGUILayout("GUIPayActivityRewardDetail", rewardData.id)
			end
		end
	end)
end

---@param data LimitedTimeGiftSignalConfigData
function GUILimitTimeSignalItemWindow:onDataChanged(data)
	self.data = data
	self.stPerText:SetText(self.data.percent)
	local activity=PlayerManager:getClientPlayer().payActivity.activities[data.activityId]
	if not activity or not data then
		return
	end

	if #data.giftContent == 1 then
		local rewardData = PayActivityRewardConfig:getCfgById(data.giftContent[1])
		if rewardData then
			if data.giftIcon and data.giftIcon ~= "" and data.giftIcon ~= "#" then
				self.siGoodsIcon:SetImage(data.giftIcon)
			elseif rewardData.image and rewardData.image~="" and rewardData.image~="#" then
				self.siGoodsIcon:SetImage(rewardData.image)
			end

			if self.data.giftName and self.data.giftName ~= "" and self.data.giftName ~= "#" then
				self.stTitleText:SetText(Lang:getString(self.data.giftName))
			elseif rewardData.name and rewardData.name ~= "" and rewardData.name ~= "#" then
				self.stTitleText:SetText(Lang:getString(rewardData.name))
			else
				self.stTitleText:SetText(Lang:getString("gui.limit.time.combined.title"))
			end

			if data.giftNum and data.giftNum > 1 then
				self.stGoodsNum:SetText("X" .. data.giftNum)
			else
				self.stGoodsNum:SetText("" )
			end
		end
	else
		if data.giftIcon and data.giftIcon ~= "" and data.giftIcon ~= "#" then
			self.siGoodsIcon:SetImage(data.giftIcon)
		end

		if data.giftName and data.giftName ~= "" and data.giftName ~= "#" then
			self.stTitleText:SetText(Lang:getString(data.giftName))
		else
			self.stTitleText:SetText(Lang:getString("gui.limit.time.combined.title"))
		end

		if data.giftNum and data.giftNum > 1 then
			self.stGoodsNum:SetText("X" .. data.giftNum)
		else
			self.stGoodsNum:SetText("" )
		end
	end
	activity.info:addKeyObserver("GiftSignalCanRewardRecord", function(activity, key, value)
		--print("================>> GUILimitTimeSignalItemWindow,GiftSignalCanRewardRecord ",key,value)
		--LogUtil.pv(value)
		self:updateBoughtBtnShow()
	end)
	self:updateBoughtBtnShow()
end

function GUILimitTimeSignalItemWindow:updateBoughtBtnShow()
	if not self.data  then
		return
	end
	local activity=PlayerManager:getClientPlayer().payActivity.activities[self.data.activityId]
	if not activity then
		return
	end

	if not activity:canRewardGift(self.data.id) and not LimitedTimeGiftSignalConfig:canRepeatBuy(self.data.id) then
		self.btnBuyBtn:SetText(Lang:getString("gui.limit.time.combined.purchased"))
		self.siInitDiaIcon:SetVisible(false)
		self.siFinalDiaIcon:SetVisible(false)
		self.btnBuyBtn:SetEnabled(false)
		self.btnBuyBtn:SetTouchable(false)
	else
		self.btnBuyBtn:SetEnabled(true)
		self.btnBuyBtn:SetTouchable(true)
		self.btnBuyBtn:SetText("")
		self.siInitDiaIcon:SetVisible(true)
		self.siFinalDiaIcon:SetVisible(true)

		self.stFinalPrice:SetText(self.data.finalPrice)
		self.stInitPrice:SetText(self.data.initPrice)
		--local strW = self.stInitPrice:GetFont():GetStringWidth(self.data.initPrice)
		--self.stInitLine:SetWidth({0, strW + 35})
	end
end

return GUILimitTimeSignalItemWindow
