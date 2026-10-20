local CustomGame = {}

local UGCExtraConfig = require "base.config.UGCExtraConfig"
local SafeCallUtil = require "base.util.SafeCallUtil"

function CustomGame:init()
    isGameEnd = true
    isGameStart = false
    self.settingCache = {}
end

function CustomGame:setGameInfo(gameInfo)
    print("CustomGame:setGameInfo() " .. StringUtil.v2s(gameInfo))
    self.gameMode = gameInfo.mode
    if self.gameMode == Define.CustomGameMode.PVP then
        self:showRealTimeRank()
    end

    if self.gameMode == Define.CustomGameMode.RUN then
        isGameStart = false
        isGameEnd = true
    else
        isGameStart = true
        isGameEnd = false
    end

    self.settingCache = gameInfo.setting
    self.globalSetting = gameInfo.globalSetting
    if not self.globalSetting then 
        self.globalSetting = {}
    end

    self.ugcSetting = gameInfo.ugcSetting

    self.ugcExtraConfig = UGCExtraConfig.new()
    self.ugcExtraConfig:loadTableConfig(gameInfo.ugcExtraConfig)

    if self.ugcExtraConfig.isOldSo then
        local player = PlayerManager:getClientPlayer()
        local entityPlayer = player and (player.Player or player)
        if entityPlayer then
            entityPlayer:setWatchMode(true)
        end
        player:sendPacket({
            pid = "oldSoSetWatchMode"
        })
    end

    if self.gameMode == Define.CustomGameMode.EDIT and self.ugcExtraConfig.isEditable then
        SoundUtil.playSound(SoundType.EditModeBgm)
        self:initEditModeSkyBox(false)
    end

    self:initEditModeVisualHelpBox(false)

    if (self.globalSetting[Define.CustomRoomSettingType.UNLIMIT_ITEM] == nil
        or self.globalSetting[Define.CustomRoomSettingType.UNLIMIT_ITEM])
        and self.settingCache[Define.CustomRoomSettingType.UNLIMIT_ITEM] then
        self:showCreativeBag()
    else
        self:HideCreativeBag()
    end

    if self.settingCache[Define.CustomRoomSettingType.FOOD] then 
        self:showHealthUI()
        self:showFoodUI()
    else
        self:hideHealthUI()
        self:hideFoodUI()
    end
    local window = GUIManager:getWindowByName("Main-Gun-Operate-AimBtn", GUIType.Button)
    if window then
        window:SetXPosition({0,-120})
        window:SetYPosition({-0.46,0})
    end
    
    window = GUIManager:getWindowByName("Main-Gun-Operate-CancelAimBtn", GUIType.Button)
    if window then
        window:SetXPosition({0,-120})
        window:SetYPosition({-0.46,0})
    end
end

function CustomGame:showRealTimeRank()
    local window = GUIManager:getWindowByName("ToolBar-Real-Time-Rank-Btn", GUIType.Button)
    if window then
        window:SetVisible(true)
    end
    local VersionCode = tonumber(GameAnalyticsCache:getClientInfo().version_code) or 0
    if isLocalWin or (not Game:isEnableIndie() and VersionCode > 5261) or (Platform.isMacOSX() and VersionCode > 5252) then
        RootGuiLayout.Instance():showRealTimeRank()
        RootGuiLayout.Instance():isColseRealTimeRank(true)
    end
end

function CustomGame:initEditModeSkyBox(take)
    local skyBoxConfig = Global.setting.SkyBoxConfig
    if take then
        HostApi.restoreSky(skyBoxConfig.nor_sky.skyType)
    else
        HostApi.backupSkyInfoList()
        HostApi.setSky(skyBoxConfig.edit_sky.skyboxName)
    end
end

function CustomGame:initEditModeVisualHelpBox(take)
    if self.ugcExtraConfig.isEditable then
        local globalRender = Blockman.Instance().m_globalRender
        SafeCallUtil.tryCallMethodWithSelf(globalRender, "setEditBoxLineWidth", 10)
        SafeCallUtil.tryCallMethodWithSelf(globalRender, "clearEditBox")
        if not take then
            if self.ugcExtraConfig.hasEditArea then
                local min_pos, max_pos = CustomRoomUtil.toBoxMinMax(self.ugcExtraConfig.initBlockPos, self.ugcExtraConfig.buildSize)
                SafeCallUtil.tryCallMethodWithSelf(globalRender, "addEditBox", min_pos, max_pos, Color.GREEN)
            end
        end
        SafeCallUtil.tryCallMethodWithSelf(globalRender, "drawEditBox")
    end
end

