---@class UICustomResourceEditLayout : IGUILayout
local UICustomResourceEditLayout = class("UICustomResourceEditLayout", IGUILayout)
---@type ItemsConfig
local ItemsConfig = T(Global, "ItemsConfig")
---@type CResourcesMgr
local CResourcesMgr = T(Global, "CResourcesMgr")
local IntervalAve = 1 / (Define.IntervalMax - Define.IntervalMin)
local MaxItemAve = 1 / (Define.MaxItemMax - Define.MaxItemMin)

---@private
function UICustomResourceEditLayout:ctor(parent)
    self.super.ctor(self, "CustomResourceEdit.json", parent)
end

---@private
function UICustomResourceEditLayout:isDelayLoad()
    return true
end

---@private
function UICustomResourceEditLayout:onCreate()
    self:initCreateEvent()
end

---@private
function UICustomResourceEditLayout:initCreateEvent()
end

---@private
function UICustomResourceEditLayout:onLoad()
    self.shopId = 0
    self.selectItem = {
        id = 0,
        meta = 0
    }
    self.siBgMask = self:getChildWindow("CustomResourceEdit-Bg-Mask", GUIType.StaticImage)
    self.siBg = self:getChildWindow("CustomResourceEdit-Bg", GUIType.StaticImage)
    self.llTop = self:getChildWindow("CustomResourceEdit-Top", GUIType.Layout)
    self.stTitle = self:getChildWindow("CustomResourceEdit-Title", GUIType.StaticText)
    self.btnClose = self:getChildWindow("CustomResourceEdit-Close", GUIType.Button)
    self.btnSave = self:getChildWindow("CustomResourceEdit-Save", GUIType.Button)
    self.btnRecycling = self:getChildWindow("CustomResourceEdit-Recycling", GUIType.Button)
    self.stItemTitle = self:getChildWindow("CustomResourceEdit-Item-Title", GUIType.StaticText)
    self.llItem = self:getChildWindow("CustomResourceEdit-Item", GUIType.Layout)
    self.stIntervalTitle = self:getChildWindow("CustomResourceEdit-Interval-Title", GUIType.StaticText)
    self.stIntervalAdd = self:getChildWindow("CustomResourceEdit-Interval-Add", GUIType.Button)
    self.stIntervalDec = self:getChildWindow("CustomResourceEdit-Interval-Dec", GUIType.Button)
    self.slInterval = self:getChildWindow("CustomResourceEdit-Interval", GUIType.Slider)
    self.stIntervalText = self:getChildWindow("CustomResourceEdit-Interval-Text", GUIType.StaticText)
    self.stMaxTitle = self:getChildWindow("CustomResourceEdit-Max-Title", GUIType.StaticText)
    self.stMaxAdd = self:getChildWindow("CustomResourceEdit-Max-Add", GUIType.Button)
    self.stMaxDec = self:getChildWindow("CustomResourceEdit-Max-Dec", GUIType.Button)
    self.slMax = self:getChildWindow("CustomResourceEdit-Max", GUIType.Slider)
    self.stMaxText = self:getChildWindow("CustomResourceEdit-Max-Text", GUIType.StaticText)
    self.llSelectLayout = self:getChildWindow("CustomResourceEdit-Select-Layout", GUIType.Layout)
    self.siSelectBg = self:getChildWindow("CustomResourceEdit-Select-Bg", GUIType.StaticImage)
    self.llSelectTop = self:getChildWindow("CustomResourceEdit-Select-Top", GUIType.Layout)
    self.stSelectTitle = self:getChildWindow("CustomResourceEdit-Select-Title", GUIType.StaticText)
    self.btnSelectClose = self:getChildWindow("CustomResourceEdit-Select-Close", GUIType.Button)
    self.siSelectContent = self:getChildWindow("CustomResourceEdit-Select-Content", GUIType.StaticImage)
    self.llSelectTabs = self:getChildWindow("CustomResourceEdit-Select-Tabs", GUIType.Layout)
    self.btnSelectSure = self:getChildWindow("CustomResourceEdit-Select-Sure", GUIType.Button)
    self:initView()
    self:initEvent()
end

