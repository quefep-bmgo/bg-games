--[[u6dzds4GcviqbdfDsg9wdpWHRe]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 4785
                          local checkFileName = "GUIPayActivityRewardResult.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[Anxw7B6o5PkUiGsIhWJjZ0fc7tn3GnmlkjbMvjuQudEmdXRrbBxmG9elYjIBiF1Bw0BbH1n5r6ROeFHVg6n7kABHMMvyTBI3aLfjRVi2Wxa9qv3DutrzKZPmFFUZ80kkUyz0MQlrsU0mbu4kz433HTM]]---@class UIPayActivityRewardResultLayout : IGUILayout
local UIPayActivityRewardResultLayout = class("UIPayActivityRewardResultLayout", IGUILayout)
---@type PayActivityRewardConfig
local PayActivityRewardConfig = T(Global, "PayActivityRewardConfig")

---@private
function UIPayActivityRewardResultLayout:ctor(parent)
    self.super.ctor(self, "PayActivityRewardResult.json", parent)
end

---@private
function UIPayActivityRewardResultLayout:isDelayLoad()
    return true
end

---@private
function UIPayActivityRewardResultLayout:onCreate()
    self.rewards = {}
    self:initCreateEvent()
end

---@private
function UIPayActivityRewardResultLayout:initCreateEvent()

end

---@private
function UIPayActivityRewardResultLayout:onLoad()
    self.stTitle = self:getChildWindow("PayActivityRewardResult-Title", GUIType.StaticText)
    self.llLight = self:getChildWindow("PayActivityRewardResult-Light", GUIType.Layout)
    self.stTip = self:getChildWindow("PayActivityRewardResult-Tip", GUIType.StaticText)
    self:initView()
    self:initEvent()
end

---@private
function UIPayActivityRewardResultLayout:initView()
    ---@type GUIPayActivityRewardResultItemWindow[]
    self.wItems = {}
    self.stTip:SetText(Lang:getString("gui.pay.activity.reward.tip"))
end

---@private
function UIPayActivityRewardResultLayout:initEvent()
    self.root:registerEvent(GUIEvent.Click, function()
        if self.stTip:IsVisible() then
            self:hide()
        end
    end)
end

function UIPayActivityRewardResultLayout:show(rewards)
    TableUtil.mergeArray(self.rewards, rewards)
    self.super.show(self, rewards)
end

function UIPayActivityRewardResultLayout:onShow()
    self:tryShowRewardList()
end

function UIPayActivityRewardResultLayout:findRewardResultItem()
    for _, item in pairs(self.wItems) do
        if not item.root:IsVisible() then
            return item
        end
    end
    if #self.wItems == 10 then
        return nil
    end
    ---@type GUIPayActivityRewardResultItemWindow
    local item = UIHelper.newGameGUIWindow("GUIPayActivityRewardResultItem")
    item.root:SetVerticalAlignment(VerticalAlignment.Center)
    self.root:AddChildWindow(item.root)
    table.insert(self.wItems, item)
    return item
end

function UIPayActivityRewardResultLayout:tryShowRewardList()
    local count = math.min(10, #self.rewards)
    if count == 0 then
        self:hide()
        return
    end
    for _, item in pairs(self.wItems) do
        item:setVisible(false)
    end
    self.stTip:SetVisible(false)
    local space = 18
    local startPos = (self.root:GetPixelSize().x - (count * (99 + space) - space)) / 2
    for i = 1, count do
        local rewardId = self.rewards[1]
        local cfg = TableUtil.copyTable(PayActivityRewardConfig:getCfgById(rewardId))
        table.remove(self.rewards, 1)
        local item = self:findRewardResultItem()
        item:setVisible(true)
        item:setXPosition({ 0, startPos })
        item:onDataChanged(cfg)
        startPos = startPos + 97 + space
        self:addTimer(LuaTimer:scheduleTicker(function()
            item:setVisible(true)
            if i == count then
                self.stTip:SetVisible(true)
            end
            UIAnimation:alpha(item.root, 0, 1.1, 5)
            UIAnimation:scale(item.root, 0.8, 1, 5, function(destroy)
                if destroy then
                    return
                end
                UIAnimation:scale(item.root, 1.1, 1, 3)
            end)
        end, 5 * i, 1))
    end
    for _, item in pairs(self.wItems) do
        item:setVisible(false)
    end
end

function UIPayActivityRewardResultLayout:onHide()
    if #self.rewards == 0 then
        return
    end
    self:show({})
end

return UIPayActivityRewardResultLayout
--[[mhCVHGPH8XPR6YJNgrjtwFl6qmRH4UWDg3iKllBnr041EDZgIF9Xgqkv74lal9OvmgBDn81ufA5diDMrQNRfZft5jly60MPqggLOhWCYS]]---