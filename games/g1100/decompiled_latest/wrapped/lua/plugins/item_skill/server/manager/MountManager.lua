--[[3TZgCLwc98d26gRXd0cpmXSVMeGsuTFekKSLHiGbFWgSggI]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1235
                          local checkFileName = "MountManager.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[sOXw]]---@type GameMount[]
local Mounts = {}

MountManager = {}

function MountManager:addMount(entity)
    Mounts[tostring(entity.entityId)] = entity
end

function MountManager:getMount(entityId)
    return Mounts[tostring(entityId)]
end

function MountManager:removeMount(entity)
    Mounts[tostring(entity.entityId)] = nil
end

function MountManager:onTick()
    for _, entity in pairs(Mounts) do
        entity:onTick()
    end
end--[[PiJvAielSvnW]]---