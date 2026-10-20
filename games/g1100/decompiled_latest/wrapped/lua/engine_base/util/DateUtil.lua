--[[l2SuZIW6rSgA2KWVs]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 9073
                          local checkFileName = "DateUtil.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[vnmSmVEAKlRXHM2UJ2OQG0ViJLTKWY3C79jQGUmlsRzQQ98GloWNg8pKYSuApEF75ZP0of6jKkNuDL885JsltI10CNVdhP5XjndHU7yj0b12L41MiUQLYtMFgPKXjNUU5aQ9qLrmPE5zd8JLnv5F8oG0gz2wcag9KvHQiUkkTFE2q4OqATqgP0hO8mpVpgGsqWhin97QntlveUlrL9nR4LJDWn8nvDoJDrsIjbdwF8XzAMoICV7LhklkQfl]]---
--- Created by Jimmy.
--- DateTime: 2018/3/8 0008 10:16
---
DateUtil = {}

---获取在本年第几周的key(string)，格式：年周，例子：202201
function DateUtil.getYearWeek(time)
    if isClient then
        HostApi.log("DateUtil.getYearWeek(time) prohibited for client use!", 2)
    end
    local week = DateUtil.getWeeksOfYear(time)
    if week >= 10 then
        return os.date("%Y", time) .. week
    else
        return os.date("%Y", time) .. "0" .. week
    end
end

---获取在本年第几周(int)
function DateUtil.getWeeksOfYear(time)
    if isClient then
        HostApi.log("DateUtil.getWeeksOfYear(time) prohibited for client use!", 2)
    end
    time = time or os.time()
    local firstYearTime = os.time({ day = 1, month = 1, year = os.date("%Y", time) })
    local firstYearDate = os.date("*t", firstYearTime)
    local date = os.date("*t", time)
    local start_wday = firstYearDate.wday - 1
    local yday = date.yday
    if (start_wday + yday) % 7 == 0 then
        return math.floor((start_wday + yday) / 7)
    else
        return NumberUtil.getIntPart((start_wday + yday) / 7) + 1
    end
end

function DateUtil.getWeekDay(time)
    if isClient then
        HostApi.log("DateUtil.getWeekDay(time) prohibited for client use!", 2)
    end
    time = time or os.time()
    return os.date("*t", time).wday
end

function DateUtil.getYearDay(time)
    if isClient then
        HostApi.log("DateUtil.getYearDay(time) prohibited for client use!", 2)
    end
    time = time or os.time()
    return os.date("%Y%j", time)
end

function DateUtil.getYearMonth(time)
    time = time or os.time()
    return os.date("%Y%m", time)
end

function DateUtil.getDate(time)
    time = time or os.time()
    return os.date("%Y-%m-%d", time)
end

function DateUtil.getDateString(time)
    time = time or os.time()
    return os.date("%Y-%m-%d %X", time)
end

---获取本月（time）最后的时间戳
function DateUtil.getMonthLastTime(time)
    time = time or os.time()
    local date = os.date("*t", time)
    if date.month >= 12 then
        time = os.time({ year = date.year + 1, month = 1, day = 1, hour = 0, minute = 0, second = 0 })
    else
        time = os.time({ year = date.year, month = date.month + 1, day = 1, hour = 0, minute = 0, second = 0 })
    end
    return time + (os.time(os.date("*t")) - os.time(os.date("*t")))
end

---获取本周（time）最后的时间戳
function DateUtil.getWeekLastTime(time)
    time = time or os.time()
    return time + DateUtil.getWeekLeftSeconds(time) - 1
end

---获取当天（time）最后的时间戳
function DateUtil.getDayLastTime(time)
    time = time or os.time()
    return time + DateUtil.getDayLeftSeconds(time) - 1
end

---获取当天（time）剩余的秒数
function DateUtil.getDayLeftSeconds(time)
    time = time or os.time()
    local seconds = 86400 - time % 86400
    if isTest then
        if seconds >= 28800 then
            seconds = seconds - 28800
        else
            seconds = seconds + 57600
        end
    end
    return seconds
end

---获取本周（time）剩余的秒数
function DateUtil.getWeekLeftSeconds(time)
    time = time or os.time()
    local weeks = math.floor(time / 604800)
    local weekLastTime = weeks * 604800 + 3 * 86400
    if weekLastTime <= time then
        weekLastTime = weekLastTime + 604800
    end
    local seconds = weekLastTime - time
    if isTest then
        if seconds >= 28800 then
            seconds = seconds - 28800
        else
            seconds = seconds + 576000
        end
    end
    return seconds
end

function DateUtil.getWeekSeconds()
    return 604800
end

function DateUtil.getDaySeconds()
    return 86400
end

local function checkTime(text, append, format, pattern, split)
    split = split or ":"
    if string.find(format, pattern) ~= nil then
        if #text ~= 0 then
            text = text .. split
        end
        if append < 10 then
            text = text .. "0" .. append
        else
            text = text .. append
        end
    end
    return text
end

---获取格式化后的时间 默认(HH:mm:ss)
---@param seconds number 秒数
---@param format string 格式化规则
function DateUtil.getFormatTime(seconds, format, split)
    format = format or "HH:mm:ss"
    local text = ""
    local hour = math.floor(seconds / 3600)
    local minute = math.floor((seconds % 3600) / 60)
    local second = math.floor(seconds % 60)
    text = checkTime(text, hour, format, "HH", split)
    text = checkTime(text, minute, format, "mm", split)
    text = checkTime(text, second, format, "ss", split)
    return text
end

function DateUtil.getFormatTimeWithDay(seconds)
    local text = ""
    local day = math.floor(seconds / (3600 * 24))
    local hour = math.floor((seconds % (3600 * 24)) / 3600)
    local minute = math.floor((seconds % 3600) / 60)
    local second = seconds % 60
    if day > 0 then
        text = text .. day .. "D "
    end
    if hour < 10 then
        text = text .. "0" .. hour .. ":"
    else
        text = text .. hour .. ":"
    end
    if minute < 10 then
        text = text .. "0" .. minute .. ":"
    else
        text = text .. minute .. ":"
    end
    if second < 10 then
        text = text .. "0" .. second
    else
        text = text .. second
    end
    return text
end

---@param seconds number 秒数
function DateUtil.getTimeByTwoPara(seconds)
    local text = ""
    local day = math.floor(seconds / (3600 * 24))
    local hour = math.floor((seconds % (3600 * 24)) / 3600)
    local minute = math.floor((seconds % 3600) / 60)
    local second = seconds % 60
    if day >= 1 then
        text = text .. day .. "d"
        if hour >= 1 then
            text = text .. " " .. hour .. "h"
        end
    elseif hour >= 1 then
        text = text .. hour .. "h"
        if minute >= 1 then
            text = text .. " " .. minute .. "min"
        end
    elseif minute >= 1 then
        text = text .. minute .. "min"
        if second >= 1 then
            text = text .. " " .. second .. "s"
        end
    else
        text = text .. " " .. second .. "s"
    end
    return text
end

---获取北京跟当前服务器时间戳的差值
local function getBeiJingDiffTime()
    return os.time(os.date("*t")) - os.time(os.date("!*t")) - 28800
end

---根据date获取北京时间戳
---@param date table 某个北京时间日期的table
---eg: { year = 2020, month = 1, day = 20, hour = 1, min = 1, sec = 0 }
function DateUtil.date2BeiJingTime(date)
    date.isdst = false
    return os.time(date) + getBeiJingDiffTime()
end

function DateUtil.getGreenwichDayStartTime(time)
    time = time or os.time()
    return DateUtil.getGreenwichDayLastTime(time) - 86400
end

---获取最近的格林威治一天最后的时间
function DateUtil.getGreenwichDayLastTime(time)
    return DateUtil.getDayLastTime(time) + 1
end

---获取最近的格林威治一周最后的时间
function DateUtil.getGreenwichWeekLastTime(time)
    return DateUtil.getWeekLastTime(time) + 1
end

---获取最近的格林威治一月最后的时间
function DateUtil.getGreenwichMonthLastTime(time)
    time = time or os.time()
    local date = os.date("!*t", time)
    if date.month >= 12 then
        time = os.time({ year = date.year + 1, month = 1, day = 1, hour = 0, minute = 0, second = 0 })
    else
        time = os.time({ year = date.year, month = date.month + 1, day = 1, hour = 0, minute = 0, second = 0 })
    end
    return time + (os.time(os.date("*t")) - os.time(os.date("!*t")))
end

function DateUtil.getMondayWeekCycle(time, weekSec)
    time = time or os.time()
    weekSec = weekSec or DateUtil.getWeekSeconds()
    return math.floor((time - DateUtil.getDaySeconds() * 4) / weekSec)
end

function DateUtil.getMondayWeekLastTime(time)
    time = time or os.time()
    local cycle = DateUtil.getMondayWeekCycle(time)
    return DateUtil.getWeekSeconds() * (cycle + 1) + DateUtil.getDaySeconds() * 4 - time
end

return DateUtil--[[DCA8SawOBMcjUpeP4Tk3cWEuevqt9Capnfj55w97qimhhNmlaeYRHYJarmAqo9idZJFpvIr4X5pEr0KGnPQ3ci51RVMUZ9MTznLmSgFSJv3kUelp97AUM6xs9cCJ7]]---