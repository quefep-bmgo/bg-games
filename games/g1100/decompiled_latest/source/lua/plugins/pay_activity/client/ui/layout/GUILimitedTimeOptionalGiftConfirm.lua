---@class GUILimitedTimeOptionalGiftConfirmLayout : IGUILayout
local GUILimitedTimeOptionalGiftConfirmLayout = class("GUILimitedTimeOptionalGiftConfirmLayout", IGUILayout)
local PayActivityRewardConfig = T(Global, "PayActivityRewardConfig")

---@private
function GUILimitedTimeOptionalGiftConfirmLayout:ctor(parent)
	self.super.ctor(self, "LimitedTimeOptionalGiftConfirm.json", parent)
end

---@private
function GUILimitedTimeOptionalGiftConfirmLayout:isDelayLoad()
	return true
end

---@private
function GUILimitedTimeOptionalGiftConfirmLayout:onCreate()
	self:initCreateEvent()
end

---@private
function GUILimitedTimeOptionalGiftConfirmLayout:initCreateEvent()

end

---@private
function GUILimitedTimeOptionalGiftConfirmLayout:onLoad()
	self.llWnd = self:getChildWindow("LimitedTimeOptionalGiftConfirm-wnd", GUIType.Layout)
	self.siWndBg = self:getChildWindow("LimitedTimeOptionalGiftConfirm-wnd_bg", GUIType.StaticImage)
	self.siTopImg = self:getChildWindow("LimitedTimeOptionalGiftConfirm-topImg", GUIType.StaticImage)
	self.stTitle = self:getChildWindow("LimitedTimeOptionalGiftConfirm-title", GUIType.StaticText)
	self.stGiftTitle = self:getChildWindow("LimitedTimeOptionalGiftConfirm-GiftTitle", GUIType.StaticText)
	self.llGoodsPanel = self:getChildWindow("LimitedTimeOptionalGiftConfirm-GoodsPanel", GUIType.Layout)
	self.siGoodsIcon3 = self:getChildWindow("LimitedTimeOptionalGiftConfirm-GoodsIcon3", GUIType.StaticImage)
	self.stGoodsNum3 = self:getChildWindow("LimitedTimeOptionalGiftConfirm-GoodsNum3", GUIType.StaticText)
	self.llDetails = self:getChildWindow("LimitedTimeOptionalGiftConfirm-details", GUIType.Layout)
	self.stRewardDesc = self:getChildWindow("LimitedTimeOptionalGiftConfirm-reward_desc", GUIType.StaticText)
	self.siLAdorn = self:getChildWindow("LimitedTimeOptionalGiftConfirm-l_adorn", GUIType.StaticImage)
	self.siRAdorn0 = self:getChildWindow("LimitedTimeOptionalGiftConfirm-r_adorn_0", GUIType.StaticImage)
	self.siDetailsBg = self:getChildWindow("LimitedTimeOptionalGiftConfirm-details_bg", GUIType.StaticImage)
	self.stDecText = self:getChildWindow("LimitedTimeOptionalGiftConfirm-dec_text", GUIType.StaticText)
	self.siPriceBg = self:getChildWindow("LimitedTimeOptionalGiftConfirm-priceBg", GUIType.StaticImage)
	self.siDiaIcon = self:getChildWindow("LimitedTimeOptionalGiftConfirm-DiaIcon", GUIType.StaticImage)
	self.stInitPrice = self:getChildWindow("LimitedTimeOptionalGiftConfirm-InitPrice", GUIType.StaticText)
	self.siPerIcon = self:getChildWindow("LimitedTimeOptionalGiftConfirm-PerIcon", GUIType.StaticImage)
	self.btnClose = self:getChildWindow("LimitedTimeOptionalGiftConfirm-close", GUIType.Button)
	self.siCloseImg = self:getChildWindow("LimitedTimeOptionalGiftConfirm-closeImg", GUIType.StaticImage)
	self.btnCancelBtn = self:getChildWindow("LimitedTimeOptionalGiftConfirm-CancelBtn", GUIType.Button)
	self.siCancelIcon = self:getChildWindow("LimitedTimeOptionalGiftConfirm-CancelIcon", GUIType.StaticImage)
	self.stCancelText = self:getChildWindow("LimitedTimeOptionalGiftConfirm-CancelText", GUIType.StaticText)
	self.btnConfirmBtn = self:getChildWindow("LimitedTimeOptionalGiftConfirm-ConfirmBtn", GUIType.Button)
	self.siConfirmIcon = self:getChildWindow("LimitedTimeOptionalGiftConfirm-ConfirmIcon", GUIType.StaticImage)
	self.stConfirmText = self:getChildWindow("LimitedTimeOptionalGiftConfirm-ConfirmText", GUIType.StaticText)

	self.lytGoodsItemList = {}
	self.imgGoodsIconList = {}
	self.txtGoodsNumList = {}
	self.txtGoodsBgList = {}

	for i = 1, 4 do
		self.lytGoodsItemList[i] = self:getChildWindow("LimitedTimeOptionalGiftConfirm-GoodsItem" .. i, GUIType.Layout)
		self.imgGoodsIconList[i] = self:getChildWindow("LimitedTimeOptionalGiftConfirm-GoodsIcon" .. i, GUIType.StaticImage)
		self.txtGoodsNumList[i] = self:getChildWindow("LimitedTimeOptionalGiftConfirm-GoodsNum" .. i, GUIType.StaticText)
		self.txtGoodsBgList[i] = self:getChildWindow("LimitedTimeOptionalGiftConfirm-GoodsBg" .. i, GUIType.StaticImage)
	end

	self:initView()
	self:initEvent()
