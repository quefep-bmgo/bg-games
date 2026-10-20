---@class UICustomShopLayout : IGUILayout
local UICustomShopLayout = class("UICustomShopLayout", IGUILayout)
---@type ItemsConfig
local ItemsConfig = T(Global, "ItemsConfig")
---@type CShopMgr
local CShopMgr = T(Global, "CShopMgr")
---@private
function UICustomShopLayout:ctor()
	self.super.ctor(self, "CustomShop.json")
end

---@private
function UICustomShopLayout:isDelayLoad()
	return true
end

---@private
function UICustomShopLayout:onCreate()
	self:initCreateEvent()
end

---@private
function UICustomShopLayout:initCreateEvent()

end

---@private
function UICustomShopLayout:onLoad()
	self.shopId = 0
	self.editStatus = false
	self.selectItem = {
		id = 0,
		meta = 0
	}
	self.selectCount = 1
	self.siBgMask = self:getChildWindow("CustomShop-Bg-Mask", GUIType.StaticImage)
	self.siBg = self:getChildWindow("CustomShop-Bg", GUIType.StaticImage)
	self.llTop = self:getChildWindow("CustomShop-Top", GUIType.Layout)
	self.btnClose = self:getChildWindow("CustomShop-Close", GUIType.Button)
	self.stTitle = self:getChildWindow("CustomShop-Title", GUIType.StaticText)
	self.siContentBg = self:getChildWindow("CustomShop-Content-Bg", GUIType.StaticImage)
	self.stNoGoodsTip = self:getChildWindow("CustomShop-No-Goods-Tip", GUIType.StaticText)
	self.llTabs = self:getChildWindow("CustomShop-Tabs", GUIType.Layout)
	self.btnEditShop = self:getChildWindow("CustomShop-Edit-Shop", GUIType.Button)
	self.btnRecycling = self:getChildWindow("CustomShop-Recycling", GUIType.Button)
	self.llSelectLayout = self:getChildWindow("CustomShop-Select-Layout", GUIType.Layout)
	self.siSelectBg = self:getChildWindow("CustomShop-Select-Bg", GUIType.StaticImage)
	self.llSelectTop = self:getChildWindow("CustomShop-Select-Top", GUIType.Layout)
	self.btnSelectClose = self:getChildWindow("CustomShop-Select-Close", GUIType.Button)
	self.stSelectTitle = self:getChildWindow("CustomShop-Select-Title", GUIType.StaticText)
	self.siSelectContent = self:getChildWindow("CustomShop-Select-Content", GUIType.StaticImage)
	self.llSelectTabs = self:getChildWindow("CustomShop-Select-Tabs", GUIType.Layout)
	self.btnSelectSure = self:getChildWindow("CustomShop-Select-Sure", GUIType.Button)
	self.btnSelectInput = self:getChildWindow("CustomShop-Select-Num", GUIType.Button)
	self.btnEditTitle = self:getChildWindow("CustomShop-Edit-Title", GUIType.Button)

	self:initView()
	self:initEvent()
end

