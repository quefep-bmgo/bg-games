---@class RecorderUtil
local RecorderUtil = T(Global, "RecorderUtil")
RecorderUtil.isHideSelf = false
RecorderUtil.isHideOther = false
---@type ShellInterface
local ShellInterface = CGame.Instance():getShellInterface()
---@type ReportEvent
local ReportEvent = T(Global, "ReportEvent")

-- Called by app when video record finished
function onVideoRecordResult(result)
    local tip
    if result == 0 then
        tip = "gui.new_video.record_success"
    elseif result == 38 then
        tip = "gui.new_video.record_fail"
    elseif result == 48 then
        tip = "gui.new_video.record_memory"
        ReportEvent.reportEvent(Game:getPlatformUserId(), "error_storage")
    end
    if not tip then
        return
    end
    UIHelper.showToast(Lang:getString(tip), 3000)
end

function RecorderUtil:setHideName(hide)
    ClientHelper.putBoolPrefs("RenderHeadText", not hide)
    CEvents.RecorderHideHeadTextEvent:invoke(hide)
end

function RecorderUtil:setHidePlayerOnly(only)
    Blockman.Instance().m_gameSettings:setHidePlayerOnly(only)
end

function RecorderUtil:setHideSelf(hide)
    Blockman.Instance().m_gameSettings:setHideSelf(hide)
    CEvents.RecorderHideSelfEvent:invoke(hide)
    self.isHideSelf = hide
end

function RecorderUtil:setHideOtherPlayers(hide)
    Blockman.Instance().m_gameSettings:setHideOtherPlayers(hide)
    CEvents.RecorderHideOtherPlayersEvent:invoke(hide)
    self.isHideOther = hide
end

function RecorderUtil:setHideUi(hide)
    if self.hideUi == hide then
        return
    end
    self.hideUi = hide
    ClientHelper.putBoolPrefs("HideAllUI", hide)
    if hide then
        ClientHelper.putFloatPrefs("EngineUIAlphaX", 0)
        GUIManager:hideAllWindowsExcept(self.hideUiWhiteList or {})
    else
        ClientHelper.putFloatPrefs("EngineUIAlphaX", 1)
        GUIManager:restoreAllWindows()
    end
    GUIManager:setWindowsAlphaToZero(self.alphaTo0UiList or {}, hide)
end

function RecorderUtil:canUiShow(name)
    return (not self.hideUi) or self.hideUiWhiteList[name]
end

function RecorderUtil:addHideUiWhiteList(list)
    self.hideUiWhiteList = self.hideUiWhiteList or {}
    TableUtil.mergeArray(self.hideUiWhiteList, list)
end

function RecorderUtil:addAlphaToZeroUiList(list)
    self.alphaTo0UiList = self.alphaTo0UiList or {}
    TableUtil.mergeArray(self.alphaTo0UiList, list)
end

function RecorderUtil:printUiNames()
    local names = GUIManager:getAllWindowNames()
    for _, name in ipairs(names) do
        print(name)
    end
end

local weathers = {
    sunny = {
        skybox = "qing",
        effects = {
        },
    },
    rainy = {
        skybox = "yu",
        effects = {
            --"camera_effect_weather_rain_heavy.effect"
            "camera_effect_weather_rain.effect"
        },
    },
    snowy = {
        skybox = "xue",
        effects = {
            "camera_effect_weather_snow.effect"
        },
    },
    star = {
        skybox = "fanxing",
        effects = {
        },
    },
    sunset = {
        skybox = "wanxia",
        effects = {
        },
    },
}

function RecorderUtil:setWeather(id, disable)
    if disable then
        if not self.weatherId then
            return
        end
        self.weatherId = nil
        self:restoreSkyBox()
        self:removeWeatherEffects()
        return
    end

    if self.weatherId == id then
        return
    end
    self.weatherId = id

    self:updateSkyBox()
    self:updateWeatherEffect()
end

function RecorderUtil:IsUsingWeather()
    return self.weatherId ~= nil
end

function RecorderUtil:restoreSkyBox()
    HostApi.restoreSky(self.oldSkyType or 1)
end

function RecorderUtil:updateSkyBox()
    local cfg = weathers[self.weatherId or ""]
    if not cfg then
        return
    end

    if not self.oldSkyType then
        self.oldSkyType = HostApi.getSkyType()
        HostApi.backupSkyInfoList()
    end
    HostApi.setSky(cfg.skybox)
end

function RecorderUtil:removeWeatherEffects()
    BaseListener.unregisterCallBack(CEvents.GameMainTickEvent, self.onGameMainTick)

    for _, effectName in ipairs(self.weatherEffects or {}) do
        WorldEffectManager.Instance():removeSimpleEffect(effectName)
    end
    self.weatherEffects = {}
end