---@private
function UICustomResourceEditLayout:initView()
    self.stTitle:SetText(Lang:getString("gui.resource.edit.title"))
    self.stSelectTitle:SetText(Lang:getString("gui.custom.shop.select.title"))
    self.btnRecycling:SetText(Lang:getString("gui.resource.edit.recycling"))
    self.btnSave:SetText(Lang:getString("custom_room_save"))
    self.btnSelectSure:SetText(Lang:getString("gui_dialog_tip_btn_sure"))
    self.stItemTitle:SetText(Lang:getString("gui.resource.edit.item.title"))
    self.stIntervalTitle:SetText(Lang:getString("gui.resource.edit.interval.title"))
    self.stMaxTitle:SetText(Lang:getString("gui.resource.edit.max.title"))

    ---@type GUICustomShopSelectItemWindow
    self.item = UIHelper.newGameGUIWindow("GUICustomShopSelectItem")
    self.llItem:AddChildWindow(self.item.root)
    self.item.root:SetArea({ 0, 0 }, { 0, 0 }, { 1, 0 }, { 1, 0 })
    self.item:setClickFunc(function()
        self:showSelect(true, function(id, meta)
            self:onItemEdit(id, meta)
        end)
    end)

    self.lvSelectList = IGUIGridView.new("CustomResourceEdit-Select-List", self.siSelectContent)
    self.lvSelectList.root:SetArea({ 0, 0 }, { 0, 0 }, { 1, -18 }, { 1, -18 })
    self.lvSelectList.root:SetHorizontalAlignment(HorizontalAlignment.Center)
    self.lvSelectList.root:SetVerticalAlignment(VerticalAlignment.Center)
    self.lvSelectList:setConfig(4, 4, 9)
    ---@type CustomShopSelectItemAdapter
    self.selectAdapter = UIHelper.newGameAdapter("CustomShopSelectItemAdapter")
    local width = (self.lvSelectList.root:GetPixelSize().x - 32) / 9
    self.selectAdapter:setItemSize(width, width)
    self.lvSelectList:setAdapter(self.selectAdapter)

    self.selectTabs = {}
    local index = 1
    for _, type in pairs(Define.ShopItemType) do
        local win = UIHelper.newGameGUIWindow("GUICustomShopTab")
        self.llSelectTabs:AddChildWindow(win.root)
        win.root:SetYPosition({ 0, (index - 1) * 74 })
        win:onDataChanged({
            group = Define.ShopTabGroup.Select,
            type = type
        })
        self.selectTabs[type] = win
        index = index + 1
    end
end

---@private
function UICustomResourceEditLayout:initEvent()
    self.btnClose:registerEvent(GUIEvent.ButtonClick, function()
        self:hide()
    end)

    self.btnSave:registerEvent(GUIEvent.ButtonClick, function()
        self:onSave()
        self:hide()
    end)

    self.btnRecycling:registerEvent(GUIEvent.ButtonClick, function()
        CustomDialog.builder()
                    .setLevel(48)
                    .setAlwaysOnTop()
                    .setContentText(Lang:getString("gui.resource.recycle.tip"))
                    .setRightClickListener(function() self:recycleResource() end)
                    .show()
    end)

    self.btnSelectClose:registerEvent(GUIEvent.ButtonClick, function()
        self:showSelect(false)
    end)

    self.btnSelectSure:registerEvent(GUIEvent.ButtonClick, function()
        if self.selectItem and self.sureFunc then
            self.sureFunc(self.selectItem.id, self.selectItem.meta)
        end
        self:showSelect(false)
    end)

    self.stIntervalAdd:registerEvent(GUIEvent.ButtonClick, function()
        self.info.interval = self.info.interval or Define.IntervalMin
        if self.info.interval >= Define.IntervalMax then
            return
        end
        self.info.interval = self.info.interval + 1
        self.hasChange = true
        self:updateIntervalUi()
    end)
    self.stIntervalDec:registerEvent(GUIEvent.ButtonClick, function()
        self.info.interval = self.info.interval or Define.IntervalMin
        if self.info.interval <= Define.IntervalMin then
            return
        end
        self.info.interval = self.info.interval - 1
        self.hasChange = true
        self:updateIntervalUi()
    end)
    self.slInterval:registerEvent(GUIEvent.TouchDown, function()
        self:editIntervalPro()
    end)
    self.slInterval:registerEvent(GUIEvent.TouchMove, function()
        self:editIntervalPro()
    end)

    self.stMaxAdd:registerEvent(GUIEvent.ButtonClick, function()
        self.info.max = self.info.max or Define.MaxItemMin
        if self.info.max >= Define.MaxItemMax then
            return
        end
        self.info.max = self.info.max + 1
        self.hasChange = true
        self:updateMaxUi()
    end)
    self.stMaxDec:registerEvent(GUIEvent.ButtonClick, function()
        self.info.max = self.info.max or Define.MaxItemMin
        if self.info.max <= Define.MaxItemMin then
            return
        end
        self.info.max = self.info.max - 1
        self.hasChange = true
        self:updateMaxUi()
    end)
    self.slMax:registerEvent(GUIEvent.TouchDown, function()
        self:editMaxPro()
    end)
    self.slMax:registerEvent(GUIEvent.TouchMove, function()
        self:editMaxPro()
    end)

    self:registerEvent(Events.ShopTabSelectEvent, function(group, type)
        if group == Define.ShopTabGroup.Select then
            if not self.llSelectLayout:IsVisible() then
                return
            end
            self:updateSelectList(type)
        end
    end)

    self:registerEvent(Events.ShopSelectItemEvent, function(id, meta)
        if self.selectItem and self.selectItem.id == id and self.selectItem.meta == meta then
            return
        end
        self.selectItem = {
            id = id,
            meta = meta
        }
    end)
