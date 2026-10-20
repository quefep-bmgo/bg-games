--[[G260pxjuM65J8Vtq20NHsXG0zaQUro]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1938
                          local checkFileName = "GUIDisconnectMask.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[fnHosZs1ZnILc3UxUV6I9yzRhvPXiGCvzsMHCEBox1hS2Jz0G0nWQEGeYG3CVDYKcukqFk8qtrYLT4UFqhhrTxQokHmiygh2HUjdKJ8fYfeQnd5yKggHvwWmMxqczGDGJd6jMcU5q]]---@class UIDisconnectMaskLayout : IGUILayout
---@field super IGUILayout
local UIDisconnectMaskLayout = class("UIDisconnectMaskLayout", IGUILayout)

---@private
function UIDisconnectMaskLayout:ctor(parent)
	self.super.ctor(self, "DisconnectMask.json", parent)
end

---@private
function UIDisconnectMaskLayout:onLoad()
	self.siLoading = self:getChildWindow("DisconnectMask-Loading", GUIType.StaticImage)
	self.stLoadingText = self:getChildWindow("DisconnectMask-LoadingText", GUIType.StaticText)
	self:initView()
end

---@private
function UIDisconnectMaskLayout:isShowAnim()
	return false
end

---@private
function UIDisconnectMaskLayout:initView()
	self.stLoadingText:SetText(Lang:getString("gui.disconnect.loading.text"))
end

---@private
function UIDisconnectMaskLayout:onShow(params)
	if params and #params ~= 0 then
		self.stLoadingText:SetText(Lang:getString(params))
	end
end

function UIDisconnectMaskLayout:hide(force)
	if not force then
		return
	end
	self.super.hide(self)
end

return UIDisconnectMaskLayout
--[[i9jsK]]