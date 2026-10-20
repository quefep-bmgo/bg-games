--[[G5BME8LFHEUVULdhtwNiPM6]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1938
                          local checkFileName = "GUITriggerGiftSwitchPoint.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[THopcBi5FuGGs4lSuQMGam4vVE2mTq]]---@class GUITriggerGiftSwitchPointWindow : IGUIWindow
local GUITriggerGiftSwitchPointWindow = class("GUITriggerGiftSwitchPointWindow", IGUIWindow)

---@private
function GUITriggerGiftSwitchPointWindow:ctor(...)
    self.super.ctor(self, "TriggerGiftSwitchPoint.json", ...)
end

---@private
function GUITriggerGiftSwitchPointWindow:onLoad()
    self.checkBox = self:getChildWindowByName("TriggerGiftSwitchPoint", GUIType.CheckBox)
    self.siImg = self:getChildWindowByName("TriggerGiftSwitchPoint-Img", GUIType.StaticImage)
    self.siTabImg = self:getChildWindowByName("TriggerGiftSwitchPoint-Tab-Image", GUIType.StaticImage)
    self:initEvent()
end

---@private
function GUITriggerGiftSwitchPointWindow:initEvent()

end

function GUITriggerGiftSwitchPointWindow:showIsSwitching(isSwitching)
    if isSwitching then
        self.siImg:SetImage("set:trigger_gift.json image:chb_0_select")
    else
        self.siImg:SetImage("set:trigger_gift.json image:chb_0_normal")
    end
end

return GUITriggerGiftSwitchPointWindow
--[[mhCVHGPH8XPR6YJNgrjtwFl6qmRH4UWDg3iKllBnr041EDZgIF9Xgqkv74lal9OvmgBDn81ufA5diDMrQNRfZft5jly60MPqggLOhWCYS]]