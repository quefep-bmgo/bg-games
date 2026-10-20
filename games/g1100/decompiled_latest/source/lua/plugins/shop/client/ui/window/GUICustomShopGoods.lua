---@class GUICustomShopGoodsWindow : IGUIWindow
local GUICustomShopGoodsWindow = class("GUICustomShopGoodsWindow", IGUIWindow)
---@type UICustomShopLayout
local GUICustomShop = UIHelper.newGameGUILayout("GUICustomShop")

---@private
function GUICustomShopGoodsWindow:ctor(...)
	self.super.ctor(self, "CustomShopGoods.json", ...)
end

---@private
function GUICustomShopGoodsWindow:onLoad()
	self.siItemBg = self:getChildWindowByName("CustomShopGoods-Item-Bg", GUIType.StaticImage)
	self.siItemIcon = self:getChildWindowByName("CustomShopGoods-Item-Icon", GUIType.StaticImage)
	self.stNum = self:getChildWindowByName("CustomShopGoods-Num", GUIType.StaticText)
	self.btnBuy = self:getChildWindowByName("CustomShopGoods-Buy", GUIType.Button)
	self.siPriceIcon = self:getChildWindowByName("CustomShopGoods-Price-Icon", GUIType.StaticImage)
	self.stPrice = self:getChildWindowByName("CustomShopGoods-Price", GUIType.StaticText)
	self.btnDelete = self:getChildWindowByName("CustomShopGoods-Delete", GUIType.Button)
	self.siItemAdd = self:getChildWindowByName("CustomShopGoods-Item-Add", GUIType.StaticImage)
	self.siPriceAdd = self:getChildWindowByName("CustomShopGoods-Price-Add", GUIType.StaticImage)

	self:initView()
	self:initEvent()
end

---@private
function GUICustomShopGoodsWindow:initView()

end

---@private
function GUICustomShopGoodsWindow:initEvent()
	self.siItemAdd:registerEvent(GUIEvent.Click, function()
		if not GUICustomShop.editStatus then
			return
		end
		GUICustomShop:showSelect(true, function(id, meta, num)
			self:onEditGoodsInfo(id, meta, num, true)

		end, 1)
	end)

	self.siItemBg:registerEvent(GUIEvent.Click, function()
		if not GUICustomShop.editStatus then
			return
		end
		GUICustomShop:showSelect(true, function(id, meta, num)
			self:onEditGoodsInfo(id, meta, num, true)
		end, 1)
	end)

	self.siPriceAdd:registerEvent(GUIEvent.Click, function()
		if not GUICustomShop.editStatus then
			return
		end
		GUICustomShop:showSelect(true, function(id, meta, num)
			self:onEditGoodsInfo(id, meta, num, false)
		end, 0)
	end)

	self.btnBuy:registerEvent(GUIEvent.ButtonClick, function()
		if GUICustomShop.editStatus then
			GUICustomShop:showSelect(true, function(id, meta, num)
				self:onEditGoodsInfo(id, meta, num, false)
			end, 0)
		else
			PlayerManager:getClientPlayer():sendPacket({
				pid = "onBuyGoods",
				shopId = GUICustomShop.shopId,
				goods = self.data
			})
		end
	end)

	self.btnDelete:registerEvent(GUIEvent.ButtonClick, function()
		if not self.data then
			return
		end
		GUICustomShop:editGoods(Define.ShopEditOption.RemoveGoods, GUICustomShop.curTab, { goods = self.data })
	end)
end

---@param data table
function GUICustomShopGoodsWindow:onDataChanged(data)
	self.data = data
	local goods = StringUtil.split(self.data, ":", false, true)
	local hasGoods = goods[1] and goods[1] ~= 0
	local hasPrice = goods[4] and goods[4] ~= 0
	self.siItemIcon:SetVisible(hasGoods)
	self.stNum:SetVisible(hasGoods)
	self.siItemAdd:SetVisible(not hasGoods)
	self.siPriceIcon:SetVisible(hasPrice)
	self.siPriceAdd:SetVisible(not hasPrice)
	self.btnDelete:SetVisible(hasGoods and hasPrice and GUICustomShop.editStatus)

	GuiItemStack.showItemIcon(self.siItemIcon, goods[1] or 0, goods[2] or 0, "")
	GuiItemStack.showItemIcon(self.siPriceIcon, goods[4] or 0, goods[5] or 0, "")
	self.stNum:SetText((goods[3] and goods[3] > 0) and goods[3] or "")
	local price = (goods[6] and goods[6] > 0) and goods[6] or 0
	self.siPriceIcon:SetVisible(price > 0)
	self.stPrice:SetText(price)
	self.btnBuy:SetText(price > 0 and "" or Lang:getString("gui.shop.free"))

end

function GUICustomShopGoodsWindow:onEditGoodsInfo(id, meta, num, isItemChange)
	if id == 0 then
		return
	end
	local goods = StringUtil.split(self.data, ":", false, true)
	if isItemChange then
		goods[1] = id
		goods[2] = meta
		goods[3] = num
	else
		goods[4] = id
		goods[5] = meta
		goods[6] = num
	end
	local old = self.data
	local option = self.data == "0:0:0:0:0:0" and Define.ShopEditOption.AddGoods or Define.ShopEditOption.ChangeGoods
	self.data = table.concat(goods, ":")
	GUICustomShop:editGoods(option, GUICustomShop.curTab, { old = old, new = self.data })
	self:onDataChanged(self.data)
end

return GUICustomShopGoodsWindow