function CustomGame:showCreativeBag()
    local windowBlockBag = GUIManager:getWindowByName("ArmorPanel-Inventory-Radio-CreativeBlock", GUIType.RadioButton)
    if windowBlockBag then
        windowBlockBag:SetVisible(true)
    end

    local windowItemBag = GUIManager:getWindowByName("ArmorPanel-Inventory-Radio-CreativeItem", GUIType.RadioButton)
    if windowItemBag then
        windowItemBag:SetVisible(true)
    end
end

function CustomGame:HideCreativeBag()
    local windowBlockBag = GUIManager:getWindowByName("ArmorPanel-Inventory-Radio-CreativeBlock", GUIType.RadioButton)
    if windowBlockBag then
        windowBlockBag:SetVisible(false)
    end

    local windowItemBag = GUIManager:getWindowByName("ArmorPanel-Inventory-Radio-CreativeItem", GUIType.RadioButton)
    if windowItemBag then
        windowItemBag:SetVisible(false)
    end

    local windowAll = GUIManager:getWindowByName("ArmorPanel-Inventory-Radio-All", GUIType.RadioButton)
    if windowAll then
        windowAll:SetSelected(true)
    end
end

function CustomGame:hideFoodUI()

    local windowValue = GUIManager:getWindowByName("PlayerInfo-FoodSaturation-Value", GUIType.ProgressBar)
    if windowValue then
        windowValue:SetVisible(false)
    end

    local windowNumber = GUIManager:getWindowByName("PlayerInfo-FoodSaturation-Number", GUIType.StaticText)
    if windowNumber then
        windowNumber:SetVisible(false)
    end

    local windowBar = GUIManager:getWindowByName("PlayerInfo-FoodSaturation", GUIType.Layout)
    if windowBar then
        windowBar:SetVisible(false)
    end

    local windowHealthIcon = GUIManager:getWindowByName("PlayerInfo-FoodSaturation-Icon", GUIType.StaticImage)
    if windowHealthIcon then
        windowHealthIcon:SetVisible(false)
    end

end

function CustomGame:showFoodUI()
    local windowValue = GUIManager:getWindowByName("PlayerInfo-FoodSaturation-Value", GUIType.ProgressBar)
    if windowValue then
        windowValue:SetVisible(true)
    end

    local windowNumber = GUIManager:getWindowByName("PlayerInfo-FoodSaturation-Number", GUIType.StaticText)
    if windowNumber then
        windowNumber:SetVisible(true)
    end

    local windowBar = GUIManager:getWindowByName("PlayerInfo-FoodSaturation", GUIType.Layout)
    if windowBar then
        windowBar:SetVisible(true)
    end

    local windowHealthIcon = GUIManager:getWindowByName("PlayerInfo-FoodSaturation-Icon", GUIType.StaticImage)
    if windowHealthIcon then
        windowHealthIcon:SetVisible(true)
    end
end

function CustomGame:hideHealthUI()
    local windowValue = GUIManager:getWindowByName("PlayerInfo-Health-Value", GUIType.ProgressBar)
    if windowValue then
        windowValue:SetVisible(false)
    end

    local windowNumber = GUIManager:getWindowByName("PlayerInfo-Health-Number", GUIType.StaticText)
    if windowNumber then
        windowNumber:SetVisible(false)
    end

    local windowBar = GUIManager:getWindowByName("PlayerInfo-HeartBar", GUIType.Layout)
    if windowBar then
        windowBar:SetVisible(false)
    end

    local windowHealthIcon = GUIManager:getWindowByName("PlayerInfo-Health-Icon", GUIType.StaticImage)
    if windowHealthIcon then
        windowHealthIcon:SetVisible(false)
    end
end

function CustomGame:showHealthUI()
    local windowValue = GUIManager:getWindowByName("PlayerInfo-Health-Value", GUIType.ProgressBar)
    if windowValue then
        windowValue:SetVisible(true)
    end

    local windowNumber = GUIManager:getWindowByName("PlayerInfo-Health-Number", GUIType.StaticText)
    if windowNumber then
        windowNumber:SetVisible(true)
    end

    local windowBar = GUIManager:getWindowByName("PlayerInfo-HeartBar", GUIType.Layout)
    if windowBar then
        windowBar:SetVisible(true)
    end

    local windowHealthIcon = GUIManager:getWindowByName("PlayerInfo-Health-Icon", GUIType.StaticImage)
    if windowHealthIcon then
        windowHealthIcon:SetVisible(true)
    end
end

function CustomGame:needShowRealTimeRank()
    return self.gameMode and self.gameMode == Define.CustomGameMode.PVP
end

function CustomGame:getFastBreakBlock()
    return self.settingCache[Define.CustomRoomSettingType.FAST_BREAK_BLOCK] or false
end

