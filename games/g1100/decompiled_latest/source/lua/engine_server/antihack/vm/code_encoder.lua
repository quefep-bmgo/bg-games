--代码加密器，主要是将函数名字替换成乱码，字符串加密，然后给代码添加一些花指令

local function dec2hex(input)
    return string.format('%X', tonumber(input));
end;

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

local function explode(delim, input)
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

local function strEncrypt(input, key)
    if(#input == 0) then return "" end

    if(input == "\\n") then return input end

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

local function strDecrypt(input, key)
    if(#input == 0) then return "" end
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


local CodeEncoder = T(Global, "CodeEncoder")

function CodeEncoder:encodeString()

end

function CodeEncoder:getVMTableName()
    if not self.vmTableName then  return "LuaVM" end
    return self.vmTableName
end

function CodeEncoder:getExecuteFunctionName()
    if not self.vmExecuteFuncionName then  return "execute" end 
    return self.vmExecuteFuncionName
end

function CodeEncoder:encodeFunction()

end

function CodeEncoder:addFlowerInstruction()

end

-- 转义字符串中的正则表达式魔法字符（用于模式匹配）
local function escapePattern(str)
    -- Lua 的魔法字符: ^$()%.[]*+-?
    return str:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
end

-- 转义替换字符串中的特殊字符（用于替换内容）
local function escapeReplacement(str)
    -- 在替换字符串中，% 需要转义为 %%
    return str:gsub("%%", "%%%%")
end

-- 转义字符串中的单引号（用于在单引号字符串中）
local function escapeSingleQuote(str)
    return str:gsub("'", "\\'")
end


-- 生成随机标识符名（符合Lua标识符规范：字母或下划线开头，后跟字母、数字或下划线）
local function generateRandomIdentifier()
    local identifier = ""
    -- 第一个字符必须是字母或下划线
    local firstChar = math.random(1, 2)
    if firstChar == 1 then
        -- 生成字母 a-z 或 A-Z
        local isUpper = math.random(1, 2) == 1
        if isUpper then
            identifier = string.char(math.random(65, 90)) -- A-Z
        else
            identifier = string.char(math.random(97, 122)) -- a-z
        end
    else
        -- 生成下划线
        identifier = "_"
    end
    
    -- 后续字符可以是字母、数字或下划线
    for i = 2, 8 do
        local charType = math.random(1, 3)
        if charType == 1 then
            -- 字母 a-z
            identifier = identifier .. string.char(math.random(97, 122))
        elseif charType == 2 then
            -- 字母 A-Z
            identifier = identifier .. string.char(math.random(65, 90))
        else
            -- 数字 0-9 或下划线
            local numOrUnderscore = math.random(1, 2)
            if numOrUnderscore == 1 then
                identifier = identifier .. string.char(math.random(48, 57)) -- 0-9
            else
                identifier = identifier .. "_"
            end
        end
    end
    
    return identifier
end

-- 加密
function CodeEncoder:encodeConstants(constants)
    for i, v in pairs(constants) do
        if type(v) == "string" then
            constants[i] = strEncrypt(v, self.stringEncodeKey)
        end
    end
    return constants
end

function CodeEncoder:encryptIdentifier(identifier)
    return strEncrypt(identifier, self.stringEncodeKey)
end
-- luaVm 只需要混淆字符串即可
function CodeEncoder:encodeLua(luaCode)
    if self.cacheEncodeLua ~= nil then 
        return self.cacheEncodeLua
    end

    -- 先替换字符串加密秘钥 将占位符 string_encode_key 替换成 stringEncodeKey
    self.stringEncodeKey = randString(6) ..":"..randString(6)

   

    -- 移除注释
    luaCode = luaCode:gsub("%-%-[^\r\n]*", "")
    luaCode = luaCode:gsub("%-%-%[%[.-%]%]", "")
    -- 词法分析 拿到函数名 以及 字符串
    local tokens = self:tokenize(luaCode)
    local replacedString = {}
    local replacedIdentifier = {} -- 标识符混淆映射表


    --提前准备好luaVM  vmStrDecrypt 的混淆串
    replacedString["LuaVM"] = generateRandomIdentifier()
    replacedIdentifier["LuaVM"] = replacedString["LuaVM"]
    replacedIdentifier["vmStrDecrypt"] = generateRandomIdentifier()

    -- 标记需要替换的字符串token和标识符token
    for index, token in ipairs(tokens) do

        -- 空字符串不处理
        if token.type == "string"  then
            if #token.value == 0 then 
                token.encryptedValue = "''"
            elseif token.value == "string_encode_key" then
                token.encryptedValue = "'"..self.stringEncodeKey.."'"
            elseif self.beginEncodeString then
                if not replacedString[token.value]  then
                    replacedString[token.value] = strEncrypt(token.value, self.stringEncodeKey)
                end
                -- 如果已经处理过，也设置加密值
                local encryptedValue = replacedString[token.value]
                if token.value == "LuaVM" then 
                    self.vmTableName = encryptedValue
                    token.encryptedValue = "'"..encryptedValue.."'"
                else
                    -- 转义加密值中的单引号
                    local escapedEncryptedValue = escapeSingleQuote(encryptedValue)
                    local escapedKey = escapeSingleQuote(self.stringEncodeKey)
                    token.encryptedValue = replacedIdentifier["vmStrDecrypt"].. "('"..escapedEncryptedValue.."','"..escapedKey.."')"
                end
            else
                token.encryptedValue = "'"..token.value.."'"
            end
        elseif token.type == "identifier" then
            -- 将表以及成员函数都改为随机字符串
            local identifier = token.value
            local prevToken = nil
            local preIndex = index -1
            local prepreIndex = index - 2
            if prepreIndex >=1 then
                if tokens[preIndex].value == "." or tokens[preIndex].value == ":" or tokens[preIndex].value == "["  then
                    prevToken = tokens[prepreIndex]
                end
            end
            if self:isGlobleIdentifier(prevToken, identifier) then
                ---不做处理
                token.obfuscatedValue = identifier
            else
                if not replacedIdentifier[identifier] then
                    replacedIdentifier[identifier] = generateRandomIdentifier()
                end
                token.obfuscatedValue = replacedIdentifier[identifier]
                if identifier == "vmExecute" then
                    self.vmExecuteFuncionName = token.obfuscatedValue
                end
            end
        elseif token.type == "keyword" and token.value == "_G" then
            self.beginEncodeString = true 
        end
    end


    -- 判断两个token之间是否需要空格
    local function needSpace(curr, nextr)
        -- . : [] 前后都可以不需要空格
        local noSpaceIdentifiers = {
            ".",
            ":",
            "[",
            "]",
            "(",
            ")",
        }

        -- a.b or a:b
        if curr and (curr.value == "."  or curr.value == ":") then 
            return false
        end

        -- a[] or a()
        if nextr and (nextr.value == "("  or nextr.value == "["  or nextr.value == ":" or nextr.value == ".") then 
            return false
        end

        -- 其他情况默认需要空格
        return true
    end

    --根据token 重新生成lua代码（只遵循lua语法，不保留原始格式）
    local newLuaCode = ""
    local nextToken = nil
    
    for index, token in ipairs(tokens) do
        nextToken = tokens[index + 1]
        if token.type == "whitespace" then
            -- 跳过所有空白字符（包括空格、制表符、换行符），不保留原始格式
            -- 只根据lua语法需要添加必要的空格
            --newLuaCode = newLuaCode ..token.value
            newLuaCode = newLuaCode
        else

            if token.type == "string" then
                -- 字符串类型，替换为加密函数调用
                newLuaCode = newLuaCode .. token.encryptedValue
            elseif token.type == "identifier" then
                -- 标识符类型，使用混淆后的值（如果已设置）
                if token.obfuscatedValue then
                    newLuaCode = newLuaCode .. token.obfuscatedValue
                else
                    -- 如果未设置混淆值，使用原值（理论上不应该发生）
                    newLuaCode = newLuaCode .. token.value
                end
            elseif token.type == "number" then
                -- 数字类型，直接添加（已经是字符串形式）
                newLuaCode = newLuaCode .. token.value
            else
                -- 其他类型（关键字、运算符等），直接添加
                newLuaCode = newLuaCode .. token.value
            end

            -- 根据后一个token决定是否需要添加空格
            if needSpace(token, nextToken) then
                newLuaCode = newLuaCode .. " "
            end
        end
    end
    self.cacheEncodeLua = newLuaCode
    return newLuaCode
end

function CodeEncoder:isGlobleIdentifier(preindextifier, identifier)
    return self:isSystemGlobleIdentifier(preindextifier, identifier)
end

function CodeEncoder:isEngineGlobalFunction(identifier)
    local globalFunctions = {
            -- 游戏引擎全局变量
            ["T"] = T,
            ["Global"] = Global,
            ["StringUtil"] = StringUtil,
            ["json"] = json,
            ["CGame"] = CGame,
            ["misc"] = misc,
            ["LuaTimer"] = LuaTimer,
    }
end

function CodeEncoder:isSystemGlobleIdentifier(preindextifier, identifier)
           -- 全局变量白名单
           local globalWhitelist = {
            -- 基础Lua函数
            ["print"] = print,
            ["tostring"] = tostring,
            ["tonumber"] = tonumber,
            ["type"] = type,
            ["pairs"] = pairs,
            ["ipairs"] = ipairs,
            ["next"] = next,
            ["table"] = table,
            ["string"] = string,
            ["math"] = math,
            ["os"] = os,
            ["io"] = io,
            ["_G"] = _G,

            --引擎全局变量
            ["T"] = T,
            ["Global"] = Global,
            ["StringUtil"] = StringUtil,
            ["json"] = json,
            ["CGame"] = CGame,
            ["misc"] = misc,
            ["LuaTimer"] = LuaTimer,
            ["MathUtil"] = MathUtil
        }

        if preindextifier == nil then 
            return globalWhitelist[identifier] ~= nil
        end

        for i, v in pairs(globalWhitelist) do
            if type(v) == "table" and v[identifier] ~= nil then
                return true
            end
        end

        return false
end

function CodeEncoder:encodeVMCode(code)
        -- 移除注释
        code = code:gsub("%-%-[^\r\n]*", "")
        code = code:gsub("%-%-%[%[.-%]%]", "")
        -- 词法分析 拿到函数名 以及 字符串
        local tokens = self:tokenize(code)

        -- 标记需要替换的字符串token和标识符token
        local replacedIdentifier = {} -- 标识符混淆映射表
        for index, token in ipairs(tokens) do
            if token.type == "identifier" then
                -- 将表以及成员函数都改为随机字符串
                local identifier = token.value
                local prevToken = nil
                local preIndex = index -1
                local prepreIndex = index - 2
                if prepreIndex >=1 then
                    if tokens[preIndex].value == "." or tokens[preIndex].value == ":" or tokens[preIndex].value == "["  then
                        prevToken = tokens[prepreIndex]
                    end
                end
                if self:isGlobleIdentifier(prevToken, identifier) then
                    ---不做处理
                    token.obfuscatedValue = identifier
                else
                    if not replacedIdentifier[identifier] then
                        replacedIdentifier[identifier] = generateRandomIdentifier()
                    end
                    token.obfuscatedValue = replacedIdentifier[identifier]
                end
            end
        end


            -- 判断两个token之间是否需要空格
    local function needSpace(curr, nextr)
        -- . : [] 前后都可以不需要空格
        local noSpaceIdentifiers = {
            ".",
            ":",
            "[",
            "]",
            "(",
            ")",
        }

        -- a.b or a:b
        if curr and (curr.value == "."  or curr.value == ":") then 
            return false
        end

        -- a[] or a()
        if nextr and (nextr.value == "("  or nextr.value == "["  or nextr.value == ":" or nextr.value == ".") then 
            return false
        end

        -- 其他情况默认需要空格
        return true
    end
            --根据token 重新生成lua代码（只遵循lua语法，不保留原始格式）
        local newCode = ""
        local nextToken = nil
        for index, token in ipairs(tokens) do
            nextToken = tokens[index + 1]
            if token.type == "whitespace" then
                -- 跳过所有空白字符（包括空格、制表符、换行符），不保留原始格式
                -- 只根据lua语法需要添加必要的空格

                --newCode = newCode..token.value
                newCode = newCode
            else
    
                if token.type == "string" then
                    -- 字符串类型，不做处理
                    newCode = newCode .. "'"..token.value.."'"
                elseif token.type == "identifier" then
                    -- 标识符类型，使用混淆后的值（如果已设置）
                    if token.obfuscatedValue then
                        newCode = newCode .. token.obfuscatedValue
                    else
                        -- 如果未设置混淆值，使用原值（理论上不应该发生）
                        newCode = newCode .. token.value
                    end
                elseif token.type == "number" then
                    -- 数字类型，直接添加（已经是字符串形式）
                    newCode = newCode .. token.value
                else
                    -- 其他类型（关键字、运算符等），直接添加
                    newCode = newCode .. token.value
                end
    
                -- 根据后一个token决定是否需要添加空格
                if needSpace(token, nextToken) then
                    newCode = newCode .. " "
                end
            end
        end
    return newCode
end
-- 词法分析器
function CodeEncoder:tokenize(code)
    local tokens = {}
    local i = 1
    
    -- 移除注释
    code = code:gsub("%-%-[^\r\n]*", "")
    code = code:gsub("%-%-%[%[.-%]%]", "")
    
    while i <= #code do
        local char = code:sub(i, i)
        
        -- 保存空白字符
        if char:match("%s") then
            local whitespace = ""
            while i <= #code and code:sub(i, i):match("%s") do
                whitespace = whitespace .. code:sub(i, i)
                i = i + 1
            end
            table.insert(tokens, {type = "whitespace", value = whitespace})
            
        -- 字符串字面量
        elseif char == '"' or char == "'" then
            local quote = char
            local str = ""
            i = i + 1
            while i <= #code do
                local currentChar = code:sub(i, i)
                if currentChar == quote then
                    -- 找到结束引号
                    break
                elseif currentChar == '\\' and i < #code then
                    -- 处理转义字符
                    i = i + 1
                    local nextChar = code:sub(i, i)
                    if nextChar == 'n' then
                        str = str .. '\n'
                    elseif nextChar == 't' then
                        str = str .. '\t'
                    elseif nextChar == 'r' then
                        str = str .. '\r'
                    elseif nextChar == '\\' or nextChar == quote then
                        str = str .. nextChar
                    else
                        -- 其他转义字符，保留原样
                        str = str .. '\\' .. nextChar
                    end
                    i = i + 1
                else
                    str = str .. currentChar
                    i = i + 1
                end
            end
            i = i + 1 -- 跳过结束引号
            table.insert(tokens, {type = "string", value = str, quote = quote})
            
        -- 数字字面量（支持十进制和十六进制）
        elseif char:match("%d") or (char == "0" and i < #code and code:sub(i+1, i+1):lower() == "x") then
            local num = ""
            
            -- 检查是否是十六进制数字（0x 或 0X 开头）
            if char == "0" and i < #code and code:sub(i+1, i+1):lower() == "x" then
                -- 十六进制数字
                num = num .. code:sub(i, i) -- 添加 '0'
                i = i + 1
                num = num .. code:sub(i, i) -- 添加 'x' 或 'X'
                i = i + 1
                
                -- 读取十六进制数字 (0-9, a-f, A-F)
                while i <= #code and code:sub(i, i):match("[%da-fA-F]") do
                    num = num .. code:sub(i, i)
                    i = i + 1
                end
            else
                -- 十进制数字（包括小数）
                while i <= #code and code:sub(i, i):match("[%d%.]") do
                    num = num .. code:sub(i, i)
                    i = i + 1
                end
            end
            
            table.insert(tokens, {type = "number", value = num}) -- 保持字符串形式，避免精度丢失
            
        -- 标识符和关键字
        elseif char:match("[%a_]") then
            local ident = ""
            while i <= #code and code:sub(i, i):match("[%w_]") do
                ident = ident .. code:sub(i, i)
                i = i + 1
            end
            
            -- 检查是否是关键字
            local keywords = {
                ["local"] = true, ["if"] = true, ["then"] = true, ["else"] = true,['elseif'] = true,
                ["end"] = true, ["for"] = true, ["do"] = true, ["while"] = true, ["break"] = true,
                ["function"] = true, ["return"] = true, ["true"] = true, ["false"] = true,
                ["nil"] = true, ["and"] = true, ["or"] = true, ["not"] = true, ["self"] = true,
                ["in"] = true, ["pairs"] = true, ["ipairs"] = true, ["_G"] = true, ["goto"] = true,
                ["continue"] = true, ["until"] = true, ["repeat"] = true, ["pcall"] = true,["unpack"] = true,
                ["error"] = true
            }
            
            if keywords[ident] then
                table.insert(tokens, {type = "keyword", value = ident})
            else
                table.insert(tokens, {type = "identifier", value = ident})
            end
            
        -- 运算符和符号
        elseif char == "=" then
            if i < #code and code:sub(i+1, i+1) == "=" then
                table.insert(tokens, {type = "operator", value = "=="})
                i = i + 2
            else
                table.insert(tokens, {type = "operator", value = "="})
                i = i + 1
            end
            
        elseif char == "~" then
            if i < #code and code:sub(i+1, i+1) == "=" then
                table.insert(tokens, {type = "operator", value = "~="})
                i = i + 2
            else
                -- 位运算符 ~ (按位取反)
                table.insert(tokens, {type = "operator", value = "~"})
                i = i + 1
            end
            
        elseif char == "&" then
            table.insert(tokens, {type = "operator", value = "&"})
            i = i + 1
            
        elseif char == "|" then
            table.insert(tokens, {type = "operator", value = "|"})
            i = i + 1
            
        elseif char == "^" then
            table.insert(tokens, {type = "operator", value = "^"})
            i = i + 1
            
        elseif char == "<" then
            if i < #code and code:sub(i+1, i+1) == "<" then
                table.insert(tokens, {type = "operator", value = "<<"})
                i = i + 2
            elseif i < #code and code:sub(i+1, i+1) == "=" then
                table.insert(tokens, {type = "operator", value = "<="})
                i = i + 2
            else
                table.insert(tokens, {type = "operator", value = "<"})
                i = i + 1
            end
            
        elseif char == ">" then
            if i < #code and code:sub(i+1, i+1) == ">" then
                table.insert(tokens, {type = "operator", value = ">>"})
                i = i + 2
            elseif i < #code and code:sub(i+1, i+1) == "=" then
                table.insert(tokens, {type = "operator", value = ">="})
                i = i + 2
            else
                table.insert(tokens, {type = "operator", value = ">"})
                i = i + 1
            end
            
        elseif char:match("[%+%-%*/%%]") then
            table.insert(tokens, {type = "operator", value = char})
            i = i + 1
            
        elseif char == "#" then
            table.insert(tokens, {type = "operator", value = "#"})
            i = i + 1
            
        elseif char:match("[%(%)%{%}%[%]]") then
            table.insert(tokens, {type = "delimiter", value = char})
            i = i + 1
            
        elseif char == "," then
            table.insert(tokens, {type = "comma", value = ","})
            i = i + 1
            
        elseif char == "." then
            -- 支持字符串连接操作符 .. 与属性访问 . 的区分
            if i < #code and code:sub(i+1, i+1) == "." then
                table.insert(tokens, {type = "operator", value = ".."})
                i = i + 2
            else
                table.insert(tokens, {type = "dot", value = "."})
                i = i + 1
            end
            
        elseif char == ":" then
            table.insert(tokens, {type = "colon", value = ":"})
            i = i + 1
            
        else
            i = i + 1 -- 跳过未知字符
        end
    end
    
    return tokens
end

return CodeEncoder