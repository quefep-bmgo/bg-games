--[[4Z2cV1dr0gKiymeugswYgDan74bbPJTq2pBUJpAAlNNJkSklT0Md4SrUaoqk8332Fi8yBjkk0cc33PQHTmhjMFob2E4qAA79UNxP2wfDsurKYp5CkP7gyktkAlFl3Yi4U93aTXoxRbejlAfiSptE1QapsonKs8v8X5QbvLTLTlDIcwKEgneRV51fByKzyDWWMwSKic7HEpQw]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 5419
                          local checkFileName = "GUICustomShopTemplate.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[EK1yByuNTdEoyORBiqlFff9L1uGvYY]]---@class GUICustomShopTemplateWindow : IGUIWindow
local GUICustomShopTemplateWindow = class("GUICustomShopTemplateWindow", IGUIWindow)
---@type UICustomShopLayout
local GUICustomShop = UIHelper.newGameGUILayout("GUICustomShop")

---@private
function GUICustomShopTemplateWindow:ctor(...)
	self.super.ctor(self, "CustomShopTemplate.json", ...)
end

---@private
function GUICustomShopTemplateWindow:onLoad()
	self.btnTemplate = self:getChildWindowByName("CustomShopTemplate-Button", GUIType.Button)
	self.lyTemplate = self:getChildWindowByName("CustomShopTemplate-Layout", GUIType.Layout)
	self.stTitle = self:getChildWindowByName("CustomShopTemplate-Title", GUIType.StaticText)
	self.btnClose = self:getChildWindowByName("CustomShopTemplate-Close", GUIType.Button)
	self.siItemBg = self:getChildWindowByName("CustomShopTemplate-Item-Bg", GUIType.StaticImage)
	self.siWeaponBg = self:getChildWindowByName("CustomShopTemplate-Weapon-Bg", GUIType.StaticImage)
	self.siEquipBg = self:getChildWindowByName("CustomShopTemplate-Equip-Bg", GUIType.StaticImage)
	self.siItemSelect = self:getChildWindowByName("CustomShopTemplate-Item-Select", GUIType.StaticImage)
	self.siWeaponSelect = self:getChildWindowByName("CustomShopTemplate-Weapon-Select", GUIType.StaticImage)
	self.siEquipSelect = self:getChildWindowByName("CustomShopTemplate-Equip-Select", GUIType.StaticImage)
	self.stItem = self:getChildWindowByName("CustomShopTemplate-Item-Text", GUIType.StaticText)
	self.stWeapon = self:getChildWindowByName("CustomShopTemplate-Weapon-Text", GUIType.StaticText)
	self.stEquip = self:getChildWindowByName("CustomShopTemplate-Equip-Text", GUIType.StaticText)
	self.btnSure = self:getChildWindowByName("CustomShopTemplate-Sure", GUIType.Button)
	self:initView()
	self:initEvent()
end

---@private
function GUICustomShopTemplateWindow:initView()
	self.curSelect = 0
	self.btnTemplate:SetText(Lang:getString("gui.shop.template"))
	self.stTitle:SetText(Lang:getString("gui.shop.template"))
	self.stItem:SetText(Lang:getString("gui.shop.template.item"))
	self.stWeapon:SetText(Lang:getString("gui.shop.template.weapon"))
	self.stEquip:SetText(Lang:getString("gui.shop.template.equip"))
	self.btnSure:SetText(Lang:getString("gui.shop.template.add"))
	self.lyTemplate:SetVisible(false)
	self.siItemSelect:SetVisible(false)
	self.siWeaponSelect:SetVisible(false)
	self.siEquipSelect:SetVisible(false)
	self:updateSelect(self.curSelect)
end

---@private
function GUICustomShopTemplateWindow:initEvent()
	self.btnTemplate:registerEvent(GUIEvent.ButtonClick, function()
		self.lyTemplate:SetVisible(true)
		self.curSelect = 0
		self:updateSelect(0)
	end)
	self.btnClose:registerEvent(GUIEvent.ButtonClick, function()
		self.lyTemplate:SetVisible(false)
	end)
	self.btnSure:registerEvent(GUIEvent.ButtonClick, function()
		self.lyTemplate:SetVisible(false)
		if self.curSelect == 0 then
			return	
		end
		self:onAddGoods(self.curSelect)
	end)

	self.siItemBg:registerEvent(GUIEvent.Click, function()
		self:updateSelect(1)
	end)
	self.siWeaponBg:registerEvent(GUIEvent.Click, function()
		self:updateSelect(2)
	end)
	self.siEquipBg:registerEvent(GUIEvent.Click, function()
		self:updateSelect(3)
	end)
end

function GUICustomShopTemplateWindow:updateSelect(select)
	self.btnSure:SetVisible(select ~= 0)
	self.siItemSelect:SetVisible(false)
	self.siWeaponSelect:SetVisible(false)
	self.siEquipSelect:SetVisible(false)
	if self.curSelect == select then
		return
	end
	self.curSelect = select
	if self.curSelect == 1 then
		self.siItemSelect:SetVisible(true)
	elseif self.curSelect == 2 then
		self.siWeaponSelect:SetVisible(true)
	elseif self.curSelect == 3 then
		self.siEquipSelect:SetVisible(true)
	end
end

function GUICustomShopTemplateWindow:onAddGoods(select)
	local langKey = ""
	if select == 1 then
		langKey = "gui.shop.template.item"
	elseif select == 2 then
		langKey = "gui.shop.template.weapon"
	elseif select == 3 then
		langKey = "gui.shop.template.equip"
	else
		return
	end
	local goodTemplate = Global.setting.goodTemplate
	if not goodTemplate then
		return
	end

	local goods = nil
	for _, v in ipairs(goodTemplate) do
        if v.tab == langKey then
            goods = v.goods
			break
        end
    end
	if not goods then
		return
	end
	
	GUICustomShop:editGoodsTemplate(Lang:getString(langKey), goods)
end

return GUICustomShopTemplateWindow
--[[DBmYX6rTFxKFxb8sqYPmFczYKiKzLFtMs3eQtvzhf9vw4FZ4uP3SfHn0xa8nYFW5kjzu4TP9PAPSXlLLA2r8id]]---