---@private
function UICustomShopLayout:initView()
	self.btnRecycling:SetText(Lang:getString("gui.custom.shop.recycling"))
	self.btnSelectSure:SetText(Lang:getString("gui_dialog_tip_btn_sure"))
	self.btnSelectInput:SetText(1)
	self.stTitle:SetText(Lang:getString("gui.custom.shop.title"))
	self.stNoGoodsTip:SetText(Lang:getString("gui.custom.shop.no.goods.tip"))
	self.stSelectTitle:SetText(Lang:getString("gui.custom.shop.select.title"))

	self.lvGoodsList = IGUIGridView.new("CustomShop-Goods-List", self.siContentBg)
	self.lvGoodsList.root:SetArea({ 0, 0 }, { 0, 0 }, { 1, -26 }, { 1, -26 })
	self.lvGoodsList.root:SetHorizontalAlignment(HorizontalAlignment.Center)
	self.lvGoodsList.root:SetVerticalAlignment(VerticalAlignment.Center)
	self.lvGoodsList.root:SetClipChild(false)
	self.lvGoodsList:setConfig(11, 11, 8)
	---@type CustomShopGoodsAdapter
	self.goodsAdapter = UIHelper.newGameAdapter("CustomShopGoodsAdapter")
	local itemWidth = (self.lvGoodsList.root:GetPixelSize().x - 77) / 8
	local itemHeight = itemWidth / 106 * 146
	self.goodsAdapter:setItemSize(itemWidth, itemHeight)
	self.lvGoodsList:setAdapter(self.goodsAdapter)

	self.lvSelectList = IGUIGridView.new("CustomShop-Select-List", self.siSelectContent)
	self.lvSelectList.root:SetArea({ 0, 0 }, { 0, 0 }, { 1, -18 }, { 1, -18 })
	self.lvSelectList.root:SetHorizontalAlignment(HorizontalAlignment.Center)
	self.lvSelectList.root:SetVerticalAlignment(VerticalAlignment.Center)
	self.lvSelectList:setConfig(4, 4, 9)
	---@type CustomShopSelectItemAdapter
	self.selectAdapter = UIHelper.newGameAdapter("CustomShopSelectItemAdapter")
	local width = (self.lvSelectList.root:GetPixelSize().x - 32) / 9
	self.selectAdapter:setItemSize(width, width)
	self.lvSelectList:setAdapter(self.selectAdapter)

	self.selectTabs = {}
	local index = 1
	for _, type in pairs(Define.ShopItemType) do
		local win = UIHelper.newGameGUIWindow("GUICustomShopTab")
		self.llSelectTabs:AddChildWindow(win.root)
		win.root:SetYPosition({ 0, (index - 1) * 74 })
		win:onDataChanged({
			group = Define.ShopTabGroup.Select,
			type = type
		})
		self.selectTabs[type] = win
		index = index + 1
	end

	local win = UIHelper.newGameGUIWindow("GUICustomShopTemplate")
	self.lshopTemplate = win.root
	self.siContentBg:AddChildWindow(self.lshopTemplate)
	self.lshopTemplate:SetVisible(false)
end

---@private
function UICustomShopLayout:initEvent()
	self.btnClose:registerEvent(GUIEvent.ButtonClick, function()
		if self.editStatus then
			CustomDialog.builder()
						.setLevel(48)
						.setAlwaysOnTop()
						.setContentText(Lang:getString("gui.shop.close.on.edit.tip"))
						.setRightClickListener(function()
					self:hide()
				end)
						.show()
			return
		end
		self:hide()
	end)

	self.btnEditShop:registerEvent(GUIEvent.ButtonClick, function()
		self:changeEditStatus(true)
	end)

	self.btnRecycling:registerEvent(GUIEvent.ButtonClick, function()
		if TableUtil.isEmpty(self.tabs) then
			self:recycleShop()
			return
		end
		CustomDialog.builder()
					.setLevel(48)
					.setAlwaysOnTop()
					.setContentText(Lang:getString("gui.shop.recycle.tip"))
					.setRightClickListener(function()
			self:recycleShop()
		end)
					.show()
	end)

	self.btnSelectClose:registerEvent(GUIEvent.ButtonClick, function()
		self:showSelect(false)
	end)

	self.btnSelectSure:registerEvent(GUIEvent.ButtonClick, function()
		if self.selectItem and self.sureFunc then
			self.sureFunc(self.selectItem.id, self.selectItem.meta, self.selectCount)
		end
		self:showSelect(false)
	end)

	self.btnSelectInput:registerEvent(GUIEvent.ButtonClick, function()
		self:showNumberInput()
	end)

	self.btnEditTitle:registerEvent(GUIEvent.ButtonClick, function()
		if not self.editStatus then
			return
		end
		self:onEditTitle()
	end)

	self:registerEvent(Events.ShopTabSelectEvent, function(group, type)
		if group == Define.ShopTabGroup.Goods then
			self:onGoodsTabSelect(type)
		elseif group == Define.ShopTabGroup.Select then
			if not self.llSelectLayout:IsVisible() then
				return
			end
			self:updateSelectList(type)
		end
	end)

	self:registerEvent(Events.ShopSelectItemEvent, function(id, meta)
		if self.selectItem and self.selectItem.id == id and self.selectItem.meta == meta then
			return
		end
		self.selectItem = {
			id = id,
			meta = meta
		}
		self:setCount(1)
	end)

	self:registerEvent(Events.ShopGoodsUpdateEvent, function(id)
		if not self:isShow() or not self.shopId or self.shopId ~= id then
			return
		end
		self:onShow(id)
	end)
