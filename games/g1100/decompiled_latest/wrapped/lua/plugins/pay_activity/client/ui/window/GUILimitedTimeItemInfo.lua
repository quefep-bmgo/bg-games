--[[pZrA8LlFG]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 2481
                          local checkFileName = "GUILimitedTimeItemInfo.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[XoD4BExDhRfsMc52Hm9dUTv]]---@class GUILimitedTimeItemInfoWindow : IGUIWindow
local GUILimitedTimeItemInfoWindow = class("GUILimitedTimeItemInfoWindow", IGUIWindow)

---@type PayActivityRewardConfig
local PayActivityRewardConfig = T(Global, "PayActivityRewardConfig")

---@private
function GUILimitedTimeItemInfoWindow:ctor(...)
	self.super.ctor(self, "LimitedTimeItemInfo.json", ...)
end

---@private
function GUILimitedTimeItemInfoWindow:onLoad()
	self.siIconBg = self:getChildWindowByName("LimitedTimeItemInfo-IconBg", GUIType.StaticImage)
	self.siIcon = self:getChildWindowByName("LimitedTimeItemInfo-Icon", GUIType.StaticImage)
	self.stNum = self:getChildWindowByName("LimitedTimeItemInfo-Num", GUIType.StaticText)
	self.siIconPre = self:getChildWindowByName("LimitedTimeItemInfo-IconPre", GUIType.StaticImage)
	self:initView()
	self:initEvent()
end

---@private
function GUILimitedTimeItemInfoWindow:initView()
	self.stNum:SetText("")
end

---@private
function GUILimitedTimeItemInfoWindow:initEvent()
	self.siIcon:registerEvent(GUIEvent.TouchUp, function()
		if not self.data or self.data.isSelect then return end
		self.data.view:onItemClick(self.data)
	end)
end

---@param data PayActivityRewardConfigData
function GUILimitedTimeItemInfoWindow:onDataChanged(data)
	--PayActivityRewardConfig:getCfgById(id)
	self.data = data
	if data.count > 1 then
		self.stNum:SetText("X" .. data.count)
	else
		self.stNum:SetText("")
	end
	local quality = data.quality or 1
	PayActivityRewardConfig:setRewardImage(self.siIcon, data)
	self.siIconBg:SetImage("set:limited_time_activity.json image:img_frame_quality0".. quality)
	self.siIconPre:SetVisible(data.isSelect)
end

return GUILimitedTimeItemInfoWindow
--[[bDQJVbmonMX7ACq9fkc]]---