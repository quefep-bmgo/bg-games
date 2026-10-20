--[[SbfLUWWBZ4XZBLNBS28mxZ3UdWb6q9igNm4ZWkZbyi53ghpqQrTA1I3A0tQJFzOEJT1JFaBjy3d4U]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 2237
                          local checkFileName = "GUITriggerGiftRewardItem2.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[2otBRs90C440UpSOVmL4uVb9h7dDNAwzwwfvb6r6u1c5Yqn3B]]---@class GUITriggerGiftRewardItem2Window : IGUIWindow
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
--[[LDFs8vtC4gFAhG1JGEijF0IK1f]]---