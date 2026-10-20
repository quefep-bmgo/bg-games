---@class UILimitTimeSCombinationEntryLayout : IGUILayout
local UILimitTimeSCombinationEntryLayout = class("UILimitTimeSCombinationEntryLayout", IGUILayout)

---@private
function UILimitTimeSCombinationEntryLayout:ctor(parent)
	self.super.ctor(self, "LimitTimeCombinationEntry.json", GUIManager:getMainControl())
end

---@private
function UILimitTimeSCombinationEntryLayout:isDelayLoad()
	return true
end

---@private
function UILimitTimeSCombinationEntryLayout:onCreate()
	self:initCreateEvent()
end

---@private
function UILimitTimeSCombinationEntryLayout:initCreateEvent()

end

---@private
function UILimitTimeSCombinationEntryLayout:onLoad()
	self.btnBtn = self:getChildWindow("LimitTimeCombinationEntry-Btn", GUIType.Button)
	self.stName = self:getChildWindow("LimitTimeCombinationEntry-name", GUIType.StaticText)
	self.siRedDot = self:getChildWindow("LimitTimeCombinationEntry-RedDot", GUIType.StaticImage)
	self:initView()
	self:initEvent()
end

---@private
function UILimitTimeSCombinationEntryLayout:initView()
	self.stName:SetText(Lang:getString(Lang:getString("gui.limit.time.combined.title")))
end

---@private
function UILimitTimeSCombinationEntryLayout:initEvent()
	self.btnBtn:registerEvent(GUIEvent.ButtonClick, function()
		local activity=PlayerManager:getClientPlayer().payActivity.activities[self.activityId]
		if activity then
			activity:tryShowActivityUI()
			if self.siRedDot then
				self.siRedDot:SetVisible(false)
			end
		end
	end)

	self:registerEvent(Events.PayActivityGiftCombinedRecord,function ()
		self:hide()
	end)
end

function UILimitTimeSCombinationEntryLayout:onShow(activityId)
	self.activityId=activityId
end


return UILimitTimeSCombinationEntryLayout
