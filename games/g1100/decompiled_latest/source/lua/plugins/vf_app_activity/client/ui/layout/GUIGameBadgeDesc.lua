---@class UIGameBadgeDescLayout : IGUILayout
local UIGameBadgeDescLayout = class("UIGameBadgeDescLayout", IGUILayout)

---@private
function UIGameBadgeDescLayout:ctor(parent)
	self.super.ctor(self, "GameBadgeDesc.json", parent)
end

---@private
function UIGameBadgeDescLayout:isDelayLoad()
	return true
end

---@private
function UIGameBadgeDescLayout:onCreate()
	self:initCreateEvent()
end

---@private
function UIGameBadgeDescLayout:initCreateEvent()

end

---@private
function UIGameBadgeDescLayout:onLoad()
	self.uivDescUrl = self:getChildWindow("GameBadgeDesc-DescUrl", GUIType.UrlImage)
	self.siClose = self:getChildWindow("GameBadgeDesc-Close", GUIType.StaticImage)
	self.siDesc = self:getChildWindow("GameBadgeDesc-Desc", GUIType.StaticImage)
	self.stDescText = self:getChildWindow("GameBadgeDesc-DescText", GUIType.StaticText)
	self:initView()
	self:initEvent()
end

---@private
function UIGameBadgeDescLayout:initView()
	self.uivDescUrl:setChildMaterial(0)
	self.uivDescUrl:setDefaultImage("")
	self.root:SetLevel(0)
end

---@private
function UIGameBadgeDescLayout:initEvent()
	self.siClose:registerEvent(GUIEvent.Click, function()
		self:hide()
	end)
end

function UIGameBadgeDescLayout:showDesc(data)
	self:show()
	self.uivDescUrl:setUrl(data.guidePic)
	self.stDescText:SetText(data.guideDesc)
end

return UIGameBadgeDescLayout
