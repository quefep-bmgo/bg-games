--[[JTk7Y1pDvqvxXZGL3UX65WcP89abcixCNuLJwzQGHixps3ZbWI5a8qO4nhegxFNh5DIH20ooAeY2CC7IWehpzSEbVw16inFcPmNz5OsL04UsWdgin3CZrev1OjyKEW94jcSMotBzOwyjAYmuXsaaR0fQOZ7Wc04jqMWvXz6GwhzYUJEap49CB7qrXFMFkm]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 6017
                          local checkFileName = "UserInfoCache.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[wtFO6DuRBF8D8QHsJug99hd]]---
--- Created by Jimmy.
--- DateTime: 2018/5/29 0029 11:15
---
---@class UserInfo
---@field userId number
---@field age number
---@field vip number
---@field name string
---@field nickName string
---@field colorfulNickName string
---@field personalityItems table
---@field picUrl string
---@field sex number
---@field country string 国家
---@field language string 语言
---@field tag string 部落id，值为0，表示未加入部落
---@field gameId string 当status=20时，该值有效，表示当前进入的游戏
---@field friend boolean 是否为好友
---@field status number 用户状态，10:表示在线；15:表示在Party中；20:表示游戏中；30:表示离线；
---@field level number 等级
---@field skins table 平台装扮
---@field region string 所在区
---@field isRobot boolean 是否是机器人
---@field clanName boolean 部落名
---@field clanId boolean 部落Id
---@field role boolean 部落职位，0:成员 10:长老 20:酋长
---@alias IUserInfo UserInfo

---@class UserInfoCache
UserInfoCache = {}
---@type table<string, UserInfo>
local Caches = T(Global, "UserInfoCaches")
---@type table
local RequestCache = {}

local function FilterExistedUserId(userIds)
    local ids = {}
    for _, userId in pairs(userIds) do
        local uid = tostring(userId)
        if Caches[uid] == nil and uid ~= "0" then
            table.insert(ids, userId)
        end
    end
    return ids
end

---@private
function UserInfoCache:tryDoRequestCache()
    if self.inRequest then
        return
    end
    

    if TableUtil.isEmpty(RequestCache) then
        return
    end
    local userIds = {}
    local funcList = {}
    for _, cache in pairs(RequestCache) do
        for _, userId in pairs(cache.ids) do
            if not TableUtil.tableContain(userIds, userId) then
                table.insert(userIds, userId)
            end
        end
        table.insert(funcList, cache.func)
    end
    RequestCache = {}
    self.inRequest = true
    WebService:GetUserInfos(userIds, function(userInfos)
        self.inRequest = false
        if isClient then
            self:UpdateUserInfos(userInfos)
        else
            for _, item in pairs(userInfos or {}) do
                local info = {}
                info.userId = item.userId
                info.vip = item.vip
                info.name = StringUtil.reconstructName(item.name or ("user:" .. item.userId), item.colorfulNickName, item.personalityItems and item.personalityItems.nameplate)
                info.picUrl = item.picUrl or ""
                Caches[tostring(item.userId)] = info
            end
        end
        for _, func in pairs(funcList) do
            func()
        end
    end)
end

function UserInfoCache:GetCacheByUserIds(userIds, func)
    local ids = FilterExistedUserId(userIds)
    if #ids == 0 then
        func()
        return
    end
    table.insert(RequestCache, { ids = ids, func = func })
end

---@return IUserInfo
function UserInfoCache:GetCache(userId)
    return Caches[tostring(userId)]
end

---@param userInfos UserInfo[]
---@return number[]
function UserInfoCache:UpdateUserInfos(userInfos)
    local region
    if isClient and isGarena then
        region = Game:getUserRegion()
    end
    local time = os.time()
    local userIds = {}
    for _, info in pairs(userInfos or {}) do
        info._time = time
        if info.language then
            info.language = info.language or "en"
        end
        if info.name then
            info.nickName = info.name
        end
        if info.nickName then
            info.name = info.nickName
        end
        if info.headPic then
            info.picUrl = info.headPic
            info.headPic = nil
        end
        if info.vip then
            info.vip = 0
        end
        if info.status then
            if info.gameId == GameType or PlayerManager:getPlayerByUserId(info.userId) then
                info.status = 10
            end
        end
        if isClient and isGarena then
            if info.region ~= nil and region ~= info.region then
                info.status = 30
            end
        end
        local player = PlayerManager:getPlayerByUserId(info.userId)
        if player then
            player.name = info.name or player.name
        end
        local cache = Caches[tostring(info.userId)]
        if not cache then
            cache = TableUtil.copyTable(info)
            Caches[tostring(info.userId)] = cache
        else
            for key, value in pairs(info) do
                cache[key] = value
            end
        end
        if cache.picUrl and cache.avatarFrame and not string.find(cache.picUrl, "pendant") then
            local avatarFrame = string.gsub(cache.avatarFrame, ".png", ".svga")
            cache.picUrl = cache.picUrl .. "?pendant=" .. avatarFrame
        end
        cache.name = StringUtil.reconstructName(cache.name, cache.colorfulNickName, cache.personalityItems and cache.personalityItems.nameplate)
        table.insert(userIds, info.userId)
    end
    return userIds
end

return UserInfoCache--[[viz]]---