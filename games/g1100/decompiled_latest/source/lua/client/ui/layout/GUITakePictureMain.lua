---@class UITakePictureMainLayout : IGUILayout
local UITakePictureMainLayout = class("UITakePictureMainLayout", IGUILayout)
---@type RecorderUtil
local RecorderUtil = T(Global, "RecorderUtil")

---@private
function UITakePictureMainLayout:ctor()
    self.super.ctor(self, "TakePictureMain.json", GUIManager:getMainControl())
end

---@private
function UITakePictureMainLayout:isDelayLoad()
    return true
end

---@private
function UITakePictureMainLayout:onCreate()
    self:initCreateEvent()
end

---@private
function UITakePictureMainLayout:initCreateEvent()

end

---@private
function UITakePictureMainLayout:onLoad()
    self.startPos = {}
    self.lockCameraTag = {}
    self.btnTake = self:getChildWindow("TakePictureMain-Take", GUIType.Button)
    self.btnCancel = self:getChildWindow("TakePictureMain-Cancel", GUIType.Button)
    self.stTitle = self:getChildWindow("TakePictureMain-Title", GUIType.StaticText)
    self:initView()
    self:initEvent()
end

---@private
function UITakePictureMainLayout:initView()
    self.stTitle:SetText(Lang:getString("gui.take.picture.title"))
end

---@private
function UITakePictureMainLayout:initEvent()
    self.btnTake:registerEvent(GUIEvent.ButtonClick, function()
        self:tryTakePicture()
        SoundUtil.clickUI()
    end)
    self.btnCancel:registerEvent(GUIEvent.ButtonClick, function()
        local result = {
            code = -1,
            msg = ""
        }
        ClientHelper.onAppActionTrigger(CDefine.AppActionType.APP_ACTION_CUSTOM_TAKE_PICTURE, json.encode(result))
        local player = PlayerManager:getClientPlayer()
        player:sendPacket({
            pid = "takePictureStatus",
            userId = player.userId,
            status = false
        })
        self:hide()
        SoundUtil.clickUI()
    end)
end

function UITakePictureMainLayout:onShow()
    local customGame = T(Global, "customGame")
    customGame:initEditModeSkyBox(true)
    customGame:initEditModeVisualHelpBox(true)

    GUIManager:hideWindowByName("ToolBar.json")
    self:lockCamera(1, "take_picture")
    PlayerManager:getClientPlayer().Player:setCameraLocked(true)
    ClientHelper.putBoolPrefs("IsViewBobbing", false)
    self.startPos = PlayerManager:getClientPlayer():getPosition()
    self.isFlying = PlayerManager:getClientPlayer().Player:getIsFlying()
end

function UITakePictureMainLayout:onHide()
    local customGame = T(Global, "customGame")
    customGame:initEditModeSkyBox(false)
    customGame:initEditModeVisualHelpBox(false)

    GUIManager:showWindowByName("ToolBar.json")
    self:releaseCamera("take_picture")
    PlayerManager:getClientPlayer().Player:setCameraLocked(false)
    ClientHelper.putBoolPrefs("IsViewBobbing", true)
    PlayerManager:getClientPlayer().Player:setPosition(self.startPos)
    PlayerManager:getClientPlayer().Player:setFlying(self.isFlying)
end

function UITakePictureMainLayout:tryTakePicture()
    GUISystem.Instance():GetRootWindow():SetVisible(false)
    Blockman.Instance():hideGui()
    local result = {
        code = 1,
        msg = ""
    }
    ClientHelper.onAppActionTrigger(CDefine.AppActionType.APP_ACTION_CUSTOM_TAKE_PICTURE, json.encode(result))
    if isLocalWin then
        self:addTimer(LuaTimer:schedule(function()
            CEvents.GameActionTriggerEvent:invoke(CDefine.GameActionType.GAME_ACTION_CUSTOM_ROOM_TAKE_PICTURE,
                        "end")
        end, 2000))
    end
end

function UITakePictureMainLayout:lockCamera(view, key)
    self.lockCameraTag[key] = view
    Blockman.Instance():setPersonView(view)
    RecorderUtil:setHideName(true)
    RecorderUtil:setHideSelf(true)
    RecorderUtil:setHidePlayerOnly(true)
    RecorderUtil:setHideOtherPlayers(true)
end

function UITakePictureMainLayout:releaseCamera(key)
    self.lockCameraTag[key] = nil
    if next(self.lockCameraTag) then
        return
    end
    RecorderUtil:setHideName(false)
    RecorderUtil:setHideSelf(false)
    RecorderUtil:setHidePlayerOnly(false)
    RecorderUtil:setHideOtherPlayers(false)
end

return UITakePictureMainLayout
