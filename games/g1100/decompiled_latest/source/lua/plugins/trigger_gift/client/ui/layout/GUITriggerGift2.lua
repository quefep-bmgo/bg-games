---@class UITriggerGift2Layout : IGUILayout
local UITriggerGift2Layout = class("UITriggerGift2Layout", IGUILayout)
---@type TriggerGiftRewardGroupConfig
local TriggerGiftRewardGroupConfig = Plugins.Require("trigger_gift", "common.config.TriggerGiftRewardGroupConfig")
---@type TriggerGiftDescConfig
local TriggerGiftDescConfig = Plugins.Require("trigger_gift", "common.config.TriggerGiftDescConfig")

---@type TriggerGiftDataMgr
local TriggerGiftDataMgr = Plugins.Require("trigger_gift", "client.data.TriggerGiftDataMgr")
---@type UIUtils
local UIUtils = T(Global, "UIUtils")

---@private
function UITriggerGift2Layout:ctor(parent)
	self.super.ctor(self, "TriggerGift2.json", parent)
end

local OffNumImage = "set:trigger_gift_2.json image:img_0_gift_discount"

---@private
function UITriggerGift2Layout:onLoad()
	self.siBg = self:getChildWindow("TriggerGift2-Bg", GUIType.StaticImage)
	self.siDescBg = self:getChildWindow("TriggerGift2-Desc-Bg", GUIType.StaticImage)
	self.stDesc = self:getChildWindow("TriggerGift2-Desc", GUIType.StaticText)
	self.llItems = self:getChildWindow("TriggerGift2-Items", GUIType.Layout)
	self.ltTab = self:getChildWindow("TriggerGift2-Tab", GUIType.Layout)
	self.btnClose = self:getChildWindow("TriggerGift2-Close", GUIType.Button)
	self.btnBuy = self:getChildWindow("TriggerGift2-Buy", GUIType.Button)
	self.llOffValue = self:getChildWindow("TriggerGift2-Off-Value", GUIType.Layout)
	self.siIcon = self:getChildWindow("TriggerGift2-Icon", GUIType.StaticImage)
	self.stPrice = self:getChildWindow("TriggerGift2-Price", GUIType.StaticText)
	self.stValue = self:getChildWindow("TriggerGift2-Value", GUIType.StaticText)
	self.siValueLine = self:getChildWindow("TriggerGift2-Value-Line", GUIType.StaticImage)
	self.siItemBG = self:getChildWindow("TriggerGift2-Item-BG", GUIType.StaticImage)
	self.stCountDownNum = self:getChildWindow("TriggerGift2-CountDown-Num", GUIType.StaticText)
	self.siTopImage = self:getChildWindow("TriggerGift2-TopImage", GUIType.StaticImage)

	---@type GUICommonActivityRewardFloat
	self.wFloatReward = UIHelper.newEngineGUIWindow("GUICommonActivityRewardFloat")
	self.root:AddChildWindow(self.wFloatReward.root)

	self:initView()
	self:initEvent()

	self.tabs = {}
end

