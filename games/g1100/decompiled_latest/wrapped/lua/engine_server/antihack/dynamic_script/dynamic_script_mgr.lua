--[[4MS6El8jzBjnzbApLuO3KEBxUpfb9xyC3HFsRvURd7Hh13BjA0eWXptbcWpNmHgJME2VmSbNM1bmTmsLmzWSfCZ1E7Uv0]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 12335
                          local checkFileName = "dynamic_script_mgr.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[noOYYwppQ7vppVuriF3xoT2v4hZPZt2hngJlWtG7xbJ790dohC1gDl9O2uEiUDwr3cdfzPTW9043AVZR8bg2Pu]]local AntiScriptPlayerStatus = class("AntiScriptPlayerStatus")
AntiScriptPlayerStatus.nextScriptId = 1
AntiScriptPlayerStatus.nextSendTimer = nil

function AntiScriptPlayerStatus:onPlayerSendScript(playerId, curId, nextSendTimer)
    self.nextScriptId = curId + 1
    self.playerId = playerId
    self.checkReceiveTimer = false
    if self.nextSendTimer ~= nil then
        LuaTimer:cancel(self.nextSendTimer)
    end
    self.nextSendTimer = nextSendTimer
    if self.sendScriptTime == nil then 
        self.sendScriptTime = {}
    end
end

function AntiScriptPlayerStatus:OnReciveScript()
    if self.reciveScriptTimer ~= nil then
        LuaTimer:cancel(self.reciveScriptTimer)
        self.reciveScriptTimer = nil
    end
    self.checkReceiveTimer = true
end

function AntiScriptPlayerStatus:OnReciveScriptTimeOut()
    if self.reciveScriptTimer ~= nil then
        LuaTimer:cancel(self.reciveScriptTimer)
        self.reciveScriptTimer = nil
    end
    self.checkReceiveTimer = true
    local HackReport = T(Global, "HackReport", nil)
    HackReport:Report(self.playerId, HackReport.actionType.failedReviceServerScriptRet, "recvive script result timeout")
end

local DynamicScriptMgr = T(Global, "DynamicScriptMgr")

DynamicScriptMgr.scripts = {}
DynamicScriptMgr.nextScriptId = 1
DynamicScriptMgr.lastScriptId = 1
DynamicScriptMgr.playerStatus = {}

local baseCheckLua = [[
    local checkFunc = function()
        %s 
    end 

    local function encodeFunc(sType, excuteRt, errorMsg)
        local strStype = tostring(sType)
        local rtLen = #excuteRt
        local strRtLen = tostring(rtLen)
        while #strRtLen < 4 do 
            strRtLen = "0"..strRtLen
        end
        return strStype..strRtLen..excuteRt..errorMsg
    end

    local ok, rt = pcall(checkFunc)
    local excuteRt = ok and rt or "nil"
    local errorMsg = not ok and tostring(rt) or "nil"
    local jsonRt = encodeFunc(%d, excuteRt, errorMsg) 
    return jsonRt
]]

function DynamicScriptMgr:init()
    local this = self
    BaseListener.registerCallBack(CEvents.PlayerReadyEvent, function(player)
        if PlayerManager:isAIPlayer(player) then
            return
        end
        this:onPlayerLogin(player)
    end)

    BaseListener.registerCallBack(CEvents.PlayerLogoutEvent, function(player)
        this:onPlayerLogout(player.userId)
    end)
    BaseListener.registerCallBack(CEvents.RemoteLuaResultEvent, function(player, id, result)
        this:onReceiveExecuteLuaResult(player, id, result)
    end)
    self:initScript()
end


function DynamicScriptMgr:initScript()
    local AntiHackConfig = T(Global, "AntiHackConfig")
    self.recviveVMResult = {}
    self.waitResultScript = {} -- 发送出去后等待结果的脚本
    -- 检查是否启用虚拟机保护模式

    if AntiHackConfig:isVMProtectionEnabled() then

        --第一个脚本是注册虚拟机，一定要等这个脚本返回才能发送之后的脚本
        self:registerScript(require "engine_server.antihack.dynamic_script.init_vm")

        -- 使用自动包装器将现有脚本转换为虚拟机保护版本
        local AutoVMWrapper = require "engine_server.antihack.vm.AutoVMWrapper"
        self:registerScript(AutoVMWrapper.new(require "engine_server.antihack.dynamic_script.check_fake_app"))
        self:registerScript(AutoVMWrapper.new(require "engine_server.antihack.dynamic_script.check_so_in_mem"))
        --self:registerScript(AutoVMWrapper.new(require "engine_server.antihack.dynamic_script.check_so_md5"))
        self:registerScript(AutoVMWrapper.new(require "engine_server.antihack.dynamic_script.check_illegal_lua_files"))
        self:registerScript(AutoVMWrapper.new(require "engine_server.antihack.dynamic_script.check_lua_hook"))

        if AntiHackConfig:isOpenScriptCheck() then 
            self:registerScript(AutoVMWrapper.new(require "engine_server.antihack.dynamic_script.check_client_lua"))
        end
    else
        -- 使用传统的明文检测脚本
        self:registerScript(require "engine_server.antihack.dynamic_script.check_so_in_mem")
        self:registerScript(require "engine_server.antihack.dynamic_script.check_fake_app")
        self:registerScript(require "engine_server.antihack.dynamic_script.check_so_md5")
        self:registerScript(require "engine_server.antihack.dynamic_script.check_illegal_lua_files")
        self:registerScript(require "engine_server.antihack.dynamic_script.check_lua_hook")
        if AntiHackConfig:isOpenScriptCheck() then 
            self:registerScript(require "engine_server.antihack.dynamic_script.check_client_lua")
        end
    end
end


function DynamicScriptMgr:onPlayerLogin(player)
    self.playerStatus[player.userId] = AntiScriptPlayerStatus.new()
    self.recviveVMResult[player.userId] = {}
    self.waitResultScript[player.userId] = nil
    self:sendScript(player)
end

function DynamicScriptMgr:onPlayerLogout(playerId)
    local playerStatus = self.playerStatus[playerId]
    if playerStatus ~= nil and playerStatus.nextSendTimer ~= nil then
        LuaTimer:cancel(playerStatus.nextSendTimer)
    end

    if playerStatus ~= nil and playerStatus.reciveScriptTimer ~= nil then
        LuaTimer:cancel(playerStatus.reciveScriptTimer)
    end

    self.playerStatus[playerId] = nil
end

function DynamicScriptMgr:registerScript(script)
    local rt = self.nextScriptId
    self.scripts[self.nextScriptId] = clone(script)
    self.lastScriptId = self.nextScriptId
    self.nextScriptId = self.nextScriptId + 1
    return rt
end

function DynamicScriptMgr:sendScript(player)
    local playerId = player.userId
	if not self.playerStatus[playerId] then 
		return 
	end
	
    local sendScriptId = self.playerStatus[playerId].nextScriptId
    local this = self

    -- vm一定要等vm初始化成功再发送
    local AntiHackConfig = T(Global, "AntiHackConfig")
    if AntiHackConfig:isVMProtectionEnabled()  and sendScriptId ~= 1 then 
        if self.recviveVMResult[playerId]  and self.recviveVMResult[playerId][1] ~= true then
            nextSendScriptTimer = LuaTimer:schedule(function()
                local newPlayer = PlayerManager:getPlayerByUserId(playerId)
                if newPlayer then
                    this:sendScript(newPlayer)
                end
            end, 5000)
            return
        end
    end

    --如果有等待结果的脚本 则等待结果
    if self.waitResultScript[playerId] ~= nil then
        nextSendScriptTimer = LuaTimer:schedule(function()
            local newPlayer = PlayerManager:getPlayerByUserId(playerId)
            if newPlayer then
                this:sendScript(newPlayer)
            end
        end, 5000)
        return
    end

    local script = self.scripts[sendScriptId]
    local scriptContent = script:getContent()
    local sendScript = string.format(baseCheckLua, scriptContent, sendScriptId)
--    if AntiHackConfig:isVMProtectionEnabled() then
--        sendScript = scriptContent
--    end
    
   
    local nextSendScriptTimer = nil
    if sendScriptId ~= self.lastScriptId then
        nextSendScriptTimer = LuaTimer:schedule(function()
            local newPlayer = PlayerManager:getPlayerByUserId(playerId)
            if newPlayer then
                this:sendScript(newPlayer)
            end
        end, 5000)
    end
    self.waitResultScript[playerId] = sendScriptId
    self.playerStatus[playerId]:onPlayerSendScript(playerId, sendScriptId, nextSendScriptTimer)

    PacketSender:getSender():sendServerLua(player.rakssid, 1, sendScript)
    if script.onSend then 
        script:onSend(playerId, sendScriptId)
    end
end


function DynamicScriptMgr:onReceiveExecuteLuaResult(player, id, data)
    if id ~= 1 then 
        return 
    end
    
    local HackReport = T(Global, "HackReport", nil)
    local playerId = player.userId
    local waitScriptId = self.waitResultScript[playerId]
    if waitScriptId == nil then
        HackReport:Report(playerId, HackReport.actionType.failedExecuteServerScript, "recive script id error: "..StringUtil.v2s(data or "{}"))
        return
    end

    self.waitResultScript[playerId] = nil
    self.recviveVMResult[playerId][waitScriptId] = true

    print("onReceiveExecuteLuaResult"..tostring(id).."user: "..tostring(playerId).."data: "..StringUtil.v2s(data))

    local sType = tonumber(string.sub(data, 1, 1))
    local rtLen = tonumber(string.sub(data, 2, 5))
    local playerId = player.userId

    if not sType or sType ~= waitScriptId or rtLen > (#data - 5) then
        local HackReport = T(Global, "HackReport", nil)
        HackReport:Report(playerId, HackReport.actionType.failedExecuteServerScript, "result nil: "..StringUtil.v2s(data or "{}"))
        return
    end

    local excuteRt = string.sub(data, 6, 6 + rtLen - 1)
    local errorMsg = string.sub(data, 6 + rtLen, -1)

-- 执行失败先上报。同时根据配置决定要不要T人
    local excuteFailed = false
    if errorMsg ~= nil and errorMsg ~= "nil"  then
         HackReport:Report(playerId, HackReport.actionType.failedExecuteServerScript, "execute error:  "..tostring(waitScriptId).." info:"..errorMsg)
         excuteFailed = true
    end

    -- 虚拟机初始化不需要处理结果
    if sType == 1 then
        self.scripts[1]:onReciveResult(playerId, "ok", false)
        return
    end

    local script = self.scripts[waitScriptId]
    local randomBeginStr = ""
    local randomEndStr = ""
    if excuteRt then 
        excuteRt, randomBeginStr, randomEndStr = script:decodeResult(excuteRt)
    end

    if not excuteRt then
        HackReport:Report(playerId, HackReport.actionType.failedExecuteServerScript, "decode result error:  "..StringUtil.v2s(data).." randomBeginStr: "..randomBeginStr.." randomEndStr: "..randomEndStr)
        excuteFailed = true
        excuteRt = "nil"
    end

    -- 虚拟机内部执行遇到错误  将excutert置nil
    if string.find(excuteRt, "vm error:") then
        HackReport:Report(playerId, HackReport.actionType.failedExecuteServerScript, "vm excute error:  "..excuteRt)
        excuteFailed = true
        excuteRt = "nil"
    end

    local AntiHackConfig = T(Global, "AntiHackConfig")
    if excuteFailed and AntiHackConfig:getConfig().kickOutVMError then
        HostApi.sendGameoverByPlatformUserId(playerId, "Error Detected Id: 16", 16)
        return
    end

    local findHack = script:onReciveResult(playerId, excuteRt, excuteFailed)

    if findHack then
        self:handleHackPlayer(script, playerId)
    end
    local playerStatus = self.playerStatus[playerId]
    if playerStatus ~= nil then
        if playerStatus.nextScriptId > self.lastScriptId then
            self.playerStatus[playerId] = nil
        end
    end
end


function DynamicScriptMgr:handleHackPlayer(script, playerId)
    local HackReport = T(Global, "HackReport")
    local hackType, hackReason = script:getReportHackInfo()
    HackReport:Report(playerId, hackType, hackReason)
    local player = PlayerManager:getPlayerByUserId(playerId)
    if player and script:needKickoutPlayer() and not isLocalWin then
        --防止被查到是哪个包 等6S后再T人。
        LuaTimer:schedule(function()
            CEvents.PlayerCheatEvent:invoke(player.rakssid, 16)
            HostApi.sendGameoverByPlatformUserId(playerId, "Error Detected Id: 16", 16)
        end, 6000)
    end
end
return DynamicScriptMgr:init()--[[aAKw7N8SvG8vqJ6JspdZ19bGLwXd17cRp7x3Fmb]]---