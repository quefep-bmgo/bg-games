--[[kzilhMMJyf5DxsYNS6YHkl5AxI]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 2046
                          local checkFileName = "GUICustomShopInputContent.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[wtFO6DuRBF8D8QHsJug99hd]]---@class UICustomShopInputContentLayout : IGUILayout
local UICustomShopInputContentLayout = class("UICustomShopInputContentLayout", IGUILayout)

---@private
function UICustomShopInputContentLayout:onLoad()
	self.siInputBg = self:getChildWindow("CustomShopInputContent-Input-Bg", GUIType.StaticImage)
	self.etInput = self:getChildWindow("CustomShopInputContent-Input", GUIType.Edit)
	self:initView()
	self:initEvent()
end

---@private
function UICustomShopInputContentLayout:initView()

end

---@private
function UICustomShopInputContentLayout:initEvent()
	self.etInput:registerEvent(GUIEvent.EditTextInput, function(args)
		if self.contentChangeListener then
			local text = self.etInput:GetText()
			text = FilterWord.getReplaceContent(text)
			self.contentChangeListener(text)
		end
	end)
end

function UICustomShopInputContentLayout:setDefaultContentText(content)
	self.etInput:SetText(content)
end

function UICustomShopInputContentLayout:onHide()
	self.contentChangeListener = nil
	self.etInput:SetText("")
end

function UICustomShopInputContentLayout:setContentChangeListener(contentChangeListener)
	self.contentChangeListener = contentChangeListener
end

return UICustomShopInputContentLayout
--[[HjEAUMjyZa92mzBG3oDchAibYuLiRxmbLV12fI3r]]