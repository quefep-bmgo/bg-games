local RequestSession = 0
local RequestCache = T(Global, "RequestCache")
---@type DressUtil
local DressUtil = T(Global, "DressUtil")

local ClientHttpHost = "http://dev.mods.sandboxol.cn"
local UserInfosApi = "/friend/api/v1/friends/by/userIds"
local UserDetailApi = "/friend/api/v2/friends/%s"
local GetPlayerDecorationApi = "/decoration/api/v1/decorations/%s/using"
local ConfigFileApi = "/config/files/{fileName}"
local UserInfosWithClanApi = "/bedwar/api/v1/friends/clan/by/userIds"
local EngineEventBlacklist = "/config/files/engine_blacklist_event"
local UploadFileApi = "/user/api/v1/directory/file"

-- 材质包
local GetUsingMaterialBag = "/bedwar/api/v1/material/bag/user/using" -- 获取用户正在使用的材质包
local UseMaterialBag = "/bedwar/api/v1/material/bag/use"                   -- 客户端使用材质包
local GetMaterialBagListByIds = "/bedwar/api/v1/material/bag/byIds"        -- 根据id获取列表
local CancelUseMaterialBag = "/bedwar/api/v1/material/bag/cancelUse"              -- 取消材质包使用

WebService = {}

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

local function formatData(url, result)
    if result == "{}" then
        return nil, 0
    end
    local success = false
    success, result = pcall(json.decode, string.gsub(result, "▢", ""))
    if not success then
        LogUtil.log("[Http Response Error] [url]=" .. url .. " [result]=" .. result, LogUtil.LogLevel.Error)
        return nil, 0
    end
    if type(result) ~= "table" then
        return nil, 0
    end
    if result.code == 1 or result.data ~= nil then
        return result.data, result.code
    else
        LogUtil.log("[Http Response Error] [url]=" .. url .. " [code]=" .. result.code .. " [message]=" .. (result.message or ""), LogUtil.LogLevel.Error)
    end
    return nil, result.code
end

local function addRequest(url, params, body, response)
    if url:find("http") == nil then
        url = ClientHttpHost .. url
    end
    RequestSession = RequestSession + 1
    local request = {
        session = RequestSession,
        url = url,
        params = params,
        body = body,
        response = response,
    }
    if request.response then
        request.callback = function(result)
            result = formatResult(result)
            local data, code = formatData(url, result)
            request.response(data, code)
        end
    end
    RequestCache[RequestSession] = request
    return request
end

function onHttpResponse(session, result)
    local request = RequestCache[session]
    if not request then
        return
    end
    if request.callback then
        request.callback(result)
    end
    RequestCache[session] = nil
end

function WebService.testForUpdate()

end
function WebService:init()
    ClientHttpHost = CGame.Instance():getBaseUrl()
    loadWindowHttpHost()
end

function WebService:setHttpHost(host)
    ClientHttpHost = host or ClientHttpHost
    LogUtil.logInfo("[WebService:setHttpHost]",
            "\nClientHttpHost=" .. ClientHttpHost)
end

function WebService:getHttpHost()
    return ClientHttpHost
end

function WebService:destroy()
    RequestCache = {}
end

function WebService.asyncGet(url, params, callback)
    local request = addRequest(url, params, nil, callback)
    ClientHttpRequest.asyncGet(request.url, params, request.session)
end

function WebService.asyncPost(url, params, body, callback)
    body = body or {}
    if type(body) == "table" then
        body = json.encode(body)
    end
    local request = addRequest(url, params, body, callback)
    ClientHttpRequest.asyncPost(request.url, params, body, request.session)
end

function WebService.asyncPut(url, params, body, callback)
    body = body or {}
    if type(body) == "table" then
        body = json.encode(body)
    end
    local request = addRequest(url, params, body, callback)
    ClientHttpRequest.asyncPut(request.url, params, body, request.session)
end

function WebService.asyncDelete(url, params, body, callback)
    body = body or {}
    if type(body) == "table" then
        body = json.encode(body)
    end
    local request = addRequest(url, params, body, callback)
    ClientHttpRequest.asyncDelete(request.url, params, body, request.session)
end

function WebService.asyncUpload(url, params, filePath, callback)
    if not ClientHttpRequest.asyncUpload then
        return
    end
    local request = addRequest(url, params, filePath, callback)
    ClientHttpRequest.asyncUpload(request.url, filePath, params, request.session)
end

