---@class UICustomGameToolBarLayout : IGUILayout
local UICustomGameToolBarLayout = class("UICustomGameToolBarLayout", IGUILayout)
---@type UICustomGameMainLayout
local GUIMain = UIHelper.newGameGUILayout("GUICustomGameMain")

local customGame = T(Global, "customGame")

local DefaultIcon = "default_headshot.png"

---@private
function UICustomGameToolBarLayout:ctor(parent)
    self.super.ctor(self, "CustomGameToolBar.json", GUIManager:getToolBar())
end

---@private
function UICustomGameToolBarLayout:isDelayLoad()
    return true
end

---@private
function UICustomGameToolBarLayout:onCreate()
    self:initCreateEvent()
end

---@private
function UICustomGameToolBarLayout:initCreateEvent()
end

---@private
function UICustomGameToolBarLayout:onLoad()
    self.startTime = 0
    self.rebirthTime = 0
    self.showKilledInfoTime = 0
    self.showKillInfoTime = 0

    self.btnRank = self:getChildWindow("CustomGameToolBar-Rank", GUIType.Button)

    self.siTime = self:getChildWindow("CustomGameToolBar-Time", GUIType.StaticImage)
    self.stTimeText = self:getChildWindow("CustomGameToolBar-Time-Text", GUIType.StaticText)

    self.siGameType = self:getChildWindow("CustomGameToolBar-Game-Type", GUIType.StaticImage)
    self.stGameTypeDesc = self:getChildWindow("CustomGameToolBar-Game-Type-Desc", GUIType.StaticText)

    self.stRebirthBG = self:getChildWindow("CustomGameToolBar-Rebirth-BG", GUIType.StaticImage)
    self.stRebirthTip = self:getChildWindow("CustomGameToolBar-Rebirth", GUIType.StaticText)

    self.siTeamFlag = self:getChildWindow("CustomGameToolBar-Team-Flag", GUIType.StaticImage)
    self.stTeamText = self:getChildWindow("CustomGameToolBar-Team-Text", GUIType.StaticText)

    self.lEditView = self:getChildWindow("CustomGameToolBar-Edit-Info-View", GUIType.Layout)
    self.stEditTitle = self:getChildWindow("CustomGameToolBar-Edit-Info-Title", GUIType.StaticText)
    self.stEditSize = self:getChildWindow("CustomGameToolBar-Edit-Info-Size", GUIType.StaticText)
    self.stEditNum = self:getChildWindow("CustomGameToolBar-Edit-Info-Num", GUIType.StaticText)
    self.bEditBtn = self:getChildWindow("CustomGameToolBar-Edit-Info-Btn", GUIType.Button)
    self.siEditArraw = self:getChildWindow("CustomGameToolBar-Edit-Info-Arraw", GUIType.StaticImage)

    self.lKillInfo = self:getChildWindow("CustomGameToolBar-Kill-Info", GUIType.Layout)
    self.uiKillSelfIcon = self:getChildWindow("CustomGameToolBar-Kill-Self-Icon", GUIType.UrlImage)
    self.stKillSelfName = self:getChildWindow("CustomGameToolBar-Kill-Self-Name", GUIType.StaticText)
    self.uiKillOtherIcon = self:getChildWindow("CustomGameToolBar-Kill-Other-Icon", GUIType.UrlImage)
    self.stKillOtherName = self:getChildWindow("CustomGameToolBar-Kill-Other-Name", GUIType.StaticText)

    self.lKilledInfo = self:getChildWindow("CustomGameToolBar-Killed-Info", GUIType.Layout)
    self.uiKilledOtherIcon = self:getChildWindow("CustomGameToolBar-Killed-Other-Icon", GUIType.UrlImage)
    self.stKilledText = self:getChildWindow("CustomGameToolBar-Killed-Self-Text", GUIType.StaticText)

    self.stAppUpdateBG = self:getChildWindow("CustomGameToolBar-AppUpdate-BG", GUIType.StaticImage)
    self.stAppUpdateTip = self:getChildWindow("CustomGameToolBar-AppUpdate", GUIType.StaticText)

    self:initView()
    self:initEvent()
end

