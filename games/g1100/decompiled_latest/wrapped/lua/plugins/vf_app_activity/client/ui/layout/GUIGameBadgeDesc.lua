--[[CbUv8sdYoOFdlRYN4XDSgZuZs0HL6t]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 2256
                          local checkFileName = "GUIGameBadgeDesc.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[nohl5AHMSQo31vea4IQocWREwbJSfwEQKMnxwsgPsqOlLSWSMaHBtcvc5qifqGraepWC40m35Ys9Vv4xoOtaxLSubwGTp1zoJ0c41P7ZlQFz690RbJC191K]]---@class UIGameBadgeDescLayout : IGUILayout
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
--[[5D3OnD0bJ0xFGNEVrlnPz]]