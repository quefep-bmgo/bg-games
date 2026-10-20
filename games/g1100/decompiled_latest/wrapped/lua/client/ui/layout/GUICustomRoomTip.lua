--[[e6RXHBBftDPt8jrPTAFeMqMLe7gvAa4jroDLBfNGxEXMuRkMsrRi3]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 2174
                          local checkFileName = "GUICustomRoomTip.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[6IYeYAsgeuLtDjWiH9UKfHpZJxZ8rzQGbBrDxQaOrxSjgu2nEnSwkqYXKsxQvGlm0mhzTTFWhI43xDzBtZvo4R7iiCTgVUqgALbEIsJMN85rGlz1x1t2YGnchc60DaDeJPUcyzmeZSgU9QponDtCCjtZLXfSOa2okMHvJBDESmt9wgHzykAN1FXKy8pBY3lOWtLngLtPsz0avAjMSWGa1uTfFgDui5RQHf2wuvvDzO1sUCtz8qRLCG2ZW13]]---@class UICustomRoomTipLayout : IGUILayout
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
--[[5D3OnD0bJ0xFGNEVrlnPz]]