---@class UISingleTranslationLayout : IGUILayout
local UISingleTranslationLayout = class("UISingleTranslationLayout", IGUILayout)
---@type TranslationHelper
local TranslationHelper = T(Global, "TranslationHelper")

---@private
function UISingleTranslationLayout:ctor(parent)
	self.super.ctor(self, "SingleTranslation.json", parent)
end

---@private
function UISingleTranslationLayout:isDelayLoad()
	return true
end

---@private
function UISingleTranslationLayout:onCreate()
	self:initCreateEvent()
end

---@private
function UISingleTranslationLayout:initCreateEvent()

end

---@private
function UISingleTranslationLayout:onLoad()
	self.llMask = self:getChildWindow("SingleTranslation-Mask", GUIType.Layout)
	self.btnBtn = self:getChildWindow("SingleTranslation-Btn", GUIType.Button)
	self:initView()
	self:initEvent()
end

---@private
function UISingleTranslationLayout:initView()

end

---@private
function UISingleTranslationLayout:initEvent()
	self.llMask:registerEvent(GUIEvent.Click, function()
		self:hide()
	end)

	self.btnBtn:registerEvent(GUIEvent.ButtonClick, function()
		if self.data then
			TranslationHelper:tryTranslate(self.data)
		end
		self:hide()
	end)
end

function UISingleTranslationLayout:onShow(pos, data)
	self.data = data
	if not data then
		self:hide()
		return
	end
	self.btnBtn:SetXPosition({0,pos.x - 38})
	self.btnBtn:SetYPosition({0,pos.y - 80})
end

return UISingleTranslationLayout