end

---@private
function UICustomShopLayout:showNumberInput()
	self.selectCount = tonumber(self.btnSelectInput:GetText()) or 1
	---@type UIDigitalInputLayout
	local UIDigitalInputLayout = UIHelper.showGameGUILayout("GUIDigitalInput", self.btnSelectInput)
	UIDigitalInputLayout:setNumberData(self.selectCount, self.minCount or 1, 999)
	UIDigitalInputLayout:setInputListener(function(number)
		self:setCount(math.min(number, 999))
	end)
end

function UICustomShopLayout:setCount(num)
	self.btnSelectInput:SetText(num)
	self.selectCount = num
end

function UICustomShopLayout:showSelect(isShow, sureFunc, minCount)
	if isShow and not self.curTab then
		UIHelper.showGameGUILayout("GUICustomRoomTip", "gui.shop.create.tab.tip")
		return
	end
	self.minCount = minCount or 1
	self.llSelectLayout:SetVisible(isShow)
	self.sureFunc = false
	if isShow then
		Events.ShopTabSelectEvent:invoke(Define.ShopTabGroup.Select, Define.ShopItemType.Block)
		self.sureFunc = sureFunc
	end
end

function UICustomShopLayout:onShow(shopId)
	if not CShopMgr:getShop(shopId) then
		self:hide()
		return
	end
	self.shopId = shopId
	self.editStatus = false
	Events.ShopEditStatusChangeEvent:invoke(self.editStatus)
	self.hasChange = false
	self.btnEditShop:SetText(Lang:getString("gui.edit.text.edit"))
	self.editRecord = {}
	self.btnEditTitle:SetVisible(false)
	self:updateBtns()
	self:updateShopUi()
	self:updateTitle()
end

function UICustomShopLayout:updateSelectList(type)
	if self.curSelectTab and self.curSelectTab == type then
		return
	end
	self.curSelectTab = type
	local items = ItemsConfig:getCfgs(type)
	if not items then
		return
	end
	self.selectAdapter:setData(items)
	local item = items[1]
	Events.ShopSelectItemEvent:invoke(item.id, item.meta)
end

function UICustomShopLayout:updateShopUi()
	if not self.shopId then
		return
	end
	local shop = CShopMgr:getShop(self.shopId)
	if not shop then
		return
	end
	self.llTabs:CleanupChildren()
	self.lshopTemplate:SetVisible(false)
	self.tabs = {}
	self.goods = {}
	self.curTab = false
	local goods = shop:getGoods()
	for index, goodsInfo in pairs(goods) do
		local win = UIHelper.newGameGUIWindow("GUICustomShopTab")
		self.llTabs:AddChildWindow(win.root)
		win.root:SetYPosition({ 0, (index - 1) * 74 })
		win:onDataChanged({
			group = Define.ShopTabGroup.Goods,
			type = index,
			text = goodsInfo.tab
		})
		self.tabs[index] = win
		self.goods[index] = goodsInfo
	end
	self.stNoGoodsTip:SetVisible(false)
	if not TableUtil.isEmpty(self.tabs) then
		Events.ShopTabSelectEvent:invoke(Define.ShopTabGroup.Goods, 1)
	else
		self.stNoGoodsTip:SetVisible(true)
		self.goodsAdapter:clearItems()
	end