---@private
function UITriggerGift2Layout:initView()
	--self.stDesc:SetText(Lang:getString("common.triggerGift.title"))
	self.stPrice:SetText(Lang:getString(""))
	self.stValue:SetText(Lang:getString(""))

	---@type IGUIListView
	self.lvShowItemList = IGUIListView.new("TriggerGift-Rewards-List", self.llItems, nil, Orientation.Horizontal)
	self.lvShowItemList.root:SetHorizontalAlignment(HorizontalAlignment.Center)
	self.lvShowItemList.root:SetVerticalAlignment(VerticalAlignment.Center)
	self.lvShowItemList.root:SetClipChild(false)
	self.lvShowItemList:setItemSpace(25)

	self.showItemAdapt = (require "ui.adapter.TriggerGiftRewardItemAdapt").new()
	self.showItemAdapt:setItemParent(self)
	self.showItemAdapt:setItemSize(60, 60)

	self.lvShowItemList:setAdapter(self.showItemAdapt)
	self.lvShowItemList.offset = 0

	self.lvShowItemList.root:registerEvent(GUIEvent.ScrollMoveChange, function(events)
		local scroll = events.offset
		if self.curGiftRewardConfig then
			if scroll < -125 then
				local first = table.remove(self.curGiftRewardConfig, 1)
				table.insert(self.curGiftRewardConfig, first)
				self.showItemAdapt:setData(self.curGiftRewardConfig)
				scroll = scroll + 125
				self.lvShowItemList.root:SetScrollOffset(scroll)
			elseif scroll > 25 then
				local last = table.remove(self.curGiftRewardConfig, #self.curGiftRewardConfig)
				table.insert(self.curGiftRewardConfig, 1, last)
				self.showItemAdapt:setData(self.curGiftRewardConfig)
				scroll = scroll - 125
				self.lvShowItemList.root:SetScrollOffset(scroll)
			end
		end
	end)

	self.lvShowItemList.root:registerEvent(GUIEvent.ScrollMoveEnd, function(events)
		self.isBeScroll = false
	end)

	self.lvShowItemList.root:registerEvent(GUIEvent.ScrollCardClick, function(events)
		self.isBeScroll = false
	end)

	self.lvTabs = IGUIListView.new("GUITriggerGift2-Tabs-List", self.ltTab)
	self.lvTabs:setItemSpace(4)
	self.lvTabs.root:SetWidth({ 0, 130 })
	self.lvTabs.root:SetClipChild(false)
end

---@private
function UITriggerGift2Layout:initEvent()
	self.btnClose:registerEvent(GUIEvent.ButtonClick, function()
		self:hide()
	end)
	self.btnBuy:registerEvent(GUIEvent.ButtonClick, function()
		self:onClickBuy()
	end)
end

function UITriggerGift2Layout:onTick()
	local curGiftList = TriggerGiftDataMgr:getTriggerGiftData()
	if curGiftList[self.curGiftIndex] then
		local giftConfig = TriggerGiftDescConfig:getCfgById(curGiftList[self.curGiftIndex].giftId)
		if giftConfig then
			local lastTime = curGiftList[self.curGiftIndex].startTime + giftConfig.duration - os.time()
			if lastTime >= 0 then
				self.stCountDownNum:SetText(DateUtil.getFormatTime(lastTime))
				self.stCountDownNum:SetWidth({ 0, self.stCountDownNum:GetTextWidth() + 10 })
			else
				TriggerGiftDataMgr:showTriggerGiftWindow()
			end
		end
	end
	local giftNum = #self.curGiftRewardConfig
	if giftNum > 4 then
		self.lvShowItemList.root:SetArea({ 0, 0 }, { 0, 0 }, { 1, 0 }, { 1, 0 })
		local scroll = self.lvShowItemList.root:GetScrollOffset()
		if not self.isBeScroll then
			self.lvShowItemList.root:SetScrollOffset(scroll - 2)
		end
	else
		local offset = giftNum * 60 + (giftNum - 1) * 10
		self.lvShowItemList.root:SetArea({ 0, 0 }, { 0, 0 }, { 0, offset }, { 1, 0 })
	end
end

function UITriggerGift2Layout:onClickBuy()
	if not self.curGiftIndex then
		return
	end
	local curGiftList = TriggerGiftDataMgr:getTriggerGiftData()
	local data = curGiftList[self.curGiftIndex]
	local config = TriggerGiftDescConfig:getCfgById(data.giftId)
	if data.startTime + config.duration < os.time() then
		return
	end
	PayHelper.checkMoney(CurrencyId.Diamonds, config.price, function(success)
		if success then
			CustomDialog.builder().setTitleText("TriggerGift.buyPop.title")
						.setRightText(Lang:getString("gui_dialog_tip_btn_sure"))
						.setContentText(Lang:getString("TriggerGift.buyPop.content"))
						.setRightClickListener(function()
				PlayerManager:getClientPlayer():sendPacket({
					pid = "BuyTriggerGift",
					giftId = data.giftId
				})
			end).show()
		end
	end)
end

---@param data TriggerGiftInfo[]
function UITriggerGift2Layout:onDataChange(data)
	self.tabs = {}
	self.lvTabs:clearItems()
	local curGiftList = TriggerGiftDataMgr:getTriggerGiftData()
	for i, gift in ipairs(curGiftList) do
		--local giftConfig = TriggerGiftDescConfig:getCfgById(gift.giftId)
		self:newTab(i)
	end

	if not self.curGiftIndex then
		self:changeCurSelect(1)
	else
		if self.curGiftIndex > #curGiftList then
			self:changeCurSelect(#curGiftList)
		else
			self:changeCurSelect(self.curGiftIndex)
		end
	end
end

function UITriggerGift2Layout:changeCurSelect(index)
	local curGiftList = TriggerGiftDataMgr:getTriggerGiftData()
	if not curGiftList[index] then
		return
	end
	self.curGiftIndex = index
	self:selectTab(index)

	local giftConfig = TriggerGiftDescConfig:getCfgById(curGiftList[index].giftId)
	if not giftConfig then
		return
	end

	self.siTopImage:SetImage(giftConfig.topImage)
	self.stDesc:SetText(Lang:getString(giftConfig.desc))
	self.stPrice:SetText(giftConfig.price)
	self.stValue:SetText(giftConfig.value)

	local nameLen = string.len(giftConfig.name)
	if self.llOffValue:GetChildCount() > nameLen then
		for i = self.llOffValue:GetChildCount(), (nameLen + 1), -1 do
			GUIManager:getWindowByName("TriggerGift2-Off-" .. tostring(i), GUIType.StaticImage):SetVisible(false)
		end
	end
	local posX = 0
	for i = 1, nameLen do
		local image = GUIManager:getWindowByName("TriggerGift2-Off-" .. tostring(i), GUIType.StaticImage)
		if not image then
			image = GUIManager:createGUIWindow(GUIType.StaticImage, "TriggerGift2-Off-" .. tostring(i))
			image:SetHorizontalAlignment(HorizontalAlignment.Left)
			image:SetVerticalAlignment(VerticalAlignment.Center)
			self.llOffValue:AddChildWindow(image)
		end
		image:SetVisible(true)
		local width, height = UIHelper:getImageSize(OffNumImage .. tostring(string.sub(giftConfig.name, i, i)), 28, 32)
		image:SetArea({ 0, posX }, { 0, 0 }, { 0, width[2] }, { 0, 32 })
		posX = posX + width[2]
		image:SetImage(OffNumImage .. tostring(string.sub(giftConfig.name, i, i)))
	end

	self.curGiftRewardConfig = TriggerGiftRewardGroupConfig:getCfgByGroupId(giftConfig.rewardGroupId)
	if self.curGiftRewardConfig then
		local giftNum = #self.curGiftRewardConfig
		if giftNum > 4 then
			giftNum = 4
		end

		local offset = giftNum * 59 + (giftNum - 1) * 10

		self.llItems:SetHeight({ 0, 60 })
		self.showItemAdapt:clearItems()
		self.showItemAdapt:setItemSize(60, 60)
		self.lvShowItemList:setItemSpace(10)
		self.lvShowItemList.root:SetArea({ 0, 0 }, { 0, 0 }, { 0, offset }, { 1, 0 })
		self.lvShowItemList.root:SetScrollOffset(0)

		self.showItemAdapt:setData(self.curGiftRewardConfig)
	end
end

function UITriggerGift2Layout:clickItem(item)
	self.wFloatReward:showReward(item.reward, item.root)
end

function UITriggerGift2Layout:refreshTab()

end

function UITriggerGift2Layout:newTab(index)
	local tab = UIHelper.newGameGUIWindow("GUITriggerGiftTab2")
	tab:setContent(index, function(tabIndex)
		self:changeCurSelect(tabIndex)
	end)
	self.tabs[index] = tab
	self.lvTabs:addItem(tab, true, index)
end


function UITriggerGift2Layout:selectTab(index)
	for _, tab in pairs(self.tabs) do
		tab:setSelect(false)
	end
	if self.tabs[index] then
		self.tabs[index]:setSelect(true)
	end
end

function UITriggerGift2Layout:onHide()
	self.tabs = {}
	self.lvTabs:clearItems()
end

return UITriggerGift2Layout
