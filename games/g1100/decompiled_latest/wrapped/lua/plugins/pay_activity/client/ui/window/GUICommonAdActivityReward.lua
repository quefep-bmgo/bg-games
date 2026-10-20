--[[e6RXHBBftDPt8jrPTAFeMqMLe7gvAa4jroDLBfNGxEXMuRkMsrRi3]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 3094
                          local checkFileName = "GUICommonAdActivityReward.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[XoVJjUOljkW9bzrmgnWWJYHK73]]---@class GUICommonAdActivityRewardWindow : IGUIWindow
local GUICommonAdActivityRewardWindow = class("GUICommonAdActivityRewardWindow", IGUIWindow)
---@type PayActivityRewardConfig
local PayActivityRewardConfig = T(Global, "PayActivityRewardConfig")
---@private
function GUICommonAdActivityRewardWindow:ctor(...)
    self.super.ctor(self, "CommonAdActivityReward.json", ...)
end

---@private
---@param activity CommonAdActivity
function GUICommonAdActivityRewardWindow:onLoad(activity)
    self.activity = activity
    self.siIcon = self:getChildWindowByName("CommonAdActivityReward-Icon", GUIType.StaticImage)
    self.siPoint = self:getChildWindowByName("CommonAdActivityReward-Point", GUIType.StaticImage)
    self.stTimes = self:getChildWindowByName("CommonAdActivityReward-Times", GUIType.StaticText)
    self.siEffect = self:getChildWindowByName("CommonAdActivityReward-Effect", GUIType.StaticImage)
    self:initView()
    self:initEvent()
end

---@private
function GUICommonAdActivityRewardWindow:initView()

end

---@private
function GUICommonAdActivityRewardWindow:initEvent()
    self.siIcon:registerEvent(GUIEvent.Click, function()
        if self.siEffect:IsVisible() then
            self.activity:tryGetReward(self.data.id)
        end
        SoundUtil.clickUI()
    end)
end

---@param data CommonAdActivityRewardData
function GUICommonAdActivityRewardWindow:onDataChanged(data)
    self.data = data
    self.activity = PlayerManager:getClientPlayer().payActivity.activities[data.activityId]
    if not self.activity then
        return
    end
    local record = self.activity.info:getValue("Record")
    local get = TableUtil.tableContain(record, data.id)
    local reward = PayActivityRewardConfig:getCfgById(data.rewardId)
    PayActivityRewardConfig:setRewardImage(self.siIcon, reward)
    self.stTimes:SetText(data.needTimes)
    local times = self.activity.info:getValue("Times")
    self.siEffect:SetVisible(times >= data.needTimes and not get)
    if data.needTimes ~= data.maxTimes then
        self.siIcon:SetWidth({ 0, 63 })
        self.siIcon:SetHeight({ 0, 63 })
    else
        self.siIcon:SetWidth({ 0, 70 })
        self.siIcon:SetHeight({ 0, 70 })
    end
end

return GUICommonAdActivityRewardWindow
--[[qDuxOZ5zaKhJqTQhSFs8f1]]