---@class GUILimitedTimeActivityRewardResult : IGUILayout
local GUILimitedTimeActivityRewardResult = class("GUILimitedTimeActivityRewardResult", IGUILayout)
---@type PayActivityRewardConfig
local PayActivityRewardConfig = T(Global, "PayActivityRewardConfig")

---@private
function GUILimitedTimeActivityRewardResult:ctor(parent)
    self.super.ctor(self, "LimitedTimeActivityRewardResult.json", parent)
end

---@private
function GUILimitedTimeActivityRewardResult:isDelayLoad()
    return true
end

---@private
function GUILimitedTimeActivityRewardResult:onCreate()
    self.rewards = {}
    self:initCreateEvent()
end

---@private
function GUILimitedTimeActivityRewardResult:initCreateEvent()

end

---@private
function GUILimitedTimeActivityRewardResult:onLoad()
    self.stTitle = self:getChildWindow("LimitedTimeActivityRewardResult-Title", GUIType.StaticText)
    self.llLight = self:getChildWindow("LimitedTimeActivityRewardResult-Light", GUIType.Layout)
    self.llLight2 = self:getChildWindow("LimitedTimeActivityRewardResult-Light2", GUIType.Layout)
    self.stTip = self:getChildWindow("LimitedTimeActivityRewardResult-Tip", GUIType.StaticText)
    self:initView()
    self:initEvent()
end

---@private
function GUILimitedTimeActivityRewardResult:initView()
    ---@type GUILimitedTimeActivityRewardResultItemWindow[]
    self.wItems = {}
    self.stTitle:SetText(Lang:getString("gui.limit.time.activity.congratulations"))
    self.stTip:SetText(Lang:getString("gui.pay.activity.reward.tip"))
end

---@private
function GUILimitedTimeActivityRewardResult:initEvent()
    self.root:registerEvent(GUIEvent.Click, function()
        if self.stTip:IsVisible() then
            self:hide()
        end
    end)
end

function GUILimitedTimeActivityRewardResult:show(rewards,params)
    TableUtil.mergeArray(self.rewards, rewards)
    self.params=params
    self.super.show(self, rewards)
end

function GUILimitedTimeActivityRewardResult:onShow()
    self:tryShowRewardList()
end

function GUILimitedTimeActivityRewardResult:findRewardResultItem()
    for _, item in pairs(self.wItems) do
        if not item.root:IsVisible() then
            return item
        end
    end
    if #self.wItems == 10 then
        return nil
    end
    ---@type GUILimitedTimeActivityRewardResultItemWindow
    local item = UIHelper.newGameGUIWindow("GUILimitedTimeActivityRewardResultItem")
    item.root:SetVerticalAlignment(VerticalAlignment.Center)
    self.root:AddChildWindow(item.root)
    table.insert(self.wItems, item)
    return item
end

function GUILimitedTimeActivityRewardResult:tryShowRewardList()
    local count = math.min(10, #self.rewards)
    if count == 0 then
        self:hide()
        return
    end
    self.llLight:SetVisible(count ~= 1)
    self.llLight2:SetVisible(count == 1)
    for _, item in pairs(self.wItems) do
        item:setVisible(false)
    end
    self.stTip:SetVisible(false)
    local space = 40
    local towRowNum=10
    local isTowRow=count>=towRowNum
    local midNum=math.ceil(count/2)
    local initPosX=(self.root:GetPixelSize().x - ((isTowRow and midNum or count) * (99 + space) - space)) / 2
    local startPosX = initPosX
    for i = 1, count do
        local rewardId = self.rewards[1]
        local cfg = TableUtil.copyTable(PayActivityRewardConfig:getCfgById(rewardId))
        table.remove(self.rewards, 1)
        local item = self:findRewardResultItem()
        item:setVisible(true)
        if isTowRow then
            item:setYPosition({ 0, i>midNum and 75 or -75 })
            if i == midNum+1 then
                startPosX=initPosX
            end
        else
            item:setYPosition({ 0, 0 })
        end
        item:setXPosition({ 0, startPosX })
        if self.params then
            if self.params.counts and self.params.counts[cfg.id]  then
                cfg.count=cfg.count*self.params.counts[cfg.id]
            end
        end
        item:onDataChanged(cfg)
        startPosX = startPosX + 97 + space
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
    if self.params and self.params.title then
        self.stTitle:SetText(Lang:getString(self.params.title))
    else
        self.stTitle:SetText(Lang:getString("gui.limit.time.activity.congratulations"))
    end
end

function GUILimitedTimeActivityRewardResult:onHide()
    if #self.rewards == 0 then
        return
    end
    self:show({})
end

return GUILimitedTimeActivityRewardResult