---@private
function UICustomGameToolBarLayout:initView()
    self.stTimeText:SetText(Lang:getString(""))
    self.btnRank:SetText(Lang:getString("gui_rank_button"))
    self.btnRank:SetVisible(false)
    self.siTime:SetVisible(false)
    self.siGameType:SetVisible(false)
    self.stRebirthBG:SetVisible(false)
    self.siTeamFlag:SetVisible(false)
    self.lEditView:SetVisible(false)
    self.lKillInfo:SetVisible(false)
    self.lKilledInfo:SetVisible(false)
    self.stAppUpdateBG:SetVisible(false)
end

---@private
function UICustomGameToolBarLayout:initEvent()
    self.btnRank:registerEvent(GUIEvent.ButtonClick, function()
        GUIMain:onRankBtnClick()
    end)
    self.bEditBtn:registerEvent(GUIEvent.ButtonClick, function()
        if self.showEditView and self:_needShowEditView() then
            self:_hideEditView()
        else
            self:_showEditView()
        end
    end)
end

function UICustomGameToolBarLayout:onTick(frameTime, renderDt)
    if self.startTime > 0 then
        local sec = math.max(self.startTime - os.time(), 0)
        if self.lastSec ~= sec then
            self.lastSec = sec
            if self.isGameRunning then
                self.stTimeText:SetText(DateUtil.getFormatTime(sec, "mm:ss"))
            else
                self.stTimeText:SetText(Lang:format("gui.game.end", sec))
                if self.lastSec <= 0 then
                    self.startTime = 0
                    self:onGameReset()
                end
            end
        end
    end

    if self.rebirthTime > 0 then
        local sec = math.max(self.rebirthTime - os.time(), 0)
        if self.lastRebirthSec ~= sec then
            self.lastRebirthSec = sec
            if self.isGameRunning then
                self.stRebirthTip:SetText(Lang:format("gui.text.rebirth", sec))
            end
            if self.lastRebirthSec <= 0 then
                self.rebirthTime = 0
                self.stRebirthBG:SetVisible(false)
            end
        end
    end

    if self.showKilledInfoTime > 0 then
        local sec = math.max(self.showKilledInfoTime - os.time(), 0)
        if self.lastKilledSec ~= sec then
            self.lastKilledSec = sec
            if self.lastKilledSec <= 0 then
                self.showKilledInfoTime = 0
                self.lKilledInfo:SetVisible(false)
            end
        end
    end

    if self.showKillInfoTime > 0 then
        local sec = math.max(self.showKillInfoTime - os.time(), 0)
        if self.lastKillSec ~= sec then
            self.lastKillSec = sec
            if self.lastKillSec <= 0 then
                self.showKillInfoTime = 0
                self.lKillInfo:SetVisible(false)
            end
        end
    end

    if self.watchWindow then
        self.watchWindow:SetVisible(false)
    end
end

function UICustomGameToolBarLayout:setGameInfo(gameInfo)
    self.lEditView:SetVisible(false)
    if gameInfo.mode == Define.CustomGameMode.EDIT or gameInfo.mode == Define.CustomGameMode.CREATIVE then
        if self:_needShowEditView() then
            self.lEditView:SetVisible(true)
            self.stEditTitle:SetText(Lang:format("custom_room_ugc_info_title", Lang:getString("custom_room_ugc_info_" .. customGame.ugcExtraConfig.secondaryTag)))
            local buildSize = customGame.ugcExtraConfig.buildSize
            self.stEditSize:SetText(Lang:format("custom_room_ugc_info_size", buildSize.x, buildSize.y, buildSize.z))
            self:updateEditViewBlockNum()
            self:_showEditView()
        end
        if not customGame.ugcExtraConfig.isEditable then
            self.watchWindow = GUIManager:getWindowByName("Main-Watch-Battle-Tip", GUIType.DefaultWindow)
        end
        if customGame.ugcExtraConfig.isOldSo then
            self.stAppUpdateBG:SetVisible(true)
            self.stAppUpdateTip:SetText(Lang:getString("gui_app_update_tip"))
        end
    end
end

