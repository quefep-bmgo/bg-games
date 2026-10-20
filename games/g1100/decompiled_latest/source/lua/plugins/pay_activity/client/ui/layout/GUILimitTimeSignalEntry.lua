---@class UILimitTimeSignalEntryLayout : IGUILayout
local UILimitTimeSignalEntryLayout = class("UILimitTimeSignalEntryLayout", IGUILayout)

---@type LimitedTimeGiftSignalConfig
local LimitedTimeGiftSignalConfig = T(Global, "LimitedTimeGiftSignalConfig")

---@private
function UILimitTimeSignalEntryLayout:ctor(parent)
	self.super.ctor(self, "LimitTimeSignalEntry.json", GUIManager:getMainControl())
end

---@private
function UILimitTimeSignalEntryLayout:isDelayLoad()
	return true
end

---@private
function UILimitTimeSignalEntryLayout:onCreate()
	self:initCreateEvent()
end

---@private
function UILimitTimeSignalEntryLayout:initCreateEvent()

end

---@private
function UILimitTimeSignalEntryLayout:onLoad()
	self.btnBtn = self:getChildWindow("LimitTimeSignalEntry-Btn", GUIType.Button)
	self.stName = self:getChildWindow("LimitTimeSignalEntry-name", GUIType.StaticText)
	self.siRedDot = self:getChildWindow("LimitTimeSignalEntry-RedDot", GUIType.StaticImage)
	self:initView()
	self:initEvent()
end

---@private
function UILimitTimeSignalEntryLayout:initView()
	self.stName:SetText(Lang:getString(Lang:getString("gui.limit.time.combined.title")))
end

---@private
function UILimitTimeSignalEntryLayout:initEvent()
	self.btnBtn:registerEvent(GUIEvent.ButtonClick, function()
		local activity=PlayerManager:getClientPlayer().payActivity.activities[self.activityId]
		if activity then
			activity:tryShowActivityUI()
			activity:updateCanReward()
			if self.siRedDot then
				self.siRedDot:SetVisible(false)
			end
		end
	end)
end

function UILimitTimeSignalEntryLayout:onShow(activityId)
	self.activityId=activityId
end


return UILimitTimeSignalEntryLayout
