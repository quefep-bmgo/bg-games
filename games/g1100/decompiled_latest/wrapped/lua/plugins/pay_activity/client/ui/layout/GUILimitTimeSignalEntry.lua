--[[G260pxjuM65J8Vtq20NHsXG0zaQUro]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 2574
                          local checkFileName = "GUILimitTimeSignalEntry.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[MIj7vrlHPacoedLWifPcwHzT7UtucD8pDlkAbfk5t8g5tJLL2CtHHrLyK8JPpGXqtCTbxqvuBf8YM77ZTMrAwLExt8t2FE2A1udfGH1dsUe]]---@class UILimitTimeSignalEntryLayout : IGUILayout
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
--[[LDFs8vtC4gFAhG1JGEijF0IK1f]]