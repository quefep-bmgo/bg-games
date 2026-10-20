---@class UIDisconnectMaskLayout : IGUILayout
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
