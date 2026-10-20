local lfs = require("lfs")
local misc = require("misc")
local ts = require("telnetserver")

---@class TelnetServer
local TelnetServer = ts.mt
function TelnetServer:writeLine(...)
    local arg = table.pack(...)
    for i = 1, arg.n do
        arg[i] = tostring(arg[i]):gsub("\n", "\r\n")
    end
    self:write(table.concat(arg, "\t") .. "\r\n")
end

---@type table<TelnetServer, DebugServerInfo>
local DebugServerInfos = {}
local REPORT_SERVER = "47.243.80.43"
local LuaPrint = print

---@type DebugCmd
local DebugCmd = require "engine_base.debug.DebugCmd"
---@class DebugPort
local DebugPort = T(Global, "DebugPort")
---@type string[]
local PrintCache = T(Global, "PrintCache")

---@class DebugEnv
local DebugEnv = setmetatable({}, { __index = _G })
---@type TelnetServer
DebugEnv.curServer = nil

function DebugEnv.print(...)
    table.insert(PrintCache, { ... })
    LuaPrint(...)
    if not DebugEnv.curServer then
        return
    end
    DebugEnv.curServer:writeLine(...)
end

function DebugPort:getDebugEnv()
    return DebugEnv
end

local CC_Home = string.char(27, 91, 49, 126)
local CC_Del = string.char(27, 91, 51, 126)
local CC_End = string.char(27, 91, 52, 126)
local CC_Up = string.char(27, 91, 65)
local CC_Down = string.char(27, 91, 66)
local CC_Right = string.char(27, 91, 67)
local CC_Left = string.char(27, 91, 68)

---@param serverInfo DebugServerInfo
local function addText(serverInfo, text)
    local i = serverInfo.cursor
    serverInfo.text = serverInfo.text:sub(1, i - 1) .. text .. serverInfo.text:sub(i)
    serverInfo.cursor = i + #text
end

