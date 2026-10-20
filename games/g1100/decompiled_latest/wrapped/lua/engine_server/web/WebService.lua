--[[xYwtpgg28KhElJE]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 47126
                          local checkFileName = "WebService.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[MIj7vrlHPacoedLWifPcwHzT7UtucD8pDlkAbfk5t8g5tJLL2CtHHrLyK8JPpGXqtCTbxqvuBf8YM77ZTMrAwLExt8t2FE2]]---@type ReportEvent
local ReportEvent = T(Global, "ReportEvent")

local RequestQueue = {}
local RequestRunningCount = 0
local RequestSession = 0
---@type table<number, HttpRequest>
local RequestCache = T(Global, "RequestCache")

local UserAttrApi = "/user/api/v1/inner/user/details"
local UserInfosApi = "/user/api/v1/inner/simple-info"
local RewardApi = "/game/api/v1/users/games/settlement"
local RewardGoldApi = "/game/api/v1/users/games/settlement/golds"
local RewardListApi = "/game/api/v1/users/inner/games/settlement/list"
local ReportListApi = "/game/api/v2/inner/users/games/reporting/list"
local ExpRuleApi = "/activity/api/v1/inner/activity/games/settlement/rule"
local UserExpApi = "/activity/api/v1/inner/activity/games/user/exp"
local SaveExpApi = "/activity/api/v1/inner/activity/games/records"
local SaveHonorApi = "/gameaide/api/v1/inner/user/segment/integral"
local UserSeasonInfoApi = "/gameaide/api/v1/inner/user/segment/info"
local UserSeasonRewardApi = "/gameaide/api/v1/inner/segment/integral/reward"
local SeasonSettlementApi = "/gameaide/api/v1/inner/one/click/settlement"
local UserHasRechargeApi = "/pay/api/v1/pay/inner/has/user/recharge"
local UserPropsApi = "/gameaide/api/v1/inner/user/game/props"
local ConsumeUserPropsApi = "/gameaide/api/v1/inner/user/game/props/times"
local PayOrderApi = "/pay/api/v2/inner/pay/users/purchase/game/props"
local UploadRankApi = "/gameaide/api/v1/inner/rank/integral/upload/{gameId}"
local MailsApi = "/gameaide/api/v1/inner/game/mails"
local MailsStatusApi = "/gameaide/api/v1/inner/game/mails/{id}/status"
local SendMsgApi = "/gameaide/api/v1/inner/msg/send"
local SendThumbUpRecordApi = "/gameaide/api/v1/inner/insert/thumbs-up-record"
local GetThumbUpRecordApi = "/gameaide/api/v1/inner/get/thumbs-up-record"
local DeleteThumbUpRecordApi = "/gameaide/api/v1/inner/delete/thumbs-up-record"
local UserGameDataApi = "/api/v2/game/data"
local SaveGameDataApi = "/api/v2/game/data"
local AppRankUserApi = "/game/api/v1/inner/games/{gameId}/uses/rank"
local AppRankAllApi = "/game/api/v1/inner/games/{gameId}/rank"
local GetDispatchApi = "/game/api/v1/inner/region/disp-cluster/{regionCode}"
local DispatchPartyApi = "/v1/dispatch-party"
local SumRechargeGCubeApi = "/pay/api/v1/inner/user/game/recharge/sum/gDiamond"
local RecordRankApi = "/gameaide/api/v1/inner/game/rank"
local GameTimeApi = "/user/api/v1/inner/user/game/career/time"
local HaveCubeOrderApi = "/pay/pay/api/v1/inner/user/consume"
local ConfigFileApi = "/config/files/{fileName}"
local GetExchangePropApi = "/activity/api/v1/inner/collect/exchange/game/props"
local SetExchangePropApi = "/activity/api/v1/inner/collect/exchange/game/props"
local ConsumeExchangePropApi = "/activity/api/v1/inner/collect/exchange/game/notify"
local ConnectorListApi = "/game/api/v1/inner/region/connector-cluster/{regionCode}/{gameId}"
local GiftCountApi = "/gameaide/api/v1/inner/game/count"
local GetCubeConsumeInGameApi = "/pay/api/v1/inner/game/user/consume/total"
local GetApkCERTWhiteListApi = "/game/api/v1/inner/engine/md5"
local UploadInvalidCertMD5Api = "/game/api/v1/inner/user/engine/md5"
local NewCheatReport = "/user/api/v1/inner/counterCheating/save"
local GetEasterTimeApi = "/activity/api/v1/inner/easter/activity/time"
local AddEasterEggApi = "/activity/api/v1/inner/game/easter/egg"
local EngineEventBlacklist = "/config/files/engine_blacklist_event"
local GetUserMoneyApi = "/pay/i/api/v1/wealth/users/{userId}"
local ResumeOrderApi = "/pay/api/v1/pay/users/game/props/billings"
local CancelOrderApi = "/pay/api/v1/pay/inner/users/game/props/billings/refund"
local VipInfoApi = "/user/api/v1/inner/user/vip/info"
local UserPrivilegeApi = "/game/api/v1/inner/vip-privilege-game/privilege-lv"
local ReportGameBillingApi = "/api/v1/game/billing"
local ReportGameCashBillingApi = "/api/v1/inner/game/inner/pay/order"
local GetUnreceivedCashRechargeApi = "/pay/api/v1/inner/game/inner-pay/order/list"
local MarkCashRechargeOrderApi = "/pay/api/v1/inner/game/inner-pay/order/lock"
local ReceivedCashRechargeOrderApi = "/pay/api/v1/inner/game/inner-pay/order/received"
local CancelCashRechargeOrderApi = "/pay/api/v1/inner/game/inner-pay/order/rollback"

local function formatResult(result)
    if type(result) ~= "string" or string.len(result) == 0 then
        return "{}"
    end
    if string.sub(result, 1, 1) == '{' and string.find(result, "\"code\":") ~= nil then
        return result
    end
    LogUtil.log("[Error] http request failed: " .. result, LogUtil.LogLevel.Error)
    return "{}"
end

local function formatData(url, result, params)
    if result == "{}" then
        return nil, 0, ""
    end
    local success = false
    success, result = pcall(json.decode, result)
    if not success then
        LogUtil.log("[Http Response Error] [url]=" .. url .. " [result]=" .. result, LogUtil.LogLevel.Error)
        return nil, 0, ""
    end
    if type(result) ~= "table" then
        return nil, 0, ""
    end
    if result.code == 1 or result.data ~= nil then
        return result.data, result.code, result.message or ""
    else
        LogUtil.log("[Http Response Error] [url]=" .. url .. " [code]=" .. result.code .. " [message]=" .. (result.message or ""), LogUtil.LogLevel.Error)
    end
    return nil, result.code, result.message or ""
end

local function handleRequest(requestFunc, queue, ...)
    if not queue then
        return true
    end
    if RequestRunningCount >= 20 then
        local request = { func = requestFunc, params = { ... } }
        table.insert(RequestQueue, request)
        return false
    end
    RequestRunningCount = RequestRunningCount + 1
    return true
end

local function addRequest(url, params, body, response, queue)
    RequestSession = RequestSession + 1
    ---@class HttpRequest
    local request = {
        session = RequestSession,
        url = url,
        params = params,
        body = body,
        queue = queue,
        response = response,
        times = 1,
    }
    request.callback = function(result)
        if request.response then
            result = formatResult(result)
            local data, code, message = formatData(url, result, params)
            request.response(data, code, message)
        end
        if not request.queue then
            return
        end
        RequestRunningCount = RequestRunningCount - 1
        if #RequestQueue > 0 then
            RequestQueue[1].func(unpack(RequestQueue[1].params))
            table.remove(RequestQueue, 1)
        end
    end
    RequestCache[RequestSession] = request
    return request
end

---@param request HttpRequest
local function checkRetryRequest(request)
    local url = request.url
    if request.times < 4 then
        request.times = request.times + 1
        if request.times % 2 == 0 then
            url = string.gsub(url, WebService.ServerHttpHost, WebService.ServerHttpRetryHost)
            url = string.gsub(url, WebService.DBHttpHost, WebService.DBHttpRetryHost)
        else
            url = string.gsub(url, WebService.ServerHttpRetryHost, WebService.ServerHttpHost)
            url = string.gsub(url, WebService.DBHttpRetryHost, WebService.DBHttpHost)
        end
        request.url = url
        return true
    end
    return false
end

---@type table<number, number>
local UserPrivilegeGrade = T(Global, "UserPrivilegeGrade")
---@param player SBasePlayer
local function PrivilegeGradeChange(player, vipLv)
    if not player or not vipLv then
        return
    end
    if player.vipLv ~= vipLv then
        local nameplate
        if vipLv > 10 then
            nameplate = string.format("vip_nameplate_%s.svga", "10_plus")
        else
            nameplate = string.format("vip_nameplate_%s.svga", vipLv)
        end
        if player.personalityItems then
            player.personalityItems.nameplate = nameplate
        end
        local name = StringUtil.getRealName(player.name)
        name = StringUtil.reconstructName(name, player.colorfulNickName, nameplate)
        if name ~= player.name then
            player.name = name
            player:setShowName(player:buildShowName())
        end
        player.vipLv = vipLv
        local level = UserPrivilegeGrade[player.userId] or 0
        CEvents.PrivilegeGradeChangeEvent:invoke(player.userId, level, vipLv)
    end
end

function onHttpResponse(session, result)
    local request = RequestCache[session]
    if not request then
        return
    end
    if request.callback then
        request.callback(result)
    end
end

WebService = {}

---@param version string
---@param config RoomGameConfig
function WebService:init(version, config)
    self.ver = version
    self.ServerHttpHost = config.blockymodsUrl
    self.ServerHttpRetryHost = #config.blockymodsRetryUrl ~= 0 and config.blockymodsRetryUrl or config.blockymodsUrl
    self.DBHttpHost = config.dbHttpServiceUrl
    self.DBHttpRetryHost = config.dbHttpServiceRetryUrl
    loadWindowHttpHost()
    LogUtil.logInfo("[WebService:init]",
            "\nServerHttpHost=" .. self.ServerHttpHost,
            "\nServerHttpRetryHost=" .. self.ServerHttpRetryHost,
            "\nDBHttpHost=" .. self.DBHttpHost,
            "\nDBHttpRetryHost=" .. self.DBHttpRetryHost)
    self:initGameId()
end

function WebService:initGameId()
    local uuid = require "engine_base.util.uuid"
    uuid.randomseed(os.time())
    self.gameId = uuid()
end

function WebService.asyncGet(url, params, callback, queue)
    if not handleRequest(WebService.asyncGet, queue, url, params, callback, queue) then
        return
    end
    ---@type HttpRequest
    local request
    request = addRequest(url, params, nil, function(data, code, message)
        if code == 0 and checkRetryRequest(request) then
            HttpRequest.asyncGet(request.url, params, request.session)
        else
            if callback then
                callback(data, code, message)
            end
            RequestCache[request.session] = nil
        end
    end, queue)
    HttpRequest.asyncGet(request.url, params, request.session)
    return request
end

function WebService.asyncPost(url, params, body, callback, queue)
    if not handleRequest(WebService.asyncPost, queue, url, params, body, callback, queue) then
        return
    end
    body = body or {}
    if type(body) == "table" then
        body = json.encode(body)
    end
    ---@type HttpRequest
    local request
    request = addRequest(url, params, body, function(data, code, message)
        if code == 0 and checkRetryRequest(request) then
            HttpRequest.asyncPost(request.url, params, body, request.session)
        else
            if callback then
                callback(data, code, message)
            end
            RequestCache[request.session] = nil
        end
    end, queue)
    HttpRequest.asyncPost(request.url, params, body, request.session)
    return request
end

function WebService.asyncPut(url, params, body, callback, queue)
    if not handleRequest(WebService.asyncPut, queue, url, params, body, callback, queue) then
        return
    end
    body = body or {}
    if type(body) == "table" then
        body = json.encode(body)
    end
    ---@type HttpRequest
    local request
    request = addRequest(url, params, body, function(data, code, message)
        if code == 0 and checkRetryRequest(request) then
            HttpRequest.asyncPut(request.url, params, body, request.session)
        else
            if callback then
                callback(data, code, message)
            end
            RequestCache[request.session] = nil
        end
    end, queue)
    HttpRequest.asyncPut(request.url, params, body, request.session)
    return request
end

function WebService.asyncDelete(url, params, body, callback, queue)
    if not handleRequest(WebService.asyncDelete, queue, url, params, body, callback, queue) then
        return
    end
    body = body or {}
    if type(body) == "table" then
        body = json.encode(body)
    end
    ---@type HttpRequest
    local request
    request = addRequest(url, params, body, function(data, code, message)
        if code == 0 and checkRetryRequest(request) then
            HttpRequest.asyncDelete(request.url, params, body, request.session)
        else
            if callback then
                callback(data, code, message)
            end
            RequestCache[request.session] = nil
        end
    end, queue)
    HttpRequest.asyncDelete(request.url, params, body, request.session)
    return request
end

function WebService:GetAntiConfig(callback)
    local path = self.ServerHttpHost .. ConfigFileApi
    path = string.gsub(path, "{fileName}", "anti-cheat-config")
    local params = {
        { "reload", "true" }
    }
    WebService.asyncGet(path, params, callback)
end

---获取游戏动态配置
function WebService:GetGameDynamicConfig(callback)
    local path = self.ServerHttpHost .. ConfigFileApi
    path = string.gsub(path, "{fileName}", "game-dynamic-config")
    local params = {
        { "reload", "true" }
    }
    WebService.asyncGet(path, params, callback)
end

---获取玩家详情信息
function WebService:GetUserAttr(userId, callback)
    local path = self.ServerHttpHost .. UserAttrApi
    local params = {
        { "userId", tostring(userId) },
        { "gameId", BaseMain:getGameType() }
    }
    WebService.asyncGet(path, params, function(data, code)
        if data ~= nil then
            ---@type SBasePlayer
            local player = PlayerManager:getPlayerByUserId(data.userId)
            if player ~= nil then
                local nickName = data.nickName or player.name
                if #nickName > 32 then
                    ReportEvent.reportEvent(userId, "long_nickname_cheat", nil, {
                        source = StringUtil.subStringUTF8(nickName, 1, 32),
                    })
                end
                nickName = StringUtil.subStringUTF8(nickName, 1, 16)
                nickName = StringUtil.keepEnglishName(nickName)
                player.name = StringUtil.reconstructName(nickName, data.colorfulNickName, data.personalityItems and data.personalityItems.nameplate)
                if data.familyType then
                    local diyName = StringUtil.keepEnglishName(data.diyName or "")
                    player.familyInfo = {
                        familyType = data.familyType or 0,
                        familyName = data.familyName or "",
                        diyName = diyName,
                    }
                end
                player.personalityItems = data.personalityItems
                player.colorfulNickName = data.colorfulNickName
                local clanName = StringUtil.keepEnglishName(data.clanName or "")
                player.staticAttr.clanId = data.clanId or 0
                player.staticAttr.clanName = clanName
                player.staticAttr.role = data.role or -1
                player.staticAttr.props = data.propsId or {}
                player.staticAttr.region = data.region or "SG-HK"
                player.clientPeer:setName(player.name)
                player.entityPlayerMP:setUserName(player.name)
            else
                data = nil
            end
        else
            if Platform.isWindow() then
                data = {}
            end
        end
        callback(data)
    end)
end

---获得n个玩家的简单信息
function WebService:GetUserInfos(userIds, callback)
    local path = self.ServerHttpHost .. UserInfosApi
    local params = {
        { "userIdList", table.concat(userIds, ",") }
    }
    WebService.asyncGet(path, params, function(data, code)
        callback(data)
    end)
end

function WebService:GetUserSimpleInfo(userId, callback)
    userId = tostring(userId)
    local path = self.ServerHttpHost .. UserInfosApi
    local params = {
        { "userIdList", userId }
    }
    WebService.asyncGet(path, params, function(data, code)
        if type(data) == "table" and data[userId] ~= nil then
            callback(data[userId])
        end
    end)
end

---给一个玩家结算平台奖励
function WebService:GetReward(userId, data, callback)
    callback({})
    --local path = self.ServerHttpHost .. RewardApi
    --local params = {
    --    { "userId", tostring(userId) },
    --    { "gameId", RewardManager:getGameType() }
    --}
    --WebService.asyncPost(path, params, data, function(data, code)
    --    if data ~= nil then
    --        local player = PlayerManager:getPlayerByUserId(data.userId)
    --        if player ~= nil then
    --            player.gold = data.golds or 0
    --            player.available = data.available or 0
    --            player.hasGet = data.hasGet or 0
    --            player.adSwitch = data.adSwitch or 0
    --        end
    --    end
    --    callback(data)
    --end)
end

---给一个玩家结算平台奖励{自定义金币数量}
function WebService:GetGoldReward(userId, golds, callback)
    callback({})
    --local path = self.ServerHttpHost .. RewardGoldApi
    --local params = {
    --    { "userId", tostring(userId) },
    --    { "gameId", RewardManager:getGameType() },
    --    { "golds", math.floor(tonumber(golds)) }
    --}
    --WebService.asyncPost(path, params, "{}", function(data, code)
    --    if data ~= nil then
    --        local player = PlayerManager:getPlayerByUserId(data.userId)
    --        if player ~= nil then
    --            player.gold = data.golds or 0
    --            player.available = data.available or 0
    --            player.hasGet = data.hasGet or 0
    --        end
    --    end
    --    callback(data)
    --end)
end

---给n个玩家结算平台奖励
function WebService:GetRewardList(data, callback)
    callback({})
    --local path = self.ServerHttpHost .. RewardListApi
    --WebService.asyncPost(path, {}, data, function(data, code)
    --    if data ~= nil then
    --        for _, reward in pairs(data) do
    --            local player = PlayerManager:getPlayerByUserId(reward.userId)
    --            if player ~= nil then
    --                player.gold = reward.golds or 0
    --                player.available = reward.available or 0
    --                player.hasGet = reward.hasGet or 0
    --                player.adSwitch = reward.adSwitch or 0
    --            end
    --        end
    --    end
    --    callback(data)
    --end)
end

---上报n个玩家游戏数据
function WebService:GetReportList(data)
    HostApi.log("[GetReportList]: " .. json.encode(data))
    local path = self.ServerHttpHost .. ReportListApi
    WebService.asyncPost(path, {}, data)
end

---获得经验获取规则，主要用于平台做活动
function WebService:GetExpRule()
    ExpRule:disable()
    --local path = self.ServerHttpHost .. ExpRuleApi
    --local params = {
    --    { "gameId", BaseMain:getGameType() }
    --}
    --WebService.asyncGet(path, params, function(data, code)
    --    if data ~= nil then
    --        ExpRule:initRule(data)
    --    else
    --        ExpRule:disable()
    --    end
    --end)
end

---获取玩家当前的经验信息，主要用于平台做活动
function WebService:GetUserExp(userId)
    --local path = self.ServerHttpHost .. UserExpApi
    --local params = {
    --    { "userId", tostring(userId) }
    --}
    --WebService.asyncGet(path, params, function(data, code)
    --    if data ~= nil then
    --        local player = PlayerManager:getPlayerByUserId(data.userId)
    --        if player ~= nil then
    --            UserExpManager:addExpCache(data.userId, data.level, data.experience, data.expGetToday)
    --        end
    --    end
    --end)
end

---给玩家添加经验，主要用于平台做活动
function WebService:SaveUsersExp(data)
    --local path = self.ServerHttpHost .. SaveExpApi
    --WebService.asyncPost(path, {}, data)
end

---给n个玩家添加段位分，主要用于段位匹配
function WebService:SaveUsersHonor(data)
    local path = self.ServerHttpHost .. SaveHonorApi
    WebService.asyncPost(path, {}, data)
end

---获取玩家赛季的段位信息
function WebService:GetUserSeasonInfo(userId, isLast, callback)
    local path = self.ServerHttpHost .. UserSeasonInfoApi
    local lastSeason
    if isLast then
        lastSeason = "1"
    else
        lastSeason = "0"
    end
    local params = {
        { "userId", tostring(userId) },
        { "gameId", DBManager:getGameType() },
        { "lastSeason", lastSeason }
    }
    WebService.asyncGet(path, params, function(data, code)
        callback(data)
    end)
end

---更新玩家结算奖励的状态，主要用与赛季结算奖励
function WebService:UpdateUserSeasonReward(userId)
    local path = self.ServerHttpHost .. UserSeasonRewardApi
    local params = {
        { "userId", tostring(userId) },
        { "gameId", DBManager:getGameType() }
    }
    WebService.asyncPost(path, params, "{}")
end

---旧排位一键结算赛季
function WebService:TrySeasonSettlement()
    local path = self.ServerHttpHost .. SeasonSettlementApi
    local params = {
        { "gameId", DBManager:getGameType() }
    }
    WebService.asyncPut(path, params, "{}")
end

---查询玩家是否有过消费订单(记录)
function WebService:HasRecharge(userId, callback)
    local path = self.ServerHttpHost .. UserHasRechargeApi
    local params = {
        { "userId", tostring(userId) }
    }
    WebService.asyncGet(path, params, function(data, code)
        local status = 0
        if data ~= nil then
            status = data.status
        end
        callback(status)
    end)
end

---获取玩家购买过并且正在生效的道具信息，自定义google道具，需要花费现金购买的道具
function WebService:GetUserProps(userId, gameType, callback)
    local path = self.ServerHttpHost .. UserPropsApi
    local params = {
        { "userId", tostring(userId) },
        { "gameId", gameType or BaseMain:getGameType() }
    }
    WebService.asyncGet(path, params, function(data, code)
        callback(data or {})
    end)
end

---消耗玩家道具(google自定义道具)次数
function WebService:ConsumeProps(userId, gameType, propsId, callback)
    local path = self.ServerHttpHost .. ConsumeUserPropsApi
    local params = {
        { "userId", tostring(userId) },
        { "gameId", gameType or BaseMain:getGameType() },
        { "propsId", propsId }
    }
    WebService.asyncPost(path, params, "{}", function(data, code)
        callback(data)
    end)
end

function WebService:CheckMails(userId, gameType, callback)
    local path = self.ServerHttpHost .. MailsApi
    local params = {
        { "userId", tostring(userId) },
        { "gameType", gameType }
    }
    WebService.asyncGet(path, params, function(data, code)
        local items = {}
        if data ~= nil then
            for _, mail in pairs(data) do
                if mail.id ~= nil then
                    local item = {}
                    item.id = mail.id
                    item.title = mail.title
                    item.content = mail.content
                    item.fromUser = mail.fromUser
                    item.toUser = mail.toUser
                    item.status = mail.status
                    item.mailType = mail.mailType
                    table.insert(items, item)
                end
            end
        end
        callback(items)
    end)
end

function WebService:SendMails(fromUser, toUser, mailType, title, content, gameType)
    local path = self.ServerHttpHost .. MailsApi
    local content_json = json.encode(content)
    local data = {
        fromUser = tostring(fromUser),
        toUser = tostring(toUser),
        mailType = mailType,
        title = title,
        content = content_json,
        gameType = gameType,
    }
    WebService.asyncPost(path, {}, data)
end

function WebService:UpdateMails(id, status, callback)
    local path = self.ServerHttpHost .. MailsStatusApi
    path = string.gsub(path, "{id}", id)
    local params = {
        { "status", status }
    }
    WebService.asyncPost(path, params, "{}", function(data, code)
        callback(data, code)
    end)
end

---向某人/某游戏发送消息，可以跨服务器
function WebService:SendMsg(targets, content, msgType, scope, gameType)
    local path = self.ServerHttpHost .. SendMsgApi
    local data = {
        content = content,
        gameType = gameType,
        msgType = msgType,
        scope = scope, -- 'all', 'game', 'user'
        targets = targets,
    }
    WebService.asyncPost(path, {}, data)
end

function WebService:SendThumbUpRecord(userId, targetId, status)
    local path = self.ServerHttpHost .. SendThumbUpRecordApi
    local data = {
        activeUserId = tostring(userId),
        gameId = BaseMain:getGameType(),
        passiveUserId = tostring(targetId),
        status = status,
    }
    WebService.asyncPost(path, {}, data)
end

function WebService:GetThumbUpRecord(userId, pageNo, pageSize)
    local path = self.ServerHttpHost .. GetThumbUpRecordApi
    local params = {
        { "userId", tostring(userId) },
        { "gameId", BaseMain:getGameType() },
        { "pageNo", pageNo },
        { "pageSize", pageSize }
    }
    WebService.asyncGet(path, params)
end

function WebService:DeleteThumbUpRecord(messageId)
    local path = self.ServerHttpHost .. DeleteThumbUpRecordApi
    local params = {
        { "id", messageId },
    }
    WebService.asyncPost(path, params, "{}")
end

local function removeAssistKey(table)
    for key, value in pairs(table) do
        if key == "__add" or key == "__rm" then
            table[key] = nil
        end
        if type(value) == "table" then
            removeAssistKey(value)
        end
    end
end

---获取玩家的游戏数据，数据库
function WebService:GetUserGameData(userId, subKey, callback)
    if isLocalDb() then
        LogUtil.logInfo(string.format("[Local] WebService:GetUserGameData, gameType=%s, userId=%s, subKey=%s", DBManager:getGameType(), userId, subKey))
        local dir = string.format("game_cache/%s/%s", DBManager:getGameType(), userId)
        local path = string.format("%s/%s.db", dir, subKey)
        local file = io.open(path, "r")
        local content
        if not file then
            content = ""
        else
            content = file:read("*a")
            file:close()
        end
        if content == "" or content == "{}" then
            callback({ __first = true })
        else
            callback(json.decode(content))
        end
        return
    end
    local path = self.DBHttpHost .. UserGameDataApi
    local params = {
        { "userId", tostring(userId) },
        { "subKey", tostring(subKey) },
        { "tableName", DBManager:getGameType() }
    }
    WebService.asyncGet(path, params, function(data, code)
        if code == 11 then
            data = { __first = true }
        elseif code ~= 1 then
            data = nil
        end
        if isTest and data then
            removeAssistKey(data)
        end
        callback(data)
    end, true)
end

---保存玩家的游戏数据，数据库
function WebService:SaveUserGameData(data, callback)
    if isLocalDb() then
        local dataList = json.decode(data)
        for _, info in pairs(dataList) do
            LogUtil.logInfo(string.format("[Local] WebService:SaveUserGameData, gameType=%s, userId=%s, subKey=%s", DBManager:getGameType(), info.userId, info.subKey))
            local dir = string.format("game_cache/%s/%s", DBManager:getGameType(), info.userId)
            local attr = lfs.attributes(dir, nil, true)
            if not attr then
                os.execute(string.format("mkdir \"%s\"", dir))
            end
            local cache = DBManager:getCache(info.userId, info.subKey)
            local path = string.format("%s/%s.db", dir, info.subKey)
            local file = io.open(path, "w")
            file:write(json.format(json.encode(cache)))
            file:close()
        end
        callback(1)
        return
    end
    local path = self.DBHttpHost .. SaveGameDataApi
    local params = {
        { "tableName", DBManager:getGameType() }
    }
    WebService.asyncPost(path, params, data, function(_, code, message)
        if code == 3 and message:find("maximum allowed size") == nil then
            local dataList = json.decode(data)
            local infoData = {}
            for _, info in pairs(dataList) do
                local key = tostring(info.userId) .. "#" .. tostring(info.subKey)
                infoData[key] = infoData[key] or {}
                table.insert(infoData[key], info)
            end
            for key, info in pairs(infoData) do
                local keys = StringUtil.split(key, "#")
                local userId = keys[1]
                local subKey = keys[2]
                local _params = {
                    { "userId", userId },
                    { "subKey", subKey },
                    { "tableName", DBManager:getGameType() }
                }
                WebService.asyncGet(path, _params, function(_data, _code)
                    if _data == nil or next(_data) == nil then
                        local format = "[DBManager:replaceCache] http get data failed, data is nil or data is empty, userId=%s, data=%s"
                        LogUtil.logScriptException(string.format(format, userId, StringUtil.v2s(data)))
                        callback(code)
                        return
                    end
                    if isTest and _data then
                        removeAssistKey(_data)
                    end
                    DBManager:replaceCache(userId, subKey, _data)
                end)
            end
            return
        end
        callback(code)
    end)
end

---更新排行榜信息，客户端可以自己读取的排行榜
function WebService:UpdateRank(userId, gameId, score, type)
    local path = self.ServerHttpHost .. UploadRankApi
    path = string.gsub(path, "{gameId}", gameId)
    local params = {
        { "userId", tostring(userId) },
        { "gameId", gameId },
        { "type", type },
        { "integral", score }
    }
    WebService.asyncPost(path, params, "{}")
end

---使用平台货币支付(蓝/金魔方、金币)
function WebService:Pay(userId, propsId, currency, quantity, callback)
    local path = self.ServerHttpHost .. PayOrderApi
    local versionCode = "1"
    local packageName = "com.sandboxol.blockymods"
    local info = GameAnalyticsCache:getClientInfo(userId)
    if info ~= nil then
        versionCode = info.version_code or "1"
        packageName = info.package_name or "com.sandboxol.blockymods"
    end
    if currency == 1 then
        currency = 0
    end
    local body = {
        userId = tostring(userId),
        propsId = propsId,
        currency = currency,
        quantity = quantity,
        gameId = BaseMain:getGameType(),
        gameType = DBManager:getGameType(),
        engineVersion = EngineVersionSetting.getEngineVersion(),
        appVersion = versionCode,
        packageName = packageName,
    }
    local player = PlayerManager:getPlayerByUserId(userId)
    if player then
        body.gameCashCoupon = player.gameCashCoupon
    else
        body.gameCashCoupon = 0
    end
    local request = WebService.asyncPost(path, {}, body, function(data, code)
        if data and data.vipLv then
            PrivilegeGradeChange(PlayerManager:getPlayerByUserId(userId), data.vipLv)
        end
        callback(data)
    end)
    request.times = 4
end

function WebService:GetUserAppRank(userId, type, lastWeek, callback)
    local path = self.ServerHttpHost .. AppRankUserApi
    path = string.gsub(path, "{gameId}", RewardManager:getGameType())
    local params = {
        { "userId", tostring(userId) },
        { "gameId", RewardManager:getGameType() },
        { "type", type }, -- all, month, week
        { "lastWeek", lastWeek }, -- 0 this week, 1 last week
    }
    WebService.asyncGet(path, params, function(data, code)
        if not data then
            return
        end
        callback(data)
    end)
end

function WebService:GetAllAppRank(type, pageNo, pageSize, lastWeek, callback)
    local path = self.ServerHttpHost .. AppRankAllApi
    path = string.gsub(path, "{gameId}", RewardManager:getGameType())
    local params = {
        { "userId", tostring(0) },
        { "gameId", RewardManager:getGameType() },
        { "type", type }, -- all, month, week
        { "pageNo", pageNo },
        { "pageSize", pageSize },
        { "lastWeek", lastWeek }, -- 0 this week, 1 last week
    }
    WebService.asyncGet(path, params, function(data, code)
        if data and data.pageInfo then
            callback(data.pageInfo)
        end
    end)
end

function WebService:GetDispatchUrl(regionId, callback)
    local path = self.ServerHttpHost .. GetDispatchApi
    path = string.gsub(path, "{regionCode}", tostring(regionId))
    local params = {
        { "engineType", "v1" }
    }
    WebService.asyncGet(path, params, callback)
end

function WebService:GetDispatchParty(dispatchUrl, info, callback)
    local path = dispatchUrl .. DispatchPartyApi
    WebService.asyncPost(path, {}, info, callback)
end

function WebService:GetSumRechargeGCube(userId, callback)
    local path = self.ServerHttpHost .. SumRechargeGCubeApi
    local params = {
        { "userId", tostring(userId) },
        { "gameId", DBManager:getGameType() }
    }
    WebService.asyncGet(path, params, function(data, code)
        callback(data)
    end)
end

---分页获取对应key记录排行榜的数据
function WebService:GetRecordList(key, pageNo, pageSize, callback)
    local path = self.ServerHttpHost .. RecordRankApi
    local params = {
        { "key", tostring(key) },
        { "pageNo", tostring(pageNo) },
        { "pageSize", tostring(pageSize) }
    }
    WebService.asyncGet(path, params, function(data, code)
        callback(data)
    end)
end

---分页获取对应key记录排行榜的数据
function WebService:ReportOneRecord(key, value, scores, callback, maxSize)
    maxSize = maxSize or 10
    local path = self.ServerHttpHost .. RecordRankApi

    local data = {
        key = tostring(key),
        maxSize = maxSize,
        member = tostring(value),
        scores = scores,
    }

    WebService.asyncPost(path, {}, data, function(data, code)
        callback(data, code)
    end)
end

function WebService:GetPlayerIdentityCache(callback)
    local path = self.ServerHttpHost .. ConfigFileApi
    path = string.gsub(path, "{fileName}", "player-identity-config")
    local params = {
        { "reload", "true" }
    }
    WebService.asyncGet(path, params, callback)
end

function WebService:GetGamePlayerAuthList(callback)
    local path = self.ServerHttpHost .. ConfigFileApi
    path = string.gsub(path, "{fileName}", "game-player-auth-config")
    local params = {
        { "reload", "true" }
    }
    WebService.asyncGet(path, params, callback)
end

function WebService:GetExchangeProp(userId, callback)
    --local path = self.ServerHttpHost .. GetExchangePropApi
    --local params = {
    --    { "userId", tostring(userId) },
    --    { "gameId", DBManager:getGameType() }
    --}
    --WebService.asyncGet(path, params, function(data, code)
    --    if data then
    --        callback(data)
    --    end
    --end)
end

function WebService:SetExchangeProp(userId, propsId, propsCount, expiryTime)
    --local path = self.ServerHttpHost .. SetExchangePropApi
    --local params = {
    --    { "userId", tostring(userId) },
    --    { "gameId", DBManager:getGameType() },
    --    { "gamePropsId", tostring(propsId) },
    --    { "propsAmount", tostring(propsCount) },
    --    { "expiryDate", tostring(expiryTime) }
    --}
    --WebService.asyncPost(path, params, "{}")
end

function WebService:ConsumeExchangeProp(userId, propsId, callback)
    --local path = self.ServerHttpHost .. ConsumeExchangePropApi
    --local params = {
    --    { "userId", tostring(userId) },
    --    { "gameId", DBManager:getGameType() },
    --    { "gamePropsId", propsId }
    --}
    --WebService.asyncPost(path, params, "{}", function(data)
    --    if data then
    --        callback(data)
    --    end
    --end)
end

---获取游戏总时长
function WebService:GetGameTime(userId, gameIds, callback)
    local path = self.ServerHttpHost .. GameTimeApi
    local params = {
        { "userId", tostring(userId) },
        { "gameIds", table.concat(gameIds, ",") }
    }
    WebService.asyncGet(path, params, function(data, code)
        callback(code, data)
    end)
end

---是否存在游戏金魔方订单
function WebService:CheckHaveCubeOrder(userId, callback)
    local path = self.ServerHttpHost .. HaveCubeOrderApi
    local params = {
        { "userId", tostring(userId) }
    }
    WebService.asyncGet(path, params, function(data, code)
        callback(code, data)
    end)
end

---获取Connector列表
function WebService:GetConnectorListApi(callback)
    local path = self.ServerHttpHost .. ConnectorListApi
    path = string.gsub(path, "{regionCode}", GameServer:getServerConfig().regionId)
    path = string.gsub(path, "{gameId}", GameType)
    WebService.asyncGet(path, {}, function(data, code)
        callback(code, data)
    end)
end

---获取礼包是否可以触发
function WebService:CheckTriggerGiftApi(callback, giftId)
    local path = self.ServerHttpHost .. GiftCountApi
    local params = {
        { "key", tonumber(giftId) }
    }
    WebService.asyncPost(path, params, "{}", function(data, code)
        callback(data)
    end)
end

---获取玩家在游戏内的魔方消费总额
---@param userId number 玩家Id
---@param gameIds number[]  游戏Id列表
---@param callback function
function WebService:GetCubeConsumeInGame(userId, gameIds, callback)
    local path = self.ServerHttpHost .. GetCubeConsumeInGameApi
    local params = {
        { "userId", tostring(userId) },
        { "gameIds", table.concat(gameIds, ",") }
    }
    WebService.asyncGet(path, params, function(data, code)
        if not data then
            return
        end
        if callback then
            callback(code, data or {})
        end
    end)
end

---获取apk的证书md5白名单列表
function WebService:GetAPKCERTWhiteList(engineVersion, callback)
    local path = self.ServerHttpHost .. GetApkCERTWhiteListApi
    local params = {
        { "engineVersion", tonumber(engineVersion) }
    }
    WebService.asyncGet(path, params, function(data, code)
        if not data then
            return
        end
        if callback then
            callback(code, data or {})
        end
    end)
end

---上传使用非法证书玩家信息
---已经废弃
function WebService:UploadUserUseInvalidCert(userId, certMd5, engineVersion)
    local path = self.ServerHttpHost .. UploadInvalidCertMD5Api
    local bodyData = {
        engineVersion = tonumber(engineVersion),
        userId = tonumber(userId),
        md5 = tostring(certMd5),
    }
    WebService.asyncPost(path, {}, bodyData, function(data, code)
    end)
end

--- 上报玩家作弊信息
function WebService:uploadCheatInfo(userId, os, cheatSource, desc, type)
    local path = self.ServerHttpHost .. NewCheatReport
    local body = json.encode({
        userId = tonumber(userId),
        osPlatform = tostring(os),
        reason = tostring(desc) .. ";" .. GameType,
        detectSource = tostring(cheatSource),
        type = tonumber(type)
    })
    WebService.asyncPost(path, {}, body, function(data, code)
        LogUtil.logInfo("[WebService:uploadCheatInfo] code=" .. code .. " body=" .. body)
    end)
end

---获取玩家所在大区的活动时间
function WebService:getEasterTime(userId, callback)
    local path = self.ServerHttpHost .. GetEasterTimeApi
    local params = {
        { "userId", tonumber(userId) }
    }
    WebService.asyncGet(path, params, function(data, code)
        if callback then
            callback(data, code)
        end
    end)
end

---加复活节彩蛋数量
function WebService:addEasterEgg(userId, gameId, number, callback)
    local path = self.ServerHttpHost .. AddEasterEggApi
    local param = {
        { "userId", tonumber(userId) },
        { "gameId", tostring(gameId) },
        { "number", tonumber(number) },
    }
    WebService.asyncPost(path, param, "{}", function(data, code)
        if callback then
            callback(data, code)
        end
    end)
end

function WebService:getEngineEventBlacklist(callback)
    local path = self.ServerHttpHost .. EngineEventBlacklist
    WebService.asyncGet(path, {}, function(data, code)
        if callback then
            callback(data, code)
        end
    end)
end

function WebService:GetGameServerLang(callback)
    local path = self.ServerHttpHost .. ConfigFileApi
    path = string.gsub(path, "{fileName}", "game-server-lang")
    local params = {
        { "reload", "true" }
    }
    WebService.asyncGet(path, params, callback)
end

function WebService:GetUserMoney(userId)
    local path = self.ServerHttpHost .. GetUserMoneyApi
    path = string.gsub(path, "{userId}", userId)
    local params = {
        { "gameType", DBManager:getGameType() }
    }
    WebService.asyncGet(path, params, function(data, code)
        if not data then
            return
        end
        PayHelper.syncPlayerMoney(userId, data)
    end)
end

function WebService:ResumeOrder(orderId)
    local path = self.ServerHttpHost .. ResumeOrderApi
    local params = {
        { "orderId", orderId }
    }
    WebService.asyncPut(path, params, {})
end

function WebService:CancelOrder(userId, orderId)
    local path = self.ServerHttpHost .. CancelOrderApi
    local params = {
        { "orderId", orderId },
        { "gameType", DBManager:getGameType() }
    }
    WebService.asyncPut(path, params, {}, function(data, code)
        if not data then
            return
        end
        PayHelper.syncPlayerMoney(userId, data)
    end)
end

---@type table<number, number>
local VipRecord = T(Global, "VipRecord")

function WebService:GetVipInfo(userId)
    local path = self.ServerHttpHost .. VipInfoApi
    local params = {
        { "userId", tonumber(userId) },
    }
    WebService.asyncGet(path, params, function(data, code)
        if not data then
            return
        end
        local player = PlayerManager:getPlayerByUserId(userId)
        if not player then
            return
        end
        VipRecord[player.userId] = data.vip or 0
        player:sendPacket({
            pid = "SyncVipInfo",
            userId = player.userId,
            vip = data.vip or 0,
            expireDate = data.expireDate,
        })
        CEvents.PlayerVipChangeEvent:invoke(player.userId, data.vip)
    end)
end

function WebService:GetUserPrivilege(userId)
    local path = self.ServerHttpHost .. UserPrivilegeApi
    local params = {
        { "gameId", DBManager:getGameType() },
        { "userId", tonumber(userId) },
    }
    WebService.asyncGet(path, params, function(data, _)
        if not data then
            return
        end
        ---@type SBasePlayer
        local player = PlayerManager:getPlayerByUserId(userId)
        if not player then
            return
        end
        local vipLv = data.vipLv or 0
        if player.vipLv ~= vipLv then
            player:sendPacket({
                pid = "SyncUserPrivilege",
                userId = player.userId,
                vipLv = vipLv,
                cfg = data.levelConfigs,
                vip = data.level or 0,
            })
            UserPrivilegeGrade[player.userId] = data.level or 0
            PrivilegeGradeChange(player, vipLv)
        end
    end)
end

function WebService:ReportGameBilling(userId, billings)
    local path = self.DBHttpHost .. ReportGameBillingApi
    local params = {
        { "userId", userId },
        { "gameType", GameType }
    }
    LogUtil.logInfo("[ReportGameBilling] userId=" .. userId .. ", billings=" .. StringUtil.a2s(billings))
    WebService.asyncPost(path, params, billings)
end

function WebService:ReportGameCashBilling(userId, billings)
    local path = self.DBHttpHost .. ReportGameCashBillingApi
    local params = {
        { "userId", userId },
        { "gameType", DBManager:getGameType() }
    }
    LogUtil.logInfo("[ReportGameCashBilling] userId=" .. userId .. ", billings=" .. StringUtil.a2s(billings))
    WebService.asyncPost(path, params, billings)
end

---获取未接收的现金充值订单列表
function WebService:GetUnreceivedCashRecharge(userId, productId, callback)
    local path = self.ServerHttpHost .. GetUnreceivedCashRechargeApi
    local params = {
        { "userId", tonumber(userId) },
        { "gameId", DBManager:getGameType() },
    }
    if productId then
        table.insert(params, { "productId", tostring(productId) })
    end
    WebService.asyncGet(path, params, callback)
end

---标记未领取订单（平台标记加锁、流程上要求先锁再发放奖励）
function WebService:MarkCashRechargeOrder(userId, orderId, callback)
    local path = self.ServerHttpHost .. MarkCashRechargeOrderApi
    local param = {
        { "userId", tonumber(userId) },
        { "orderId", tostring(orderId) },
    }
    WebService.asyncPost(path, param, "{}", callback)
end

---完成 现金充值
function WebService:ReceivedRechargeOrder(userId, orderId, callback)
    local path = self.ServerHttpHost .. ReceivedCashRechargeOrderApi
    local param = {
        { "userId", tonumber(userId) },
        { "orderId", tostring(orderId) },
    }
    WebService.asyncPost(path, param, "{}", callback)
end

---回滚 现金订单状态
function WebService:CancelRechargeOrder(userId, orderId, callback)
    local path = self.ServerHttpHost .. CancelCashRechargeOrderApi
    local param = {
        { "userId", tonumber(userId) },
        { "orderId", tostring(orderId) },
    }
    WebService.asyncPost(path, param, "{}", callback)
end

---获取游戏动态配置
function WebService:GetCheckClientHackFileConfig(callback)
    local path = self.ServerHttpHost .. ConfigFileApi
    if isStaging then
        path = string.gsub(path, "{fileName}", "check-client-hack-file-staging")
    else
        path = string.gsub(path, "{fileName}", "check-client-hack-file")
    end
    local params = {
        { "reload", "true" }
    }
    WebService.asyncGet(path, params, callback)
end

--endregion
--[[Ofszs]]