--[[83i4cLJWSTbYhgkDSF5oP0oCkuXZuAy7i4Nng7wSiIDytX1TUn5zJffxragVK4DBlBV85sXs6xlV3oD8y8mabQJ7yZpj4rlXW7v7O]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 5946
                          local checkFileName = "ConfigLoader.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[vnTFEFldIRaG2yJlu01ZRy8LSRjHQVvTaRHErWMSzDvnEhFb7QFs]]---
--- Created by Zhao Zongsheng.
--- DateTime: 2021/3/25
--- 用于加载并预处理配置
---
--- 配置读进近程序之后，还需要做一些预处理逻辑才能被程序使用。配置的预处理分为两个阶段：
--- 1. 离线处理阶段
--- 2. 运行时处理阶段
--- 我们可以把尽可能多的逻辑放在离线处理阶段来提升游戏的加载速度
---
--- 离线处理可以在打包配置的时候进行，也可以在运行时加载配置的时候进行。
--- 一般开发时不做离线处理，在读配置时运行时处理。发布的配置则已经经过了离线处理，可以跳过这个阶段
--- 
--- 预处理逻辑和游戏逻辑代码强相关，所以属于游戏代码，但是离线处理的时候我们不希望启动游戏。所以我们通过ConfigLoader去加载配置
--- ConfigLoader为离线预处理代码提供一个沙盒环境，只能访问lua标准库函数以及少数的utility函数以及环境参数，保证运行时和离线时可以提供一样的环境
--- 预处理逻辑放在几个config_preprocessor文件夹中，lua文件名和配置名相同，所属目录也和配置所属目录相对应
--- 由于ConfigLoader要在离线处理阶段使用，所以不能依赖与引擎的内容，也尽可能少依赖其余的lua文件
---

ConfigLoader = {}

local binaryEnabled = true
function ConfigLoader.setBinaryEnabled(value)
    binaryEnabled = value
end

local mapPath = ""
function ConfigLoader.setMapPath(path)
    mapPath = path
end

local searchPath = ""
function ConfigLoader.setPreprocessorPathList(list)
    local replacedPathList = {}
    for _, path in pairs(list) do
        local entry = package.path:gsub('?.lua', path .. '?.lua')
        table.insert(replacedPathList, entry)
    end
    searchPath = table.concat(replacedPathList, ';')
end
function ConfigLoader.setPreprocessorPath(path)
    searchPath = package.path:gsub('?.lua', path .. '?.lua')
end
function ConfigLoader.addPreprocessorPath(path)
    local entry = package.path:gsub('?.lua', path .. '?.lua')
    searchPath = entry .. ";" .. searchPath
end

local reportError = print
local util = {
    readCsv = CsvUtil.loadCsvFile,
    splitString = StringUtil.split,
    reportError = reportError,
}
function ConfigLoader.setErrorReporter(func)
    reportError = func
    util.reportError = func
end

local envMetatable = {
    -- lua built-in functions
    table = table,
    string = string,
    math = math,
    assert = assert,
    collectgarbage = collectgarbage,
    dofile = dofile,
    error = error,
    getmetatable = getmetatable,
    ipairs = ipairs,
    load = load,
    loadfile = loadfile,
    loadstring = loadstring,
    next = next,
    pairs = pairs,
    pcall = pcall,
    print = print,
    rawequal = rawequal,
    rawget = rawget,
    rawset = rawset,
    require = require,
    select = select,
    setmetatable = setmetatable,
    tonumber = tonumber,
    tostring = tostring,
    type = type,
    unpack = table.unpack,
    xpcall = xpcall,

    -- additional functions and variables
    util = util,
}
envMetatable.__index = envMetatable
local configs = {}
local getLoader = (package.searchers and package.searchers or package.loaders)[2]
local configLoaderEnv = setmetatable({}, envMetatable)

local function readConfig(relativePath)
    if relativePath:sub(-4):lower() ~= '.csv' then
        -- currently, only support csv config
        return {}
    end
    local modulePath = relativePath:sub(1, -5)

    -- read from lua bytecode
    if binaryEnabled then
        local path = mapPath .. modulePath .. ".lbc"
        local preprocessor = loadfile(path)
        if preprocessor then
            local ret = preprocessor()
            if not ret then
                LogUtil.reportErrorFile(path, "Failed to read config file: " .. path)
                return {}
            end
            return ret
        end
    end

    -- read from config preprocessor
    local moduleName = modulePath:gsub('/', '.'):gsub('\\', '.')
    local original = package.path
    package.path = searchPath
    local loader = getLoader(moduleName)
    package.path = original
    if type(loader) ~= "function" then
        reportError("failed to read config " .. relativePath .. ": " .. tostring(loader))
        return {}
    end
    configLoaderEnv.path = mapPath .. relativePath
    setfenv(loader, configLoaderEnv)
    local success, result = pcall(loader, moduleName)
    if success then 
        if not result then
            local path = mapPath .. modulePath .. ".csv"
            LogUtil.reportErrorFile(path, "Failed to read csv config file: " .. path)
            return {}
        end
        return result
    end
    reportError("failed to read config " .. relativePath .. ": " .. result)
    return {}
end

function ConfigLoader.getConfig(path)
    local config = configs[path]
    if not config then
        config = readConfig(path)
        configs[path] = config
    end
    return config
end

util.getConfig = ConfigLoader.getConfig--[[aAKw7N8SvG8vqJ6JspdZ19bGLwXd17cRp7x3Fmb]]