local ByteFunc = {
    [0] = function(tb)
        return 1, true
    end,
    [8] = function(tb)
        local c = tb.cursor - 1
        if c >= 1 then
            tb.text = tb.text:sub(1, c - 1) .. tb.text:sub(c + 1)
            tb.cursor = c
        end
        return 1, false
    end,
    [10] = function(tb)
        local nb = tb.buff:byte(2)
        if nb == 13 or nb == 0 then
            return 2, true
        else
            return 1, true
        end
    end,
    [13] = function(tb, index)
        local nb = tb.buff:byte(2)
        if nb == 10 or nb == 0 then
            return 2, true
        else
            return 1, true
        end
    end,
    [27] = function(tb)
        if #tb.buff == 1 then
            tb.text = ""
            tb.cursor = 1
            return 1, false
        end
        local cc3 = tb.buff:sub(1, 3)
        local cc4 = tb.buff:sub(1, 4)
        if cc3 == CC_Left then
            local c = tb.cursor - 1
            if c >= 1 then
                tb.cursor = c
            end
            return 3, false
        elseif cc3 == CC_Right then
            local c = tb.cursor + 1
            if c <= #tb.text + 1 then
                tb.cursor = c
            end
            return 3, false
        elseif cc3 == CC_Up then
            local lines = DebugCmd:readHistory()
            local h = tb.history or (#lines + 1)
            if h > 1 then
                h = h - 1
                tb.text = lines[h] or ""
                tb.cursor = #tb.text + 1
                tb.history = h
            end
            return 3, false
        elseif cc3 == CC_Down then
            local h = tb.history
            if h then
                local lines = DebugCmd:readHistory()
                if h >= #lines then
                    h = nil
                    tb.text = ""
                    tb.cursor = 1
                else
                    h = h + 1
                    tb.text = lines[h]
                    tb.cursor = #tb.text + 1
                end
                tb.history = h
            end
            return 3, false
        elseif cc4 == CC_Del then
            local c = tb.cursor
            tb.text = tb.text:sub(1, c - 1) .. tb.text:sub(c + 1)
            return 4, false
        elseif cc4 == CC_Home then
            tb.cursor = 1
            return 4, false
        elseif cc4 == CC_End then
            tb.cursor = #tb.text + 1
            return 4, false
        end
        return #cc3, false
    end,
    [127] = function(tb)
        local c = tb.cursor
        tb.text = tb.text:sub(1, c - 1) .. tb.text:sub(c + 1)
        return 1, false
    end,
    [255] = function(tb)
        local buff = tb.buff
        if #buff < 2 then
            return false
        end
        local b = buff:byte(2)
        if b == 255 then
            addText(tb, string.char(255))
            return 2, false
        end
        if b ~= 250 then
            print("[DebugPort] unknown code:", b)
            return 2, false
        end
        local sub = ""
        local iac = false
        for i = 3, #buff do
            b = buff:byte(i)
            if iac then
                if b == 255 then
                    sub = sub .. string.char(b)
                elseif b == 240 then
                    return i, sub
                else
                    print("[DebugPort] unknown sub code:", b)
                    return i, false
                end
            elseif b == 255 then
                iac = true
            else
                sub = sub .. string.char(b)
            end
        end
        return false
    end,
}

---@param serverInfo DebugServerInfo
local function addBuffText(serverInfo, index)
    if index <= 1 then
        return false
    end
    addText(serverInfo, serverInfo.buff:sub(1, index - 1))
    serverInfo.buff = serverInfo.buff:sub(index)
    return true
end

---@param serverInfo DebugServerInfo
local function readLine(serverInfo)
    if not serverInfo.server then
        return
    end
    local buff, running = serverInfo.server:readbuff()
    buff = buff or ''
    serverInfo.buff = serverInfo.buff .. buff
    if serverInfo.buff == '' then
        return nil, running
    end
    local index = 1
    while index <= #serverInfo.buff do
        local b = serverInfo.buff:byte(index)
        local func = ByteFunc[b]
        if func then
            addBuffText(serverInfo, index)
            local len, lok = func(serverInfo, index)
            if not len then
                break
            end
            serverInfo.buff = serverInfo.buff:sub(len + 1)
            if lok then
                return lok, running
            end
            index = 1
        else
            index = index + 1
        end
    end
    addBuffText(serverInfo, index)
    return false, running
end

---@param serverInfo DebugServerInfo
local function writeInput(serverInfo)
    if not serverInfo.server then
        return
    end
    local text = serverInfo.text
    local sp = serverInfo.inputLen - #text
    if sp < 0 then
        sp = 0
    end
    local prompt = ""
    if serverInfo.isREPLMode then
        prompt = prompt .. "i"
    end
    if serverInfo.isMultilineStatement then
        prompt = prompt .. ">>> "
    else
        prompt = prompt .. "> "
    end

    serverInfo.server:write(string.rep(CC_Up, serverInfo.inputRow) .. string.char(13) .. prompt .. text .. string.rep(" ", sp + 1) .. string.char(8))
    serverInfo.inputLen = #text
    local cursor = serverInfo.cursor + #prompt - 1
    serverInfo.inputRow = math.floor(cursor / serverInfo.screenWidth)
    serverInfo.server:write(string.rep(CC_Up, math.floor((serverInfo.inputLen + sp + #prompt) / serverInfo.screenWidth) - serverInfo.inputRow)
            .. string.char(13) .. string.rep(CC_Right, cursor % serverInfo.screenWidth))
end

---@param serverInfo DebugServerInfo
local function doSub(serverInfo, data)
    local code = data:byte(1)
    if code == 31 then
        -- Negotiate About Window Size
        local x1, x2 = data:byte(2, 3)
        serverInfo.screenWidth = x1 * 256 + x2
        print("screenWidth", serverInfo.screenWidth)
    else
        print("[DebugPort] unknown sub option:", code)
    end
end

function DebugPort.Init(path, from, to)
    if not isTest then
        return
    end
    LuaTimer:scheduleTicker(DebugPort.Tick, 1)
    assert(not DebugPort.listen, "already inited!")
    DebugCmd:init(path)
    to = to or from
    local listen = ts.create()
    for port = from, to do
        if ts.listen(listen, "127.0.0.1", port) then
            DebugPort.port = port
            print("[DebugPort] start listen:", port)
            break
        end
    end
    DebugPort.udp = ts.create(true)
    ts.noblock(DebugPort.udp, true)
    if not DebugPort.port then
        ts.close(listen)
        print("[DebugPort] start failed!", from, to)
        return false
    end
    ts.listen(DebugPort.udp, "127.0.0.1", DebugPort.port, true)
    ts.noblock(listen, true)
    DebugPort.listen = listen
    local engineVersion = EngineVersionSetting.getEngineVersion()
    DebugPort.engineVersion = engineVersion
    local isClient = isClient
    local data = misc.sys_info()
    if isClient and not Platform.isWindow() then

    end
    data.port = DebugPort.port
    data.dir = lfs.currentdir()
    data.game = GameType
    data.gamePort = DebugPort.gamePort
    data.client = isClient
    data.engineVersion = engineVersion
    if isClient then
        data.userId = CGame.Instance():getPlatformUserId()
    end
    ts.sendto(DebugPort.udp, misc.data_encode(data), REPORT_SERVER, 10086)
    return true
end

function DebugPort.Tick()
    if not DebugPort.listen then
        return
    end
    local sock, addr = ts.accept(DebugPort.listen)
    if sock then
        LogUtil.logScriptException("[DebugPort] client connected:", addr, sock)
        ---@type TelnetServer
        local server = ts.newserver(sock)
        ---@class DebugServerInfo
        ---@field server TelnetServer
        local serverInfo = {
            server = server,
            addr = addr,
            buff = "",
            text = "",
            cursor = 1,
            history = nil,
            inputLen = 0,
            inputRow = 0,
            screenWidth = 999,
        }
        DebugServerInfos[server] = serverInfo
        server:setoption(1, false, true)    -- echo
        server:setoption(3, false, true)    -- SUPPRESS-GO-AHEAD
        server:setoption(31, true, true)    -- Telnet Window Size
        server:setoption(34, true, false)    -- Linemode
        server:start()
        if isClient then
            local player = PlayerManager:getClientPlayer()
            if player then
                server:writeLine(string.format("[port:%d] Client of %s[%d]", DebugPort.port, tostring(player.userId), player.entityId))
            else
                server:writeLine(string.format("[port:%d] Client without player", DebugPort.port))
            end
        else
            server:writeLine(string.format("[port:%d] Server", DebugPort.port))
        end
        server:writeLine("dir:", lfs.currentdir())
        server:writeLine("game:", GameType, DebugPort.engineVersion)
        server:writeLine("isTest=" .. tostring(isTest), "isLocalWin=" .. tostring(isLocalWin),
                "isClient=" .. tostring(isClient), "isBeta=" .. tostring(isBeta), "isGarena=" .. tostring(isGarena))
        DebugCmd:doCmd(serverInfo, "help", true)
    end
    for server, serverInfo in pairs(DebugServerInfos) do
        for _ = 1, 10 do
            -- server might be closed in the last loop
            if serverInfo.server == nil then
                break
            end
            local data, running = readLine(serverInfo)
            if data == true then
                local text = serverInfo.text
                if text ~= "" then
                    DebugCmd:addHistory(text)
                end
                serverInfo.cursor = #text + 1
                writeInput(serverInfo)
                server:writeLine()
                serverInfo.text = ""
                serverInfo.cursor = 1
                serverInfo.inputLen = 0
                serverInfo.inputRow = 0
                serverInfo.history = nil
                DebugCmd:doCmd(serverInfo, text, true)
            elseif data ~= nil then
                if type(data) == "string" then
                    doSub(serverInfo, data)
                end
                writeInput(serverInfo)
            elseif not running then
                print("[DebugPort] client closed:", serverInfo.addr)
                DebugServerInfos[server] = nil
                server:close()
                serverInfo.server = nil
                break
            elseif not data then
                break
            end
        end
    end
end

---@param serverInfo DebugServerInfo
function DebugPort.writeInput(serverInfo)
    writeInput(serverInfo)
end

---@param serverInfo DebugServerInfo
function DebugPort.Quit(serverInfo)
    if not serverInfo.server then
        return
    end
    DebugServerInfos[serverInfo.server] = nil
    serverInfo.server:close()
    serverInfo.server = nil
end

return DebugPort
