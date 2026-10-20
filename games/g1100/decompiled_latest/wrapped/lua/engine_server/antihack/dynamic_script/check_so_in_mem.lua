--[[SbfLUWWBZ4XZBLNBS28mxZ3UdWb6q9igNm4ZWkZbyi53ghpqQrTA1I3A0tQJFzOEJT1JFaBjy3d4U]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 6116
                          local checkFileName = "check_so_in_mem.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[THopcBi5FuGGs4lSuQMGam4vVE2mTq]]local CheckSoInMemScript = class("CheckSoInMemScript", require "engine_server.antihack.dynamic_script.check_base")
local checkScript = [[


-- 获取应用基本路径
local function isInApp(soPath)
    local releasePath = "com.sandboxol"
    local testPath = "test.sandboxol"

    return string.find(soPath, releasePath) ~= nil or string.find(soPath, testPath) ~= nil
end

local function readProcMaps()
    local procFile = io.open("proc/self/maps", "r")
    if not procFile then return nil end
    
    local allFiles = {}
    local seenFiles = {}
    local fmodPath = nil
    local releasePath = "com.sandboxol"
    local testPath = "test.sandboxol"
    
    -- 读取所有数据
    local allTargetData = procFile:read("*a")

    procFile:close()
    
    -- 将收集到的所有相关数据分行处理
    if #allTargetData > 0 then
        local lines = split(allTargetData, releasePath, testPath)
        
        -- 处理每一行，提取文件路径
        for _, line in ipairs(lines) do
            if string.find(line, releasePath) or string.find(line, testPath) then
                local ibegin, iend = string.find(line, " %s+")
                if ibegin ~= nil then
                    local fullPath = string.sub(line, iend + 1)
                    if fullPath and not seenFiles[fullPath] then
                        allFiles[#allFiles + 1] = fullPath
                        seenFiles[fullPath] = true
                    end
                end
            end
            line = iter()
        end
    end
    
    local rt = {}
    rt.allFiles = allFiles
    rt.fmodPath = fmodPath
    return rt
end

-- 检查文件是否为ELF格式
local function isElfFile(filePath)
    local f = io.open(filePath, "rb")
    if not f then return false end
    
    local magic = f:read(16)
    f:close()
    
    if not magic or #magic < 7 then return false end
    
    local b1 = string.byte(magic, 1)
    local b2 = string.byte(magic, 2)
    local b3 = string.byte(magic, 3)
    local b4 = string.byte(magic, 4)
    local class = string.byte(magic, 5)
    local endian = string.byte(magic, 6)
    local version = string.byte(magic, 7)
    
    return b1 == 0x7F and 
           b2 == string.byte("E") and 
           b3 == string.byte("L") and 
           b4 == string.byte("F") and 
           (class == 1 or class == 2) and 
           (endian == 1 or endian == 2) and 
           version == 1
end



-- 检查并收集可疑的SO文件
local function collectSuspiciousSoFiles(allFiles)
    local getFileMd5Api = CGame and CGame.getFileMd5 or nil
    local retAllSoName = {}
    local added = {}

    for _, p in ipairs(allFiles) do
        local isDex = string.match(p, "%.dex$") ~= nil
        local isoDex = string.match(p, "%.odex$") ~= nil
        if not isDex and not isoDex and isElfFile(p) then
            local fileName = p:match("[^/]+$") or p
            if fileName then
                local savedQueryName = fileName
                if fileName == "libBlockMan_arm64-v8a.so" or fileName == "libBlockMan_armeabi-v7a.so" then
                    savedQueryName = "libBlockMan.so"
                end
                
                local savedMd5 = ""
                if getFileMd5Api then
                    local gameInstance = CGame.Instance()
                    savedMd5 = gameInstance:getFileMd5(savedQueryName)
                    if savedMd5 == "" and not added[fileName] then
                        table.insert(retAllSoName, fileName)
                        added[fileName] = true
                    end
                end
            end
        end
    end
    
    return retAllSoName
end

-- 主函数
local result = "nil"
local procMaps = readProcMaps()
local allFiles = procMaps and procMaps.allFiles or nil 

if allFiles then
    local suspiciousSoFiles = collectSuspiciousSoFiles(allFiles)
    for _, soFile in ipairs(suspiciousSoFiles) do
        result = result .. soFile .. "|"
    end
else
    result = "nil2"
end

]]


function CheckSoInMemScript:getContent()
	return checkScript..self:getResultCode()
end

function CheckSoInMemScript:getReportHackInfo()
	local HackReport = T(Global, "HackReport", nil)
	return HackReport.actionType.useFakeAppBySo, self.hackDesc
end

function CheckSoInMemScript:needKickoutPlayer()
	local AntiHackConfig = T(Global, "AntiHackConfig")
	if AntiHackConfig:getConfig().KickOutSoHack then 
		return true
	end
	return false
end

function CheckSoInMemScript:onSend(playerId, id)
    self.super:onSend(playerId, id)
end

function CheckSoInMemScript:onReciveResult(playerId, result, excuteFailed)
    self.super:onReciveResult(playerId, result)
    
    if excuteFailed then
        return false
    end

	local AntiHackConfig = T(Global, "AntiHackConfig")
	if result ~= nil then 
		local allSo = result.soFile
        local clientInfo = GameAnalyticsCache:getClientInfo(playerId)
        if result == "nil2" and clientInfo.os_platform ~= "ios" then
            self.hackDesc = "so in mem check nil2 " .. StringUtil.v2s(allSo)
            return true
        elseif allSo and #allSo > 0 then 
            self.hackDesc = "so in mem check" .. StringUtil.v2s(allSo)
            return true
        end
	end
	return false
end
return CheckSoInMemScript

--[[LDFs8vtC4gFAhG1JGEijF0IK1f]]