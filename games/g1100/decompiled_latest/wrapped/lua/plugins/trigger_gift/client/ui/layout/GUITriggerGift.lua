--[[CYPZje2CwJqQQbpXGcE18l2bMlUWNzTOOJZ71RfmfD2c1bHCXaoKZsVQ7MVET6LHGftJ0zLzDJvu6D]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 13553
                          local checkFileName = "GUITriggerGift.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[zJAkKZTIkGp8muN4hPApAkMl4GgFuLPiGhTaCp5nx6lRPlXKADyDESuanJFwaDUXzovdeDeJUZmEvNPUtrj4Z25crZxve8Xv8pinbmLPAPVLuE]]---@class UITriggerGiftLayout : IGUILayout
local UITriggerGiftLayout = class("UITriggerGiftLayout", IGUILayout)
---@type TriggerGiftRewardGroupConfig
local TriggerGiftRewardGroupConfig = Plugins.Require("trigger_gift", "common.config.TriggerGiftRewardGroupConfig")
---@type TriggerGiftDescConfig
local TriggerGiftDescConfig = Plugins.Require("trigger_gift", "common.config.TriggerGiftDescConfig")

---@type TriggerGiftDataMgr
local TriggerGiftDataMgr = Plugins.Require("trigger_gift", "client.data.TriggerGiftDataMgr")

---@type UIUtils
local UIUtils = T(Global, "UIUtils")

local OffNumImage = "set:trigger_gift.json image:img_0_gift_discount"
local RewardsListSize = {
    { width = { 0, 206 }, height = { 0, 163 }, itemWidth = 122, itemHeight = 158, itemSpace = 42 },
    { width = { 0, 370 }, height = { 0, 164 }, itemWidth = 122, itemHeight = 158, itemSpace = 42 },
    { width = { 0, 478 }, height = { 0, 146 }, itemWidth = 110, itemHeight = 143, itemSpace = 37 },
    { width = { 0, 525 }, height = { 0, 132 }, itemWidth = 100, itemHeight = 130, itemSpace = 25 },
}
--- 628 346

---@private
function UITriggerGiftLayout:ctor(parent)
    self.super.ctor(self, "TriggerGift.json", parent)
end

---@private
function UITriggerGiftLayout:onLoad()
    self.llBox = self:getChildWindow("TriggerGift-Box", GUIType.Layout)
    self.siBigImage = self:getChildWindow("TriggerGift-Big-Image", GUIType.StaticImage)
    self.llTitle = self:getChildWindow("TriggerGift-Title", GUIType.StaticImage)
    self.stDesc = self:getChildWindow("TriggerGift-Desc", GUIType.StaticText)
    self.llOffValue = self:getChildWindow("TriggerGift-Off-Value", GUIType.Layout)
    self.siOffBg = self:getChildWindow("TriggerGift-Off-Bg", GUIType.StaticImage)
    self.llRewards = self:getChildWindow("TriggerGift-Rewards", GUIType.Layout)
    self.btnBuy = self:getChildWindow("TriggerGift-Buy", GUIType.Button)
    self.siBuyIcon = self:getChildWindow("TriggerGift-Buy-Icon", GUIType.StaticImage)
    self.stPrice = self:getChildWindow("TriggerGift-Price", GUIType.StaticText)
    self.stValue = self:getChildWindow("TriggerGift-Value", GUIType.StaticText)
    self.siValueLine = self:getChildWindow("TriggerGift-Value-Line", GUIType.StaticImage)
    self.stCountDownNum = self:getChildWindow("TriggerGift-CountDown-Num", GUIType.StaticText)
    self.btnClose = self:getChildWindow("TriggerGift-Close", GUIType.Button)

    self.llTabList = self:getChildWindow("TriggerGift-TabList", GUIType.Layout)

    self:initView()
    self:initEvent()
end

---@private
function UITriggerGiftLayout:initEvent()
    self.btnClose:registerEvent(GUIEvent.ButtonClick, function()
        self:hide()
    end)

    self.btnBuy:registerEvent(GUIEvent.ButtonClick, function()
        self:onClickBuy()
    end)
end

---@private
function UITriggerGiftLayout:initView()
    self.stDesc:SetText(Lang:getString("common.triggerGift.title"))
    UIHelper:setImageAdjustSize(self.llTitle, UIUtils.GetLangImage("set:trigger_gift.json image:text"), 9999, 9999)

    ---@type IGUIListView
    self.lvShowItemList = IGUIListView.new("TriggerGift-Rewards-List", self.llRewards, nil, Orientation.Horizontal)
    self.lvShowItemList.root:SetHorizontalAlignment(HorizontalAlignment.Center)
    self.lvShowItemList.root:SetVerticalAlignment(VerticalAlignment.Center)
    self.lvShowItemList.root:SetClipChild(false)
    self.lvShowItemList:setItemSpace(25)

    self.showItemAdapt = (require "ui.adapter.TriggerGiftRewardItemAdapt").new()
    self.showItemAdapt:setItemParent(self)
    self.showItemAdapt:setItemSize(100, 130)

    self.lvShowItemList:setAdapter(self.showItemAdapt)
    self.lvShowItemList.offset = 0
    self.curGiftList = {}
    self.curGiftRewardConfig = {}

    self.lvShowItemList.root:registerEvent(GUIEvent.ScrollMoveChange, function(events)
        local scroll = events.offset
        if self.curGiftRewardConfig then
            if scroll < -125 then
                local first = table.remove(self.curGiftRewardConfig, 1)
                table.insert(self.curGiftRewardConfig, first)
                self.showItemAdapt:setData(self.curGiftRewardConfig)
                scroll = scroll + 125
                self.lvShowItemList.root:SetScrollOffset(scroll)
            elseif scroll > 25 then
                local last = table.remove(self.curGiftRewardConfig, #self.curGiftRewardConfig)
                table.insert(self.curGiftRewardConfig, 1, last)
                self.showItemAdapt:setData(self.curGiftRewardConfig)
                scroll = scroll - 125
                self.lvShowItemList.root:SetScrollOffset(scroll)
            end
        end
    end)

    self.lvShowItemList.root:registerEvent(GUIEvent.ScrollMoveEnd, function(events)
        self.isBeScroll = false
    end)

    self.lvShowItemList.root:registerEvent(GUIEvent.ScrollCardClick, function(events)
        self.isBeScroll = false
    end)

    ---@type GUICheckBox
    self.checkBoxList = {}
end

function UITriggerGiftLayout:onTick()
    if self.curGiftList[self.curGiftIndex] then
        local giftConfig = TriggerGiftDescConfig:getCfgById(self.curGiftList[self.curGiftIndex].giftId)
        if giftConfig then
            local lastTime = self.curGiftList[self.curGiftIndex].startTime + giftConfig.duration - os.time()
            if lastTime >= 0 then
                self.stCountDownNum:SetText(DateUtil.getFormatTime(lastTime))
                self.stCountDownNum:SetWidth({ 0, self.stCountDownNum:GetTextWidth() + 10 })
            else
                TriggerGiftDataMgr:showTriggerGiftWindow()
            end
        end
    end

    local giftNum = #self.curGiftRewardConfig

    if giftNum > 4 then
        self.lvShowItemList.root:SetArea({ 0, 0 }, { 0, 0 }, { 1, 0 }, { 1, 0 })
        local scroll = self.lvShowItemList.root:GetScrollOffset()
        if not self.isBeScroll then
            self.lvShowItemList.root:SetScrollOffset(scroll - 2)
        end
    else
        self.lvShowItemList.root:SetArea({ 0, 0 }, { 0, 0 }, { 1, 0 }, { 1, 0 })
    end
end

---@private
function UITriggerGiftLayout:onClickBuy()
    if not self.curGiftIndex then
        return
    end

    if self.curGiftList[self.curGiftIndex].startTime + self.curGiftList[self.curGiftIndex].duration < os.time() then
        return
    end
    PayHelper.checkMoney(CurrencyId.Diamonds, self.curGiftList[self.curGiftIndex].price, function(success)
        if success then
            CustomDialog.builder().setTitleText("TriggerGift.buyPop.title")
                        .setRightText(Lang:getString("gui_dialog_tip_btn_sure"))
                        .setContentText(Lang:getString("TriggerGift.buyPop.content"))
                        .setRightClickListener(function()
                PlayerManager:getClientPlayer():sendPacket({
                    pid = "BuyTriggerGift",
                    giftId = self.curGiftList[self.curGiftIndex].giftId
                })
            end).show()
        end
    end)
end

---@param data TriggerGiftInfo[]
function UITriggerGiftLayout:onDataChange(data)
    self.curGiftList = data

    local startPos = 0
    for i, gift in ipairs(self.curGiftList) do
        local giftConfig = TriggerGiftDescConfig:getCfgById(gift.giftId)
        local checkBox = self.checkBoxList[i]
        if not checkBox then
            checkBox = self:createCheckBox()
        end
        checkBox.siTabImg:SetImage(giftConfig.tabImage)
        checkBox.root:SetVisible(true)
        checkBox.root:SetArea({ 0, 0 }, { 0, startPos }, { 0, 93 }, { 0, 48 })
        startPos = startPos + 48 + 7.5
    end

    for i = #self.curGiftList + 1, #self.checkBoxList, 1 do
        local checkBox = self.checkBoxList[i]
        checkBox.root:SetVisible(false)
    end

    if not self.curGiftIndex then
        self:changeCurSelect(1)
    else
        if self.curGiftIndex > #self.curGiftList then
            self:changeCurSelect(#self.curGiftList)
        else
            self:changeCurSelect(self.curGiftIndex)
        end
    end
end

function UITriggerGiftLayout:changeCurSelect(index)
    if not self.curGiftList[index] then
        return
    end
    self.curGiftIndex = index
    self:selectCheckBox(index)

    local giftConfig = TriggerGiftDescConfig:getCfgById(self.curGiftList[index].giftId)
    if not giftConfig then
        return
    end

    self.stPrice:SetText(giftConfig.price)
    self.stValue:SetText(giftConfig.value)

    local nameLen = string.len(giftConfig.name)

    if self.llOffValue:GetChildCount() > nameLen then
        for i = self.llOffValue:GetChildCount(), (nameLen + 1), -1 do
            GUIManager:getWindowByName("TriggerGift-Off-" .. tostring(i), GUIType.StaticImage):SetVisible(false)
        end
    end
    local posX = 0
    for i = 1, nameLen do
        local image = GUIManager:getWindowByName("TriggerGift-Off-" .. tostring(i), GUIType.StaticImage)
        if not image then
            image = GUIManager:createGUIWindow(GUIType.StaticImage, "TriggerGift-Off-" .. tostring(i))
            image:SetHorizontalAlignment(HorizontalAlignment.Left)
            image:SetVerticalAlignment(VerticalAlignment.Center)
            self.llOffValue:AddChildWindow(image)
        end
        image:SetVisible(true)
        local width, height = UIHelper:getImageSize(OffNumImage .. tostring(string.sub(giftConfig.name, i, i)), 28, 32)
        image:SetArea({ 0, posX }, { 0, 0 }, { 0, width[2] }, { 0, 32 })
        posX = posX + width[2]
        image:SetImage(OffNumImage .. tostring(string.sub(giftConfig.name, i, i)))
    end
    self.llOffValue:SetArea({ 0, -posX * 0.5 }, { 0, 10 }, { 0, 0 }, { 0, 32 })

    self.siBigImage:SetImage(giftConfig.image)

    self.curGiftRewardConfig = TriggerGiftRewardGroupConfig:getCfgByGroupId(giftConfig.rewardGroupId)
    if self.curGiftRewardConfig then
        local giftNum = #self.curGiftRewardConfig
        if giftNum > 4 then
            giftNum = 4
        end
        self.llRewards:SetHeight({ 0, 104 })
        --self.llRewards:SetWidth(RewardsListSize[giftNum].width)
        self.showItemAdapt:clearItems()
        self.showItemAdapt:setItemSize(104, 104)
        self.lvShowItemList:setItemSpace(13)
        self.lvShowItemList.root:SetArea({ 0, 0 }, { 0, 0 }, { 1, 0 }, { 1, 0 })
        self.lvShowItemList.root:SetScrollOffset(0)

        self.showItemAdapt:setData(self.curGiftRewardConfig)
    end
end

---新建checkBox
function UITriggerGiftLayout:createCheckBox()
    local newCheckBox = UIHelper.newGameGUIWindow("GUITriggerGiftSwitchPoint")
    table.insert(self.checkBoxList, newCheckBox)
    newCheckBox.checkBox:registerEvent(GUIEvent.CheckStateChanged, function()
        if newCheckBox.checkBox:GetChecked() then
            for index, tabCheckBox in pairs(self.checkBoxList) do
                if tabCheckBox.checkBox:GetChecked() and tabCheckBox ~= newCheckBox then
                    tabCheckBox.checkBox:SetChecked(false)
                    tabCheckBox:showIsSwitching(false)
                    tabCheckBox.checkBox:SetTouchable(true)
                end
                if tabCheckBox == newCheckBox then
                    if self.curGiftIndex ~= index then
                        self:changeCurSelect(index)
                    end
                end
            end
            newCheckBox.checkBox:SetTouchable(false)
            newCheckBox:showIsSwitching(true)
        end
    end)

    self.llTabList:AddChildWindow(newCheckBox.root)
    return newCheckBox
    --self:updateCheckBoxList()
end

---选中checkBox
function UITriggerGiftLayout:selectCheckBox(index)
    if self.checkBoxList[index] then
        self.checkBoxList[index].checkBox:SetChecked(true)
    end
    --self:setSwitchStatus()
end

---移除checkBox
function UITriggerGiftLayout:removeCheckBox()
    if #self.checkBoxList >= 1 then
        self.llTabList:RemoveChildWindow1(self.checkBoxList[#self.checkBoxList].root)
        table.remove(self.checkBoxList, #self.checkBoxList)
        self:updateCheckBoxList()
    end
end

function UITriggerGiftLayout:updateCheckBoxList()
    local num = #self.checkBoxList
    if num == 0 then
        return
    end
    if num == 1 then
        self.checkBoxList[1].root:SetVisible(false)
    else
        self.checkBoxList[1].root:SetVisible(true)
    end

    local startPos = 0
    for index, checkBox in pairs(self.checkBoxList) do
        checkBox.root:SetArea({ 0, 0 }, { 0, startPos }, { 0, 93 }, { 0, 48 })
        startPos = startPos + 48 + 7.5
    end
end

function UITriggerGiftLayout:clickItem(item)
    ---TODO 游戏自定义弹窗
end

return UITriggerGiftLayout
--[[C93n2MK2HFCV8yvbEald4iNv9e31PG25Pl7cGtOyZNzZEgVjXnKyNAXEzWcnwFR]]---