---异步下载文件到本地
---@param url string 下载地址（支持完整url或相对路径）
---@param params table 查询参数
---@param savePath string 本地保存路径
---@param callback function 下载结果回调(data, code)
function WebService.asyncDownload(url, params, savePath, callback)
    if not ClientHttpRequest.asyncDownload then
        return
    end
    local request = addRequest(url, params, savePath, callback)
    ClientHttpRequest.asyncDownload(request.url, savePath, params, request.session)
end

function WebService.friendOperation(type, userId)
    ClientHttpRequest.friendOperation(type, userId)
end

---获得n个玩家的简单信息
function WebService:GetUserInfos(userIds, callback)
    local params = {
        { "userIds", table.concat(userIds, ",") }
    }
    WebService.asyncGet(UserInfosApi, params, function(data, code)
        callback(data)
    end)
end

function WebService:GetUserDetail(userId, callback)
    local path = string.format(UserDetailApi, userId)
    WebService.asyncGet(path, {}, function(data, code)
        if not data then
            return
        end
        UserInfoCache:UpdateUserInfos({ data })
        if callback then
            callback()
        end
    end)
end

function WebService.GetPlayerDecoration(userId, callback)
    local cache = UserInfoCache:GetCache(userId)
    if cache and cache.skins then
        callback(cache.skins)
        return
    end

    local path = string.format(GetPlayerDecorationApi, userId)
    WebService.asyncGet(path, {}, function(data, code)
        local skins = DressUtil:parseDressData(data)
        callback(skins)
        local userInfo = {}
        userInfo.userId = userId
        userInfo.skins = skins
        UserInfoCache:UpdateUserInfos({ userInfo })
    end)
end

function WebService.GetConfigFile(fileName, callback, reload)
    local path = ConfigFileApi
    path = string.gsub(path, "{fileName}", fileName)
    reload = reload or false
    local params = {
        { "reload", tostring(reload) }
    }
    WebService.asyncGet(path, params, function(data, code)
        callback(data)
    end)
end

---获取玩家信息（带部落信息）
function WebService:GetUserInfosWithClan(userIds, callback)
    local params = {
        { "userIds", table.concat(userIds, ",") }
    }
    WebService.asyncGet(UserInfosWithClanApi, params, function(data, code)
        for _, info in pairs(data or {}) do
            if not info.clanRole then
                info.clanRole = {
                    clanId = 0
                }
            end
        end
        UserInfoCache:UpdateUserInfos(data)
        if callback then
            callback(data)
        end
    end)
end

function WebService:getEngineEventBlacklist(callback)
    WebService.asyncGet(EngineEventBlacklist, {}, function(data, code)
        if callback then
            callback(data, code)
        end
    end)
end

---获取当前使用材质包
function WebService:GetUsingMaterialBag(callback)
    WebService.asyncGet(GetUsingMaterialBag, {}, function(data, code)
        if callback then
            callback(data, code)
        end
    end)
end

---设置使用材质包
function WebService:UseMaterialBag(materialBagId, callback)
    local params = {
        { "materialBagId", materialBagId }
    }
    WebService.asyncPost(UseMaterialBag, params, "{}", function(data, code)
        if callback then
            callback(data, code)
        end
    end)
end

---取消使用材质包
function WebService:CancelUseMaterialBag(callback)
    WebService.asyncPost(CancelUseMaterialBag, {}, "{}", function(data, code)
        if callback then
            callback(data, code)
        end
    end)
end

---获取材质包列表
function WebService:GetMaterialBagListByIds(materialIds, callback)
    local params = {
        { "materialIds", table.concat(materialIds, ",") }
    }
    WebService.asyncGet(GetMaterialBagListByIds, params, function(data, code)
        if callback then
            callback(data, code)
        end
    end)
end

---上传文件
function WebService:UploadFile(fileName, directory, filePath, callback)
    local params = {
        { "fileName", fileName },
        { "directory", directory },
    }
    WebService.asyncUpload(UploadFileApi, params, filePath, function(data, code)
        if callback then
            callback(data, code)
        end
    end)
end

---下载文件到本地
---@param url string 下载地址（完整url）
---@param savePath string 本地保存路径（含文件名）
---@param callback function 下载回调(data, code)
---@param params table|nil 查询参数（可选）
function WebService:DownloadFile(url, savePath, callback, params)
    params = params or {}
    WebService.asyncDownload(url, params, savePath, function(data, code)
        if callback then
            callback(data, code)
        end
    end)
end

return WebService
