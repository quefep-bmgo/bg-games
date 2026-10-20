---@class UICustomShopInputContentLayout : IGUILayout
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