function UICustomGameToolBarLayout:onGameStart(teamId, gameEndTime)
    self.siTime:SetVisible(true)
    self.siGameType:SetVisible(true)
    self.stGameTypeDesc:SetVisible(true)
    self.stRebirthBG:SetVisible(false)
    self.siTeamFlag:SetVisible(false)
    self.lKillInfo:SetVisible(false)
    self.lKilledInfo:SetVisible(false)

    local customGame = T(Global, "customGame")
    if not customGame.ugcSetting then
        return
    end

    local winInfo = customGame.ugcSetting.winCondition
    local teamCount = customGame.ugcSetting.teamSetting.teamCount

    self.overCondition = winInfo.type
    self.isGameRunning = true
    isGameEnd = false
    isGameStart = true
    self.startTime = os.time() + gameEndTime
    local setting = nil
    for i, v in pairs(Global.setting.gameTypeSetting) do
        if v.type == winInfo.type then
            setting = v
            break
        end
    end
    if not setting then
        return
    end

    if winInfo.type == Define.OverCondition.KillNum then
        self.siGameType:SetImage(setting.icon)
        self.stGameTypeDesc:SetText(Lang:format(setting.desc, winInfo.param[1]))
    elseif winInfo.type == Define.OverCondition.Survival then
        self.siGameType:SetImage(setting.icon)
        self.stGameTypeDesc:SetText(Lang:getString(setting.desc))
    elseif winInfo.type == Define.OverCondition.Kill then
        self.siGameType:SetImage(setting.icon)
        self.stGameTypeDesc:SetText(Lang:getString(setting.desc))
    elseif winInfo.type == Define.OverCondition.CollectNum then
        local itemName = Lang:getItemName(winInfo.param[2], winInfo.param[3])
        self.stGameTypeDesc:SetText(Lang:format(setting.desc, itemName, winInfo.param[1]))
    elseif winInfo.type == Define.OverCondition.Collect then
        local itemName = Lang:getItemName(winInfo.param[1], winInfo.param[2])
        self.stGameTypeDesc:SetText(Lang:format(setting.desc, itemName))
    elseif winInfo.type == Define.OverCondition.Marker then
        self.siGameType:SetImage(setting.icon)
        self.stGameTypeDesc:SetText(Lang:getString(setting.desc))
    elseif winInfo.type == Define.OverCondition.MarkerAndKill then
        self.siGameType:SetImage(setting.icon)
        self.stGameTypeDesc:SetText(Lang:getString(setting.desc))
    end
    if teamId > 0 and teamCount > 0 then
        self.siTeamFlag:SetVisible(true)
        local teamUi = Global.setting.teamUi[teamId]
        self.siTeamFlag:SetImage(teamUi.icon)
        self.stTeamText:SetText(Lang:getString("gui.text.team") .. tostring(teamId))
    end
    SoundUtil.playSound(SoundType.RunModeBgm)
end

function UICustomGameToolBarLayout:playerRespawnCountdown(respawnTime)
    self.rebirthTime = respawnTime + os.time()
    self.stRebirthBG:SetVisible(true)
    if self.lKilledInfo:IsVisible() then
        self.lKilledInfo:SetYPosition({ 1.5, 65 })
    end
end

function UICustomGameToolBarLayout:killPlayerInGame(killerUserId, dierUserId)
    local userInfo = nil

    userInfo = UserInfoCache:GetCache(killerUserId)
    self.uiKillSelfIcon:setDefaultImage(DefaultIcon)
    if userInfo then
        if userInfo.picUrl and string.len(userInfo.picUrl) > 0 then
            self.uiKillSelfIcon:setUrl(userInfo.picUrl)
        end
        self.stKillSelfName:SetText(userInfo.nickName)
    end

    userInfo = UserInfoCache:GetCache(dierUserId)
    self.uiKillOtherIcon:setDefaultImage(DefaultIcon)
    if userInfo then
        if userInfo.picUrl and string.len(userInfo.picUrl) > 0 then
            self.uiKillOtherIcon:setUrl(userInfo.picUrl)
        else
        end
        self.stKillOtherName:SetText(userInfo.nickName)
    end

    self.lKilledInfo:SetVisible(false)
    self.lKillInfo:SetVisible(true)
    self.showKillInfoTime = os.time() + 5
    SoundUtil.playSound(SoundType.Kill)
