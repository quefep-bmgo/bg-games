---@class GUITriggerGiftRewardItem2Window : IGUIWindow
local GUITriggerGiftRewardItem2Window = class("GUITriggerGiftRewardItem2Window", IGUIWindow)

---@private
function GUITriggerGiftRewardItem2Window:ctor(...)
	self.super.ctor(self, "TriggerGiftRewardItem2.json", ...)
end

---@private
function GUITriggerGiftRewardItem2Window:onLoad(json, parent)
	self.parent = parent
	self.llRoot = DynamicCast.dynamicCastWindow(GUIType.Layout, self.root)
	self.siBG = self:getChildWindowByName("TriggerGiftRewardItem-BG", GUIType.StaticImage)
	self.siReward = self:getChildWindowByName("TriggerGiftRewardItem2-Reward", GUIType.StaticImage)
	self.stNum = self:getChildWindowByName("TriggerGiftRewardItem2-Num", GUIType.StaticText)
	self:initView()
	self:initEvent()
end

---@private
function GUITriggerGiftRewardItem2Window:initView()
	self.stNum:SetText()
end

---@private
function GUITriggerGiftRewardItem2Window:initEvent()
	self.llRoot:registerEvent(GUIEvent.Click, function()
		self.parent:clickItem(self)
	end)
end

---@param data TriggerGiftRewardGroupData
function GUITriggerGiftRewardItem2Window:onDataChanged(data)
	self.siReward:SetImage(data.image)
	if data.num == 1 then
		self.stNum:SetText(" ")
	else
		self.stNum:SetText(data.num)
	end
	data.numLang = data.num
	self.reward = data
end

return GUITriggerGiftRewardItem2Window