function RecorderUtil:updateWeatherEffect()
    self:removeWeatherEffects()

    local cfg = weathers[self.weatherId or ""]
    if not cfg or not next(cfg.effects or {}) then
        return
    end

    local camera = SceneManager.Instance():getMainCamera()
    local cp = camera:getPosition()
    local cdir = camera:getDirection()
    local pos = VectorUtil.newVector3(cp.x + cdir.x * 2, cp.y + cdir.y * 2, cp.z + cdir.z * 2)

    for _, effectName in ipairs(cfg.effects) do
        local effect = WorldEffectManager.Instance():addSimpleEffect(effectName, pos, 0, -1, 1, 1, 1)
        self.weatherEffects = self.weatherEffects or {}
        table.insert(self.weatherEffects, effect.mEffectName)
    end

    BaseListener.registerCallBack(CEvents.GameMainTickEvent, self.onGameMainTick)
end

local lastPos
function RecorderUtil.onGameMainTick()
    local camera = SceneManager.Instance():getMainCamera()
    local cp = camera:getPosition()
    local cdir = camera:getDirection()
    local pos = VectorUtil.newVector3(cp.x + cdir.x * 2, cp.y + cdir.y * 2, cp.z + cdir.z * 2)
    if lastPos and lastPos == pos then
        return
    end
    lastPos = pos
    for _, name in ipairs(RecorderUtil.weatherEffects) do
        local effect = WorldEffectManager:Instance():getSimpleEffect(name)
        if effect then
            effect.mPosition = pos
        end
    end
end

function RecorderUtil:playUiEffect(effectName, stop)
    self.uiEffects = self.uiEffects or {}
    if stop then
        local wnd = self.uiEffects[effectName]
        if not wnd then
            return
        end
        TableUtil.tableRemove(self.hideUiWhiteList, effectName)
        GUIManager:destroyGUIWindow(wnd)
        self.uiEffects[effectName] = nil
        return
    end

    if self.uiEffects[effectName] then
        return
    end

    self:removeAllUiEffects()
    table.insert(self.hideUiWhiteList, effectName)
    local wnd = GUIManager:createGUIWindow("Layout", effectName)
    GUISystem.Instance():GetRootWindow():AddChildWindow(wnd)
    wnd:SetArea({0, 0}, {-0.5, 0}, {1, 0}, {1, 0})
    wnd:SetTouchable(false)
    wnd:SetEffectName(effectName)
    wnd:SetEffectScale(VectorUtil.newVector2(1, 1.8))
    self.uiEffects[effectName] = wnd
    wnd:PlayEffect(math.huge)
end

function RecorderUtil:removeAllUiEffects()
    for name in pairs(self.uiEffects or {}) do
        TableUtil.tableRemove(self.hideUiWhiteList, name)
        self:playUiEffect(name, true)
    end
    self.uiEffects = {}
end

local bloomSettings = {
    enable = true,
    enableFullScreen = true,
    threshold = 0.75,
    saturation = 0.552,
    intensity = 2.098,
    blurDeviation = 2.587,
    blurMultiplier = 1.399,
}
function RecorderUtil:enableFilterLightBlur(disable)
    if self.filterLightBlurDisabled == disable then
        return
    end
    self.filterLightBlurDisabled = disable

    local bm = Blockman.Instance()
    local settings = self.oldBloomSettings or {}
    if not disable then -- save old
        self.oldBloomSettings = {
            enable = bm:getBloomEnable(),
            enableFullScreen = bm:getEnableFullscreenBloom(),
            threshold = bm:getBloomThreshold(),
            saturation = bm:getBloomSaturation(),
            intensity = bm:getBloomIntensity(),
            blurDeviation = bm:getBloomBlurDeviation(),
            blurMultiplier = bm:getBloomBlurMultiplier(),
        }
        settings = bloomSettings
    end

    bm:setBloomEnable(settings.enable or false)
    bm:enableFullscreenBloom(settings.enableFullScreen or false)
    bm:setBloomThreshold(settings.threshold or 0)
    bm:setBloomSaturation(settings.saturation or 0)
    bm:setBloomIntensity(settings.intensity or 0)
    bm:setBloomBlurDeviation(settings.blurDeviation or 0)
    bm:setBloomBlurMultiplier(settings.blurMultiplier or 0)
end

function RecorderUtil:enablePatternTorch(disable)
    local strength = disable and 0 or 1
    Blockman.Instance().m_gameSettings:setPatternTorchStrength(strength)
end

function RecorderUtil:enableSpeedLine(disable)
    local strength = disable and 0 or 1
    local interval = 0.1
    Blockman.Instance().m_gameSettings:setPatternSpeedLine(strength, interval)
end

function RecorderUtil:enableTopBottomCover(disable)
    local height = disable and 0 or 0.122
    local colorRGBA = {}
    Blockman.Instance().m_gameSettings:setTopBottomCoverHeight(height)
    if next(colorRGBA or {}) then
        Blockman.Instance().m_gameSettings:setTopBottomCoverColor(table.unpack(colorRGBA))
    end
end

function RecorderUtil:videoRecordStart()
    ShellInterface:videoRecordStart()
end

function RecorderUtil:videoRecordStop()
    ShellInterface:vidoeRecordStop()
end

function RecorderUtil:isVideoRecordRecording()
    return ShellInterface:isVideoRecordRecording()
end

function RecorderUtil:isVideoRecordSupported()
    return ShellInterface:isVideoRecordSupported()
end
