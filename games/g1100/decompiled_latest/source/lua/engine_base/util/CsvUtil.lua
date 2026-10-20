---
--- Created by Jimmy.
--- DateTime: 2018/4/25 0025 12:26
---
---
---
---
---
--- fix hack
CsvUtil = {}

function CsvUtil.getRowContent(file, filePath)
    if file == nil then
        assert(false, filePath .. " -----------------> is not exist.")
    end
    local content;
    local check = false
    local count = 0
    while true do
        local t = file:read()
        if not t then
            if count == 0 then
                check = true
            end
            break
        end

        if not content then
            content = t
        else
            content = content .. t
        end

        local i = 1
        while true do
            local index = string.find(t, "\n", i)
            if not index then
                break
            end
            i = index + 1
            count = count + 1
        end

        if count % 2 == 0 then
            check = true
            break
        end
    end

    if not check then
        assert(1 ~= 1)
    end

    if content then
        return string.gsub(content, "\r", "")
    end

    return content
end
--- fix hack
function CsvUtil.loadCsvFile(filePath, tRow, indexNumber, allowEmpty)
    local file = io.open(filePath, "r")
    local content = file:read("*a")
    file:close()
    content = string.gsub(content, "\r", "")
    content = StringUtil.removeBom(content)
    local lines = StringUtil.split(content, "\n")
    local titleRow = tRow or 2
    local titles = StringUtil.split(lines[titleRow], "\t", true)
    local id = 1
    local result = {}
    for row = titleRow + 1, #lines, 1 do
        local line = StringUtil.split(lines[row], "\t", true)
        if indexNumber then
            id = tonumber(line[1])
        else
            id = tostring(line[1])
        end
        if type(id) == "string" and #id == 0 then
            break
        end
        if isLocalWin and result[id] ~= nil then
            LogUtil.logScriptException(filePath .. " -----------------> " .. "repeat " .. titles[1] .. ", repeat id=" .. id .. ", row=" .. row)
        end
        result[id] = {}
        for col = 1, #titles, 1 do
            if #titles[col] > 0 then
                result[id][titles[col]] = line[col]
                if isTest and col <= #titles and line[col] and #line[col] == 0 and not allowEmpty then
                    assert(false, filePath .. " -----------------> " .. titles[col] .. " is nil value, row = " .. row .. " col = " .. col)
                end
            end
        end
    end
    return result
end
--- fix hackend 
return CsvUtil
--- fix hackend 