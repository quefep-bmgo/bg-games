---@class UIPayActivityLayout : IGUILayout
local UIPayActivityLayout = class("UIPayActivityLayout", IGUILayout)

---@private
function UIPayActivityLayout:ctor(parent)
    self.super.ctor(self, "PayActivity.json", parent)
end

---@private
function UIPayActivityLayout:isDelayLoad()
    return true
end

---@private
function UIPayActivityLayout:onCreate()
    self:initCreateEvent()
end

---@private
function UIPayActivityLayout:initCreateEvent()

end

---@private
function UIPayActivityLayout:onLoad()
    self.llPanels = self:getChildWindow("PayActivity-Panels", GUIType.Layout)
    self.llTabs = self:getChildWindow("PayActivity-Tabs", GUIType.Layout)
    self.btnBack = self:getChildWindow("PayActivity-Back", GUIType.Button)
    self.siBackImage = self:getChildWindow("PayActivity-BackImage", GUIType.StaticImage)
    self.llDialog = self:getChildWindow("PayActivity-Dialog", GUIType.Layout)
    self.siDialogNpc = self:getChildWindow("PayActivity-DialogNpc", GUIType.StaticImage)
    self.stDialogText = self:getChildWindow("PayActivity-DialogText", GUIType.StaticText)
    self.siDialogContinue = self:getChildWindow("PayActivity-DialogContinue", GUIType.StaticImage)
    self.stDialogContinueText = self:getChildWindow("PayActivity-DialogContinueText", GUIType.StaticText)
    self:initView()
    self:initEvent()
end

---@private
function UIPayActivityLayout:initView()
    ---@type IPayActivity
    self.curSelectActivity = nil
    ---@type IGUIWindow[]
    self.wPanels = {}
    self.llDialog:SetVisible(false)
    self.stDialogContinueText:SetText(Lang:getString("gui.dialog.continue"))
    ---@type GUIPayActivityCurrencyGroupWindow
    self.wCurrentGroup = UIHelper.newGameGUIWindow("GUIPayActivityCurrencyGroup")
    self.wCurrentGroup:onDataChanged({ CurrencyId.GCube })
    self.root:AddChildWindow(self.wCurrentGroup.root)
end

---@private
function UIPayActivityLayout:initEvent()
    self.btnBack:registerEvent(GUIEvent.ButtonClick, function()
        self:hide()
    end)
    self.llDialog:registerEvent(GUIEvent.Click, function()
        if self.siDialogContinue:IsVisible() then
            self:tryDialogContinue()
        end
    end)
end

function UIPayActivityLayout:show(...)
    if not PlayerManager:getClientPlayer().payActivity:canShowPayActivity() then
        CustomDialog.builder()
                    .setContentText(Lang:getString("common.activity.end.tip"))
                    .setHideLeftButton()
                    .show()
        return
    end
    RootGuiLayout.Instance():hideAllChildren()
    self.super.show(self, ...)
end

function UIPayActivityLayout:onShow(activity)
    self:createActivityTabs()
    if activity then
        self:setCurSelectActivity(activity)
    end
end

function UIPayActivityLayout:onHide()
    RootGuiLayout.Instance():showMainControl()
    if self.curSelectActivity then
        local panel = self.wPanels[self.curSelectActivity.cfg.id]
        if panel and panel.onHide then
            panel:onHide()
        end
    end
end

function UIPayActivityLayout:onTick()
    self.wCurrentGroup:onTick()
end

function UIPayActivityLayout:showNpcDialog(npcImage, npcTexts)
    self.contents = npcTexts
    self.siDialogNpc:SetImage(npcImage)
    LuaTimer:cancel(self.dialogTimer)
    self:tryDialogContinue()
end

---@private
function UIPayActivityLayout:tryDialogContinue()
    ---@type string
    local _, content = next(self.contents)
    if not content then
        self.llDialog:SetVisible(false)
        self.siDialogContinue:SetVisible(true)
        return
    end
    self.llDialog:SetVisible(true)
    self.siDialogContinue:SetVisible(false)
    table.remove(self.contents, 1)
    content = Lang:getString(content)
    local times = math.min(#content, 80)
    local charSub = #content / times
    local curIndex = 0
    self.stDialogText:SetText("")
    self.dialogTimer = LuaTimer:scheduleTimerWithEnd(function()
        curIndex = curIndex + charSub
        local text = content:sub(1, math.floor(curIndex + 1))
        self.stDialogText:SetText(text)
    end, function()
        self.dialogTimer = LuaTimer:schedule(function()
            self.siDialogContinue:SetVisible(true)
        end, 500)
    end, 30, times)
end

---@private
function UIPayActivityLayout:createActivityTabs()
    if self.tabAdapter == nil then
        self.lvTabList = IGUIListView.new("PayActivity-TabList", self.llTabs)
        self.lvTabList:setArea({ 0, 0 }, { 0, 60 }, { 1, 37 }, { 1, -60 })
        ---@type PayActivityTabAdapter
        self.tabAdapter = UIHelper.newGameAdapter("PayActivityTabAdapter")
        self.lvTabList:setAdapter(self.tabAdapter)
    end
    ---@type IPayActivity[]
    local needShowActivities = {}
    local activities = PlayerManager:getClientPlayer().payActivity.activities
    for _, activity in pairs(activities) do
        if activity.cfg.tabName ~= "#" then
            table.insert(needShowActivities, activity)
        end
    end
    self:sortActivityList(needShowActivities)
    self.tabAdapter:setData(needShowActivities)
    if self.curSelectActivity and (self.curSelectActivity.cfg.endDate - os.time() > 0 and self.curSelectActivity.cfg.startDate<=os.time()) then
        self:setCurSelectActivity(self.curSelectActivity)
    elseif needShowActivities[1] then
        self:setCurSelectActivity(needShowActivities[1])
    end
end

function UIPayActivityLayout:removeActivity(remove)
    ---@type IPayActivity[]
    local needShowActivities = {}
    local activities = PlayerManager:getClientPlayer().payActivity.activities
    for _, activity in pairs(activities) do
        if activity.cfg.tabName ~= "#" then
            table.insert(needShowActivities, activity)
        end
    end
    self:sortActivityList(needShowActivities)
    self.tabAdapter:setData(needShowActivities)
    if self.curSelectActivity == remove and needShowActivities[1] then
        self:setCurSelectActivity(needShowActivities[1])
    end
end

---@param list IPayActivity[]
function UIPayActivityLayout:sortActivityList(list)
    if not list then
        return
    end
    table.sort(list,function (a,b)
        return a.cfg.order<b.cfg.order
    end)
end

---@param activity IPayActivity
function UIPayActivityLayout:setCurSelectActivity(activity)
    if self.curSelectActivity == activity then
        local panel = self.wPanels[activity.cfg.id]
        if panel and panel.onShow then
            panel:onShow()
        end
        return
    end
    if self.curSelectActivity then
        local panel = self.wPanels[self.curSelectActivity.cfg.id]
        if panel and panel.onHide then
            panel:onHide()
        end
    end
    self.curSelectActivity = activity
    self.tabAdapter:notifyDataChange()
    for _, panel in pairs(self.wPanels) do
        panel:setVisible(false)
    end
    local panel = self.wPanels[activity.cfg.id]
    if not panel then
        panel = UIHelper.newGameGUIWindow(activity.cfg.panelName)
        panel:onDataChanged(activity)
        self.llPanels:AddChildWindow(panel.root)
        self.wPanels[activity.cfg.id] = panel
    end
    panel:setVisible(true)
    if panel.onShow then
        panel:onShow()
    end
end

return UIPayActivityLayout
