--[[SayY1o]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 3023
                          local checkFileName = "SafeCallUtil.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[lPqnE1KrnUWLkKGBXiuZ6JZSOLC7XudtrDMOog25aK5guItDoAiFlNtWXaV41yMQxtzEcl09WRE34phOSNIuruljtZOVBY3T0rXnAT]]SafeCallUtil = {}

local function resolveMethodFromIndexTable(indexTable, methodName)
    if type(indexTable) ~= "table" then
        return nil
    end

    local method = rawget(indexTable, methodName)
    if type(method) == "function" then
        return method
    end

    local mt = getmetatable(indexTable)
    while type(mt) == "table" do
        local parentIndex = rawget(mt, "__index")
        if type(parentIndex) ~= "table" then
            break
        end

        method = rawget(parentIndex, methodName)
        if type(method) == "function" then
            return method
        end
        mt = getmetatable(parentIndex)
    end
    return nil
end

local function resolveMethod(obj, methodName)
    if not obj or type(methodName) ~= "string" or methodName == "" then
        return nil
    end

    local objType = type(obj)
    if objType == "table" then
        local method = rawget(obj, methodName)
        if type(method) == "function" then
            return method
        end
        local mt = getmetatable(obj)
        if type(mt) == "table" then
            return resolveMethodFromIndexTable(rawget(mt, "__index"), methodName)
        end
        return nil
    end

    if objType == "userdata" then
        local mt = getmetatable(obj)
        if type(mt) ~= "table" then
            return nil
        end

        local method = rawget(mt, methodName)
        if type(method) == "function" then
            return method
        end
        return resolveMethodFromIndexTable(rawget(mt, "__index"), methodName)
    end

    return nil
end

function SafeCallUtil.hasMethod(obj, methodName)
    return type(resolveMethod(obj, methodName)) == "function"
end

function SafeCallUtil.tryCallMethodWithSelf(obj, methodName, ...)
    local method = resolveMethod(obj, methodName)
    if type(method) ~= "function" then
        return false
    end

    return pcall(method, obj, ...)
end

function SafeCallUtil.tryCallFunctionWithoutSelf(obj, methodName, ...)
    local method = resolveMethod(obj, methodName)
    if type(method) ~= "function" then
        return false
    end

    return pcall(method, ...)
end

return SafeCallUtil
--[[iCoFiCA9i]]---