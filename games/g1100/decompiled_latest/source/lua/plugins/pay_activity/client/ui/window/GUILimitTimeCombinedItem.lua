---@class GUILimitTimeCombinedItemWindow : IGUIWindow
local GUILimitTimeCombinedItemWindow = class("GUILimitTimeCombinedItemWindow", IGUIWindow)

---@private
function GUILimitTimeCombinedItemWindow:ctor(...)
	self.super.ctor(self, "LimitTimeCombinedItem.json", ...)
end

---@private
function GUILimitTimeCombinedItemWindow:onLoad()
	self.llGoodItem = self:getChildWindowByName("LimitTimeCombinedItem-goodItem", GUIType.Layout)
	self.siGoodsBg = self:getChildWindowByName("LimitTimeCombinedItem-goodsBg", GUIType.StaticImage)
	self.siGoodsIcon = self:getChildWindowByName("LimitTimeCombinedItem-goodsIcon", GUIType.StaticImage)
	self.siNumBg = self:getChildWindowByName("LimitTimeCombinedItem-NumBg", GUIType.StaticImage)
	self.stGoodsNum = self:getChildWindowByName("LimitTimeCombinedItem-goodsNum", GUIType.StaticText)
	self.llMask = self:getChildWindowByName("LimitTimeCombinedItem-Mask", GUIType.Layout)
	self.stBought = self:getChildWindowByName("LimitTimeCombinedItem-Bought", GUIType.StaticText)
	self:initView()
	self:initEvent()

end

---@private
function GUILimitTimeCombinedItemWindow:initView()
	self.stGoodsNum:SetText(Lang:getString(""))
	self.stBought:SetText(Lang:getString("gui.limit.time.combined.purchased"))
	self.llMask:SetVisible(false)
end

---@private
function GUILimitTimeCombinedItemWindow:initEvent()
	self.llGoodItem:registerEvent(GUIEvent.Click, function()
		UIHelper.showGameGUILayout("GUIPayActivityRewardDetail", self.data.id)
	end)
end

---@param data PayActivityRewardConfigData
function GUILimitTimeCombinedItemWindow:onDataChanged(data)
	self.data = data
	self.stGoodsNum:SetText("X" .. data.count)
	self.siGoodsIcon:SetImage(data.image)
	self.llMask:SetVisible(data.isHave)
end

return GUILimitTimeCombinedItemWindow
