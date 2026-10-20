--[[esu1zuhVrjp]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 17436
                          local checkFileName = "json.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[ML6gsKpALyuHDtq5vbiuI9DnReQoPApJ8LppoitW3gYpVRW3lRMGu9sVFILS4BjPgmjWmgOpLaYKgL4U3jR5qPL3MsHsLGgCoNtEpSr71Nz1XRCqpUeniSGDpDeCvHL00WVHYleZpf3bxMrWdbYcRcnHH9GbqewTXiHZYFGAa1FYk1Ts5VLAS0ij6rbRYREIOnsG6LkZD2BngZgLKvYQwr1TjO4Taoq6bMsIy6csbuRPSLUtap11iotQ3wGIhvJoSSbyWWqUJ1KEb7RlsK0EchTis3rn2ALnwx43zaMsETS6IdVTzZZs9EhPtHako1A57HV86HdKo4JjVrR18wquC6emcGQd2IeuzHThpmmzWVxuTawHG0]]--
-- json.lua
--
-- Copyright (c) 2019 rxi
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do
-- so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

json = { _version = "0.1.2" }

-------------------------------------------------------------------------------
-- Encode
-------------------------------------------------------------------------------

local encode

local escape_char_map = {
    ["\\"] = "\\\\",
    ["\""] = "\\\"",
    ["\b"] = "\\b",
    ["\f"] = "\\f",
    ["\n"] = "\\n",
    ["\r"] = "\\r",
    ["\t"] = "\\t",
}

local escape_char_map_inv = { ["\\/"] = "/" }
for k, v in pairs(escape_char_map) do
    escape_char_map_inv[v] = k
end

local function escape_char(c)
    return escape_char_map[c] or string.format("\\u%04x", c:byte())
end

local function encode_nil(val)
    return "null"
end

local function encode_table(val, stack)
    local res = {}
    stack = stack or {}

    -- Circular reference?
    if stack[val] then
        error("circular reference")
    end

    stack[val] = true

    if rawget(val, 1) ~= nil or next(val) == nil then
        -- Treat as array -- check keys are valid and it is not sparse
        local n = 0
        for k in pairs(val) do
            if type(k) ~= "number" then
                error("invalid table: mixed or invalid key types")
            end
            n = n + 1
        end
        if n ~= #val then
            error("invalid table: sparse array")
        end
        -- Encode
        for i, v in ipairs(val) do
            table.insert(res, encode(v, stack))
        end
        stack[val] = nil
        return "[" .. table.concat(res, ",") .. "]"

    else
        -- Treat as an object
        for k, v in pairs(val) do
            if type(k) ~= "string" then
                error("invalid table: mixed or invalid key types")
            end
            table.insert(res, encode(k, stack) .. ":" .. encode(v, stack))
        end
        stack[val] = nil
        return "{" .. table.concat(res, ",") .. "}"
    end
end

local function encode_string(val)
    return '"' .. val:gsub('[%z\1-\31\\"]', escape_char) .. '"'
end

local function encode_number(val)
    -- Check for NaN, -inf and inf
    if val ~= val or val <= -math.huge or val >= math.huge then
        error("unexpected number value '" .. tostring(val) .. "'")
    end
    return string.format("%.14g", val)
end

local type_func_map = {
    ["nil"] = encode_nil,
    ["table"] = encode_table,
    ["string"] = encode_string,
    ["number"] = encode_number,
    ["boolean"] = tostring,
}

encode = function(val, stack)
    local t = type(val)
    local f = type_func_map[t]
    if f then
        return f(val, stack)
    end
    error("unexpected type '" .. t .. "'")
end

function json.encode(val)
    return (encode(val))
end

function json.safe_encode(data)
    local success, result = pcall(json.encode, data)
    if success then
        return result
    end
    return "{}"
end

-------------------------------------------------------------------------------
-- Decode
-------------------------------------------------------------------------------

local parse

local function create_set(...)
    local res = {}
    for i = 1, select("#", ...) do
        res[select(i, ...)] = true
    end
    return res
end

local space_chars = create_set(" ", "\t", "\r", "\n")
local delim_chars = create_set(" ", "\t", "\r", "\n", "]", "}", ",")
local escape_chars = create_set("\\", "/", '"', "b", "f", "n", "r", "t", "u")
local literals = create_set("true", "false", "null")

local literal_map = {
    ["true"] = true,
    ["false"] = false,
    ["null"] = nil,
}

local function next_char(str, idx, set, negate)
    for i = idx, #str do
        if set[str:sub(i, i)] ~= negate then
            return i
        end
    end
    return #str + 1
end

local function decode_error(str, idx, msg)
    local line_count = 1
    local col_count = 1
    for i = 1, idx - 1 do
        col_count = col_count + 1
        if str:sub(i, i) == "\n" then
            line_count = line_count + 1
            col_count = 1
        end
    end
    LogUtil.logError("json error str", str)
    error(string.format("%s at line %d col %d", msg, line_count, col_count))
end

local function codepoint_to_utf8(n)
    -- http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=iws-appendixa
    local f = math.floor
    if n <= 0x7f then
        return string.char(n)
    elseif n <= 0x7ff then
        return string.char(f(n / 64) + 192, n % 64 + 128)
    elseif n <= 0xffff then
        return string.char(f(n / 4096) + 224, f(n % 4096 / 64) + 128, n % 64 + 128)
    elseif n <= 0x10ffff then
        return string.char(f(n / 262144) + 240, f(n % 262144 / 4096) + 128,
                f(n % 4096 / 64) + 128, n % 64 + 128)
    end
    error(string.format("invalid unicode codepoint '%x'", n))
end

local function parse_unicode_escape(s)
    local n1 = tonumber(s:sub(3, 6), 16)
    local n2 = tonumber(s:sub(9, 12), 16)
    -- Surrogate pair?
    if n2 then
        return codepoint_to_utf8((n1 - 0xd800) * 0x400 + (n2 - 0xdc00) + 0x10000)
    else
        return codepoint_to_utf8(n1)
    end
end

local function parse_string(str, i)
    local has_unicode_escape = false
    local has_surrogate_escape = false
    local has_escape = false
    local last
    for j = i + 1, #str do
        local x = str:byte(j)

        if x < 32 then
            decode_error(str, j, "control character in string")
        end

        if last == 92 then
            -- "\\" (escape char)
            if x == 117 then
                -- "u" (unicode escape sequence)
                local hex = str:sub(j + 1, j + 5)
                if not hex:find("%x%x%x%x") then
                    decode_error(str, j, "invalid unicode escape in string")
                end
                if hex:find("^[dD][89aAbB]") then
                    has_surrogate_escape = true
                else
                    has_unicode_escape = true
                end
            else
                local c = string.char(x)
                if not escape_chars[c] then
                    decode_error(str, j, "invalid escape char '" .. c .. "' in string")
                end
                has_escape = true
            end
            last = nil

        elseif x == 34 then
            -- '"' (end of string)
            local s = str:sub(i + 1, j - 1)
            if has_surrogate_escape then
                s = s:gsub("\\u[dD][89aAbB]..\\u....", parse_unicode_escape)
            end
            if has_unicode_escape then
                s = s:gsub("\\u....", parse_unicode_escape)
            end
            if has_escape then
                s = s:gsub("\\.", escape_char_map_inv)
            end
            return s, j + 1

        else
            last = x
        end
    end
    decode_error(str, i, "expected closing quote for string")
end

local function parse_number(str, i)
    local x = next_char(str, i, delim_chars)
    local s = str:sub(i, x - 1)
    local n = tonumber(s)
    if not n then
        decode_error(str, i, "invalid number '" .. s .. "'")
    end
    local f = math.floor(n)
    return f == n and f or n, x
end

local function parse_literal(str, i)
    local x = next_char(str, i, delim_chars)
    local word = str:sub(i, x - 1)
    if not literals[word] then
        decode_error(str, i, "invalid literal '" .. word .. "'")
    end
    return literal_map[word], x
end

local function parse_array(str, i)
    local res = {}
    local n = 1
    i = i + 1
    while 1 do
        local x
        i = next_char(str, i, space_chars, true)
        -- Empty / end of array?
        if str:sub(i, i) == "]" then
            i = i + 1
            break
        end
        -- Read token
        x, i = parse(str, i)
        res[n] = x
        n = n + 1
        -- Next token
        i = next_char(str, i, space_chars, true)
        local chr = str:sub(i, i)
        i = i + 1
        if chr == "]" then
            break
        end
        if chr ~= "," then
            decode_error(str, i, "expected ']' or ','")
        end
    end
    return res, i
end

local function parse_object(str, i)
    local res = {}
    i = i + 1
    while 1 do
        local key, val
        i = next_char(str, i, space_chars, true)
        -- Empty / end of object?
        if str:sub(i, i) == "}" then
            i = i + 1
            break
        end
        -- Read key
        if str:sub(i, i) ~= '"' then
            decode_error(str, i, "expected string for key")
        end
        key, i = parse(str, i)
        -- Read ':' delimiter
        i = next_char(str, i, space_chars, true)
        if str:sub(i, i) ~= ":" then
            decode_error(str, i, "expected ':' after key")
        end
        i = next_char(str, i + 1, space_chars, true)
        -- Read value
        val, i = parse(str, i)
        -- Set
        res[key] = val
        -- Next token
        i = next_char(str, i, space_chars, true)
        local chr = str:sub(i, i)
        i = i + 1
        if chr == "}" then
            break
        end
        if chr ~= "," then
            decode_error(str, i, "expected '}' or ','")
        end
    end
    return res, i
end

local char_func_map = {
    ['"'] = parse_string,
    ["0"] = parse_number,
    ["1"] = parse_number,
    ["2"] = parse_number,
    ["3"] = parse_number,
    ["4"] = parse_number,
    ["5"] = parse_number,
    ["6"] = parse_number,
    ["7"] = parse_number,
    ["8"] = parse_number,
    ["9"] = parse_number,
    ["-"] = parse_number,
    ["t"] = parse_literal,
    ["f"] = parse_literal,
    ["n"] = parse_literal,
    ["["] = parse_array,
    ["{"] = parse_object,
}

parse = function(str, idx)
    local chr = str:sub(idx, idx)
    local f = char_func_map[chr]
    if f then
        return f(str, idx)
    end
    decode_error(str, idx, "unexpected character '" .. chr .. "'")
end

function json.decode(data)
    if type(data) ~= "string" then
        print("[Error] expected argument of type string, got " .. type(data))
        return data
    end
    local res, idx = parse(data, next_char(data, 1, space_chars, true))
    idx = next_char(data, idx, space_chars, true)
    if idx <= #data then
        decode_error(data, idx, "trailing garbage")
    end
    return res
end

function json.safe_decode(data)
    local success, result = pcall(json.decode, data)
    if success then
        return result
    end
    return data
end

---插入缩进
local function newIndent(number, indent)
    indent = indent or "  "
    local indentStr = ""
    for _ = 1, number do
        indentStr = indentStr .. indent
    end
    return indentStr
end

---插入行
local function newLine(result)
    local pre1 = result[#result]
    if pre1 == "\n" then
        return false
    end
    local pre2 = result[#result - 1]
    if pre1 == ':' then
        if pre2 == '"' or pre2 == ' ' then
            return false
        end
    end
    if pre1 == ' ' then
        if pre2 == ':' then
            return false
        end
    end
    table.insert(result, "\n")
    return true
end

---插入空格
local function newSpace(result)
    local pre1 = result[#result]
    if pre1 == " " then
        return false
    end
    table.insert(result, " ")
    return true
end

---格式化json字符串
---@param json string 未格式化的JSON字符串
---@return string 格式化的JSON字符串
function json.format(json, indent)
    local result = {}
    local number = 0
    local length = string.len(json)
    for i = 1, length do
        ---1、获取当前字符
        local key = string.sub(json, i, i)
        ---3、如果当前字符是前方括号、前花括号做如下处理：
        if key == '[' or key == '{' then
            ---(1)如果前面还有字符，并且字符为“:”，打印：换行和缩进字符字符串。
            if i - 1 > 0 and string.sub(json, i - 1, i - 1) == ':' then
                if newLine(result) then
                    table.insert(result, newIndent(number, indent))
                else
                    newSpace(result)
                end
            end
            ---(2)打印：当前字符。
            table.insert(result, key)
            ---(3)前方括号、前花括号，的后面必须换行。打印：换行。
            if newLine(result) then
                ---(4)每出现一次前方括号、前花括号；缩进次数增加一次。打印：新行缩进。
                number = number + 1
                table.insert(result, newIndent(number, indent))
            else
                newSpace(result)
            end
            ---(5)继续下一次循环。
            goto CONTINUE
        end
        ---2、如果当前字符是逗号。逗号后面换行，并缩进，不改变缩进次数。
        if key == ',' then
            if i - 1 > 0 then
                local preKey = string.sub(json, i - 1, i - 1)
                if preKey == '"' or preKey == '}' or preKey == ']' then
                    ---(1)打印：当前字符。
                    table.insert(result, key)
                    ---(2)逗号的后面必须换行。打印：换行。
                    if newLine(result) then
                        ---(3)打印：缩进
                        table.insert(result, newIndent(number, indent))
                    else
                        newSpace(result)
                    end
                    ---(4)继续下一次循环。
                    goto CONTINUE
                end
            end
            if i + 1 <= length then
                local nextKey = string.sub(json, i + 1, i + 1)
                if nextKey == '[' or nextKey == '{' or nextKey == '"' then
                    ---(1)打印：当前字符。
                    table.insert(result, key)
                    ---(2)逗号的后面必须换行。打印：换行。
                    if newLine(result) then
                        ---(3)打印：缩进
                        table.insert(result, newIndent(number, indent))
                    else
                        newSpace(result)
                    end
                    ---(4)继续下一次循环。
                    goto CONTINUE
                end
            end
        end
        ---4、如果当前字符是后方括号、后花括号做如下处理：
        if key == ']' or key == '}' then
            -----(1)后方括号、后花括号，的前面必须换行。打印：换行。
            newLine(result)
            ---(2)每出现一次后方括号、后花括号；缩进次数减少一次。打印：缩进。
            number = number - 1
            table.insert(result, newIndent(number, indent))
            ---(3)打印：当前字符。
            table.insert(result, key)
            ---(4)继续下一次循环。
            goto CONTINUE
        end
        ---5、打印冒号后面的空格
        if key == ":" and string.sub(json, i - 1, i - 1) == '"' then
            ---(1)打印：当前字符。
            table.insert(result, key)
            ---(2)打印：空格。
            newSpace(result)
            ---(3)继续下一次循环。
            goto CONTINUE
        end
        ---6、打印：当前字符。
        table.insert(result, key)
        :: CONTINUE ::
    end
    return table.concat(result)
end

return json
--[[ufve27GC2SnQlnGkfgLFFscGuM2G7AhXYEZ9tM5ig3qyho2k]]