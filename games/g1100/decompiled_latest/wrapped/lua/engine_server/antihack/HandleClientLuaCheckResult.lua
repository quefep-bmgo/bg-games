--[[d0IpUkwy31bUU0NksLFmHDdPib6Ell1G70yPZZtzMax935DFk60nGAHlzoMRdEOAsvZYNv0ksr]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 12684
                          local checkFileName = "HandleClientLuaCheckResult.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[sOXw]]---@class HandleClientLuaCheckResult
local HandleClientLuaCheckResult = T(Global, "HandleClientLuaCheckResult")
HandleClientLuaCheckResult.result = {}

function dec2hex(input)
    return string.format('%X', tonumber(input));
end;

function randString(len)
    local ret = '';
    while (#ret <= len) do
        local byte = MathUtil:randomIntNoRepeat(48, 107, 1)[1];
        if (byte >= 58 and byte <= 83) then
            byte = byte + 7;
        elseif (byte >= 84) then
            byte = byte + 13;
        end ;
        ret = ret .. string.char(byte);
    end ;
    return ret;
end;

function explode(delim, input)
    if (input == nil) then
        local ret = {};
        for i = 1, #delim do
            table.insert(ret, delim:sub(i, i));
        end ;
        return ret;
    else
        local cinput, ret, cache = '', {}, '';
        for i = 1, #input do
            cinput = input:sub(i, i);
            if (cinput == delim) then
                table.insert(ret, cache);
                cache = '';
            elseif (cinput ~= '' and cinput ~= ' ') then
                cache = cache .. cinput;
            end ;
        end ;
        if (cache ~= '' and cache ~= ' ') then
            table.insert(ret, cache);
        end ;
        return ret;
    end ;
end;

--  位操作
local bit32Op = {}

-- 向右旋转函数
function bit32Op.rrotate(n, b)
    local w = bit32Op.band(n, 0xffffffff) -- 确保数字在32位范围内
    b = b % 32 -- 旋转的位数不能超过32
    return bit32Op.bor(bit32Op.lshift(w, b), bit32Op.rshift(w, 32 - b))
end

-- 向左旋转函数
function bit32Op.lrotate(n, b)
    local w = bit32Op.band(n, 0xffffffff) -- 确保数字在32位范围内
    b = b % 32 -- 旋转的位数不能超过32
    local left = bit32Op.lshift(w, b) -- 左移
    local right = bit32Op.rshift(w, 32 - b) -- 右移
    return bit32Op.bor(left, right) -- 合并左移和右移的结果
end

-- 位与操作
function bit32Op.band(a, b)
    return a & b
end

-- 位或操作
function bit32Op.bor(a, b)
    return a | b
end

-- 位异或操作
function bit32Op.bxor(a, b)
    return a ~ b
end

-- 左移操作
function bit32Op.lshift(a, b)
    return a << b
end

-- 右移操作
function bit32Op.rshift(a, b)
    return a >> b
end

function strEncrypt(input, key)
    local input = explode(input)
    local iv1 = randString(16)
    local iv2 = randString(16)
    local key1 = key:sub(1, string.find(key, ':') - 1)
    local key2 = key:sub(string.find(key, ':') + 1)
    local ret, key1Index, key2Index, iv1Index, iv2Index = '', 1, 1, 1, 1
    for i = 1, #input do
        local inputByte = string.byte(input[i])
        local key1Byte = string.byte(key1:sub(key1Index, key1Index))
        local key2Byte = string.byte(key2:sub(key2Index, key2Index))
        local iv1Byte = string.byte(iv1:sub(iv1Index, iv1Index))
        local iv2Byte = string.byte(iv2:sub(iv2Index, iv2Index))

        local bit32 = bit32Op
        local step1 = bit32.bxor(inputByte, bit32.bxor(bit32.bxor(key2Byte, iv1Byte), iv2Byte))
        --local step2 = bit32.lrotate(step1, 10)
        local step2 = step1
        local step3 = bit32.bxor(step2, bit32.bxor(bit32.bxor(key1Byte, iv2Byte), iv1Byte))
        --local step4 = bit32.lrotate(step3,10)
        local step4 = step3

        local step5 = bit32.bxor(step4, (i - 1))
        --local step6 = bit32.lrotate(step5,10)
        local step6 = step5
        local step7 = bit32.bxor(step6, bit32.bxor(bit32.bxor(key2Byte, iv1Byte), iv2Byte))

        ret = ret .. dec2hex(step7) .. ':'

        key1Index = key1Index + 1
        if (key1Index >= #key1) then
            key1Index = 1
        end
        key2Index = key2Index + 1
        if (key2Index >= #key2) then
            key2Index = 1
        end
        iv1Index = iv1Index + 1
        if (iv1Index >= #iv1) then
            iv1Index = 1
        end
        iv2Index = iv2Index + 1
        if (iv2Index >= #iv2) then
            iv2Index = 1
        end
    end
    return string.lower(ret:sub(1, #ret - 1)) .. ';' .. iv1 .. ';' .. iv2
end;

function strDecrypt(input, key)
    local ret, key1Index, key2Index, iv1Index, iv2Index = '', 1, 1, 1, 1
    local key1 = key:sub(1, string.find(key, ':') - 1)
    local key2 = key:sub(string.find(key, ':') + 1)
    local iv1 = input:sub(string.find(input, ';') + 1, string.find(input, ';', string.find(input, ';') + 5) - 1)
    local iv2 = input:sub(string.find(input, ';', string.find(input, ';') + 5) + 1)
    local input = explode(':', input:sub(1, string.find(input, ';') - 1))

    for i = 1, #input do
        local inputByte = tonumber('0x' .. input[i])
        local key1Byte = string.byte(key1:sub(key1Index, key1Index))
        local key2Byte = string.byte(key2:sub(key2Index, key2Index))
        local iv1Byte = string.byte(iv1:sub(iv1Index, iv1Index))
        local iv2Byte = string.byte(iv2:sub(iv2Index, iv2Index))

        local bit32 = bit32Op

        local step7 = bit32.bxor(inputByte, bit32.bxor(bit32.bxor(key2Byte, iv1Byte), iv2Byte))
        --local step6 = bit32.rrotate(step7, 10)
        local step6 = step7
        local step5 = bit32.bxor(step6, (i - 1))
        --local step4 = bit32.rrotate(step5, 10)
        local step4 = step5
        local step3 = bit32.bxor(step4, bit32.bxor(bit32.bxor(key1Byte, iv2Byte), iv1Byte))
        --local step2 = bit32.rrotate(step3, 10)
        local step2 = step3
        local step1 = bit32.bxor(step2, bit32.bxor(bit32.bxor(key2Byte, iv1Byte), iv2Byte))

        ret = ret .. string.char(step1)

        key1Index = key1Index + 1
        if (key1Index >= #key1) then
            key1Index = 1
        end
        key2Index = key2Index + 1
        if (key2Index >= #key2) then
            key2Index = 1
        end
        iv1Index = iv1Index + 1
        if (iv1Index >= #iv1) then
            iv1Index = 1
        end
        iv2Index = iv2Index + 1
        if (iv2Index >= #iv2) then
            iv2Index = 1
        end
    end
    return ret
end

function simpleDecrypt(str, key)
    local result = {}
    for i = 1, #str do
        local char = str:sub(i, i)
        local char_code = string.byte(char)
        if char_code >= 32 and char_code <= 126 then
            -- 只解密加密的字符
            local new_char_code = (char_code - key + 32) % 95 + 32
            result[i] = string.char(new_char_code)
        else
            result[i] = char
        end
    end
    return table.concat(result)
end

function HandleClientLuaCheckResult:init()
    local this = self
    BaseListener.registerCallBack(CEvents.PlayerLogoutEvent, function(player)
        this:onPlayerLogout(player.userId)
    end)
end

function HandleClientLuaCheckResult:onPlayerLogout(playerId)
    if self.result[playerId] then
        if self.result[playerId].timeoutTimer then
            LuaTimer:cancel(self.result[playerId].timeoutTimer)
            self.result[playerId].timeoutTimer = nil
        end
    end
end

function HandleClientLuaCheckResult:AddRequest(playerId)
    local gtype = BaseMain:getGameType()
    local clientInfo = GameAnalyticsCache:getClientInfo(playerId)
    local os = "android"
    if clientInfo ~= nil and clientInfo.os_platform ~= nil then
        os = clientInfo.os_platform
    end

    if not self.result[playerId] and gtype == "g1008" and os == "android" then
        self:initPlayer(playerId)
        local this = self
        self.result[playerId].timeoutTimer = LuaTimer:schedule(function()
            this:reportTimerOut(playerId)
            if this.result[playerId] and this.result[playerId].timeoutTimer then
                LuaTimer:cancel(this.result[playerId].timeoutTimer)
            end
        end, 100000, 0) -- 临时改为100S防止玩家因为脚本加载失败导致误检测
    end
end

function HandleClientLuaCheckResult:reportTimerOut(playerId)
    local HackReport = T(Global, "HackReport")
    local AntiHackConfig = T(Global, "AntiHackConfig")

    local hackType = HackReport.actionType.clientLuaCheckTimeOut
    local hackReason = "ClientLuaCheck timed out"
    HackReport:Report(playerId, hackType, hackReason)

    local player = PlayerManager:getPlayerByUserId(playerId)
    if player and AntiHackConfig:getConfig().kickClientLuaCheckTimeOut and not isLocalWin then
        CEvents.PlayerCheatEvent:invoke(player.rakssid, 16)
        HostApi.sendGameoverByPlatformUserId(playerId, "Error Detected Id: 16", 16)
    end
end

function HandleClientLuaCheckResult:reportCheckClientScriptFailed(playerId, failedResean)
    local HackReport = T(Global, "HackReport")
    local AntiHackConfig = T(Global, "AntiHackConfig")

    local hackType = HackReport.actionType.clientLuaError
    local hackReason = "CheckClientScriptFailed " .. failedResean
    HackReport:Report(playerId, hackType, hackReason)
    print("ClientLuaCheck failed " .. failedResean)
end

function HandleClientLuaCheckResult:initPlayer(playerId)
    local status = {}
    status.reciveCheck = false
    status.timeoutTimer = nil
    self.result[playerId] = status
end

local function check_invalid_lua_file(files)
    local invalid = false
    local needCheck = { "Loader.lua", "BaseMain.lua", "Game.lua", "PluginMain.lua", "gmopen", "loaderror" }
    table.remove(files, #files)
    for k, v in ipairs(needCheck) do
        for kf, vf in ipairs(files) do
            if v == vf then
                invalid = true
            end
        end
    end
    return invalid
end

local reportErrorScriptPlayer = {}
function HandleClientLuaCheckResult:ReciveResult(player, returnData)
    local playerId = player.userId
    if not self.result[playerId] then
        self:initPlayer(playerId)
        self.result[playerId].reciveCheck = true
    end

    if self.result[playerId].timeoutTimer then
        LuaTimer:cancel(self.result[playerId].timeoutTimer)
        self.result[playerId].timeoutTimer = nil
    end

    local findError = true
    local decData = ""
    if returnData.data and returnData.data.r then
        decData = strDecrypt(returnData.data.r, "Loader:Plugin")
        local luas = StringUtil.split(decData, "|")
        if #luas > 1 then
            local signLua = luas[#luas]
            if signLua == "Plugin.lua" then
                findError = false
            else
                findError = check_invalid_lua_file(luas)
            end
        end
    end

    if not isLocalWin then
        print("ret " .. decData)
    end

    local needReport = returnData.data and returnData.data.e
    needReport = needReport or findError
    local gtype = BaseMain:getGameType()
    local clientInfo = GameAnalyticsCache:getClientInfo(playerId)
    local os = "android"
    if clientInfo ~= nil and clientInfo.os_platform ~= nil then
        os = clientInfo.os_platform
    end

    local AntiHackConfig = T(Global, "AntiHackConfig")
    if findError and AntiHackConfig:isOpenScriptCheck() and os == "android" then

        if not reportErrorScriptPlayer[playerId] then
            self:reportCheckClientScriptFailed(playerId, decData)
            reportErrorScriptPlayer[playerId] = true
        end

        local player = PlayerManager:getPlayerByUserId(playerId)
        for k, v in ipairs(AntiHackConfig:getConfig().KickUserWhiteList) do
            if v == playerId then
                return
            end
        end

        if player and AntiHackConfig:getConfig().kickOutErrorClientLua and not isLocalWin then
            CEvents.PlayerCheatEvent:invoke(player.rakssid, 16)
            HostApi.sendGameoverByPlatformUserId(playerId, "Error Detected Id: 16", 16)
        end
    end
end

function HandleResultPacket(player, packet)
    HandleClientLuaCheckResult:ReciveResult(player, packet)
end
local PacketHandlers = T(Global, "PacketHandlers")
PacketHandlers["c_c_l_len"] = HandleResultPacket
HandleClientLuaCheckResult:init()--[[zFMF1M7gP5cGaAI8rw94hNJIAX31FuZl4gwneiAs02P565gtSTc2Hn]]