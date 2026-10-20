---@class UIModuleBlockMainLayout : IGUILayout
local UIModuleBlockMainLayout = class("UIModuleBlockMainLayout", IGUILayout)
---@type ModuleBlockConfig
local ModuleBlockConfig = T(Global, "ModuleBlockConfig")
---@type PlaceBlockHelper
local PlaceBlockHelper = T(Global, "PlaceBlockHelper")

---@private
function UIModuleBlockMainLayout:ctor(parent)
    self.super.ctor(self, "ModuleBlockMain.json", parent)
end

---@private
function UIModuleBlockMainLayout:isDelayLoad()
    return true
end

---@private
function UIModuleBlockMainLayout:isMainControl()
    if isGameEnd then
        return false
    end
    return true
end

---@private
function UIModuleBlockMainLayout:onCreate()
    self.equipModuleIds = {}
    self:initCreateEvent()
end

---@private
function UIModuleBlockMainLayout:initCreateEvent()
    self:registerEvent(CEvents.PlayerChangeItemInHandEvent, function(userId, itemId, _)
        if isGameEnd or userId ~= Game:getPlatformUserId() then
            return
        end
        self:onHandItemChange(itemId)
    end)
end

---@private
function UIModuleBlockMainLayout:onLoad()
    self.btnFrontPlace = self:getChildWindow("ModuleBlockMain-FrontPlace", GUIType.Button)
    self.siModuleImage = self:getChildWindow("ModuleBlockMain-ModuleImage", GUIType.StaticImage)
    self.btnChange = self:getChildWindow("ModuleBlockMain-Change", GUIType.Button)
    self:initView()
    self:initEvent()
end

---@private
function UIModuleBlockMainLayout:initView()
    self.btnChange:SetVisible(false)
    self.btnFrontPlace:SetNormalImage("set:new_main.json image:img_0_add")
    self.btnFrontPlace:SetPushedImage("set:new_main.json image:img_0_add_click")
    self.siModuleImage:SetImage("")
end

---@private
function UIModuleBlockMainLayout:initEvent()
    self.btnFrontPlace:registerEvent(GUIEvent.ButtonClick, function()
        PlaceBlockHelper:onClickFrontBuildButton()
        if not self.clickFrontPlaceCount or self.clickFrontPlaceCount >= 5 then
            self.clickFrontPlaceCount = 0
        end
        self.clickFrontPlaceCount = self.clickFrontPlaceCount + 1
    end)
    self.btnChange:registerEvent(GUIEvent.ButtonClick, function()
        self:changeCurItemModule()
    end)

    self.btnFrontPlace:registerEvent(GUIEvent.LongTouchStart, function()
        self.longTouchClickFrontBuildButton = true
    end)
    self.btnFrontPlace:registerEvent(GUIEvent.LongTouchEnd, function()
        self.longTouchClickFrontBuildButton = false
    end)
    self.btnFrontPlace:registerEvent(GUIEvent.Release, function()
        self.longTouchClickFrontBuildButton = false
    end)
end

local function isBlockItem(itemId)
    local item = Item.getItemById(itemId)
    if not item then
        return false
    end
    local class = item:getClassName()
    if class == "ItemBlockImp"
            or class == "ItemSlab"
            or class == "ItemBlock"
            or class == "ItemStone"
            or class == "ItemCloth"
            or class == "ItemMultiTextureTile" then
        return true
    end
    return false
end

---@private
function UIModuleBlockMainLayout:onHandItemChange(itemId)
    if itemId == 0 then
        self:hide()
        return
    end
    if not isBlockItem(itemId) then
        self:hide()
        return
    end
    self:show()
    self.siModuleImage:SetImage("set:new_main.json image:img_0_add")
    if GameType ~= "g1064" then
        self.siModuleImage:SetImage("")
    end
    self.btnChange:SetVisible(false)
    local modules = ModuleBlockConfig:getModuleBlocks(itemId)
    if TableUtil.isEmpty(modules) then
        return
    end
    local teamId = PlayerManager:getClientPlayer():getTeamId()
    local moduleId = self.equipModuleIds[itemId] or ModuleBlockConfig:getDefaultModuleId(itemId)
    local module = ModuleBlockConfig:getModuleBlock(itemId, moduleId, teamId)
    if not module then
        return
    end
    self.equipModuleIds[itemId] = moduleId
    self.siModuleImage:SetImage(module.image)
    self.btnChange:SetVisible(true)
end

local function isOnMount()
    local entityPlayer = PlayerManager:getClientPlayer().Player
    if not entityPlayer then
        return false
    end
    return entityPlayer:isOnFloatingMount() or entityPlayer:isOnFlyingMount()
end

function UIModuleBlockMainLayout:changeCurItemModule()
    local itemId = PlayerManager:getClientPlayer():getHeldItemId()
    if itemId == 0 then
        return
    end
    self.btnChange:SetVisible(false)
    local modules = ModuleBlockConfig:getModuleBlocks(itemId)
    if TableUtil.isEmpty(modules) then
        return
    end
    local moduleId = self.equipModuleIds[itemId] or ModuleBlockConfig:getDefaultModuleId(itemId)
    ---@type ModuleBlockData
    local nextModule
    for index, module in pairs(modules) do
        if module.id == moduleId then
            nextModule = modules[index + 1]
        end
    end
    if not nextModule then
        nextModule = modules[1]
    end
    self.equipModuleIds[itemId] = nextModule.id
    self.siModuleImage:SetImage(nextModule.image)
    self.btnChange:SetVisible(true)
    PlayerManager:getClientPlayer():sendPacket({
        pid = "ChangeModuleBlock",
        itemId = itemId,
        moduleId = self.equipModuleIds[itemId],
    })
end

function UIModuleBlockMainLayout:onShow()
    local itemId = PlayerManager:getClientPlayer().Player:getHeldItemId()
    if itemId == 0 then
        self:hide()
        return
    end
    if not isBlockItem(itemId) then
        self:hide()
    end
    if isGameEnd then
        self:hide()
    end
end

function UIModuleBlockMainLayout:onTick()
    if isGameEnd then
        self:hide()
    end
    local onMount = isOnMount()
    local showFrontPlace = Events.ShowFrontPlaceBlockEvent:invoke()
    self.btnFrontPlace:SetVisible(not onMount and showFrontPlace)
    local itemId = PlayerManager:getClientPlayer():getHeldItemId()
    if self.equipModuleIds[itemId] then
        self.btnChange:SetVisible(not onMount and showFrontPlace)
    else
        self.btnChange:SetVisible(false)
    end
    if self.longTouchClickFrontBuildButton then
        PlaceBlockHelper:onClickFrontBuildButton()
    end
end

return UIModuleBlockMainLayout
