--[[V]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 5399
                          local checkFileName = "GUICommonAdActivityItem.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[gtlkAFZGPH]]---@class GUICommonAdActivityItemWindow : IGUIWindow
local GUICommonAdActivityItemWindow = class("GUICommonAdActivityItemWindow", IGUIWindow)
---@type PayActivityRewardConfig
local PayActivityRewardConfig = T(Global, "PayActivityRewardConfig")

local QualityImage = {
    [1] = "set:common_ad_activity.json image:item_bd__blue",
    [2] = "set:common_ad_activity.json image:item_bd_purple",
    [3] = "set:common_ad_activity.json image:item_bd_orange"
}

---@private
function GUICommonAdActivityItemWindow:ctor(...)
    self.super.ctor(self, "CommonAdActivityItem.json", ...)
end

---@private
function GUICommonAdActivityItemWindow:onLoad()
    self.siQuality = self:getChildWindowByName("CommonAdActivityItem-Quality", GUIType.StaticImage)
    self.siImage = self:getChildWindowByName("CommonAdActivityItem-Image", GUIType.StaticImage)
    self.stTimes = self:getChildWindowByName("CommonAdActivityItem-Times", GUIType.StaticText)
    self.stName = self:getChildWindowByName("CommonAdActivityItem-Name", GUIType.StaticText)
    self.stFreeGet = self:getChildWindowByName("CommonAdActivityItem-FreeGet", GUIType.StaticText)
    self:initView()
    self:initEvent()
end

---@private
function GUICommonAdActivityItemWindow:initView()
    self.stFreeGet:SetText(Lang:getString("gui.ad.free.get"))
    self.stFreeGet:SetWidth({ 0, self.stFreeGet:GetTextWidth() })
end

---@private
function GUICommonAdActivityItemWindow:initEvent()
    self.root:registerEvent(GUIEvent.Click, function()
        self:doAction(self.data)
    end)
end

---@param data CommonAdActivityItemData
function GUICommonAdActivityItemWindow:onDataChanged(data)
    self.data = data
    ---@type CommonAdActivity
    self.activity = PlayerManager:getClientPlayer().payActivity.activities[data.activityId]
    if not self.activity then
        return
    end
    self.siQuality:SetImage(QualityImage[data.quality] or QualityImage[1])
    UIHelper:setImageAdjustSize(self.siImage, data.image, 110, 110, 1)
    local reward = PayActivityRewardConfig:getCfgById(tonumber(data.params[1]))
    if reward then
        self.stName:SetText(Lang:getString(reward.name))
    end
    local times, max = self.activity:getAdLastTimes(data.tag)
    self.needCountDown = false
    if max >= 0 then
        if times > 0 then
            self.stTimes:SetText(times .. "/" .. max)
            if self.activity:getCoolingTime(data.tag) > 0 then
                self.stFreeGet:SetText(DateUtil.getFormatTime(self.activity:getCoolingTime(data.tag), "mm:ss"))
                self.needCountDown = true
            else
                self.stFreeGet:SetText(Lang:getString("gui.ad.free.get"))
            end
        else
            self.stTimes:SetText(TextFormat.colorRed .. times .. TextFormat.colorWrite .. "/" .. max)
            self.stFreeGet:SetText(Lang:getString("gui.ad.empty.tip"))
        end
        self.stFreeGet:SetWidth({ 0, self.stFreeGet:GetTextWidth() })
    else
        self.stTimes:SetText("")
    end
end

---@param data CommonAdActivityItemData
function GUICommonAdActivityItemWindow:doAction(data)
    if data.hideUI then
        UIHelper.hideGameGUILayout("GUIPayActivity")
    end
    if data.action == "OpenUI" then
        UIHelper.showGameGUILayout(table.unpack(data.params))
        if data.hideUI then
            local layout = UIHelper.newGameGUILayout(data.params[1])
            local callback
            callback = function(name)
                if name == layout.__name then
                    Events.GUILayoutHideEvent:unregisterCallBack(callback)
                    UIHelper.showGameGUILayout("GUIPayActivity", self.activity)
                end
            end
            Events.GUILayoutHideEvent:registerCallBack(callback)
        end
    elseif data.action == "WatchAdvert" then
        local times, max = self.activity:getAdLastTimes(data.tag)
        if max >= 0 then
            if times > 0 then
                self.activity:tryWatchAdvert(data.tag, data.params[1])
            else
                UIHelper.showToast(Lang:getString("gui.ad.empty.tip"))
            end
        else
            self.activity:tryWatchAdvert(data.tag, data.params[1])
        end
    end
    SoundUtil.clickUI()
end

function GUICommonAdActivityItemWindow:onTick()
    if not self.needCountDown then
        return
    end
    local time = self.activity:getCoolingTime(self.data.tag)
    self.stFreeGet:SetText(DateUtil.getFormatTime(time, "mm:ss"))
    if time <= 0 then
        self.needCountDown = false
        self.stFreeGet:SetText(Lang:getString("gui.ad.free.get"))
    end
end

return GUICommonAdActivityItemWindow
--[[bEnsS5qhkmobhQKhsfxIvqha7MsMX]]---