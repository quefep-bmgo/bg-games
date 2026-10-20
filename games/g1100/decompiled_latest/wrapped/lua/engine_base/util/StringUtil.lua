--[[iObW5CNCHZ3ssTRexboPjcAuckhuO15KYVW4f2SpmtHOM6T3ceTxnXe04mHt8DhFuedzPG1FjNTMgeejWgBonSykwMDESvIkN5aNm4fFY9zA2tvWj2Ds0UmqGci9n0vdCrN1j7TjgnChVnCMcL]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 9392
                          local checkFileName = "StringUtil.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[YovseyTgf8mb9EJJtkomfQWeSFWcldBMcNzdUeh92A19lAQaCRLpvrch0iMiAAG3bz]]---
--- Created by Jimmy.
--- DateTime: 2018/3/8 0008 12:04
---
StringUtil = {}


--返回当前字符实际占用的字符数
local function SubStringGetByteCount(str, index)
    local curByte = string.byte(str, index)
    local byteCount = 1;
    if curByte == nil then
        byteCount = 0
    elseif curByte > 0 and curByte <= 127 then
        byteCount = 1
    elseif curByte >= 192 and curByte <= 223 then
        byteCount = 2
    elseif curByte >= 224 and curByte <= 239 then
        byteCount = 3
    elseif curByte >= 240 and curByte <= 247 then
        byteCount = 4
    end
    return byteCount
end

--获取中英混合UTF8字符串的真实字符数量
local function SubStringGetTotalIndex(str)
    local curIndex = 0
    local i = 1
    local lastCount = 1
    repeat
        lastCount = SubStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1
    until (lastCount == 0)
    return curIndex - 1
end

local function SubStringGetTrueIndex(str, index)
    local curIndex = 0
    local i = 1;
    local lastCount = 1
    repeat
        lastCount = SubStringGetByteCount(str, i)
        i = i + lastCount
        curIndex = curIndex + 1
    until (curIndex >= index)
    return i - lastCount
end

function StringUtil.removeBom(str)
    local c1, c2, c3 = string.byte(str, 1, 3)
    if (c1 == 0xEF and c2 == 0xBB and c3 == 0xBF) then
        -- UTF-8
        str = string.sub(str, 4)
    elseif (c1 == 0xFF and c2 == 0xFE) then
        -- UTF-16(LE)
        str = string.sub(str, 3)
    end
    return str
end

---@return string[] | number[]
function StringUtil.split(str, reps, keep_blank, to_number)
    local result = {}
    if str == nil or reps == nil then
        return result
    end

    keep_blank = keep_blank or false
    if keep_blank then
        local startIndex = 1
        while true do
            local lastIndex = string.find(str, reps, startIndex)
            if not lastIndex then
                table.insert(result, string.sub(str, startIndex, string.len(str)))
                break
            end
            table.insert(result, string.sub(str, startIndex, lastIndex - 1))
            startIndex = lastIndex + string.len(reps)
        end
    else
        string.gsub(str, '[^' .. reps .. ']+', function(w)
            table.insert(result, w)
        end)
    end

    to_number = to_number or false
    if to_number then
        for i = 1, #result do
            result[i] = tonumber(result[i])
        end
    end

    return result
end

local function v2s(value, sp, restLevel, ignores)
    ignores = ignores or {}
    local typ = type(value)
    if typ == "string" then
        return '\"' .. value .. '\"'
    elseif typ ~= "table" then
        return tostring(value)
    elseif value and value.tostring_overload then
        return tostring(value)
    end
    restLevel = restLevel or 3
    restLevel = restLevel - 1
    if restLevel < 0 then
        return "..."
    end
    local nsp = sp .. "  "
    local tb = {}
    local idxs = {}
    for k, v in ipairs(tb) do
        idxs[k] = true
        if not TableUtil.tableContain(ignores, k) then
            tb[#tb + 1] = "[" .. k .. "] = " .. v2s(v, nsp, restLevel)
        end
    end
    for k, v in pairs(value) do
        if not idxs[k] then
            if not TableUtil.tableContain(ignores, k) then
                k = (type(k) == "string") and ('\"' .. k .. '\"') or tostring(k)
                tb[#tb + 1] = "[" .. k .. "] = " .. v2s(v, nsp, restLevel)
            end
        end
    end
    if not tb[1] then
        return "{}"
    end
    nsp = "\n" .. nsp
    return "{" .. nsp .. table.concat(tb, "," .. nsp) .. "\n" .. sp .. "}";
end

function StringUtil.v2s(value, maxLevel, ignores)
    return v2s(value, "", maxLevel or 3, ignores)
end

function StringUtil.a2s(array)
    return "[" .. table.concat(array, ",") .. "]"
end

local IllegalChars = {
    ["▢"] = true,
    ["▥"] = true,
    ["▨"] = true,
    ["\n"] = true,
    ["["] = true,
    ["]"] = true,
    ["<"] = true,
    [">"] = true,
    ["^"] = true,
    ["{"] = true,
    ["}"] = true,
    ["&"] = true,
}
function StringUtil.keepEnglish(str)
    local result = ""
    for i = 1, #str do
        local c = str:sub(i, i)
        if not IllegalChars[c] then
            result = result .. str:sub(i, i)
        end
    end
    return result
end

local IllegalCharsName = {
    ["▢"] = true,
    ["▥"] = true,
    ["▨"] = true,
    ["\n"] = true,
    ["["] = true,
    ["]"] = true,
    ["<"] = true,
    [">"] = true,
    ["^"] = true,
    ["{"] = true,
    ["}"] = true,
    ["&"] = true,
    ["%"] = true,
    ["="] = true,
}
function StringUtil.keepEnglishName(str)
    local result = ""
    for i = 1, #str do
        local c = str:sub(i, i)
        if not IllegalCharsName[c] then
            result = result .. str:sub(i, i)
        end
    end
    return result
end

local function reconstructColorFul(name, colorful)
    if name == nil then
        return ""
    end
    name = name:gsub("▢", "")
    name = name:gsub("▥", "")
    name = name:gsub("▨", "")
    name = name:gsub("\n", " ")
    if string.match(name, "&%$.*%$&") then
        return name
    end
    if type(colorful) == "string" and #colorful ~= 0 then
        local colors = StringUtil.split(colorful, "-")
        while SubStringGetTotalIndex(name) + 1 < #colors do
            table.remove(colors)
        end
        colorful = table.concat(colors, "-")
        name = string.format("&$[%s]$%s$&", colorful, name)
    end
    return name
end

function StringUtil.reconstructName(name, colorful, nameplate)
    name = reconstructColorFul(name, colorful)
    if nameplate then
        if string.find(name, "S=") then
            local names = StringUtil.split(name, "=")
            name = string.sub(name, 1, math.max(1, #name - (#names[2] or 0) - 3))
        end
        if Global.setting.disableVIPNameEffect then
            return name
        end
        name = name .. "[S=" .. string.match(nameplate, "[%w_]+") .. ".json]"
    elseif Global.setting.disableVIPNameEffect then
        if string.find(name, "S=") then
            local names = StringUtil.split(name, "=")
            name = string.sub(name, 1, math.max(1, #name - (#names[2] or 0) - 3))
        end
    end
    return name
end

function StringUtil.reconstructNameShowVip(name, colorful, nameplate)
    local oldSetting = Global.setting.disableVIPNameEffect
    Global.setting.disableVIPNameEffect = false
    name = StringUtil.reconstructName(name, colorful, nameplate)
    Global.setting.disableVIPNameEffect = oldSetting
    return name
end

function StringUtil.getRealName(name)
    ---example name = &$[ffca00ff-fbd33fff-cad2ceff-23b8feff-677dffff-ac61ffff-fd15ffff]$vggcddf$&
    if string.find(name, "&$%[") then
        local names = StringUtil.split(name, "$")
        if #names >= 4 then
            table.remove(names, #names)
            table.remove(names, 1)
            table.remove(names, 1)
        end
        local real_name = ""
        for _, short_name in pairs(names) do
            real_name = real_name .. short_name
        end
        return StringUtil.keepEnglishName(real_name)
    elseif string.find(name, "S=") then
        local names = StringUtil.split(name, "=")
        name = string.sub(name, 1, math.max(1, #name - (#names[2] or 0) - 3))
        return StringUtil.keepEnglishName(name)
    end
    return StringUtil.keepEnglishName(name)
end

--截取中英混合的UTF8字符串，endIndex可缺省
function StringUtil.subStringUTF8(str, startIndex, endIndex)
    if startIndex < 0 then
        startIndex = SubStringGetTotalIndex(str) + startIndex + 1
    end

    if endIndex ~= nil and endIndex < 0 then
        endIndex = SubStringGetTotalIndex(str) + endIndex + 1
    end

    if endIndex == nil then
        return string.sub(str, SubStringGetTrueIndex(str, startIndex))
    else
        return string.sub(str, SubStringGetTrueIndex(str, startIndex), SubStringGetTrueIndex(str, endIndex + 1) - 1)
    end
end

function StringUtil.subStringGBK(str, len)
    if #str <= len then
        return str
    end
    local pos = 0
    while pos < len do
        local byte = SubStringGetByteCount(str, pos + 1)
        if pos + byte > len then
            break
        end
        pos = pos + byte
    end
    return string.sub(str, 1, pos)
end

return StringUtil--[[5AhqqlwgOchmj9kyeoS7c8v7xyA6Sd3a3GiwZHuLdZHGxYxGTBsGtltIRzxIcE8XL056Lm4S8]]