end

function UICustomShopLayout:changeEditStatus(canSave)
	if not self.shopId then
		return
	end
	local shop = CShopMgr:getShop(self.shopId)
	if not shop then
		return
	end
	self.editStatus = not self.editStatus
	Events.ShopEditStatusChangeEvent:invoke(self.editStatus)
	local text = self.editStatus and "gui.edit.text.close" or "gui.edit.text.edit"
	self.btnEditShop:SetText(Lang:getString(text))
	self.btnEditTitle:SetVisible(self.editStatus)
	if self.editStatus then
		self:addEditTab()
		self:updateGoodsUi(self.curTab)
	elseif canSave then
		self:saveGoods()
	end
end

function UICustomShopLayout:onGoodsTabSelect(index)
	if self.curTab and self.curTab == index then
		return
	end
	self.curTab = index
	self:updateGoodsUi(self.curTab)
end

function UICustomShopLayout:saveGoods()
	local shop = CShopMgr:getShop(self.shopId)
	if not shop then
		self:hide()
		return
	end
	if not self.hasChange then
		self:onShow(self.shopId)
		return
	end
	local needRemoveTab = {}
	for index, v in pairs(self.goods) do
		if not v.goods or TableUtil.isEmpty(v.goods) then
			table.insert(needRemoveTab, index)
		else
			for i = #v.goods, 1, -1 do
				local goods = StringUtil.split(v.goods[i], ":", false, true)
				if #goods < 6 or goods[1] == 0 or goods[4] == 0 then
					table.remove(v.goods, i)
				end
			end
		end
	end
	for i, index in pairs(needRemoveTab) do
		self.goods[index] = nil
	end
	PlayerManager:getClientPlayer():sendPacket({
		pid = "onEditShop",
		shopId = self.shopId,
		goodsInfo = self.goods,
		name = self.stTitle:GetText()
	})
end

function UICustomShopLayout:editGoods(option, tabIndex, data)
	if option == Define.ShopEditOption.AddTab then
		self.goods[tabIndex] = {
			tab = data.text,
			goods = {}
		}
		self.hasChange = true
	elseif option == Define.ShopEditOption.ChangeTab then
		if not self.goods[tabIndex] then
			return
		end
		self.goods[tabIndex].tab = data.text
		self.hasChange = true
	elseif option == Define.ShopEditOption.AddGoods then
		if not self.goods[tabIndex] then
			return
		end
		local goods = self.goods[tabIndex].goods or {}
		if #goods >= Define.ShopGoodsMax then
			return
		end
		table.insert(goods, data.new)
		self.goods[tabIndex].goods = goods
		self.hasChange = true
	elseif option == Define.ShopEditOption.ChangeGoods then
		if not self.goods[tabIndex] then
			return
		end
		local goods = self.goods[tabIndex].goods or {}
		for i, info in pairs(goods) do
			if data.old == info then
				goods[i] = data.new
				self.hasChange = true
				break
			end
		end
		self.goods[tabIndex].goods = goods
	elseif option == Define.ShopEditOption.RemoveGoods then
		if not self.goods[tabIndex] then
			return
		end
		local goods = self.goods[tabIndex].goods or {}
		for i, info in pairs(goods) do
			if data.goods == info then
				table.remove(goods, i)
				self.hasChange = true
				break
			end
		end
		self.goods[tabIndex].goods = goods
	end
	self:onEditGoodsUpdate(option, tabIndex)
end

