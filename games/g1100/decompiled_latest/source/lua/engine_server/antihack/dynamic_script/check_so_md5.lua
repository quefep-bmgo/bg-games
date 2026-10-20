local CheckSoMd5Script = class("CheckSoMd5Script", require "engine_server.antihack.dynamic_script.check_base")
local checkScript = [[
-- Result to return
-- 获取应用基本路径
local function isInApp(soPath)
    local releasePath = "com.sandboxol"
    local testPath = "test.sandboxol"

    return string.find(soPath, releasePath) ~= nil or string.find(soPath, testPath) ~= nil
end

local function getFileMd5(path)
    local misc = require("misc")
    if misc and misc.md5_file then
        return misc.md5_file(path)
    end
    return nil
end

local function getOpenFilesWithLfs()
    local packetPath = nil
    local fdPath = "/proc/self/fd"

    local lfs = require("lfs")
    print("getOpenFilesWithLfs fdPath : " .. StringUtil.v2s(fdPath)..StringUtil.v2s(lfs))
    -- 这里找到主程序文件夹
   
    for file in lfs.dir(fdPath) do
        if file ~= "." and file ~= ".." then
            local fdFile = fdPath .. "/" .. file
            print("getOpenFilesWithLfs : " .. StringUtil.v2s(fdFile))
            local success2, attr = pcall(lfs.symlinkattributes, fdFile)
            
            if success2 and attr and attr.target then
                local target = attr.target
                print("getOpenFilesWithLfs target : " .. StringUtil.v2s(target))
                if string.find(target, "base.apk") ~= nil and isInApp(target) then
                    packetPath = target
                end
            end
        end
    end

    -- 遍历PacketPath 以及子目录找到所有so文件
    local allFiles = {}
    local seenFiles = {}
    local function traverseDirectory(dirPath)
        for file in lfs.dir(dirPath) do
            if file ~= "." and file ~= ".." then
                local fdFile = dirPath .. "/" .. file
                print("getOpenFilesWithLfs list: " .. StringUtil.v2s(fdFile))
                --如果是目录继续遍历
                local attr = lfs.attributes(fdFile)
                if attr.mode == "directory" then
                    traverseDirectory(fdFile)
                else
                    table.insert(allFiles, fdFile)
                end
            end
        end
    end

    --组装出lib目录 packetpath路径格式为 /data/app/com.sandboxol.blockymods-NOyxlNMEiHZFLxs8F4T91w==/base.apk
    local libPath = string.sub(packetPath, 1, string.find(packetPath, "/base.apk") - 1) .. "/lib"  
    print("getOpenFilesWithLfs libPath : " .. StringUtil.v2s(libPath))
    traverseDirectory(libPath)
    local rt = {}
    rt.allFiles = allFiles
    rt.fmodPath = nil
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
                    print("CheckSoInMemScript savedQueryName: " .. StringUtil.v2s(savedQueryName))
                    print("CheckSoInMemScript savedMd5: " .. StringUtil.v2s(savedMd5))

                    if savedMd5 == "" and not added[fileName] then
                        print("CheckSoMd5Script savedMd5 is empty: " .. StringUtil.v2s(fileName))
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
local procMaps = getOpenFilesWithLfs()
local allFiles = procMaps.allFiles

if allFiles then
    local suspiciousSoFiles = collectSuspiciousSoFiles(allFiles)
    for _, soFile in ipairs(suspiciousSoFiles) do
        result = result .. soFile .. "|"
    end
end

]]

function CheckSoMd5Script:getContent()
    return checkScript..self:getResultCode()
end

function CheckSoMd5Script:getReportHackInfo()
    local HackReport = T(Global, "HackReport", nil)
    return HackReport.actionType.suspiciousSoFiles, self.hackDesc
end

function CheckSoMd5Script:needKickoutPlayer()
    local AntiHackConfig = T(Global, "AntiHackConfig")
    if AntiHackConfig:getConfig().KickOutSuspiciousSoFiles then 
        return true
    end
    return false
end

function CheckSoMd5Script:onSend(playerId, id)
    self.super:onSend(playerId, id)
end

function CheckSoMd5Script:onReciveResult(playerId, result)
    self.super:onReciveResult(playerId, result)
    
    if result then
        print("CheckSoMd5Script result for player " .. playerId)
        
        if result.error then
            print("Error: " .. result.error)
            return false
        end
        
        if result.suspicious_files and #result.suspicious_files > 0 then
            local suspiciousFiles = {}
            for _, file in ipairs(result.suspicious_files) do
                local info = file.name .. " (" .. file.md5 .. ")"
                if file.reason then
                    info = info .. " - " .. file.reason
                end
                if file.expected_md5 then
                    info = info .. " - expected: " .. file.expected_md5
                end
                table.insert(suspiciousFiles, info)
            end
            
            self.hackDesc = "Suspicious SO files detected: " .. StringUtil.v2s(suspiciousFiles)
            return true
        end
    end
    
    return false
end

return CheckSoMd5Script