end

---@private
function GUILimitedTimeOptionalGiftConfirmLayout:initView()
	self.stTitle:SetText(Lang:getString("gui.limit.time.common.tips"))
	self.stRewardDesc:SetText(Lang:getString("gui.limit.time.activity.gift.desc"))
	self.stCancelText:SetText(Lang:getString("gui.limit.time.activity.cancel.tips"))
	self.stConfirmText:SetText(Lang:getString("gui.limit.time.activity.confirm.tips"))

	self.stGiftTitle:SetText(Lang:getString(""))
	self.stDecText:SetText(Lang:getString(""))
	self.stInitPrice:SetText(Lang:getString(""))
end

function GUILimitedTimeOptionalGiftConfirmLayout:changeView(data)

	self.stGiftTitle:SetText(Lang:getString(data.giftName))
	self.stInitPrice:SetText(tostring(data.price))
	local descText = ""
	for i = 1, 4 do
		local giftId = tonumber(data.items[i])
		if giftId then
			local rewardConfig = PayActivityRewardConfig:getCfgById(giftId)
			if rewardConfig then
				self.lytGoodsItemList[i]:SetVisible(true)
				PayActivityRewardConfig:setRewardImage(self.imgGoodsIconList[i], rewardConfig)
				if rewardConfig.count <= 1 then
					self.txtGoodsNumList[i]:SetText("")
					descText = descText .. Lang:getString(rewardConfig.name)
				else
					self.txtGoodsNumList[i]:SetText("X" .. rewardConfig.count)
					descText = descText .. Lang:getString(rewardConfig.name) .. "x" ..rewardConfig.count
				end
				if i < #data.items then
					descText = descText .. "\n"
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

	local size = #data.items
	if size == 1 then
		self.lytGoodsItemList[1]:SetProperty("Area", "{{0,0},{0,0},{0,89},{1,0}}")
		self.lytGoodsItemList[2]:SetProperty("Area", "{{0,0},{0,0},{0,89},{1,0}}")
		self.lytGoodsItemList[3]:SetProperty("Area", "{{0,0},{0,0},{0,89},{1,0}}")
		self.lytGoodsItemList[4]:SetProperty("Area", "{{0,0},{0,0},{0,89},{1,0}}")
	elseif size == 2 then
		self.lytGoodsItemList[1]:SetProperty("Area", "{{0,-52},{0,0},{0,37},{1,0}}")
		self.lytGoodsItemList[2]:SetProperty("Area", "{{0,52},{0,0},{0,141},{1,0}}")
		self.lytGoodsItemList[3]:SetProperty("Area", "{{0,0},{0,0},{0,89},{1,0}}")
		self.lytGoodsItemList[4]:SetProperty("Area", "{{0,0},{0,0},{0,89},{1,0}}")
	elseif size == 3 then
		self.lytGoodsItemList[1]:SetProperty("Area", "{{0,-104},{0,0},{0,-15},{1,0}}")
		self.lytGoodsItemList[2]:SetProperty("Area", "{{0,0},{0,0},{0,89},{1,0}}")
		self.lytGoodsItemList[3]:SetProperty("Area", "{{0,104},{0,0},{0,193},{1,0}}")
		self.lytGoodsItemList[4]:SetProperty("Area", "{{0,0},{0,0},{0,89},{1,0}}")
	elseif size == 4 then
		self.lytGoodsItemList[1]:SetProperty("Area", "{{0,-155.5},{0,0},{0,-66.5},{1,0}}")
		self.lytGoodsItemList[2]:SetProperty("Area", "{{0,-51.5},{0,0},{0,37.5},{1,0}}")
		self.lytGoodsItemList[3]:SetProperty("Area", "{{0,51.5},{0,0},{0,140.5},{1,0}}")
		self.lytGoodsItemList[4]:SetProperty("Area", "{{0,155.5},{0,0},{0,244.5},{1,0}}")
	end

	self.stDecText:SetText(descText)
end

---@param data LimitedTimeWeekGiftConfigData
function GUILimitedTimeOptionalGiftConfirmLayout:onShow(data)
	if not data then return end
	self.data = data
	self:changeView(data)
end

---@private
function GUILimitedTimeOptionalGiftConfirmLayout:initEvent()
	self.btnClose:registerEvent(GUIEvent.ButtonClick, function()
		self:hide()
	end)
	self.btnCancelBtn:registerEvent(GUIEvent.ButtonClick, function()
		self:hide()
	end)
	self.btnConfirmBtn:registerEvent(GUIEvent.ButtonClick, function()
		self:hide()
		if not self.data then return end
		self.data.activity:tryBuy(self.data.id, self.data.items)
	end)

	for i = 1, 4 do
		self.imgGoodsIconList[i]:registerEvent(GUIEvent.TouchUp, function()
			if not self.data then return end
			local giftId = tonumber(self.data.items[i])
			if giftId then
				local rewardConfig = PayActivityRewardConfig:getCfgById(giftId)
				if rewardConfig then
					UIHelper.showGameGUILayout("GUIPayActivityRewardDetail", rewardConfig.id)
				end
			end
		end)
	end
end

return GUILimitedTimeOptionalGiftConfirmLayout