end

function UICustomResourceEditLayout:onShow(resourceId)
    if not CResourcesMgr:getResources(resourceId) then
        self:hide()
        return
    end
    self.resourceId = resourceId
    self.hasChange = false
    self.editRecord = {}
    self:updateResourceUi()
end

function UICustomResourceEditLayout:updateResourceUi()
    if not self.resourceId then
        return
    end
    local resource = CResourcesMgr:getResources(self.resourceId)
    if not resource then
        return
    end
    self.info = {}
    local info = resource:getInfo()
    self.info = info
    self:updateItemUi()
    self:updateIntervalUi()
    self:updateMaxUi()
end

function UICustomResourceEditLayout:showSelect(isShow, sureFunc)
    self.llSelectLayout:SetVisible(isShow)
    self.sureFunc = false
    if isShow then
        Events.ShopTabSelectEvent:invoke(Define.ShopTabGroup.Select, Define.ShopItemType.Block)
        self.sureFunc = sureFunc
    end
end

function UICustomResourceEditLayout:updateSelectList(type)
    if self.curSelectTab and self.curSelectTab == type then
        return
    end
    self.curSelectTab = type
    local items = ItemsConfig:getCfgs(type)
    if not items then
        return
    end
    local showItems = self:excludeItems(type, items)
    self.selectAdapter:setData(showItems)
    local item = showItems[1]
    Events.ShopSelectItemEvent:invoke(item.id, item.meta)
end

function UICustomResourceEditLayout:excludeItems(type, items)
    local exclude = Define.ResourceExclude[type]
    if exclude and #exclude > 0 then
        local showItems = {}
        for _, item in ipairs(items) do
            if not TableUtil.include(exclude, item.id) then
                table.insert(showItems, item)
            end
        end
        return showItems
    end
    return items
end

function UICustomResourceEditLayout:updateItemUi()
    local item = self.info.item or { 0, 0 }
    self.item:setItem(item)
end

function UICustomResourceEditLayout:updateIntervalUi()
    self.info.interval = self.info.interval or Define.IntervalMin
    self.stIntervalText:SetText(self.info.interval .. " / " .. Define.IntervalMax)
    local pro = math.max(0, (self.info.interval - Define.IntervalMin) * IntervalAve)
    pro = math.min(1, pro)
    self.slInterval:SetProgress(pro)
end

function UICustomResourceEditLayout:updateMaxUi()
    self.info.max = self.info.max or Define.MaxItemMin
    self.stMaxText:SetText(self.info.max .. " / " .. Define.MaxItemMax)
    local pro = math.max(0, (self.info.max - Define.MaxItemMin) * MaxItemAve)
    pro = math.min(1, pro)
    self.slMax:SetProgress(pro)
end

function UICustomResourceEditLayout:onItemEdit(id, meta)
    self.hasChange = true
    self.info.item = { id, meta }
    self:updateItemUi()
end

function UICustomResourceEditLayout:onSave()
    if not CResourcesMgr:getResources(self.resourceId) then
        self:hide()
        return
    end
    if not self.hasChange then
        return
    end
    if self.info.item[1] == 0 then
        ---todo:提示
        return
    end
    PlayerManager:getClientPlayer():sendPacket({
        pid = "onEditResources",
        resourcesId = self.resourceId,
        info = self.info
    })
end

function UICustomResourceEditLayout:editIntervalPro()
    local curProgress = self.slInterval:GetProgress()
    local num = math.floor(curProgress / IntervalAve)
    if curProgress % IntervalAve >= IntervalAve / 2 then
        num = num + 1
    end
    self.info.interval = math.min(Define.IntervalMax, num + Define.IntervalMin)
    self.hasChange = true
    self:updateIntervalUi()
end

function UICustomResourceEditLayout:editMaxPro()
    local curProgress = self.slMax:GetProgress()
    local num = math.floor(curProgress / MaxItemAve)
    if curProgress % MaxItemAve >= MaxItemAve / 2 then
        num = num + 1
    end
    self.info.max = math.min(Define.MaxItemMax, num + Define.MaxItemMin)
    self.hasChange = true
    self:updateMaxUi()
end

function UICustomResourceEditLayout:recycleResource()
    PlayerManager:getClientPlayer():sendPacket({
        pid = "onPlayerRecycleResources",
        id = self.resourceId
    })
    self:hide()
end

return UICustomResourceEditLayout
