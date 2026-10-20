---@class GUICustomShopSelectItemWindow : IGUIWindow
local GUICustomShopSelectItemWindow = class("GUICustomShopSelectItemWindow", IGUIWindow)
---@type UICustomShopLayout
local GUICustomShop = UIHelper.newGameGUILayout("GUICustomShop")

---@private
function GUICustomShopSelectItemWindow:ctor(...)
	self.super.ctor(self, "CustomShopSelectItem.json", ...)
end

---@private
function GUICustomShopSelectItemWindow:onLoad()
	self.siBg = self:getChildWindowByName("CustomShopSelectItem", GUIType.StaticImage)
	self.siIcon = self:getChildWindowByName("CustomShopSelectItem-Icon", GUIType.StaticImage)
	self.siSelect = self:getChildWindowByName("CustomShopSelectItem-Select", GUIType.StaticImage)
	self:initView()
	self:initEvent()
end

---@private
function GUICustomShopSelectItemWindow:initView()

end

---@private
function GUICustomShopSelectItemWindow:initEvent()
	self.siIcon:registerEvent(GUIEvent.Click, function()
		if self.clickFunc then
			self.clickFunc(self.id, self.meta)
			return
		end
		Events.ShopSelectItemEvent:invoke(self.id, self.meta)
	end)

	self:registerEvent(Events.ShopSelectItemEvent, function(id, meta)
		self.siSelect:SetVisible(self.id == id and self.meta == meta)
	end)
end

---@param data ShopItemCfg
function GUICustomShopSelectItemWindow:onDataChanged(data)
	self.id = data.id
	self.meta = data.meta
	GuiItemStack.showItemIcon(self.siIcon, data.id, data.meta, "")
	self.siSelect:SetVisible(false)
	if GUICustomShop.selectItem then
		self.siSelect:SetVisible(self.id == GUICustomShop.selectItem.id and self.meta == GUICustomShop.selectItem.meta)
	end
end

function GUICustomShopSelectItemWindow:setItem(data)
	self.id = data[1] or 0
	self.meta = data[2] or 0
	if self.id == 0 then
		self.siBg:SetImage("set:shop.json image:img_0_item_frame_add")
	else
		self.siBg:SetImage("set:shop.json image:img_9_item_frame")
	end
	GuiItemStack.showItemIcon(self.siIcon, self.id, self.meta, "")
	self.siSelect:SetVisible(false)
end

function GUICustomShopSelectItemWindow:setClickFunc(func)
	self.clickFunc = func
end

return GUICustomShopSelectItemWindow
