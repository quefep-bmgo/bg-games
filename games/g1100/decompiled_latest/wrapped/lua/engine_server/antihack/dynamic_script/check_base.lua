--[[O6I6vUH27X9zho1b4hKN2qCQsaOBSLMAFEKQXQFav0J2i3Tl3RzKVz0wm04XS]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 9788
                          local checkFileName = "check_base.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[htSXf05jNz8kFnwb7L5ACaiPdQ0D95FLigcFpNh4YeJgvhW8OjDPC2nHJl7IEz703eUbnFTaLcrjOnQ4fpOaAAh7CPvDDra5brUH2pc30HjV95cnJygZ0Tm3]]local CheckBase = class("CheckBase")
CheckBase.checkReciveTimer = {}


-- 加密结果。加密方式为 随机一个字符串，然后将结果字符串跟随机字符串按规律混合，再通过base64编码
local encodeResult = [[
    local randomStringbegin = "randomString_begin_proxy" -- 占位
    local randomStringEnd = "randomString_end_proxy" -- 占位
    local encodeParam = 111111 --- 占位

    -- 位异或操作
    local function vmbxor(a, b)
        return a ~ b
    end

    -- 
    local function vmexchange(a)
        local leftChar = a
        local rightChar = a

        leftChar = leftChar >> 4
        rightChar = a << 4 & 0xff
        return (leftChar | rightChar)
    end


    -- 辅助函数：字符串转字节数组
    local function strToByteArray(str)
        local byteArray = {}
        for i = 1, #str do
            byteArray[i] = string.byte(str, i)
        end
        return byteArray
    end
    
    local resultByteArray = strToByteArray(result)
    local mixedByteArray = {}
    local bbArray = "" -- 记录有百分号的位置。
    local mixedStr = ""
    local k = 0
    local totalValue = 0
    for i = 1, #resultByteArray do
        totalValue = totalValue + resultByteArray[i]
        local xorValue = vmbxor(resultByteArray[i], encodeParam)
        local exchangeValue = vmexchange(xorValue)
        if exchangeValue == 126 then
            if k ~= 0 then 
                bbArray = bbArray .. ";"
            end
            bbArray = bbArray .. tostring(i)
            k = k + 1
        else
            mixedByteArray[i] = exchangeValue
            mixedStr = mixedStr .. string.char(mixedByteArray[i])
        end
    end
    local positionInfoLen = string.format("%04d", #bbArray)
    local totalValueStr = string.format("%08d", totalValue)
    bbArray = positionInfoLen .. bbArray
    local rt = randomStringbegin .. totalValueStr .. bbArray  .. mixedStr .. randomStringEnd
    return rt
]]


-- 位异或操作
local function vmbxor(a, b)
    return a ~ b
end

-- 
local function vmexchange(a)
    local leftChar = a;
    local rightChar = a;

    leftChar = leftChar >> 4;
    rightChar = a << 4 & 0xff;
    return (leftChar | rightChar);
end


-- 辅助函数：字节数组转字符串
local function byteArrayToStr(byteArray)
    local str = ""
    for i = 1, #byteArray do
        str = str .. string.char(byteArray[i])
    end
    return str
end

local function strToByteArray(str)
    local byteArray = {}
    for i = 1, #str do
        byteArray[i] = string.byte(str, i)
    end
    return byteArray
end

local function randString(len)
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

function CheckBase:getResultCode()
    if not self.encodeResult or not self.encodeInfo  then 
        self.encodeInfo = {}

        self.encodeInfo.randomBeginStr = randString(MathUtil:randomIntNoRepeat(5, 20, 1)[1])
        self.encodeInfo.randomEndStr = randString(MathUtil:randomIntNoRepeat(5, 20, 1)[1])
        self.encodeInfo.randomCode = MathUtil:randomIntNoRepeat(22, 200, 1)[1]

        print("randomBeginStr: " .. self.encodeInfo.randomBeginStr)
        print("randomEndStr: " .. self.encodeInfo.randomEndStr)
        print("randomCode: " .. self.encodeInfo.randomCode)

        local encodeResult = encodeResult:gsub("randomString_begin_proxy", self.encodeInfo.randomBeginStr)
        local encodeResult = encodeResult:gsub("randomString_end_proxy", self.encodeInfo.randomEndStr)
        local encodeResult = encodeResult:gsub("111111", self.encodeInfo.randomCode)
        self.encodeResult = encodeResult
    end
    return self.encodeResult
end

function CheckBase:decodeResult(result)
    --判断前缀是不是  self.encodeInfo.randomBeginStr
    if string.sub(result, 1, #self.encodeInfo.randomBeginStr) ~= self.encodeInfo.randomBeginStr then
        return nil, self.encodeInfo.randomBeginStr, self.encodeInfo.randomEndStr
    end
    --判断后缀是不是  self.encodeInfo.randomEndStr
    if string.sub(result, -#self.encodeInfo.randomEndStr) ~= self.encodeInfo.randomEndStr then
        return nil, self.encodeInfo.randomBeginStr, self.encodeInfo.randomEndStr
    end

    --解码
    local content = string.sub(result, #self.encodeInfo.randomBeginStr + 1, -#self.encodeInfo.randomEndStr-1)

    -- 获取totalValue
    local totalValue = tonumber(string.sub(content, 1, 8))
    -- 解析百分号位置信息
    content = string.sub(content, 9, -1)
    local positionInfoLen = tonumber(string.sub(content, 1, 4))
    if not positionInfoLen then
        positionInfoLen = 0
    end

    local positionInfoArray = {}
    local mixedDataStart = 5
    if positionInfoLen > 0 then
        local positionInfo = string.sub(content, 5, positionInfoLen + 4)
        mixedDataStart = 5 + positionInfoLen
         positionInfoArray = StringUtil.split(positionInfo, ";")
    end

    local base64Decode = string.sub(content, mixedDataStart, -1)

    --插入"l" 这个符号经过c++层加密后会变成 % 包解密的时候会被剔除掉
    local lchar = string.char(126)
    for i = 1, #positionInfoArray do
        base64Decode = string.sub(base64Decode, 1, tonumber(positionInfoArray[i]) - 1 ) .. lchar .. string.sub(base64Decode, tonumber(positionInfoArray[i]), -1)
    end
    local encodeArray = strToByteArray(base64Decode)
    local decodeByteArray = {}
    local decodeStr = ""
    local decodeTotalValue = 0
    for i = 1, #base64Decode do
        decodeByteArray[i] = vmexchange(encodeArray[i])
        decodeByteArray[i] = vmbxor(decodeByteArray[i], self.encodeInfo.randomCode)
        decodeStr = decodeStr .. string.char(decodeByteArray[i])
        decodeTotalValue = decodeTotalValue + decodeByteArray[i]
    end
    if decodeTotalValue ~= totalValue then
        print("total value error: " .. decodeTotalValue .. " ~= " .. totalValue)
        return nil, self.encodeInfo.randomBeginStr, self.encodeInfo.randomEndStr
    end
    print("decodeStr : " .. StringUtil.v2s(decodeStr))
    return decodeStr
end

local waitTime = 60000
function CheckBase:onSend(playerId, id)

    if self.checkReciveTimer == nil then
        self.checkReciveTimer = {}
    end

    self.checkReciveTimer[playerId] = LuaTimer:schedule(function()
            self:onReciveTimeout(playerId, id)
    end, waitTime) -- 等一分钟

    local this = self
    BaseListener.registerCallBack(CEvents.PlayerLogoutEvent, function(player)
        this:onPlayerLogout(player.userId)
    end)

    CEvents.BeforeCloseSessionEvent:registerCallBack(function(playerId)
        this:onBeforeCloseSession(playerId)
    end
    )
end


function CheckBase:onPlayerLogout(playerId)
    if self.checkReciveTimer[playerId]  then
        LuaTimer:cancel(self.checkReciveTimer[playerId]  )
        self.checkReciveTimer[playerId] = nil
    end
end

function CheckBase:onBeforeCloseSession(playerId)
    if self.checkReciveTimer[playerId]  then
        LuaTimer:cancel(self.checkReciveTimer[playerId]  )
        self.checkReciveTimer[playerId] = nil
    end
end

function CheckBase:onReciveResult(playerId, result)
    if self.checkReciveTimer[playerId] then
        LuaTimer:cancel(self.checkReciveTimer[playerId])
        self.checkReciveTimer[playerId] = nil
    end
end

function CheckBase:onReciveTimeout(playerId, id)
    if self.checkReciveTimer[playerId]  then
        LuaTimer:cancel(self.checkReciveTimer[playerId]  )
        self.checkReciveTimer[playerId] = nil
        self.checkReceiveTimer = true
        local AntiHackConfig = T(Global, "AntiHackConfig")
        local player = PlayerManager:getPlayerByUserId(playerId)
        if player and  player.clientPeer and ClientPeer.isAppEnterBack then

            local isAPPEnterBack = player.clientPeer:isAppEnterBack()
            if isAPPEnterBack then -- 重新等待
                self.checkReciveTimer[playerId] = LuaTimer:schedule(function()
                    self:onReciveTimeout(playerId)
                end, waitTime)
            else
                local HackReport = T(Global, "HackReport", nil)
                HackReport:Report(playerId, HackReport.actionType.failedReviceServerScriptRet,
                "recvive script result timeout v2: "..tostring(id))
                local gtype = BaseMain:getGameType()
                if AntiHackConfig:isGameEnableScriptTimeCheck(gtype) and not isLocalWin then
                    CEvents.PlayerCheatEvent:invoke(player.rakssid, 16)
                    HostApi.sendGameoverByPlatformUserId(playerId, "Error Detected Id: 16", 16)
                end
            end
        end
    end
end
return CheckBase--[[LBX4gBKk5]]