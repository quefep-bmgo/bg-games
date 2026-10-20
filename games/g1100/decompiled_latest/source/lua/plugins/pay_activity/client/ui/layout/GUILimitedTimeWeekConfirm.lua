---@class UILimitedTimeWeekConfirmLayout : IGUILayout
local UILimitedTimeWeekConfirmLayout = class("UILimitedTimeWeekConfirmLayout", IGUILayout)
local PayActivityRewardConfig = T(Global, "PayActivityRewardConfig")

---@private
function UILimitedTimeWeekConfirmLayout:ctor(parent)
	self.super.ctor(self, "LimitedTimeWeekConfirm.json", parent)
end

---@private
function UILimitedTimeWeekConfirmLayout:isDelayLoad()
	return true
end

---@private
function UILimitedTimeWeekConfirmLayout:onCreate()
	self:initCreateEvent()
end

---@private
function UILimitedTimeWeekConfirmLayout:initCreateEvent()

end

---@private
function UILimitedTimeWeekConfirmLayout:onLoad()
	self.llWnd = self:getChildWindow("LimitedTimeWeekConfirm-wnd", GUIType.Layout)
	self.siWndBg = self:getChildWindow("LimitedTimeWeekConfirm-wnd_bg", GUIType.StaticImage)
	self.siTopImg = self:getChildWindow("LimitedTimeWeekConfirm-topImg", GUIType.StaticImage)
	self.stTitle = self:getChildWindow("LimitedTimeWeekConfirm-title", GUIType.StaticText)
	self.stGiftTitle = self:getChildWindow("LimitedTimeWeekConfirm-GiftTitle", GUIType.StaticText)
	self.llGoodsPanel = self:getChildWindow("LimitedTimeWeekConfirm-GoodsPanel", GUIType.Layout)
	self.siGoodsIcon3 = self:getChildWindow("LimitedTimeWeekConfirm-GoodsIcon3", GUIType.StaticImage)
	self.stGoodsNum3 = self:getChildWindow("LimitedTimeWeekConfirm-GoodsNum3", GUIType.StaticText)
	self.llDetails = self:getChildWindow("LimitedTimeWeekConfirm-details", GUIType.Layout)
	self.stRewardDesc = self:getChildWindow("LimitedTimeWeekConfirm-reward_desc", GUIType.StaticText)
	self.siLAdorn = self:getChildWindow("LimitedTimeWeekConfirm-l_adorn", GUIType.StaticImage)
	self.siRAdorn0 = self:getChildWindow("LimitedTimeWeekConfirm-r_adorn_0", GUIType.StaticImage)
	self.siDetailsBg = self:getChildWindow("LimitedTimeWeekConfirm-details_bg", GUIType.StaticImage)
	self.stDecText = self:getChildWindow("LimitedTimeWeekConfirm-dec_text", GUIType.StaticText)
	self.siPriceBg = self:getChildWindow("LimitedTimeWeekConfirm-priceBg", GUIType.StaticImage)
	self.siDiaIcon = self:getChildWindow("LimitedTimeWeekConfirm-DiaIcon", GUIType.StaticImage)
	self.stInitPrice = self:getChildWindow("LimitedTimeWeekConfirm-InitPrice", GUIType.StaticText)
	self.siLine = self:getChildWindow("LimitedTimeWeekConfirm-Line", GUIType.StaticImage)
	self.stFinalPrice = self:getChildWindow("LimitedTimeWeekConfirm-finalPrice", GUIType.StaticText)
	self.siPerIcon = self:getChildWindow("LimitedTimeWeekConfirm-PerIcon", GUIType.StaticImage)
	self.stPerText1 = self:getChildWindow("LimitedTimeWeekConfirm-PerText1", GUIType.StaticText)
	self.stPerText2 = self:getChildWindow("LimitedTimeWeekConfirm-PerText2", GUIType.StaticText)
	self.btnClose = self:getChildWindow("LimitedTimeWeekConfirm-close", GUIType.Button)
	self.siCloseImg = self:getChildWindow("LimitedTimeWeekConfirm-closeImg", GUIType.StaticImage)
	self.btnCancelBtn = self:getChildWindow("LimitedTimeWeekConfirm-CancelBtn", GUIType.Button)
	self.siCancelIcon = self:getChildWindow("LimitedTimeWeekConfirm-CancelIcon", GUIType.StaticImage)
	self.stCancelText = self:getChildWindow("LimitedTimeWeekConfirm-CancelText", GUIType.StaticText)
	self.btnConfirmBtn = self:getChildWindow("LimitedTimeWeekConfirm-ConfirmBtn", GUIType.Button)
	self.siConfirmIcon = self:getChildWindow("LimitedTimeWeekConfirm-ConfirmIcon", GUIType.StaticImage)
	self.stConfirmText = self:getChildWindow("LimitedTimeWeekConfirm-ConfirmText", GUIType.StaticText)

	self.lytGoodsItemList = {}
	self.imgGoodsIconList = {}
	self.txtGoodsNumList = {}
	self.txtGoodsBgList = {}

	for i = 1, 3 do
		self.lytGoodsItemList[i] = self:getChildWindow("LimitedTimeWeekConfirm-GoodsItem" .. i, GUIType.Layout)
		self.imgGoodsIconList[i] = self:getChildWindow("LimitedTimeWeekConfirm-GoodsIcon" .. i, GUIType.StaticImage)
		self.txtGoodsNumList[i] = self:getChildWindow("LimitedTimeWeekConfirm-GoodsNum" .. i, GUIType.StaticText)
		self.txtGoodsBgList[i] = self:getChildWindow("LimitedTimeWeekConfirm-GoodsBg" .. i, GUIType.StaticImage)
	end

	self:initView()
	self:initEvent()
