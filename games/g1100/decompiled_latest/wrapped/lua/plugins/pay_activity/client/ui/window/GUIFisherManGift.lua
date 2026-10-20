--[[d3NBuyZJy80hnr7bfFFDp1UOAsu5SfZ]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 7890
                          local checkFileName = "GUIFisherManGift.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[jJ]]---@class GUIFisherManGiftWindow : IGUIWindow
local GUIFisherManGiftWindow = class("GUIFisherManGiftWindow", IGUIWindow)
---@type FisherManGiftConfig
local FisherManGiftConfig = T(Global, "FisherManGiftConfig")
---@type PayActivityRewardConfig
local PayActivityRewardConfig = T(Global, "PayActivityRewardConfig")
---@type ReportEvent
local ReportEvent = T(Global, "ReportEvent")
---@type table<number, number[]>
local GiftRewardPos = {
    [1] = { 1.8, 3 },
    [2] = { 1.8, 5 },
    [3] = { 2.6, 4 },
    [4] = { 2.6, 6 },
    [5] = { 1, 4 },
    [6] = { 1, 6 },
    [7] = { 1.8, 1 },
    [8] = { 1.8, 7 },
    [9] = { 2.6, 2 },
    [10] = { 2.6, 8 },
    [11] = { 1, 2 },
    [12] = { 1, 8 },
}

---@private
function GUIFisherManGiftWindow:ctor(...)
    self.super.ctor(self, "FisherManGift.json", ...)
end

---@private
function GUIFisherManGiftWindow:onLoad()
    self.btnIntroduce = self:getChildWindowByName("FisherManGift-Introduce", GUIType.Button)
    self.stTitle = self:getChildWindowByName("FisherManGift-Title", GUIType.StaticText)
    self.llTime = self:getChildWindowByName("FisherManGift-Time", GUIType.Layout)
    self.siTimeIcon = self:getChildWindowByName("FisherManGift-TimeIcon", GUIType.StaticImage)
    self.stTimeText = self:getChildWindowByName("FisherManGift-TimeText", GUIType.StaticText)
    self.stBubbleText = self:getChildWindowByName("FisherManGift-BubbleText", GUIType.StaticText)
    self.llGifts = self:getChildWindowByName("FisherManGift-Gifts", GUIType.Layout)
    self.btnFishing = self:getChildWindowByName("FisherManGift-Fishing", GUIType.Button)
    self.stFishingTip = self:getChildWindowByName("FisherManGift-FishingTip", GUIType.StaticText)
    self.siFishingPriceIcon = self:getChildWindowByName("FisherManGift-FishingPriceIcon", GUIType.StaticImage)
    self.stFishingPrice = self:getChildWindowByName("FisherManGift-FishingPrice", GUIType.StaticText)
    self.siFishingRed = self:getChildWindowByName("FisherManGift-FishingRed", GUIType.StaticImage)
    self.stTip = self:getChildWindowByName("FisherManGift-Tip", GUIType.StaticText)
    self.llFishingMask = self:getChildWindowByName("FisherManGift-FishingMask", GUIType.Layout)
    self.siFishingEffect = self:getChildWindowByName("FisherManGift-FishingEffect", GUIType.StaticImage)
    self.stFishingEffectTip = self:getChildWindowByName("FisherManGift-FishingEffectTip", GUIType.StaticText)
    self:initView()
    self:initEvent()
end

---@private
function GUIFisherManGiftWindow:initView()
    self.stBubbleText:SetText(Lang:getString("gui.fisher.gift.bubble.text"))
    self.stFishingTip:SetText(Lang:getString("gui.pay.activity.free"))
    self.btnFishing:SetText(Lang:getString("gui.fisher.gift.fishing"))
    self.stTip:SetText(Lang:getString("gui.fisher.gift.tip"))
    self.stFishingEffectTip:SetText(Lang:getString("gui.fishing.effect.tip"))
    self.llFishingMask:SetVisible(false)
end

function GUIFisherManGiftWindow:initGifts()
    ---@type GUIFisherManGiftRewardWindow[]
    self.wGiftItems = {}
    local cfgs = FisherManGiftConfig:getAllCfgs()
    for index, cfg in pairs(cfgs) do
        local reward = PayActivityRewardConfig:getCfgById(FisherManGiftConfig:getRewardId(cfg,self.activity.player))
        local pos = GiftRewardPos[index]
        if pos and reward then
            ---@type GUIFisherManGiftRewardWindow
            local item = UIHelper.newGameGUIWindow("GUIFisherManGiftReward")
            item:onDataChanged(reward, self.activity)
            item:setArea({ 0, (pos[2] - 1) * 109 }, { 0, (pos[1] - 1) * 110 }, { 0, 109 }, { 0, 110 })
            self.llGifts:AddChildWindow(item.root)
            table.insert(self.wGiftItems, item)
        end
    end
end

---@private
function GUIFisherManGiftWindow:initEvent()
    self.btnIntroduce:registerEvent(GUIEvent.ButtonClick, function()
        CustomDialog.builder()
                    .setContentText(Lang:getString(self.activity.cfg.introduce))
                    .setHideLeftButton()
                    .show()
    end)
    self.btnFishing:registerEvent(GUIEvent.ButtonClick, function()
        ReportEvent.reportEvent(Game:getPlatformUserId(), "fisherman_fish_click")
        PayHelper.checkMoney(CurrencyId.GCube, self.activity:getLotteryPrice(), function(success)
            if success then
                self:showFishingEffect()
            end
        end)
    end)
    self.llFishingMask:registerEvent(GUIEvent.Click, function()
        LuaTimer:cancel(self.fishingTimer)
    end)
end

function GUIFisherManGiftWindow:showFishingEffect()
    self.llFishingMask:SetVisible(true)
    self.siFishingEffect:PlayEffect1("")
    self.siFishingEffect:PlayEffect1("fisherman_gift_get.effect")
    self.fishingTimer = LuaTimer:scheduleTimerWithEnd(function()

    end, function()
        self.llFishingMask:SetVisible(false)
        self.activity:tryFishing()
    end, 3000, 1)
    self:addTimer(self.fishingTimer)
end

function GUIFisherManGiftWindow:onShow(isTick)
    local countdown = self.activity.cfg.endDate - os.time()
    self.stTimeText:SetText(DateUtil.getTimeByTwoPara(countdown))
    if not isTick then
        ReportEvent.reportEvent(Game:getPlatformUserId(), "fisherman_gift_click")
    end
    LuaTimer:cancel(self.countdownTimer)
    self.countdownTimer = LuaTimer:schedule(function()
        self:onShow(true)
    end, 1000)
    self:addTimer(self.countdownTimer)
    if self.activity then
        self.llTime:SetVisible(self.activity.cfg.hideTimeUI~=1)
    end
end

function GUIFisherManGiftWindow:onHide()
    LuaTimer:cancel(self.countdownTimer)
end

---@param activity FisherManGift
function GUIFisherManGiftWindow:onDataChanged(activity)
    self.activity = activity
    self.stTitle:SetText(Lang:getString(activity.cfg.tabName))
    self.activity.info:addKeyObserver("Record", function()
        self:updateFishingUI()
    end)
    self:initGifts()
    self:updateFishingUI()
    if self.activity.info:getValue("First") then
        ---@type UIPayActivityLayout
        local GUIPayActivity = UIHelper.newGameGUILayout("GUIPayActivity")
        GUIPayActivity:showNpcDialog("set:must_win_lottery.json image:img_0_fisherman", {
            "gui.fisher.npc.dialog.text"
        })
    end
end

function GUIFisherManGiftWindow:updateFishingUI()
    local price = self.activity:getLotteryPrice()
    self.btnFishing:SetEnabled(price ~= nil)
    if price then
        self.stFishingTip:SetVisible(price == 0)
        self.siFishingRed:SetVisible(price == 0)
        self.siFishingPriceIcon:SetVisible(price ~= 0)
        self.stFishingPrice:SetText(price)
    else
        self.stFishingTip:SetVisible(false)
        self.siFishingRed:SetVisible(false)
        self.siFishingPriceIcon:SetVisible(false)
    end
    if TableUtil.isEmpty(self.activity.info:getValue("Record")) then
        self.stBubbleText:SetText(Lang:getString("gui.fisher.gift.bubble.text"))
    else
        self.stBubbleText:SetText(Lang:getString("gui.fisher.gift.bubble.text2"))
    end
    for _, item in pairs(self.wGiftItems) do
        item:updateState()
    end
end

return GUIFisherManGiftWindow
--[[GemE9f1jk4SNstzu3xutoSaImT0]]