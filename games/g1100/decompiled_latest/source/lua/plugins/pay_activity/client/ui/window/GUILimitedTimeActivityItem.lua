---@class GUILimitedTimeActivityItemWindow : IGUIWindow
local GUILimitedTimeActivityItemWindow = class("GUILimitedTimeActivityItemWindow", IGUIWindow)
---@type PayActivityRewardConfig
local PayActivityRewardConfig = T(Global, "PayActivityRewardConfig")

---@private
function GUILimitedTimeActivityItemWindow:ctor(...)
	self.super.ctor(self, "LimitedTimeActivityItem.json", ...)
end

---@private
function GUILimitedTimeActivityItemWindow:onLoad()
	self.siFrame = self:getChildWindowByName("LimitedTimeActivityItem-frame", GUIType.StaticImage)
	self.siIcon = self:getChildWindowByName("LimitedTimeActivityItem-icon", GUIType.StaticImage)
	self.stNum = self:getChildWindowByName("LimitedTimeActivityItem-num", GUIType.StaticText)
	self.stName = self:getChildWindowByName("LimitedTimeActivityItem-name", GUIType.StaticText)
	self.siEffect = self:getChildWindowByName("LimitedTimeActivityItem-effect", GUIType.StaticImage)
	self:initView()
	self:initEvent()
end

---@private
function GUILimitedTimeActivityItemWindow:initView()
	self.stNum:SetText()
	self.stName:SetText()
end

---@private
function GUILimitedTimeActivityItemWindow:initEvent()
	self.siFrame:registerEvent(GUIEvent.Click, function()
		if self.data then
			UIHelper.showGameGUILayout("GUIPayActivityRewardDetail", self.data.id,true)
		end
	end)
end

---@param data PayActivityRewardConfigData
function GUILimitedTimeActivityItemWindow:onDataChanged(data)
	self.data=data
	if data.image and data.image ~= "#" then
		self.siIcon:SetImage(data.image)
	end
	if data.name and data.name ~= "#" then
		self.stName:SetText(Lang:getString(data.name))
	end
	if data.count and data.count ~= "#" and tonumber(data.count)  and tonumber(data.count)>1 then
		self.stNum:SetText(data.count)
	else
		self.stNum:SetText()
	end
	local quality = data.quality or 1
	self.siFrame:SetImage("set:limited_time_activity.json image:img_frame_quality0".. quality)
	PayActivityRewardConfig:setRewardEffect(self.siEffect, data)
end

return GUILimitedTimeActivityItemWindow
