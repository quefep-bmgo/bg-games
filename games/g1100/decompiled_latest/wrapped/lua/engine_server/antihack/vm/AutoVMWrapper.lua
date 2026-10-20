--[[SayY1o]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 11356
                          local checkFileName = "AutoVMWrapper.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[NOZcA0XRAVbx5x2RvR1dBqL6C4jWw23XRqXxppn5ZXEfaDypXX3hOp9L4hwYAyBphiJoOky5ktfqzUWqagM]]-- 自动虚拟机包装器
-- 自动将现有的检测脚本转换为虚拟机保护版本

local AutoVMWrapper = class("AutoVMWrapper", require "engine_server.antihack.dynamic_script.check_base")
local RealLuaToVMConverter = require "engine_server.antihack.vm.RealLuaToVMConverter"
local VMObfuscator = require "engine_server.antihack.vm.VMObfuscator"
local VMCompileCache = require "engine_server.antihack.vm.VMCompileCache"

function AutoVMWrapper:ctor(originalScript)
    self.super:ctor()
    self.originalScript = clone(originalScript)
    self.converter = RealLuaToVMConverter.new()
    self.obfuscator = VMObfuscator.new()
    self.cacheKey = nil
end

-- 获取原始脚本的内容并自动转换
function AutoVMWrapper:getContent()
    -- 获取原始脚本内容
    local originalContent = self.originalScript:getContent()
    
    -- 获取配置
    local AntiHackConfig = T(Global, "AntiHackConfig")
    local obfuscationLevel = AntiHackConfig:getVMObfuscationLevel()
    local randomSeed = AntiHackConfig:getVMRandomSeed()
    
    -- 生成缓存键
    self.cacheKey = VMCompileCache:generateCacheKey(originalContent, obfuscationLevel, randomSeed)
    
    -- 尝试从缓存获取
    local cachedResult = VMCompileCache:get(self.cacheKey)
    if cachedResult then
        return cachedResult
    end
    
    -- 缓存未命中，重新编译
    local compiledResult = self:compileOriginalScript(originalContent, obfuscationLevel, randomSeed)
    
    -- 存入缓存
    VMCompileCache:set(self.cacheKey, compiledResult)
    
    return compiledResult
end

-- 编译原始脚本
function AutoVMWrapper:compileOriginalScript(originalContent, obfuscationLevel, randomSeed)
    local compiledData
    
    -- 尝试转换脚本，如果失败则使用备用方案
    local success, result = pcall(function()
        return self.converter:convertScript(originalContent)
    end)
    
    if success and result then
        compiledData = result
    else
        -- 解析失败，使用备用的简单模式
        LogUtil.logWarning("[AutoVMWrapper] 脚本解析失败，使用备用模式: " .. tostring(result))
        compiledData = self:createFallbackInstructions()
    end
    return self:generateVMCode(compiledData)
end

-- 创建备用指令（当解析失败时使用）
function AutoVMWrapper:createFallbackInstructions()
    local LuaVM = require "engine_server.antihack.vm.LuaVM"
    
    return {
        instructions = {
            {LuaVM.OpCode.TBL_NEW},           -- 创建结果表
            {LuaVM.OpCode.DUP},              -- 复制表引用
            {LuaVM.OpCode.LOAD_CONST, 1},    -- 加载键 "status"
            {LuaVM.OpCode.LOAD_CONST, 2},    -- 加载值 "normal"
            {LuaVM.OpCode.TBL_SET},          -- 设置 result.status = "normal"
            {LuaVM.OpCode.HALT}              -- 停机并返回结果
        },
        constants = {
            [1] = "status",
            [2] = "normal"
        }
    }
end

-- 生成虚拟机执行代码
function AutoVMWrapper:generateVMCode(obfuscatedData)

    local CodeEncoder = T(Global, "CodeEncoder")
    --加密常量表
    local encodedConstants = CodeEncoder:encodeConstants(obfuscatedData.constants)

    local vmContent = [[ local instructions = ]] .. self:serializeTable(obfuscatedData.instructions) .. [[
    local constants = ]] .. self:serializeTable(encodedConstants)
    

    -- byteArrayToString aab
    local strDecrepyFunc = [[

    local function byteArrayToString(byteArray)
        local str = ""
        for i = 1, #byteArray do
            str = str .. string.char(byteArray[i])
        end
        return str
    end

    local function strDecryptDecodeString(str, keys)
        local decrypted = ""
        for i = 1, #str do
            local char = string.byte(str, i)
            -- 按相反顺序移除每个密钥
            for j = #keys, 1, -1 do
                local key = keys[j]
                char = (char - key + 256) % 256  -- 加256确保结果为正数
            end
            -- 移除位置偏移
            char = (char - i + 256) % 256
            decrypted = decrypted .. string.char(char)
        end
        return decrypted
    end

    ]]

    local vmCode = [[

    local keys = {97, 107, 101, 102, 100, 98, 99, 100}
    local encryptedBytes = Global_Fix
    local encryptedString = byteArrayToString(encryptedBytes)
    local vm = _G[strDecryptDecodeString(encryptedString, keys)]
    vm = vm["vm_table_name"]
    return vm["vmExecute"](vm, instructions, constants)
    ]]

    -- 替换加密后的global
    local keys = {97, 107, 101, 102, 100, 98, 99, 100} -- "akefdbcd" 转换为字节数组
    local encodedGlobal = self:encodeString("Global", keys)
    local oriGlobal = self:decodeString(encodedGlobal, keys)
    
    -- 将加密字符串转换为字节数组表示法，避免特殊字符问题
    local byteArray = self:stringToByteArray(encodedGlobal)
    vmCode = vmCode:gsub("Global_Fix", byteArray)

    -- 替换加密后的 vm_table_name
    local encodedVmTableName = CodeEncoder:getVMTableName()
    vmCode = vmCode:gsub("vm_table_name", encodedVmTableName)

    -- 替换 execute 函数名字
    local encodedExecuteFunctionName = CodeEncoder:getExecuteFunctionName()
    vmCode = vmCode:gsub("vmExecute", encodedExecuteFunctionName)

    -- 组装代码
    vmCode = vmContent .. strDecrepyFunc .. vmCode
    local encodeVm = CodeEncoder:encodeVMCode(vmCode)
    return encodeVm
end

-- 虚拟机外的字符串加密
function AutoVMWrapper:encodeString(str, keys)
    local encrypted = ""
    for i = 1, #str do
        local char = string.byte(str, i)
        -- 加上位置偏移
        char = (char + i) % 256
        -- 依次应用每个密钥
        for _, key in ipairs(keys) do
            char = (char + key) % 256
        end
        encrypted = encrypted .. string.char(char)
    end
    return encrypted
end

function AutoVMWrapper:decodeString(str, keys)
    local decrypted = ""
    for i = 1, #str do
        local char = string.byte(str, i)
        -- 按相反顺序移除每个密钥
        for j = #keys, 1, -1 do
            local key = keys[j]
            char = (char - key + 256) % 256  -- 加256确保结果为正数
        end
        -- 移除位置偏移
        char = (char - i + 256) % 256
        decrypted = decrypted .. string.char(char)
    end
    return decrypted
end

-- 将字符串转换为字节数组表示法
function AutoVMWrapper:stringToByteArray(str)
    local bytes = {}
    for i = 1, #str do
        bytes[i] = string.byte(str, i)
    end
    return "{" .. table.concat(bytes, ",") .. "}"
end

-- 序列化表为Lua代码
function AutoVMWrapper:serializeTable(tbl)
    if type(tbl) ~= "table" then
        if type(tbl) == "string" then
            return self:escapeString(tbl)
        else
            return tostring(tbl)
        end
    end
    
    local result = "{"
    local isArray = true
    local maxIndex = 0
    
    -- 检查是否为数组
    for k, v in pairs(tbl) do
        if type(k) ~= "number" then
            isArray = false
            break
        end
        maxIndex = math.max(maxIndex, k)
    end
    
    if isArray then
        for i = 1, maxIndex do
            if i > 1 then result = result .. "," end
            result = result .. self:serializeTable(tbl[i])
        end
    else
        local first = true
        for k, v in pairs(tbl) do
            if not first then result = result .. "," end
            first = false
            
            if type(k) == "string" then
                result = result .. '["' .. k .. '"]='
            else
                result = result .. "[" .. tostring(k) .. "]="
            end
            result = result .. self:serializeTable(v)
        end
    end
    
    result = result .. "}"
    return result
end

-- 安全的字符串转义函数
function AutoVMWrapper:escapeString(str)
    if not str then
        return "nil"
    end
    
    -- 使用长字符串语法来避免转义问题
    local hasNewline = str:find("\n")
    local hasCarriageReturn = str:find("\r")
    local hasQuote = str:find('"')
    local hasSingleQuote = str:find("'")
    local hasBackslash = str:find("\\")
    
    -- 如果字符串包含特殊字符，使用长字符串语法
    if hasNewline or hasCarriageReturn or hasBackslash or (hasQuote and hasSingleQuote) then
        -- 找一个不在字符串中的长字符串分隔符
        local level = 0
        local delimiter = "["
        while str:find("%]" .. string.rep("=", level) .. "%]") do
            level = level + 1
        end
        delimiter = "[" .. string.rep("=", level) .. "["
        local endDelimiter = "]" .. string.rep("=", level) .. "]"
        
        return delimiter .. str .. endDelimiter
    elseif hasQuote then
        -- 使用单引号
        return "'" .. str .. "'"
    else
        -- 使用双引号，但需要转义一些基本字符
        local escaped = str:gsub("\\", "\\\\")  -- 转义反斜杠
        escaped = escaped:gsub('"', '\\"')      -- 转义双引号
        escaped = escaped:gsub("\n", "\\n")     -- 转义换行符
        escaped = escaped:gsub("\r", "\\r")     -- 转义回车符
        escaped = escaped:gsub("\t", "\\t")     -- 转义制表符
        return '"' .. escaped .. '"'
    end
end

-- 代理原始脚本的方法
function AutoVMWrapper:getReportHackInfo()
    if self.originalScript.getReportHackInfo then
        return self.originalScript:getReportHackInfo()
    end
    local HackReport = T(Global, "HackReport", nil)
    return HackReport.actionType.unknown, "VM自动包装检测"
end

function AutoVMWrapper:needKickoutPlayer()
    if self.originalScript.needKickoutPlayer then
        return self.originalScript:needKickoutPlayer()
    end
    local AntiHackConfig = T(Global, "AntiHackConfig")
    return AntiHackConfig:getConfig().KickOutVMHack
end

function AutoVMWrapper:onSend(playerId, id)
    if self.originalScript.onSend then
        self.originalScript:onSend(playerId, id)
    end
end

function AutoVMWrapper:onReciveResult(playerId, result, excuteFailed)
    -- 先调用原始脚本的结果处理
    if self.originalScript.onReciveResult then
        return self.originalScript:onReciveResult(playerId, result, excuteFailed)
    end
end

function AutoVMWrapper:decodeResult(str)
    return self.originalScript:decodeResult(str)
end
return AutoVMWrapper
--[[mhVipWrrApIiLw564u3jlK9Sfi9NAXfzDk9U8ja3lD8fQfUIwdP2MgU9AzFa9CJcOt2lrhISbith2bsO7AeC89K2ztGf]]