function CustomGame:updateCustomGlobalPermSetting(data)
    local newSetting = data.setting
    local userName = data.userName
    for i, v in pairs(newSetting) do
        if self.globalSetting[i] ~= v then 
            self:notifyGlobalPermSettingChanged(userName, i, v)
        end
    end

    self.globalSetting = newSetting

    if (self.globalSetting[Define.CustomRoomSettingType.UNLIMIT_ITEM] and
        self.settingCache[Define.CustomRoomSettingType.UNLIMIT_ITEM]) then
        self:showCreativeBag()
    else
        self:HideCreativeBag()
    end

end

function CustomGame:updateCustomRoomPermFromUser(data)
    local fromUser = data.editor
    local newSetting = data.perms

    local notifyFunc = function(i, v)
        self:notifySettingsChangeV2(fromUser, i, v)
    end
    self:updateCustomRoomPermSetting(newSetting, notifyFunc)
end

function CustomGame:updateCustomRoomPermSetting(newSetting, notifyFunc)
    if not notifyFunc then 
        notifyFunc = function(i, v)
            self:notifySettingsChangedV1(i, v)
        end
    end

    for i, v in pairs(newSetting) do
        if self.settingCache[i] ~= v then 
            notifyFunc(i, v)
        end
    end

    self.settingCache = newSetting

    if self.settingCache[Define.CustomRoomSettingType.FOOD] then 
        self:showHealthUI()
        self:showFoodUI()
    else
        self:hideHealthUI()
        self:hideFoodUI()
    end

    --print("updateCustomRoomPermSetting 01"..StringUtil.v2s(newSetting, 10))
    --print("updateCustomRoomPermSetting 01"..StringUtil.v2s(self.globalSetting, 10))
    
    if (self.globalSetting[Define.CustomRoomSettingType.UNLIMIT_ITEM] == nil
        or self.globalSetting[Define.CustomRoomSettingType.UNLIMIT_ITEM])
        and self.settingCache[Define.CustomRoomSettingType.UNLIMIT_ITEM] then
        self:showCreativeBag()
    else
        self:HideCreativeBag()
    end
end

-- 第二个版本 单个玩家被管理员修改权限后的通知
-- 格式： %s 打开了（关闭了）你的 %s  权限
function CustomGame:notifySettingsChangeV2(userName, setting, value)
    local msgContent = ""

    if value then 
        msgContent = Lang:getString("setting.notice.private.perm.open")
    else
        msgContent = Lang:getString("setting.notice.private.perm.close")
    end


    local perm = ""
    if setting == Define.CustomRoomSettingType.PVP then
        perm = Lang:getString("setting.permission.pvp")
    elseif setting == Define.CustomRoomSettingType.FLY then
        perm = Lang:getString("setting.permission.fly")
    elseif setting == Define.CustomRoomSettingType.PLACE_BLOCK then 
        perm = Lang:getString("setting.permission.place.block")   
    elseif setting == Define.CustomRoomSettingType.BREAK_BLOCK then
        perm = Lang:getString("setting.permission.break.block")
    elseif setting == Define.CustomRoomSettingType.FOOD then
        perm = Lang:getString("setting.permission.blood.food")
    elseif setting == Define.CustomRoomSettingType.FAST_BREAK_BLOCK then
        perm = Lang:getString("setting.permission.fast.break.block")
    elseif setting == Define.CustomRoomSettingType.UNLIMIT_ITEM then
        perm = Lang:getString("setting.permission.unlimit.item")
    elseif setting == Define.CustomRoomSettingType.SPECIAL_BLOCK then
        perm = Lang:getString("setting.permission.special.block")
    elseif setting == Define.CustomRoomSettingType.DROP_ITEM_ON_DIE then
        perm = Lang:getString("setting.permission.drop.item.on.die")
    elseif setting == Define.CustomRoomSettingType.CAN_USE_GUN then
        perm = Lang:getString("setting.permission.can.use.gun")
    end

    local msg = string.format(msgContent, userName, perm)
    HostApi.sendMsg(0, 0, msg)
end

