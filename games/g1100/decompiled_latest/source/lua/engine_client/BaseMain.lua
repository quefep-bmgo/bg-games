---
--- Created by Jimmy.
--- DateTime: 2018/10/9 0009 15:02
---
function onChatHandler(name, ...)

end

function onNotificationHandler(notificationData)
    local notification = json.decode(notificationData)
    Events.OnNotificationHandlerEvent:invoke(notification)
end

function onAdLoaded(adUnitId, status)

end

function onShowAdResult(adUnitId, result)

end

local function getPtrSize()
    if string.packsize("T") == 4 then
        return 4
    else
        return 8
    end
end

--print("script init 02"..File_Len_Check_Cache["BaseMain.lua"])
if not File_Len_Check_Result then
    File_Len_Check_Result = {}
end

if not File_Len_Check_Cache then
    File_Len_Check_Cache = {}
end

if not F_L_Check_C_NEW then
    F_L_Check_C_NEW = {}
end

local function printCheckLenCache()
    for k, v in pairs(File_Len_Check_Cache) do
        for k1, v1 in pairs(v) do
            print("k " .. k .. " v" .. tostring(v1))
        end
    end
end

S_CHECK_FLAG = {}
S_CHECK_FLAG.hasNoCheckFiles = true
S_CHECK_FLAG.doCheck = false

local oldLuaLoader = package.searchers[2]
local function luaLoader(mod)
    local func, path = oldLuaLoader(mod)
    local oldPath = path
    if not path or string.sub(path, 1, 1) ~= "@" then
        return func, path
    end

    path = string.sub(path, 2)

    local fileName = path:match("[^\\/]*$")
    local pathKey = fileName
    local fullPath, content = loadLua(fileName, path, fileName, path)

    local headerLen = getPtrSize() * 4
    if content then
        File_Len_Check_Result[pathKey] = string.len(content) - headerLen
        S_CHECK_FLAG.hasNoCheckFiles = true
    end
    return func, path
end

package.searchers[2] = luaLoader

require "engine_base.Base"
require "engine_client.define.CDefine"
require "engine_client.define.GUIDefine"
require "engine_client.util.ClientHelper"
require "engine_client.util.DynamicCast"
require "engine_client.util.MemoryPool"
require "engine_client.util.MsgSender"
require "engine_client.util.PayHelper"
require "engine_client.util.SoundUtil"
require "engine_client.util.Lang"
require "engine_client.util.DressUtil"
require "engine_client.util.CameraUtil"
require "engine_client.util.RecorderUtil"
require "engine_client.util.Quality"
require "engine_client.entity.IEntity"
require "engine_client.entity.EntityCache"
require "engine_client.event.CommonDataEvents"
require "engine_client.event.GameEvents"
require "engine_client.analytics.GameAnalytics"
require "engine_client.analytics.GameAnalyticsCache"
require "engine_client.web.WebService"
require "engine_client.listener.Listener"
require "engine_client.listener.BaseListener"
require "engine_client.data.EngineWorld"
require "engine_client.data.PlayerWallet"
require "engine_client.data.BasePlayer"
require "engine_client.data.BaseProperty"
require "engine_client.ui.UIHelper"
require "engine_client.ui.UIAnimation"
require "engine_client.ui.GUIManager"
require "engine_client.ui.IGUIBase"
require "engine_client.ui.IGUIWindow"
require "engine_client.ui.IGUILayout"
require "engine_client.ui.IGUIDataView"
require "engine_client.ui.IGUIGridView"
require "engine_client.ui.IGUIListView"
require "engine_client.ui.adapter.IDataAdapter"
require "engine_client.Game"
require "engine_client.packet.PacketSender"
require "engine_client.packet.PidPacketHandler"
require "engine_client.packet.PidPacketSender"
require "engine_client.manager.PlayerManager"
require "engine_client.manager.ClickAreaMgr"
require "engine_client.helper.MaxRecordHelper"
require "engine_client.helper.FollowPlayerHelper"
require "engine_client.helper.GMHelper"
require "engine_client.cache.SharePreferences"

BaseListener:init()
WebService:init()

BaseMain = {}
BaseMain.GameType = "g1001"

function BaseMain:setGameType(GameType)
    self.GameType = GameType
end

function BaseMain:getGameType()
    return self.GameType
end

CommonDataEvents:registerCallBack("ServerInfo", function(data)
    PacketSender:init()
    isStaging = data:getBoolParam("isStaging")
    local isChina = data:getBoolParam("isChina")
    local regionId = data:getNumberParam("regionId")
    local gameId = data:getParam("gameId")
    local tags = data:getParam("tags")
    local serverOsTime = data:getNumberParam("serverOsTime")
    Root.Instance():setChina(isChina)
    Game:setRegionId(regionId)
    Game:setGameId(gameId)
    Game:setServerTags(tags)
    if serverOsTime > 0 then
        BaseMain:fixOsTime(serverOsTime - os.time())
    end
end, DataBuilderProcessor)

