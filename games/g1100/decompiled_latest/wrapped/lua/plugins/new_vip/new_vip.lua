--[[GtLePcPYDP0KGoNt9xSNEHLozhZFEJsyvC18vu4CtxW7kWNKhsoXTwL6GANgkBUpWogqBXuYxxxe9UAmToyrByGtzTXFx8B8SEimoUWZjgZkZj]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 7537
                          local checkFileName = "new_vip.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[cLzugjGE2MJxQNtAu3HKl40MOF]]--local new_vip = L("new_vip", {})
Plugins.new_vip = Plugins.new_vip or {}
local new_vip = Plugins.new_vip
new_vip.enterMsgQueue = new_vip.enterMsgQueue or {}
new_vip.bannerPos = { { 0, 0 }, { 0, 60 } }
new_vip.enterGameFont = "HT16"
new_vip.enterGameFontColor = { 0, 0, 0 }

local SHOW_BANNER_DELAY_TIME = 2 * 1000
local SHOW_BANNER_TIME = 20 * 10 -- *50ms
local SHOW_BANNER_MARGINS = 30
local PENDANT_SCALE = 1.25
local PENDANT_OFFSET = { x = 0, y = 0 }
local BANNER_SCALE = 1.8
local pendantSetting = {}

local function read_json_file(path)
    local file = io.open(path)
    if file then
        local content = file:read("*a")
        file:close()
        local data = json.decode(content)
        return data
    end
end

local function loadPendantAnims(name)
    name = string.match(name, "[%w_]+") -- 去掉后缀
    if not name then
        return
    end
    local setting = pendantSetting[name]
    if setting then
        return setting
    end
    name = name .. ".json" -- 加上.json
    local path = FileResourceManager.Instance():GetResourceLocalFullPath(name)
    if path == "" then
        LogUtil.logError("pendant json not found: " .. name)
        return nil
    end
    setting = read_json_file(path)
    pendantSetting[name] = setting
    return setting
end

local handlers = {}

function handlers.setHeadImagePendant(headImage, pendantName, isOldUi)
    local settings = loadPendantAnims(pendantName)
    if not settings then
        return
    end
    if isOldUi then
        local scale = settings.scale or PENDANT_SCALE
        local offset = settings.offset or PENDANT_OFFSET
        local name = headImage:GetName() .. "_pendant"
        local pendant = GUIManager:getWindowByName(name, GUIType.DynamicImage)
        if pendant then
            pendant:RemoveAllImage()
            pendant:SetVisible(true)
        else
            pendant = GUIManager:createGUIWindow(GUIType.DynamicImage, name)
            pendant:SetArea({ offset.x, 0 }, { offset.y, 0 }, { scale, 0 }, { scale, 0 })
            pendant:SetProperty("Material", "CullBackLinear")
            pendant:SetTouchable(false)
            pendant:SetHorizontalAlignment(1)
            pendant:SetVerticalAlignment(1)
            headImage:AddChildWindow(pendant)
        end
        for _, frame in pairs(settings.anim) do
            pendant:AddImage(frame.image, frame.duration)
        end
    end
end

function handlers.removeHeadImagePendant(headImage)
    local name = headImage:GetName() .. "_pendant"
    local pendant = GUIManager:getWindowByName(name, GUIType.DynamicImage)
    if pendant then
        pendant:RemoveAllImage()
    end
end

local showingBanner = false
new_vip.showNextBanner = function()
    if showingBanner then
        return
    end
    local msg = new_vip.enterMsgQueue[1]
    if not msg then
        return
    end

    local bannerName, textKey, name = msg[1], msg[2], msg[3]

    table.remove(new_vip.enterMsgQueue, 1)
    local settings = loadPendantAnims(bannerName)
    if not settings then
        return new_vip.showNextBanner()
    end

    showingBanner = true

    if not new_vip.banner then
        local rootWnd = GUISystem.Instance():GetRootWindow()
        -- create banner window
        local banner = GUIManager:createGUIWindow(GUIType.DynamicImage, "newvip_banner")
        banner:SetProperty("Material", "CullBackLinear")
        banner:SetAlwaysOnTop(true)
        banner:SetHorizontalAlignment(1)
        local textLayout = GUIManager:createGUIWindow(GUIType.Layout, "newvip_banner_layout")
        local text = GUIManager:createGUIWindow(GUIType.StaticText, "newvip_banner_text")
        text:SetProperty("Font", new_vip.enterGameFont)
        text:SetTextColor(new_vip.enterGameFontColor)
        --text:SetTextHorzAlign(1)
        text:SetVerticalAlignment(VerticalAlignment.Center)
        text:SetTextVertAlign(VerticalAlignment.Center)
        text:SetTouchable(false)
        text:SetArea({ 0, 0 }, { 0, 0 }, { 1, 0 }, { 0, 72 })
        textLayout:AddChildWindow(text)
        textLayout:SetTouchable(false)
        textLayout:SetArea({ 0, SHOW_BANNER_MARGINS }, { 0, 0 }, { 1, -SHOW_BANNER_MARGINS * 2 }, { 1, 0 })
        textLayout:SetClipChild(true)
        banner:SetTouchable(false)
        banner:AddChildWindow(textLayout)
        rootWnd:AddChildWindow(banner)
        new_vip.text = text
        new_vip.banner = banner
    end
    local banner = new_vip.banner
    local text = string.format(Lang:getString(textKey) or "", name or "")
    new_vip.text:SetText(text)
    local textString = new_vip.text:GetText()
    local textWidth = new_vip.text:GetFont():GetTextExtent(textString, 1)
    banner:SetArea(new_vip.bannerPos[1], new_vip.bannerPos[2], { 0, settings.width * BANNER_SCALE }, { 0, settings.height * BANNER_SCALE })
    banner:RemoveAllImage()
    for _, frame in pairs(settings.anim) do
        banner:AddImage(frame.image, frame.duration)
    end
    if not new_vip.enterMsgQueue[1] then
        -- ui visible again
        banner:SetVisible(true)
    end

    local posX = settings.width * BANNER_SCALE
    local posY = 0
    if string.find(bannerName, "vip_entergame_011") then
        posY = 40
    end
    new_vip.text:SetArea({ 0, posX }, { 0, posY }, { 0, textWidth }, { 0, 72 })
    new_vip.text:SetText(text)
    local moveSpeed = (textWidth + posX) / SHOW_BANNER_TIME
    if moveSpeed <= 0 then
        moveSpeed = 1
    end
    new_vip.bannerTimer = LuaTimer:scheduleTicker(function()
        posX = posX - moveSpeed
        if posX + textWidth > 0 then
            new_vip.text:SetArea({ 0, posX }, { 0, posY }, { 0, textWidth }, { 0, 72 })
            return
        end
        LuaTimer:cancel(new_vip.bannerTimer)
        showingBanner = false
        if not new_vip.enterMsgQueue[1] then
            new_vip.banner:SetVisible(false)
        else
            new_vip.showNextBanner()
        end
    end, 3, -1)
end

function handlers.showVipEnterBanner(bannerName, text, name)
    table.insert(new_vip.enterMsgQueue, { bannerName, text, name })
    new_vip.showNextBanner()
end

function handlers.onUserLogin(userId, enterAnnounce)
    if (enterAnnounce == "") then
        return
    end
    if not Events.AskIfShowEnterAnnounce:invoke() then
        return
    end
    local cache = UserInfoCache:GetCache(userId)
    local data = json.decode(enterAnnounce)
    LuaTimer:scheduleTimer(handlers.showVipEnterBanner, SHOW_BANNER_DELAY_TIME, 1, data.bg, data.lang_key, cache.nickName)
end

return function(name, ...)
    if type(handlers[name]) ~= "function" then
        return
    end
    handlers[name](...)
end
--[[ecfqIDnFPf5Jz0i4RFTWO4ZLfbxih1SFbl2iO1BtLYnW4iV76wEvMdYMn1]]---