-- 第一个版本 全房间公用权限被改的通知
function CustomGame:notifySettingsChangedV1(setting, value)

    local msgEnd =".open"

    if setting == Define.CustomRoomSettingType.BREAK_BLOCK then 
        if not value then  -- 多语言配反了 这里改起来方便点
            msgEnd = ".open"
        else
            msgEnd = ".close"
        end
    else
    
        if value then 
            msgEnd = ".open"
        else
            msgEnd = ".close"
        end
    end

    local msgContent = ""
    if setting == Define.CustomRoomSettingType.PVP then
        msgContent = Lang:getString("setting.notice.pvp"..msgEnd)
    elseif setting == Define.CustomRoomSettingType.FLY then
        msgContent = Lang:getString("setting.notice.fly"..msgEnd)
    elseif setting == Define.CustomRoomSettingType.PLACE_BLOCK then 
        msgContent = Lang:getString("setting.notice.place.block"..msgEnd)   
    elseif setting == Define.CustomRoomSettingType.BREAK_BLOCK then
        msgContent = Lang:getString("setting.notice.break.block"..msgEnd)
    elseif setting == Define.CustomRoomSettingType.FOOD then
        msgContent = Lang:getString("setting.notice.blood.food"..msgEnd)
    elseif setting == Define.CustomRoomSettingType.FAST_BREAK_BLOCK then
        msgContent = Lang:getString("setting.notice.fast.break.block"..msgEnd)
    elseif setting == Define.CustomRoomSettingType.UNLIMIT_ITEM then
        msgContent = Lang:getString("setting.notice.unlimit.item"..msgEnd)
    elseif setting == Define.CustomRoomSettingType.DROP_ITEM_ON_DIE then
        msgContent = Lang:getString("setting.notice.drop.item.on.die"..msgEnd)
    elseif setting == Define.CustomRoomSettingType.CAN_USE_GUN then
        msgContent = Lang:getString("setting.notice.can.use.gun"..msgEnd)
    end

    HostApi.sendMsg(0, 0, msgContent)
end

function CustomGame:roleTypeToName(type)
    if type == Define.CustomGamePermissionRole.Owner then
        return Lang:getString("setting.role.owner")
    elseif type == Define.CustomGamePermissionRole.Admin then
        return Lang:getString("setting.role.admin")
    elseif type == Define.CustomGamePermissionRole.Member then
        return Lang:getString("setting.role.member") 
    elseif type == Define.CustomGamePermissionRole.Guest then
        return Lang:getString("setting.role.guest")
    elseif type == Define.CustomGamePermissionRole.UDefine then
        return Lang:getString("setting.role.custom")
    end
end

-- %s 被 %s 设置为 %s
function CustomGame:updateCustomRoomRoleType(data)
    local userName = data.userName
    local fromType = data.fromType
    local oldType = data.oldType
    local newType = data.newType

    local fromTypeName =  self:roleTypeToName(fromType)
    local newTypeName = self:roleTypeToName(newType)
    
    local msg = string.format(Lang:getString("notice.word.set.role"), userName, fromTypeName, newTypeName)

    HostApi.sendMsg(0, 0, msg)
end

-- %s 允许/禁止 %s
function CustomGame:notifyGlobalPermSettingChanged(userName, setting, value)
    local msgContent = ""

    if  value then  -- app设置跟实际相反
        msgContent = Lang:getString("setting.notice.word.global.allow")
    else
        msgContent=  Lang:getString("setting.notice.word.global.disable")
    end
    
    local action = ""
    if setting == Define.CustomRoomSettingType.PVP then
        action = Lang:getString("setting.permission.pvp")
    elseif setting == Define.CustomRoomSettingType.FLY then
        action = Lang:getString("setting.permission.fly")
    elseif setting == Define.CustomRoomSettingType.BREAK_BLOCK then
        action = Lang:getString("setting.permission.break.block")
    elseif setting == Define.CustomRoomSettingType.UNLIMIT_ITEM then
        action = Lang:getString("setting.permission.unlimit.item")
    elseif setting == Define.CustomRoomSettingType.DROP_ITEM_ON_DIE then
        action = Lang:getString("setting.permission.drop.item.on.die")
    elseif setting == Define.CustomRoomSettingType.CAN_USE_GUN then
        action = Lang:getString("setting.permission.can.use.gun")
    end

    local msg = string.format(msgContent, userName, action)
    HostApi.sendMsg(0, 0, msg)
end
-- %s 将房主转移给了 %s
function CustomGame:notifyExchangeOwner(oldOwnerName, newOwnerName)
    local msgContent = string.format(Lang:getString("notice.word.exchangeowner"), oldOwnerName, newOwnerName)
    HostApi.sendMsg(0, 0, msgContent)
end

function CustomGame:getPermissionSetting(perm)
    return self.settingCache[perm]
end

function CustomGame:showBlockSign(blockPos, txt)
    UIHelper.showGameGUILayout("GUIUpdateBlockSign", {blockPos = blockPos, txt = txt})
end

function CustomGame:getRespawnTime()
    if self.ugcSetting and self.ugcSetting.gameSetting then
        return self.ugcSetting.gameSetting.RespawnTime
    end
    return 0
end

function CustomGame:onPlayerDeath(player)
    if self.gameMode == Define.CustomGameMode.PVP then
        local gui_mainControl = DynamicCastHelper.dynamicCastGuiMainControl(RootGuiLayout.Instance():getLayout(0))
        if gui_mainControl then
            gui_mainControl:onCancelAim()
        end
    end
end

function CustomGame:setEditAreaBlockNum(blockNum)
    if self.ugcExtraConfig.hasEditArea then
        self.ugcExtraConfig.blockNum = blockNum
    end
end

CustomGame:init()
return CustomGame