function UICustomShopLayout:editGoodsTemplate(tabName, goods)
	local selectAddTab = nil
	for _, tab in ipairs(self.tabs) do
		if tab.isAdd then
			selectAddTab = tab
			break
		end
	end
	if not selectAddTab then
		return
	end
	self:editGoods(Define.ShopEditOption.AddTab, selectAddTab.type, { text = tabName })
	if goods and #goods > 0 then
		for _, item in ipairs(goods) do
			self:editGoods(Define.ShopEditOption.AddGoods, selectAddTab.type, { new = item })
		end
	end
	selectAddTab:onDataChanged({
		group = selectAddTab.group,
		type = selectAddTab.type,
		text = tabName
	})
end

function UICustomShopLayout:onEditGoodsUpdate(option, tabIndex)
	if option == Define.ShopEditOption.AddTab then
		if tabIndex == 1 and not self.curTab then
			Events.ShopTabSelectEvent:invoke(Define.ShopTabGroup.Goods, 1)
		end
		self:addEditTab()
	elseif option == Define.ShopEditOption.AddGoods or option == Define.ShopEditOption.RemoveGoods then
		if tabIndex ~= self.curTab then
			return
		end
		self:updateGoodsUi(self.curTab)
	end
end

function UICustomShopLayout:updateGoodsUi(index)
	local goods = self.goods[index] and self.goods[index].goods or {}
	self.stNoGoodsTip:SetVisible(false)
	if self.editStatus then
		local editGoods = TableUtil.copyTable(goods) or {}
		if #editGoods < Define.ShopGoodsMax then
			table.insert(editGoods, "0:0:0:0:0:0")
		end
		self.goodsAdapter:setData(editGoods)
	else
		if TableUtil.isEmpty(goods) then
			self.stNoGoodsTip:SetVisible(true)
			self.goodsAdapter:clearItems()
		else
			self.stNoGoodsTip:SetVisible(false)
			self.goodsAdapter:setData(goods)
		end
	end
end

function UICustomShopLayout:addEditTab()
	local count = self.llTabs:GetChildCount()
	local canAdd = count < 5
	self.lshopTemplate:SetVisible(canAdd)
	if not canAdd then
		return
	end
	local index = count + 1
	local win = UIHelper.newGameGUIWindow("GUICustomShopTab")
	self.llTabs:AddChildWindow(win.root)
	win.root:SetYPosition({ 0, (index - 1) * 74 })
	win:onDataChanged({
		group = Define.ShopTabGroup.Goods,
		type = index,
		isAdd = true
	})
	self.tabs[index] = win
	self.lshopTemplate:SetVisible(true)
end

function UICustomShopLayout:updateBtns()
	local role = PlayerManager:getClientPlayer().permissionRole or Define.CustomGamePermissionRole.Member
	local canEdit = role == Define.CustomGamePermissionRole.Admin or role == Define.CustomGamePermissionRole.Owner
	local customGame = T(Global, "customGame")
	self.btnEditShop:SetVisible(canEdit and customGame.gameMode ~= Define.CustomGameMode.RUN)
	self.btnRecycling:SetVisible(canEdit and customGame.gameMode ~= Define.CustomGameMode.RUN)
	if not canEdit and self.editStatus then
		self:changeEditStatus()
	end
end

function UICustomShopLayout:updateTitle()
	local shop = CShopMgr:getShop(self.shopId)
	if not shop then
		return
	end
	self.stTitle:SetText(shop.name)
end

function UICustomShopLayout:onEditTitle()
	local msg = self.stTitle:GetText()
	CustomShopInputContent:setDefaultContentText(msg)
	CustomShopInputContent:setContentChangeListener(function(content)
		msg = content
	end)
	CustomDialog.builder()
				.setLevel(48)
				.setAlwaysOnTop()
				.setTitleText("gui.edit.tab.text")
				.setContentView(CustomShopInputContent)
				.setRightClickListener(function()
		self.hasChange = true
		self.stTitle:SetText(msg)
	end)        .show()
end

function UICustomShopLayout:recycleShop()
	PlayerManager:getClientPlayer():sendPacket({
		pid = "onPlayerRecycleShop",
		id = self.shopId
	})
	self:hide()
end

return UICustomShopLayout
