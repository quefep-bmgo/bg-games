--[[4aPASViky3c9X]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 2932
                          local checkFileName = "GUILimitedTimeActivityGoldWheelItem.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[Anxw7B6o5PkUiGsIhWJjZ0fc7tn3GnmlkjbMvjuQudEmdXRrbBxmG9elYjIBiF1Bw0BbH1n5r6ROeFHVg6n7kABHMMvyTBI3aLfjRVi2Wxa9qv3DutrzKZPmFFUZ80kkUyz0MQlrsU0mbu4kz433HTM]]---@class GUILimitedTimeActivityGoldWheelItemWindow : IGUIWindow
local GUILimitedTimeActivityGoldWheelItemWindow = class("GUILimitedTimeActivityGoldWheelItemWindow", IGUIWindow)

---@type PayActivityRewardConfig
local PayActivityRewardConfig = T(Global, "PayActivityRewardConfig")

---@private
function GUILimitedTimeActivityGoldWheelItemWindow:ctor(...)
	self.super.ctor(self, "LimitedTimeActivityGoldWheelItem.json", ...)
end

---@private
function GUILimitedTimeActivityGoldWheelItemWindow:onLoad()
	self.siIcon = self:getChildWindowByName("LimitedTimeActivityGoldWheelItem-Icon", GUIType.StaticImage)
	self.stCount = self:getChildWindowByName("LimitedTimeActivityGoldWheelItem-Count", GUIType.StaticText)
	self.stName = self:getChildWindowByName("LimitedTimeActivityGoldWheelItem-Name", GUIType.StaticText)
	self.stOff = self:getChildWindowByName("LimitedTimeActivityGoldWheelItem-TextOff", GUIType.StaticText)
	self.siOff = self:getChildWindowByName("LimitedTimeActivityGoldWheelItem-ImageOff", GUIType.StaticImage)

	self:initView()
	self:initEvent()
end

---@private
function GUILimitedTimeActivityGoldWheelItemWindow:initView()
	self.stCount:SetText()
	self.stName:SetText()
	self.stOff:SetText()
end

---@private
function GUILimitedTimeActivityGoldWheelItemWindow:initEvent()
	self.siIcon:registerEvent(GUIEvent.Click, function()
		if self.cfg then
			UIHelper.showGameGUILayout("GUIPayActivityRewardDetail", self.cfg.id)
		end
	end)
end

---@param data LimitedTimeGoldWheelConfigData
function GUILimitedTimeActivityGoldWheelItemWindow:onDataChanged(data)
	self.data=data
	if not data then
		return
	end
	if data.percent and data.percent ~= "#" then
		self.siOff:SetVisible(true)
		self.stOff:SetText(data.percent)
	else
		self.siOff:SetVisible(false)
	end



	local cfg=PayActivityRewardConfig:getCfgById(data.giftContent)
	if not cfg then
		return
	end
	self.cfg=cfg
	self.siIcon:SetImage(cfg.image)
	self.stCount:SetText(cfg.count)
end

return GUILimitedTimeActivityGoldWheelItemWindow
--[[Ofszs]]