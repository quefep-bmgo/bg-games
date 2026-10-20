--[[qaDj3pq8CPJE45KdUJLXj6gDgjolV1QmKqLAsbBuuk0i9DetLqNE6hYZXgUnT]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 2421
                          local checkFileName = "GUISingleTranslation.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[Anxw7B6o5PkUiGsIhWJjZ0fc7tn3GnmlkjbMvjuQudEmdXRrbBxmG9elYjIBiF1Bw0BbH1n5r6ROeFHVg6n7kABHMMvyTBI3aLfjRVi2Wxa9qv3DutrzKZPmFFUZ80kkUyz0MQlrsU0mbu4kz433HTM]]---@class UISingleTranslationLayout : IGUILayout
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
--[[TCJZpGo0x0texkQDTzfLvUOoQP9bsRHNOEc1lCHnsu]]---