end

function UICustomGameToolBarLayout:playerKilledInGame(killerUserId, dierUserId)
    local userInfo = UserInfoCache:GetCache(killerUserId)
    self.uiKilledOtherIcon:setDefaultImage(DefaultIcon)
    if userInfo then
        if userInfo.picUrl and string.len(userInfo.picUrl) > 0 then
            self.uiKilledOtherIcon:setUrl(userInfo.picUrl)
        end
        self.stKilledText:SetText(Lang:format("gui.game.killed", userInfo.nickName))
    end

    self.lKillInfo:SetVisible(false)
    self.lKilledInfo:SetVisible(true)
    if self.stRebirthBG:IsVisible() then
        self.lKilledInfo:SetYPosition({ 1.5, 65 })
    else
        self.lKilledInfo:SetYPosition({ 1.5, 0 })
    end
    self.showKilledInfoTime = os.time() + 5
    SoundUtil.playSound(SoundType.Kill)
end

function UICustomGameToolBarLayout:onGameEnd()
    isGameEnd = true
    isGameStart = false
    self.isGameRunning = false
    self.btnRank:SetVisible(false)
    self.siGameType:SetVisible(false)
    self.stGameTypeDesc:SetVisible(false)
    self.stRebirthBG:SetVisible(false)
    self.lKillInfo:SetVisible(false)
    self.lKilledInfo:SetVisible(false)
    self.startTime = os.time() + 10
    SoundSystem.Instance():stopBackgroundMusic()
end

function UICustomGameToolBarLayout:onGameReset()
    self.siTime:SetVisible(false)
    self.siTeamFlag:SetVisible(false)
    self.stRebirthBG:SetVisible(false)
    self.lKillInfo:SetVisible(false)
    self.lKilledInfo:SetVisible(false)
end

function UICustomGameToolBarLayout:showRankBtn()
    if self.btnRank:IsVisible() then
        return
    end
    self.btnRank:SetVisible(true)
end

function UICustomGameToolBarLayout:updateEditViewBlockNum()
    local number = customGame.ugcExtraConfig.blockNum or 0
    local maxNum = customGame.ugcExtraConfig.maxBlockCount or 0
    if maxNum > 0 then
        if number <= maxNum then
            self.stEditNum:SetTextColor(Color.BLACK)
        else
            self.stEditNum:SetTextColor(Color.RED)
        end
        self.stEditNum:SetText(Lang:format("custom_room_ugc_info_num", tostring(number) .. "/" .. tostring(maxNum)))
    else
        self.stEditNum:SetText(Lang:format("custom_room_ugc_info_num", tostring(number)))
    end
end

function UICustomGameToolBarLayout:setEditAreaBlockNum(blockNum)
    if self:_needShowEditView() then
        customGame.ugcExtraConfig.blockNum = blockNum
        self:updateEditViewBlockNum()
    end
end

function UICustomGameToolBarLayout:_hideEditView()
    if not self:_needShowEditView() then
        return
    end
    self.showEditView = false
    self.lEditView:SetHeight({0, 30})
    self.siEditArraw:SetRotate(180)

    self.stEditTitle:SetVisible(false)
    self.stEditSize:SetVisible(false)
    self.stEditNum:SetVisible(false)
end
function UICustomGameToolBarLayout:_showEditView()
    if not self:_needShowEditView() then
        return
    end
    self.showEditView = true
    self.lEditView:SetHeight({0, 150})
    self.siEditArraw:SetRotate(0)

    self.stEditTitle:SetVisible(true)
    self.stEditSize:SetVisible(true)
    self.stEditNum:SetVisible(true)
end
function UICustomGameToolBarLayout:_needShowEditView()
    if not customGame.ugcExtraConfig then
        return false
    end
    local buildSize = customGame.ugcExtraConfig.buildSize
    if not buildSize then
        return false
    end
    return buildSize.x > 0 and buildSize.y > 0 and buildSize.z > 0
end

return UICustomGameToolBarLayout