end

---@private
function UILimitedTimeWeekConfirmLayout:initView()
	self.stTitle:SetText(Lang:getString("gui.limit.time.common.tips"))
	self.stRewardDesc:SetText(Lang:getString("gui.limit.time.activity.gift.desc"))
	self.stPerText2:SetText(Lang:getString("gui.limit.time.combined.off"))
	self.stCancelText:SetText(Lang:getString("gui.limit.time.activity.cancel.tips"))
	self.stConfirmText:SetText(Lang:getString("gui.limit.time.activity.confirm.tips"))

	self.stGiftTitle:SetText(Lang:getString(""))
	self.stDecText:SetText(Lang:getString(""))
	self.stInitPrice:SetText(Lang:getString(""))
	self.stFinalPrice:SetText(Lang:getString(""))
	self.stPerText1:SetText(Lang:getString(""))
end

function UILimitedTimeWeekConfirmLayout:changeView(data)

	self.stPerText1:SetText(data.percent)
	self.stGiftTitle:SetText(Lang:getString(data.giftName))
	--self.stDecText:SetText(Lang:getString(data.giftDesc))
	self.stFinalPrice:SetText(tostring(data.finalPrice))
	self.stInitPrice:SetText(tostring(data.initPrice))
	local descText = ""
	for i = 1, 3 do
		local giftId = tonumber(data.giftContent[i])
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
				if i < #data.giftContent then
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

	local size = #data.giftContent
	if size == 1 then
		self.lytGoodsItemList[1]:SetProperty("Area", "{{0,0},{0,0},{0,89},{1,0}}")
		self.lytGoodsItemList[2]:SetProperty("Area", "{{0,0},{0,0},{0,89},{1,0}}")
		self.lytGoodsItemList[3]:SetProperty("Area", "{{0,0},{0,0},{0,89},{1,0}}")
	elseif size == 2 then
		self.lytGoodsItemList[1]:SetProperty("Area", "{{0,-52},{0,0},{0,37},{1,0}}")
		self.lytGoodsItemList[2]:SetProperty("Area", "{{0,52},{0,0},{0,141},{1,0}}")
		self.lytGoodsItemList[3]:SetProperty("Area", "{{0,0},{0,0},{0,89},{1,0}}")
	elseif size == 3 then
		self.lytGoodsItemList[1]:SetProperty("Area", "{{0,-104},{0,0},{0,-15},{1,0}}")
		self.lytGoodsItemList[2]:SetProperty("Area", "{{0,0},{0,0},{0,89},{1,0}}")
		self.lytGoodsItemList[3]:SetProperty("Area", "{{0,104},{0,0},{0,193},{1,0}}")
	end

	self.stDecText:SetText(descText)
end

---@param data LimitedTimeWeekGiftConfigData
function UILimitedTimeWeekConfirmLayout:onShow(data)
	if not data then return end
	self.data = data
	self:changeView(data)
end

---@private
function UILimitedTimeWeekConfirmLayout:initEvent()
	self.btnClose:registerEvent(GUIEvent.ButtonClick, function()
		self:hide()
	end)
	self.btnCancelBtn:registerEvent(GUIEvent.ButtonClick, function()
		self:hide()
	end)
	self.btnConfirmBtn:registerEvent(GUIEvent.ButtonClick, function()
		self:hide()
		if not self.data then return end
		self.data.activity:tryBuy(self.data.id)
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

return UILimitedTimeWeekConfirmLayout
