---@class UICustomRoomTipLayout : IGUILayout
local UICustomRoomTipLayout = class("UICustomRoomTipLayout", IGUILayout)

---@private
function UICustomRoomTipLayout:ctor(parent)
	self.super.ctor(self, "CustomRoomTip.json", parent)
end

---@private
function UICustomRoomTipLayout:isDelayLoad()
	return true
end

---@private
function UICustomRoomTipLayout:onCreate()
	self:initCreateEvent()
end

---@private
function UICustomRoomTipLayout:initCreateEvent()

end

---@private
function UICustomRoomTipLayout:onLoad()
	self.siBg = self:getChildWindow("CustomRoomTip-Bg", GUIType.StaticImage)
	self.stText = self:getChildWindow("CustomRoomTip-Text", GUIType.StaticText)
	self:initView()
	self:initEvent()
end

---@private
function UICustomRoomTipLayout:initView()

end

---@private
function UICustomRoomTipLayout:initEvent()

end

function UICustomRoomTipLayout:onShow(str)
	self:showTip(str)
end

function UICustomRoomTipLayout:showTip(str)
	self:cancelTimer()

	self.stText:SetText(Lang:getString(str))

	self:addTimer(LuaTimer:schedule(function()
		self:hide()
	end, 2000))
end

return UICustomRoomTipLayout
