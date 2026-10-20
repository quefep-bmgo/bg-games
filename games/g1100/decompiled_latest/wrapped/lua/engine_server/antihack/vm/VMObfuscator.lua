--[[ZZfinfsdXImp4x2Hrt6y5FGzY2y7zq2jogNZ0Itph]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 16228
                          local checkFileName = "VMObfuscator.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[Io1doY4cwlMvwiGCuHGMCVl3Vdyw7PdYXXYqFNzmwDqRkE3e1P8w2gXV3NTggFPjNj4R2j7m7Iz6MhJhy]]-- 虚拟机代码混淆器
-- 提供多级混淆保护，防止虚拟机代码被逆向分析

local VMObfuscator = class("VMObfuscator")

function VMObfuscator:ctor()
    self.seed = os.time()
    self.level = 1
end

-- 设置混淆参数
function VMObfuscator:setParams(level, seed)
    self.level = level or 1
    self.seed = seed or os.time()
    math.randomseed(self.seed)
end

-- 主混淆函数
function VMObfuscator:obfuscate(instructions, constants, level)
    self.level = level or self.level
    
    local result = {
        instructions = instructions,
        constants = constants,
        metadata = {}
    }
    
    if self.level >= 1 then
        result = self:applyBasicObfuscation(result)
    end
    
    if self.level >= 2 then
        result = self:applyAdvancedObfuscation(result)
    end
    
    if self.level >= 3 then
        result = self:applyExtremeObfuscation(result)
    end
    
    return result
end

-- 基础混淆 (Level 1)
function VMObfuscator:applyBasicObfuscation(data)
    local result = {
        instructions = {},
        constants = {},
        metadata = data.metadata or {}
    }
    
    -- 1. 指令XOR混淆
    local instrKey = math.random(1, 255)
    result.metadata.instrKey = instrKey
    
    for i, instruction in ipairs(data.instructions) do
        local obfuscatedInstruction = {}
        for j, operand in ipairs(instruction) do
            if type(operand) == "number" then
                obfuscatedInstruction[j] = bit32 and bit32.bxor(operand, instrKey) or (operand + instrKey) % 256
            else
                obfuscatedInstruction[j] = operand
            end
        end
        result.instructions[i] = obfuscatedInstruction
    end
    
    -- 2. 常量字符串混淆（临时禁用）
    -- local strKey = math.random(1, 100)
    -- result.metadata.strKey = strKey
    
    for i, constant in pairs(data.constants) do
        if type(constant) == "string" then
            -- 临时禁用字符串混淆来调试问题
            result.constants[i] = constant
        else
            result.constants[i] = constant
        end
    end
    
    return result
end

-- 高级混淆 (Level 2)
function VMObfuscator:applyAdvancedObfuscation(data)
    local result = {
        instructions = {},
        constants = {},
        metadata = data.metadata or {}
    }
    
    -- 1. 指令重排序和填充
    local shuffleMap = {}
    local realInstructions = {}
    local paddingCount = math.random(5, 15)
    
    -- 插入垃圾指令
    for i = 1, paddingCount do
        table.insert(realInstructions, {0, 0, 0}) -- NOP指令
    end
    
    -- 重排序真实指令
    local indices = {}
    for i = 1, #data.instructions do
        table.insert(indices, i)
    end
    
    -- 简单打乱
    for i = #indices, 2, -1 do
        local j = math.random(1, i)
        indices[i], indices[j] = indices[j], indices[i]
    end
    
    for i, originalIndex in ipairs(indices) do
        local newIndex = paddingCount + i
        shuffleMap[originalIndex] = newIndex
        realInstructions[newIndex] = data.instructions[originalIndex]
    end
    
    result.instructions = realInstructions
    result.metadata.shuffleMap = shuffleMap
    result.metadata.paddingCount = paddingCount
    
    -- 2. 常量表分散
    local constMap = {}
    local scatteredConstants = {}
    
    for i, constant in pairs(data.constants) do
        local newIndex = math.random(1, 1000)
        while scatteredConstants[newIndex] do
            newIndex = math.random(1, 1000)
        end
        scatteredConstants[newIndex] = constant
        constMap[i] = newIndex
    end
    
    result.constants = scatteredConstants
    result.metadata.constMap = constMap
    
    return result
end

-- 极端混淆 (Level 3)
function VMObfuscator:applyExtremeObfuscation(data)
    local result = {
        instructions = {},
        constants = {},
        metadata = data.metadata or {}
    }
    
    -- 1. 多层加密
    local encryptionKeys = {}
    for i = 1, 3 do
        encryptionKeys[i] = math.random(1, 255)
    end
    result.metadata.encryptionKeys = encryptionKeys
    
    -- 对指令进行多层加密
    for i, instruction in ipairs(data.instructions) do
        local encryptedInstruction = {}
        for j, operand in ipairs(instruction) do
            if type(operand) == "number" then
                local encrypted = operand
                for k, key in ipairs(encryptionKeys) do
                    encrypted = bit32 and bit32.bxor(encrypted, key) or (encrypted + key) % 256
                end
                encryptedInstruction[j] = encrypted
            else
                encryptedInstruction[j] = operand
            end
        end
        result.instructions[i] = encryptedInstruction
    end
    
    -- 2. 动态解密代码生成
    local decryptCode = self:generateDecryptCode(encryptionKeys)
    result.metadata.decryptCode = decryptCode
    
    -- 3. 常量表加密
    for i, constant in pairs(data.constants) do
        if type(constant) == "string" then
            -- 临时禁用字符串混淆来调试问题
            result.constants[i] = constant
        elseif type(constant) == "number" then
            local encrypted = constant
            for _, key in ipairs(encryptionKeys) do
                encrypted = bit32 and bit32.bxor(encrypted, key) or (encrypted + key) % 256
            end
            result.constants[i] = encrypted
        else
            result.constants[i] = constant
        end
    end
    
    return result
end

-- 加密字符串
function VMObfuscator:encryptString(str, keys)
    local encrypted = ""
    for i = 1, #str do
        local char = string.byte(str, i)
        for _, key in ipairs(keys) do
            char = (char + key + i) % 256
        end
        encrypted = encrypted .. string.char(char)
    end
    return encrypted
end

-- 生成解密代码
function VMObfuscator:generateDecryptCode(keys)
    local code = [[
local function decrypt(data, keys)
    local result = {}
    for i, item in ipairs(data) do
        if type(item) == "table" then
            local decrypted = {}
            for j, operand in ipairs(item) do
                if type(operand) == "number" then
                    local value = operand
                    for k = #keys, 1, -1 do
                        value = bit32 and bit32.bxor(value, keys[k]) or (value - keys[k] + 256) % 256
                    end
                    decrypted[j] = value
                else
                    decrypted[j] = operand
                end
            end
            result[i] = decrypted
        else
            result[i] = item
        end
    end
    return result
end
]]
    return code
end

-- 生成反混淆代码
function VMObfuscator:generateDeobfuscationCode(metadata)
    local code = ""
    
    -- 基础解混淆
    if metadata.instrKey then
        code = code .. string.format([[
-- 解指令混淆
local function deobfuscateInstructions(instructions, key)
    local result = {}
    for i, instruction in ipairs(instructions) do
        local deobfuscated = {}
        for j, operand in ipairs(instruction) do
            if type(operand) == "number" then
                deobfuscated[j] = bit32 and bit32.bxor(operand, key) or (operand - key + 256) %% 256
            else
                deobfuscated[j] = operand
            end
        end
        result[i] = deobfuscated
    end
    return result
end
instructions = deobfuscateInstructions(instructions, %d)
]], metadata.instrKey)
    end
    
    if metadata.strKey then
        code = code .. string.format([[
-- 解字符串混淆（Base64解码）
local function deobfuscateConstants(constants, key)
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local lookup = {}
    for i = 1, #chars do
        lookup[chars:sub(i, i)] = i - 1
    end
    
    local function base64Decode(str, key)
        local result = ""
        -- 解码Base64
        for i = 1, #str, 4 do
            local a = lookup[str:sub(i, i)] or 0
            local b = lookup[str:sub(i + 1, i + 1)] or 0
            local c = lookup[str:sub(i + 2, i + 2)] or 0
            local d = lookup[str:sub(i + 3, i + 3)] or 0
            
            local bitmap = a * 262144 + b * 4096 + c * 64 + d
            
            result = result .. string.char(math.floor(bitmap / 65536))
            if str:sub(i + 2, i + 2) ~= "=" then
                result = result .. string.char(math.floor((bitmap %% 65536) / 256))
            end
            if str:sub(i + 3, i + 3) ~= "=" then
                result = result .. string.char(bitmap %% 256)
            end
        end
        
        -- 解密
        local decrypted = ""
        for i = 1, #result do
            local char = string.byte(result, i)
            local decryptedChar = bit32 and bit32.bxor(char, key) or (char - key + 256) %% 256
            decrypted = decrypted .. string.char(decryptedChar)
        end
        return decrypted
    end
    
    local result = {}
    for i, constant in pairs(constants) do
        if type(constant) == "string" then
            result[i] = base64Decode(constant, key)
        else
            result[i] = constant
        end
    end
    return result
end
constants = deobfuscateConstants(constants, %d)
]], metadata.strKey)
    end
    
    -- 高级解混淆
    if metadata.shuffleMap then
        code = code .. string.format([[
-- 解指令重排序
local shuffleMap = %s
local paddingCount = %d
local function restoreInstructionOrder(instructions, shuffleMap, paddingCount)
    local result = {}
    for originalIndexaa, newIndex in pairs(shuffleMap) do
        result[originalIndexaa] = instructions[newIndex]
    end
    return result
end
instructions = restoreInstructionOrder(instructions, shuffleMap, paddingCount)
]], self:serializeTable(metadata.shuffleMap), metadata.paddingCount or 0)
    end
    
    if metadata.constMap then
        code = code .. string.format([[
-- 解常量表分散
local constMap = %s
local function restoreConstants(scatteredConstants, constMap)
    local result = {}
    for originalIndexaa, newIndex in pairs(constMap) do
        result[originalIndexaa] = scatteredConstants[newIndex]
    end
    return result
end
constants = restoreConstants(constants, constMap)
]], self:serializeTable(metadata.constMap))
    end
    
    -- 极端解混淆
    if metadata.encryptionKeys then
        code = code .. string.format([[
-- 多层解密
local function multiLayerDecrypt(data, keys)
    local result = {}
    for i, item in pairs(data) do
        if type(item) == "table" then
            local decrypted = {}
            for j, operand in ipairs(item) do
                if type(operand) == "number" then
                    local value = operand
                    for k = #keys, 1, -1 do
                        value = bit32 and bit32.bxor(value, keys[k]) or (value - keys[k] + 256) %% 256
                    end
                    decrypted[j] = value
                else
                    decrypted[j] = operand
                end
            end
            result[i] = decrypted
        elseif type(item) == "string" then
        --临时禁用字符串混淆来调试问题
            result[i] = item
        elseif type(item) == "number" then
            local value = item
            for k = #keys, 1, -1 do
                value = bit32 and bit32.bxor(value, keys[k]) or (value - keys[k] + 256) %% 256
            end
            result[i] = value
        else
            result[i] = item
        end
    end
    return result
end
local encryptionKeys = %s
instructions = multiLayerDecrypt(instructions, encryptionKeys)
constants = multiLayerDecrypt(constants, encryptionKeys)
]], self:serializeTable(metadata.encryptionKeys))
    end
    
    return code
end

-- 简单的Base64编码（避免无效字符）
function VMObfuscator:base64Encode(str, key)
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local result = ""
    
    -- 先进行简单的XOR加密
    local encrypted = ""
    for i = 1, #str do
        local char = string.byte(str, i)
        local encryptedChar = bit32 and bit32.bxor(char, key) or (char + key) % 256
        encrypted = encrypted .. string.char(encryptedChar)
    end
    
    -- 然后进行Base64编码
    for i = 1, #encrypted, 3 do
        local a = string.byte(encrypted, i) or 0
        local b = string.byte(encrypted, i + 1) or 0
        local c = string.byte(encrypted, i + 2) or 0
        
        local bitmap = a * 65536 + b * 256 + c
        
        result = result .. chars:sub(math.floor(bitmap / 262144) + 1, math.floor(bitmap / 262144) + 1)
        result = result .. chars:sub(math.floor((bitmap % 262144) / 4096) + 1, math.floor((bitmap % 262144) / 4096) + 1)
        result = result .. (i + 1 <= #encrypted and chars:sub(math.floor((bitmap % 4096) / 64) + 1, math.floor((bitmap % 4096) / 64) + 1) or "=")
        result = result .. (i + 2 <= #encrypted and chars:sub((bitmap % 64) + 1, (bitmap % 64) + 1) or "=")
    end
    
    return result
end

-- 简单的Base64解码
function VMObfuscator:base64Decode(str, key)
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local result = ""
    
    -- 创建查找表
    local lookup = {}
    for i = 1, #chars do
        lookup[chars:sub(i, i)] = i - 1
    end
    
    -- 解码Base64
    for i = 1, #str, 4 do
        local a = lookup[str:sub(i, i)] or 0
        local b = lookup[str:sub(i + 1, i + 1)] or 0
        local c = lookup[str:sub(i + 2, i + 2)] or 0
        local d = lookup[str:sub(i + 3, i + 3)] or 0
        
        local bitmap = a * 262144 + b * 4096 + c * 64 + d
        
        result = result .. string.char(math.floor(bitmap / 65536))
        if str:sub(i + 2, i + 2) ~= "=" then
            result = result .. string.char(math.floor((bitmap % 65536) / 256))
        end
        if str:sub(i + 3, i + 3) ~= "=" then
            result = result .. string.char(bitmap % 256)
        end
    end
    
    -- 解密
    local decrypted = ""
    for i = 1, #result do
        local char = string.byte(result, i)
        local decryptedChar = bit32 and bit32.bxor(char, key) or (char - key + 256) % 256
        decrypted = decrypted .. string.char(decryptedChar)
    end
    
    return decrypted
end

-- 序列化表为Lua代码字符串
function VMObfuscator:serializeTable(t, indent)
    if not t then
        return "nil"
    end
    
    indent = indent or 0
    local indentStr = string.rep("    ", indent)
    
    if type(t) ~= "table" then
        if type(t) == "string" then
            return string.format("%q", t)
        else
            return tostring(t)
        end
    end
    
    local result = "{\n"
    for k, v in pairs(t) do
        local keyStr
        if type(k) == "string" and k:match("^[%a_][%w_]*$") then
            keyStr = k
        else
            keyStr = "[" .. self:serializeTable(k, 0) .. "]"
        end
        
        result = result .. indentStr .. "    " .. keyStr .. " = " .. self:serializeTable(v, indent + 1) .. ",\n"
    end
    result = result .. indentStr .. "}"
    
    return result
end

return VMObfuscator
--[[WgxgYMuKTjiKKnojRSoA7SkCZ0KieLGwgaBsHRHzYU3ab910OzWiBOABFapX0HLzjs2FWXB9vQMQKRm5v08xNA6fKESU9WlJgQwcPNjVh]]