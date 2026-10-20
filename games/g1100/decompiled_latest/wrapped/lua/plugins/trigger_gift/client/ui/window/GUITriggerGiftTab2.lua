--[[m5YHxV6SlZ4MLBFJfvCJ]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 2418
                          local checkFileName = "GUITriggerGiftTab2.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[bIvZIYdt8Fuk5W9M68KtFF8OwzCcKSsNrKe8FwsmvKvP5gcwucLgsuAQKQiRkFJwjfFCPCdGj2A0o2Ew08pXnDOC56IO]]---@class GUITriggerGiftTab2Window : IGUIWindow
local GUITriggerGiftTab2Window = class("GUITriggerGiftTab2Window", IGUIWindow)

---@private
function GUITriggerGiftTab2Window:ctor(...)
	self.super.ctor(self, "TriggerGiftTab2.json", ...)
end

---@private
function GUITriggerGiftTab2Window:onLoad()
	self.siBg = self:getChildWindowByName("TriggerGiftTab2-Bg", GUIType.StaticImage)
	self.stText = self:getChildWindowByName("TriggerGiftTab2-Text", GUIType.StaticText)
	self:initView()
	self:initEvent()
end

---@private
function GUITriggerGiftTab2Window:initView()

end

---@private
function GUITriggerGiftTab2Window:initEvent()
	self.root:registerEvent(GUIEvent.Click, function()
		if not self.index or not self.clickFunc then
			return
		end
		self.clickFunc(self.index)
	end)
end

function GUITriggerGiftTab2Window:setSelect(isSelect)
	if isSelect then
		self.siBg:SetImage("set:trigger_gift_2.json image:chb_0_select")
		self.siBg:SetArea({ 0, 0 }, { 0, 0 }, { 0, 130 }, { 0, 40 })
		self.stText:SetTextColor({ 135 / 255, 77 / 255, 19 / 255, 1 })
	else
		self.siBg:SetImage("set:trigger_gift_2.json image:chb_0_normal")
		self.siBg:SetArea({ 0, 0 }, { 0, 0 }, { 0, 115 }, { 0, 40 })
		self.stText:SetTextColor({ 175 / 255, 168 / 255, 129 / 255, 1 })
	end
end

function GUITriggerGiftTab2Window:setContent(index, func)
	self.index = index
	self.clickFunc = func
	self.stText:SetText(Lang:getString("gui.trigger.gift.tab.text") .. index)
end

---@param data table
function GUITriggerGiftTab2Window:onDataChanged(data)

end

return GUITriggerGiftTab2Window
--[[uiHC]]