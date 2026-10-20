---@class HackReport
local HackReport = T(Global, "HackReport")
HackReport.actionType = {}
HackReport.actionName = {}

local HackActionType = HackReport.actionType
HackActionType.lowVersion = 0
HackActionType.useFakeApp = 1
HackActionType.modifyScript = 2
HackActionType.inTheAirCheat = 3
HackActionType.addTimeSpeedCheat = 4
HackActionType.slowDownTimeCheat = 5
HackActionType.blockDestroyDisUnLimit = 6
HackActionType.noBloodLossCheat = 7
HackActionType.attackDisUnLimit = 8
HackActionType.addMoveSpeedCheat = 9
HackActionType.useFakeAppBySo = 10
HackActionType.useDoubleAppCheat = 18
HackActionType.useFakeAppByCert = 19
HackActionType.useVirtualApp = 20
HackActionType.useOldClientLua= 21
HackActionType.failedReviceServerScriptRet= 22
HackActionType.clientLuaCheckTimeOut= 23
HackActionType.clientLuaError= 24
HackActionType.innerCertError= 26
HackActionType.failedExecuteServerScript= 27
HackActionType.illegalLuaFiles= 28
HackActionType.htpCheckTimeout = 31
HackActionType.tickCheckFailed = 32
HackActionType.yidunGetInvalidToken = 33
HackActionType.yidunGetTokenTimeout = 34
HackActionType.yidunDecryptOfflineTokenFailed = 35

local HackActionName = HackReport.actionName
HackActionName[0] = "游戏服务器检测到版本号低于10086"
HackActionName[1] = "游戏服务器检测到使用破解包"
HackActionName[2] = "游戏服务器检测到修改游戏脚本"----暂时没实现 留空位
HackActionName[3] = "游戏服务器检测到飞天作弊"
HackActionName[4] = "游戏服务器检测到时间加速作弊"
HackActionName[5] = "游戏服务器检测到时间减速作弊"
HackActionName[6] = "游戏服务器检测到方块破坏无限距离作弊"
HackActionName[7] = "游戏服务器检测到不掉血作弊" -- 暂时没实现。留空位。
HackActionName[8] = "游戏服务器检测到攻击无限距离作弊"
HackActionName[9] = "游戏服务器检测到移动加速作弊"
HackActionName[10] = "游戏服务器检测到非法SO"
HackActionName[11] = "游戏服务器检测到非法尝试使用GM指令"
HackActionName[12] = "新反外挂-检测到移动作弊"
HackActionName[13] = "新反外挂-检测到飞天作弊"
HackActionName[14] = "新反外挂-检测到加速作弊"
HackActionName[15] = "反外挂2.0-检测到移动作弊"
HackActionName[16] = "反外挂2.0-检测到飞天作弊"
HackActionName[17] = "反外挂2.0-检测到加速作弊"
HackActionName[18] = "反外挂2.0-检测到多开"
HackActionName[19] = "反外挂2.0-检测到非法证书直装包"
HackActionName[20] = "反外挂2.0-检测到虚拟机启动"
HackActionName[21] = "反外挂2.0-检测到客户端脚本非新版本"
HackActionName[22] = "反外挂2.0-无法收到服务端脚本执行结果"
HackActionName[23] = "反外挂2.0-客户端脚本检测超时"
HackActionName[24] = "反外挂2.0-客户端脚本被修改"
HackActionName[25] = "反外挂2.0-弓箭发射频率检测"
HackActionName[26] = "反外挂2.0-通过内部接口检测到非法证书"
HackActionName[27] = "反外挂2.0-执行脚本遇到错误"
HackActionName[28] = "反外挂2.0-检测到非法Lua文件"
HackActionName[30] = "反外挂2.0-易盾作弊检测上报"
HackActionName[31] = "反外挂2.0-易盾作弊检测超时"
HackActionName[32] = "反外挂2.0-定时外挂检测失败"
HackActionName[33] = "反外挂2.0-易盾拿到非法Token"
HackActionName[34] = "反外挂2.0-易盾获取Token心跳超时"
HackActionName[35] = "反外挂2.0-易盾解密离线Token失败"
function HackReport:init()
    self.reportCache = {}
    local this = self
    CEvents.HackReportEvent:registerCallBack(
            function(userId, actionType, desc, desc2)
                this:Report(userId, actionType, desc or "", desc2 or "")
            end)
    CEvents.HTPHackReportEvent:registerCallBack(
            function(userId, actionType, desc, desc2)
                this:ReportHTP(userId, actionType, desc, desc2)
            end)
