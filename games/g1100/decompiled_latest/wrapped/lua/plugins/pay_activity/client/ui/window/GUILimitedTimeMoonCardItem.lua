--[[mtIyCW5tlNIkbNYyk]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 6038
                          local checkFileName = "GUILimitedTimeMoonCardItem.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[gq]]---@class GUILimitedTimeMoonCardItemWindow : IGUIWindow
local GUILimitedTimeMoonCardItemWindow = class("GUILimitedTimeMoonCardItemWindow", IGUIWindow)

---@type PayActivityRewardConfig
local PayActivityRewardConfig = T(Global, "PayActivityRewardConfig")

---@private
function GUILimitedTimeMoonCardItemWindow:ctor(...)
	self.super.ctor(self, "LimitedTimeMoonCardItem.json", ...)
end

---@private
function GUILimitedTimeMoonCardItemWindow:onLoad()
	self.siCard1 = self:getChildWindowByName("LimitedTimeMoonCardItem-card_1", GUIType.StaticImage)
	self.stCardTitle1 = self:getChildWindowByName("LimitedTimeMoonCardItem-card_title_1", GUIType.StaticText)
	self.siCardIcon1 = self:getChildWindowByName("LimitedTimeMoonCardItem-card_icon_1", GUIType.StaticImage)
	self.siCardItemOnly1 = self:getChildWindowByName("LimitedTimeMoonCardItem-card_item_only_1", GUIType.StaticImage)
	self.stCardItemOnlyTip1 = self:getChildWindowByName("LimitedTimeMoonCardItem-card_item_only_tip_1", GUIType.StaticText)
	self.stCardItemOnlyNum1 = self:getChildWindowByName("LimitedTimeMoonCardItem-card_item_only_num_1", GUIType.StaticText)
	self.siCardItemSum1 = self:getChildWindowByName("LimitedTimeMoonCardItem-card_item_sum_1", GUIType.StaticImage)
	self.stCardItemSumTip1 = self:getChildWindowByName("LimitedTimeMoonCardItem-card_item_sum_tip_1", GUIType.StaticText)
	self.stCardItemSumNum1 = self:getChildWindowByName("LimitedTimeMoonCardItem-card_item_sum_num_1", GUIType.StaticText)
	self.btnBuy1 = self:getChildWindowByName("LimitedTimeMoonCardItem-buy_1", GUIType.Button)
	self.siCurrencyIcon1 = self:getChildWindowByName("LimitedTimeMoonCardItem-currency_icon_1", GUIType.StaticImage)
	self.stPrice1 = self:getChildWindowByName("LimitedTimeMoonCardItem-price_1", GUIType.StaticText)
	self.stPurchased1 = self:getChildWindowByName("LimitedTimeMoonCardItem-purchased_1", GUIType.StaticText)
	self.stResidue1 = self:getChildWindowByName("LimitedTimeMoonCardItem-residue_1", GUIType.StaticText)
	self.stOff = self:getChildWindowByName("LimitedTimeMoonCardItem-text_off", GUIType.StaticText)
	self:initView()
	self:initEvent()
end

---@private
function GUILimitedTimeMoonCardItemWindow:initView()
	self.stCardTitle1:SetText()
	self.stCardItemOnlyTip1:SetText(Lang:getString("gui.limit.time.activity.moon.card.daily"))
	self.stCardItemOnlyNum1:SetText()
	self.stCardItemSumTip1:SetText(Lang:getString("gui.limit.time.activity.moon.card.total"))
	self.stCardItemSumNum1:SetText()
	self.stPrice1:SetText()
	self.stPurchased1:SetText(Lang:getString("gui.limit.time.combined.purchased"))
	self.stResidue1:SetText()
	self.btnBuy1:SetVisible(false)
	self.stOff:SetText()
end

---@private
function GUILimitedTimeMoonCardItemWindow:initEvent()
	self.btnBuy1:registerEvent(GUIEvent.ButtonClick, function()
		if self.data and self.activity then
			self.activity:tryBuyCard(self.data.id)
		end
	end)
end

---@param data LimitedTimeMoonCardConfigData
function GUILimitedTimeMoonCardItemWindow:onDataChanged(data)
	self.data=data
	if not data then
		return
	end

	---@type LimitedTimeMoonCard
	self.activity=PlayerManager:getClientPlayer().payActivity.activities[data.activityId]
	if not self.activity then
		return
	end
	self.activity.info:addKeyObserver(PayActivityDefine.MoonCardInf.MoonCardRecord, function()
		--local record =self.activity.info:getValue(PayActivityDefine.MoonCardInf.MoonCardRecord)
		--print("---------------- MoonCardRecord :")
		--LogUtil.pv(record)
		self:updateCardInf()
	end)
	self:updateCardInf()
end

function GUILimitedTimeMoonCardItemWindow:updateCardInf()
	if not self.data then
		return
	end
	local data=self.data
	if data.cardName and data.cardName~="#" then
		self.stCardTitle1:SetText(Lang:getString(data.cardName))
	end
	if data.img and data.img~="#" then
		self.siCard1:SetImage(data.img)
	end
	if data.icon and data.icon~="#" then
		self.siCardIcon1:SetImage(data.icon)
	end
	if data.finalPrice and data.finalPrice~="#" then
		self.stPrice1:SetText(Lang:getString(data.finalPrice))
	end
	if data.percent and data.percent~="#" then
		self.stOff:SetText(Lang:getString(data.percent))
	end

	local reward=PayActivityRewardConfig:getCfgById(data.giftContent)
	if reward then
		self.stCardItemOnlyNum1:SetText(reward.count)
		self.siCardItemOnly1:SetImage(reward.image)
		self.stCardItemSumNum1:SetText(reward.count*data.dayNum)
		self.siCardItemSum1:SetImage(reward.image)
	end

	if not self.activity then
		return
	end

	local record = self.activity.info:getValue(PayActivityDefine.MoonCardInf.MoonCardRecord)
	if record and record[data.giftKey] then
		if self.activity:isCardActive(record[data.giftKey]) then
			local remainDay=record[data.giftKey][PayActivityDefine.MoonCardInf.RemainDay]
			if remainDay and remainDay>0 then
				self.stResidue1:SetText(string.format(Lang:getString("gui.limit.time.activity.moon.card.remain.day"),remainDay))
			end
			self.btnBuy1:SetVisible(false)
			self.stPurchased1:SetVisible(true)
			self.stResidue1:SetVisible(true)
		else
			self.btnBuy1:SetVisible(true)
			self.stPurchased1:SetVisible(false)
			self.stResidue1:SetVisible(false)
		end
	else
		self.btnBuy1:SetVisible(true)
		self.stPurchased1:SetVisible(false)
		self.stResidue1:SetVisible(false)
	end
end

return GUILimitedTimeMoonCardItemWindow
--[[WgeT04SnRRs26P1]]