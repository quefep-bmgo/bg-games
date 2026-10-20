---@class GUICustomShopTabWindow : IGUIWindow
local GUICustomShopTabWindow = class("GUICustomShopTabWindow", IGUIWindow)
---@type UICustomShopLayout
local GUICustomShop = UIHelper.newGameGUILayout("GUICustomShop")

---@private
function GUICustomShopTabWindow:ctor(...)
	self.super.ctor(self, "CustomShopTab.json", ...)
end

---@private
function GUICustomShopTabWindow:onLoad()
	self.siBg = self:getChildWindowByName("CustomShopTab-Bg", GUIType.StaticImage)
	self.siEditIcon = self:getChildWindowByName("CustomShopTab-Edit-Icon", GUIType.StaticImage)
	self.stEditText = self:getChildWindowByName("CustomShopTab-Edit-Text", GUIType.StaticText)
	self.stText = self:getChildWindowByName("CustomShopTab-Text", GUIType.StaticText)
	self.siAdd = self:getChildWindowByName("CustomShopTab-Add", GUIType.StaticImage)
	self:initView()
	self:initEvent()
end

---@private
function GUICustomShopTabWindow:initView()
	self.siEditIcon:SetVisible(false)
end

---@private
function GUICustomShopTabWindow:initEvent()
	self.siBg:registerEvent(GUIEvent.Click, function()
		Events.ShopTabSelectEvent:invoke(self.group, self.type)
	end)

	self.siEditIcon:registerEvent(GUIEvent.Click, function()
		if not GUICustomShop.editStatus then
			return
		end
		self:onEdit()
	end)

	self.siAdd:registerEvent(GUIEvent.Click, function()
		if not GUICustomShop.editStatus then
			return
		end
		self:onEdit()
	end)

	self:registerEvent(Events.ShopTabSelectEvent, function(group, type)
		if group ~= self.group then
			return
		end
		self.siBg:SetImage(self.type == type and "set:shop.json image:chb_0_tab2" or "set:shop.json image:chb_0_tab1")
	end)

	self:registerEvent(Events.ShopEditStatusChangeEvent, function(editStatus)
		self:onEditStatusChange(editStatus)
	end)
end

---@param data table
function GUICustomShopTabWindow:onDataChanged(data)
	self.type = data.type
	self.group = data.group
	self.text = data.text or false
	self.isAdd = data.isAdd
	local text = ""
	if self.text then
		if self.text == Define.DefaultTab then
			text = Lang:getString(self.text)
		else
			text = self.text
		end
	else
		text = Lang:getString(Define.TabText[self.type])
	end
	self.stText:SetText(text)
	self.stEditText:SetText(text)
	self.siAdd:SetVisible(self.isAdd)
	self:onEditStatusChange(GUICustomShop.editStatus)
end

function GUICustomShopTabWindow:onEditStatusChange(status)
	if self.group == Define.ShopTabGroup.Select then
		return
	end
	self.siEditIcon:SetVisible(status)
	self.stText:SetVisible(not status)
end

function GUICustomShopTabWindow:onEdit()
	local msg = Lang:getString(Define.DefaultTab)
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
		local option = self.isAdd and Define.ShopEditOption.AddTab or Define.ShopEditOption.ChangeTab
		GUICustomShop:editGoods(option, self.type, { text = msg })
		self:onDataChanged({
			group = self.group,
			type = self.type,
			text = msg
		})
	end)        .show()
end

return GUICustomShopTabWindow
