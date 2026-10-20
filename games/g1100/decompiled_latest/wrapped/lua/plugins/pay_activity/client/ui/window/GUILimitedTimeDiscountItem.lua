--[[u6dzds4GcviqbdfDsg9wdpWHRe]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 6319
                          local checkFileName = "GUILimitedTimeDiscountItem.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[THopcBi5FuGGs4lSuQMGam4vVE2mTq]]---@class GUILimitedTimeDiscountItemWindow : IGUIWindow
local GUILimitedTimeDiscountItemWindow = class("GUILimitedTimeDiscountItemWindow", IGUIWindow)

local PayActivityRewardConfig = T(Global, "PayActivityRewardConfig")

---@private
function GUILimitedTimeDiscountItemWindow:ctor(...)
	self.super.ctor(self, "LimitedTimeDiscountItem.json", ...)
end

---@private
function GUILimitedTimeDiscountItemWindow:onLoad()
	self.llContentPanel = self:getChildWindowByName("LimitedTimeDiscountItem-ContentPanel", GUIType.Layout)
	self.stNameText = self:getChildWindowByName("LimitedTimeDiscountItem-NameText", GUIType.StaticText)
	self.llGoodsItem = self:getChildWindowByName("LimitedTimeDiscountItem-GoodsItem", GUIType.Layout)
	self.siGoodsIcon = self:getChildWindowByName("LimitedTimeDiscountItem-GoodsIcon", GUIType.StaticImage)
	self.stGoodsNum = self:getChildWindowByName("LimitedTimeDiscountItem-GoodsNum", GUIType.StaticText)
	self.stLimitText = self:getChildWindowByName("LimitedTimeDiscountItem-LimitText", GUIType.StaticText)
	self.siPerIcon = self:getChildWindowByName("LimitedTimeDiscountItem-PerIcon", GUIType.StaticImage)
	self.stPerText1 = self:getChildWindowByName("LimitedTimeDiscountItem-PerText1", GUIType.StaticText)
	self.btnBuyBtn = self:getChildWindowByName("LimitedTimeDiscountItem-BuyBtn", GUIType.Button)
	self.btnFreeBtn = self:getChildWindowByName("LimitedTimeDiscountItem-FreeBtn", GUIType.Button)
	self.siDiaIcon = self:getChildWindowByName("LimitedTimeDiscountItem-DiaIcon", GUIType.StaticImage)
	self.stInitPrice = self:getChildWindowByName("LimitedTimeDiscountItem-InitPrice", GUIType.StaticText)
	self.siLine = self:getChildWindowByName("LimitedTimeDiscountItem-Line", GUIType.StaticImage)
	self.stFinalPrice = self:getChildWindowByName("LimitedTimeDiscountItem-finalPrice", GUIType.StaticText)
	self.siSoulMask = self:getChildWindowByName("LimitedTimeDiscountItem-SoulMask", GUIType.StaticImage)
	self.siSoulIcon = self:getChildWindowByName("LimitedTimeDiscountItem-SoulIcon", GUIType.StaticImage)
	self.siRedDet = self:getChildWindowByName("LimitedTimeDiscountItem-RedDet", GUIType.StaticImage)
	self.stSoulText = self:getChildWindowByName("LimitedTimeDiscountItem-SoulText", GUIType.StaticText)
	self:initView()
	self:initEvent()
end

---@private
function GUILimitedTimeDiscountItemWindow:initView()
	self.stNameText:SetText("")
	self.stGoodsNum:SetText("")
	self.stLimitText:SetText("")
	self.stPerText1:SetText("")
	self.stInitPrice:SetText("")
	self.stFinalPrice:SetText("")
	self.stSoulText:SetText(Lang:getString("gui.limit.time.activity.soul.out"))
	self.btnFreeBtn:SetText(Lang:getString("gui.limit.time.activity.free.bought"))
end

---@private
function GUILimitedTimeDiscountItemWindow:initEvent()
	self.btnBuyBtn:registerEvent(GUIEvent.ButtonClick, function()
		if not self.data then
			return
		end
		UIHelper.showGameGUILayout("GUILimitedTimeWeekConfirm", self.data)
	end)

	self.btnFreeBtn:registerEvent(GUIEvent.ButtonClick, function()
		if not self.data then
			return
		end
		self.data.activity:tryBuy(self.data.id)
	end)

	self.llGoodsItem:registerEvent(GUIEvent.TouchUp, function()
		if not self.data then return end
		local giftId = tonumber(self.data.giftContent[1])
		if giftId then
			local rewardConfig = PayActivityRewardConfig:getCfgById(giftId)
			if rewardConfig then
				UIHelper.showGameGUILayout("GUIPayActivityRewardDetail", rewardConfig.id)
			end
		end
	end)
end

---@param data table
function GUILimitedTimeDiscountItemWindow:onDataChanged(data)
	self.data = data
	local limitCount = data.limitCounts - (data.boughtCounts or 0)
	if data.limitCounts >=0 and limitCount <= 0 then
		self.siSoulMask:SetVisible(true)
		self.stLimitText:SetVisible(false)
		self.btnBuyBtn:SetEnabled(false)
		self.btnBuyBtn:SetTouchable(false)
		self.btnBuyBtn:SetVisible(false)
		self.btnFreeBtn:SetVisible(false)
	else
		self.siSoulMask:SetVisible(false)
		self.stLimitText:SetVisible(true)
		self.btnBuyBtn:SetEnabled(true)
		self.btnBuyBtn:SetTouchable(true)
		self.btnBuyBtn:SetVisible(data.finalPrice > 0)
		self.btnFreeBtn:SetVisible(data.finalPrice <= 0)
	end
	self.siRedDet:SetVisible(data.finalPrice <= 0)
	self.stNameText:SetText(Lang:getString(data.giftName))
	self.stInitPrice:SetText(tostring(data.initPrice))
	self.stFinalPrice:SetText(tostring(data.finalPrice))
	self.stPerText1:SetText(string.format("%s OFF", data.percent))
	if data.limitCounts < 0  then
		self.stLimitText:SetText(Lang:getString("gui.limit.time.discount.store.no.limit"))
	else
		self.stLimitText:SetText(string.format("%d/%d", limitCount, data.limitCounts))
	end
	local giftId = tonumber(data.giftContent[1])
	if giftId then
		local rewardConfig = PayActivityRewardConfig:getCfgById(giftId)
		if rewardConfig then
			PayActivityRewardConfig:setRewardImage(self.siGoodsIcon, rewardConfig)
			if rewardConfig.count <= 1 then
				self.stGoodsNum:SetText("")
			else
				self.stGoodsNum:SetText("X" .. rewardConfig.count)
			end
			local quality = rewardConfig.quality or 1
			self.llGoodsItem:SetBackImage("set:limited_time_activity.json image:img_frame_quality0".. quality)
		else
			self.stGoodsNum:SetText("")
			self.siGoodsIcon:SetImage("")
			self.llGoodsItem:SetBackImage("set:limited_time_activity.json image:img_frame_quality01")
		end
	else
		self.stGoodsNum:SetText("")
		self.siGoodsIcon:SetImage("")
		self.llGoodsItem:SetBackImage("set:limited_time_activity.json image:img_frame_quality01")
	end

end

return GUILimitedTimeDiscountItemWindow
--[[GemE9f1jk4SNstzu3xutoSaImT0]]---