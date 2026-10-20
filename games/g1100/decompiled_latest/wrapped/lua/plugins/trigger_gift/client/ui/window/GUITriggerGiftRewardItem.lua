--[[832H9ao5UmSqw3UwrGQfE3CXbqGc]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 2688
                          local checkFileName = "GUITriggerGiftRewardItem.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[EHfNEVpUWFzKRAwcTvSxImv0kij1kbI2PyohG2fkrX3Qmbhaezg7UMSFpV7vtG9JRUaoCAaCyTboff2NASuzzOfqJghrNrwPc7cRnZATdJswUg0y4C6Mx5psUYB0QtKn25G1iXChIYft9JC1NJLbnZRWhWQF4b6LmNI7IHqq2Zc6gf7wGrEhmy]]---@class GUITriggerGiftRewardItemWindow : IGUIWindow
local GUITriggerGiftRewardItemWindow = class("GUITriggerGiftRewardItemWindow", IGUIWindow)
local TriggerGiftRewardGroupConfig
TriggerGiftRewardGroupConfig = Plugins.Require("trigger_gift", "common.config.TriggerGiftRewardGroupConfig")

local BgImage = {
    green = "set:trigger_gift.json image:img_0_grade01",
    blue = "set:trigger_gift.json image:img_0_grade02",
    purple = "set:trigger_gift.json image:img_0_grade03",
    yellow = "set:trigger_gift.json image:img_0_grade04"
}

---@private
function GUITriggerGiftRewardItemWindow:ctor(...)
    self.super.ctor(self, "TriggerGiftRewardItem.json", ...)
end

---@private
function GUITriggerGiftRewardItemWindow:onLoad(json, parent)
    self.parent = parent
    self.llRoot = DynamicCast.dynamicCastWindow(GUIType.Layout, self.root)
    self.siBg = self:getChildWindowByName("TriggerGiftRewardItem-Bg", GUIType.StaticImage)
    self.siReward = self:getChildWindowByName("TriggerGiftRewardItem-Reward", GUIType.StaticImage)
    self.stNum = self:getChildWindowByName("TriggerGiftRewardItem-Num", GUIType.StaticText)
    self:initEvent()
end

function GUITriggerGiftRewardItemWindow:initEvent()
    self.llRoot:registerEvent(GUIEvent.Click, function()
        self.parent:clickItem(self)
    end)
end

---@param data TriggerGiftRewardGroupData
function GUITriggerGiftRewardItemWindow:onDataChanged(data)
    --self.siBg:SetImage(BgImage[data.quality])
    self.siReward:SetImage(data.image)
    if data.num == 1 then
        self.stNum:SetText(" ")
    else
        self.stNum:SetText(data.num)
    end
    data.numLang = data.num
    self.reward = data
end

return GUITriggerGiftRewardItemWindow
--[[5D3OnD0bJ0xFGNEVrlnPz]]