CommonDataEvents:registerCallBack("SyncPlayerName", function(data)
    local trySetName
    trySetName = function(userId, name, times)
        times = times or 60
        if times <= 0 then
            return
        end
        local user = UserManager.Instance():findUser(userId)
        if user then
            UserInfoCache:UpdateUserInfos({
                {
                    userId = userId,
                    nickName = StringUtil.getRealName(name)
                }
            })
            user.userName = name
        else
            LuaTimer:schedule(function()
                trySetName(userId, name, times - 1)
            end, 1000)
        end
    end
    trySetName(data.userId, data.name, 60)
end, JsonBuilderProcessor)

function BaseMain:fixOsTime(serverTs)
    print("fixOsTime, serverTs =", serverTs)
    if math.abs(serverTs) < 10 then
        return
    end
    local oldOsTime = os.time
    os.time = function(table)
        if table then
            return oldOsTime(table)
        end
        return oldOsTime() + serverTs
    end
end

local oldSetImage = GUIStaticImage.SetImage
local oldSetDefaultImage = GuiUrlImage.setDefaultImage
local oldGetSkillTimeLength = ActorObject.GetSkillTimeLength
local oldActorWndSetActor1 = GuiActorWindow.SetActor1

GUIStaticImage.hasReportErrorSetImage = false
GuiUrlImage.hasReportErrorsetDefaultImage = false
ActorObject.hasReportNullObject = false

local function newActorWndSetActor1(actorWnd, actorName, actionName, rotate)
    local oldActorName = actorWnd:GetActorName()
    if actorName == oldActorName then
        local oldActor = actorWnd:GetActor()
        if oldActor and not oldActor:getHasInited() then
            -- 防止actor没有init 就调用skill
            print("play skill use set actor find invalid actor: " .. actorName)
            return
        end
    end
    oldActorWndSetActor1(actorWnd, actorName, actionName, rotate)
end

local function newGetSkillTimeLength(actor, param)
    if not actor then
        if not ActorObject.hasReportNullObject then
            local reportContent = "GetSkillTimeLength has null actor " .. debug.traceback("Stack trace")
            HostApi.reportError(reportContent)
            local reportData = {}
            reportData["no_download_res"] = reportContent
            reportData["download_not_suc_res"] = ""
            reportData["download_result"] = 0
            local strReportData = json.encode(reportData)
            HostApi.dataReport("important_res_download_info", strReportData)
            ActorObject.hasReportNullObject = true
        end

        return 3000
    end

    if not actor:getHasInited() then
        return 3000
    end

    local time = oldGetSkillTimeLength(actor, param)
    return time
end

local function newSetImage(imgGui, param)
    if BaseListener:GetIsDestroyed() then
        if not GUIStaticImage.hasReportErrorSetImage then
            local reportContent = "SetImage Destroy " .. debug.traceback("Stack trace")
            HostApi.reportError(reportContent)
            local reportData = {}
            reportData["no_download_res"] = reportContent
            reportData["download_not_suc_res"] = ""
            reportData["download_result"] = 0
            local strReportData = json.encode(reportData)
            HostApi.dataReport("important_res_download_info", strReportData)
            GUIStaticImage.hasReportErrorSetImage = true
        end
        return
    else
        oldSetImage(imgGui, param)
    end
end

local function newSetDefaultImage(imgGui, param)
    if BaseListener:GetIsDestroyed() then
        if not GuiUrlImage.hasReportErrorsetDefaultImage then
            local reportContent = "setDefaultImage Destroy " .. debug.traceback("Stack trace")
            HostApi.reportError(reportContent)
            local reportData = {}
            reportData["no_download_res"] = reportContent
            reportData["download_not_suc_res"] = ""
            reportData["download_result"] = 0
            local strReportData = json.encode(reportData)
            HostApi.dataReport("important_res_download_info", strReportData)
            GuiUrlImage.hasReportErrorsetDefaultImage = true
        end
        return
    else
        oldSetDefaultImage(imgGui, param)
    end
end

GUIStaticImage.SetImage = newSetImage
GuiUrlImage.setDefaultImage = newSetDefaultImage
ActorObject.GetSkillTimeLength = newGetSkillTimeLength
GuiActorWindow.SetActor1 = newActorWndSetActor1

require "engine_client.connector.ConnectorCenter"