end


function HackReport:ReportHTP(userId, actionType, desc, desc2)
    local AntiHackConfig = T(Global, "AntiHackConfig")
    if actionType == 30 then
        if AntiHackConfig:isKickOutHtpCheck(desc) then
            self:Report(userId, actionType, desc or "", desc2 or "")
            HostApi.sendGameoverByPlatformUserId(userId, "Error Detected Id: 16", 16)
        end

        --特殊添加对 102的处理
        if desc == "102" and self.reportCache[userId][26] and AntiHackConfig:getConfig().kickOut102And26 then
            self:Report(userId, actionType, desc or "", desc2 or "")
            HostApi.sendGameoverByPlatformUserId(userId, "Net Error Please retry again or update app", 10)
        end

        --特殊处理 424193 超时token解密失败。外挂修改了离线token导致的上报
        if desc == "424193" and AntiHackConfig:getConfig().kickOutHtp424193 then
            self:Report(userId, HackActionType.yidunDecryptOfflineTokenFailed, desc or "", desc2 or "")
            HostApi.sendGameoverByPlatformUserId(userId, "Net Error Please retry again or update app", 10)
        end
    end
end

function HackReport:Report(userId, actionType, desc, desc2)
    if not self.reportCache[userId] then
        self.reportCache[userId] = {}
    end

    if not self.reportCache[userId][actionType] then
        self.reportCache[userId][actionType] = true
    end
    

	desc = desc or ""
	desc2 = desc2 or ""
    local os = "unknown"
    local clientInfo = GameAnalyticsCache:getClientInfo(userId)
    if clientInfo ~= nil and clientInfo.os_platform ~= nil then
        os = clientInfo.os_platform
    end

    local cheatSource = self.actionName[actionType] or string.format("未知类型[%s]", tostring(actionType))
    WebService:uploadCheatInfo(userId, os, cheatSource, desc.."+"..desc2, actionType)
    GameAnalytics:reportCheatDetect(userId, actionType)
    local gtype = BaseMain:getGameType()
    local AntiHackConfig = T(Global, "AntiHackConfig")
    if actionType == 19 then
        if AntiHackConfig:getConfig().kickOutFakeAppByCert or gtype == "g1014" then 
            HostApi.sendGameoverByPlatformUserId(userId, "Error Detected Id: 16", 16)
        end
    end

    if actionType == 31 then
        if AntiHackConfig:getConfig().kickOutHTPCheckTimeout then
            HostApi.sendGameoverByPlatformUserId(userId, "Error Detected Id: 16", 16)
        end
    end

    if actionType == 32 then
        if AntiHackConfig:getConfig().kickOutTickCheckFailed then
            HostApi.sendGameoverByPlatformUserId(userId, "Error Detected Id: 16", 16)
        end
    end

    if actionType == 33 then
        if AntiHackConfig:getConfig().kickOutYidunGetInvalidToken then
            HostApi.sendGameoverByPlatformUserId(userId, "Error Detected Id: 16", 16)
        end
    end

    if actionType == 34 then
        if AntiHackConfig:getConfig().kickOutYidunGetTokenTimeout then
            HostApi.sendGameoverByPlatformUserId(userId, "Net Error Please retry again or update app", 10)
        end
    end

    if actionType == 27 and EngineVersionSetting.getEngineVersion() >=10113 then
        if AntiHackConfig:getConfig().kickOutExecuteServerScriptError then
            HostApi.sendGameoverByPlatformUserId(userId, "Error Detected Id: 16", 16)
        end
    end
end

HackReport:init()
