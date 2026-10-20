require "engine_base.util.zipfile"

VFS2 = {}

ResPackFile = class('ResPackFile')
function ResPackFile:ctor(path)
    self.path = path
    self.linePos = 1
    self.content = nil
    self.lineEnd = false
end

function ResPackFile:isExist()
    return ResourcePackManager:Instance():isFileExsistByFullPath(self.path)
end

function ResPackFile:read(tag)
    if tag == "*a" then
        return self:readFullFile()
    else
        return self:readLine()
    end
end

function ResPackFile:readFullFile()
    if not self.content then
        self.content = ResourcePackManager:Instance():readAsStrByFullPath(self.path)
    end
    return self.content
end

function ResPackFile:readLine()
    if not self.content then
        self.content = ResourcePackManager:Instance():readAsStrByFullPath(self.path)
    end
    return self:readNextLine()
end

function ResPackFile:readNextLine()

    if self.lineEnd then 
        return nil
    end

    local str = self.content
    local line = ""
    local first, last = string.find(str, "\r\n?", self.linePos) -- windows
    if not first then 
        first, last = string.find(str, "\n", self.linePos) --linux
    end
    if first then
        line = string.sub(str, self.linePos, first - 1)
        self.linePos = last + 1
    else
        line = string.sub(str, self.linePos)
        self.linePos = string.len(str)
    end

    if self.linePos >= string.len(str) then
        self.lineEnd = true
    end
    
    return line
end

function ResPackFile:write(content)
    print("wrong opration for respack file write")
end

function ResPackFile:close()
    
end

function VFS2:init()
    self:start()
end

local function normalizePath(path)
    path = string.gsub(string.gsub(path, "\\", "/"), "(/+)", "/")

    local head = string.sub(path, 1, 1) == "/"
    local tail = string.sub(path, -1) == "/"

    local names = {}
    for name in string.gmatch(path, "([^/]+)") do
        if name == ".." and names[#names] and names[#names] ~= ".." then
            --assert(#names > 0)

            table.remove(names)
        elseif name ~= "." or not next(names) then
            table.insert(names, name)
        end
    end

    local ret = table.concat(names, "/")
    if head then
        ret = "/" .. ret
    end

    if #names > 0 and tail then
        ret = ret .. "/"
    end

    return ret
end

local function getZipEntryName(filePath, returnOriginalName)
    local relaPath = ZipResourceManager.Instance():getEntryName(filePath)
    if relaPath ~= "" then
        return relaPath
    end
    local gamePath = normalizePath(FileUtil:getRootPath())
    local find, q = string.find(filePath, gamePath, 1, true)
    local entryName = false
    if find then
        entryName = string.sub(filePath, q + 1)
    else
        if returnOriginalName then
            entryName = filePath
        else
            entryName = nil
        end
    end
    return entryName
end

local function stringEnds(String, End)
    return String ~= nil and (End == '' or string.sub(String, -string.len(End)) == End)
end

local io_open, lfs_dir, lfs_attributes, _loadfile
function VFS2:start()
    io_open = io_open or io.open
    io.open = function(path, mod)
        local localFile, msg = io_open(path, mod)
        local oldPath
        local recordMsg
        if localFile then
            return localFile, msg
        else
            oldPath = path
            recordMsg = msg
        end

        local resPackFile  = ResPackFile.new(path)
        if resPackFile:isExist() then 
            return resPackFile, msg
        end

        path = normalizePath(path)
        local zipFile = ZipFile.new(path)
        if not zipFile:isExist() then
            zipFile = nil
            msg = string.format("open zip file fail: %s ", path)
        end
        return zipFile, msg
    end

    lfs_dir = lfs_dir or lfs.dir
    lfs.dir = function(dir)
        local attr = lfs.attributes(dir, nil, true)
        if attr then
            return lfs_dir(dir)
        end
        local dirName = getZipEntryName(dir)
        if not stringEnds(dirName, "/") and dirName ~= "" then
            dirName = dirName .. "/"
        end

        local fileList = ZipResourceManager.Instance():getFilesInEntry(dirName)
        local all = {}
        for _, file in pairs(fileList) do
            table.insert(all, file)
        end
        local index = 0
        local count = #fileList
        return function()
            index = index + 1
            if index > count then
                --print("End dir!!!!!!!!!!!!!!!!!!!!!!!!!:" .. dir)
                return nil
            end
            if string.sub(all[index], -1) == "/" then
                return string.sub(all[index], 1, string.len(all[index]) - 1)
            end
            return all[index]
        end, all
    end

    lfs_attributes = lfs_attributes or lfs.attributes
    lfs.attributes = function(path, attributename, raw)
        local result = lfs_attributes(path, attributename)
        if result then
            return result
        end
        if raw then
            return nil
        end
        path = normalizePath(path)

        local fileName
        if FileResourceManager:Instance():ResourceExistInZip(path) then
            fileName = getZipEntryName(path, true)
        elseif string.sub(path, -1) ~= "/" and FileResourceManager:Instance():ResourceExistInZip(path .. "/") then
            path = path .. "/"
            fileName = getZipEntryName(path, true)
        end
        if fileName then
            if attributename == "mode" then
                if ZipResourceManager.Instance():isFile(path) then
                    result = "file"
                else
                    result = "directory"
                end
            elseif attributename == "modification" then
                local time = ZipResourceManager.Instance():getEntryTimestamp(path)
                if time == 0 then
                    result = nil
                else
                    result = time
                end
            else
                result = {}
                if ZipResourceManager.Instance():isFile(path) then
                    result["mode"] = "file"
                else
                    result["mode"] = "directory"
                end
                result["modification"] = ZipResourceManager.Instance():getEntryTimestamp(path)
            end
        else
            --print(traceback())
            --perror(string.format("lfs.attributes fail path:%s  ||  zipName:%s  ||  attributename:%s", path, fileName, attributename))
            result = nil
        end
        return result
    end

    _loadfile = _loadfile or loadfile
    loadfile = function(path, mode, env)
        local func, errmsg = _loadfile(path, mode, env)
        if func then
        else
            if FileResourceManager:Instance():ResourceExistInZip(path) then
                local chunk = ZipResourceManager.Instance():readResource(path)
                func, errmsg = load(chunk, "@" .. path, mode, env)
            end
        end
        return func, errmsg
    end
end

function VFS2.testForUpdate()

end

VFS2:init()