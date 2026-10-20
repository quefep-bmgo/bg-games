--[[]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1684
                          local checkFileName = "SkillManager.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[wtFO6DuRBF8D8QHsJug99hd]]---@class CSkillManager
local CSkillManager = T(Global, "SkillManager")
local skills = {}

function CSkillManager:init()
    -- ---@type UIItemSkillMainLayout
    -- self.itemSkillMainLayout = UIHelper.newGameGUILayout("GUIItemSkillMain")
    -- self.itemSkillMainLayout:show()
    BaseListener.registerCallBack(CEvents.GameMainTickEvent, function(frameTime)
        if isGameStart then
            CSkillManager:onTick()
        end
    end)
end

function CSkillManager:onTick()
    for _, class in pairs(skills) do
        if class.onTick then
            class:onTick()
        end
    end
end

function CSkillManager:toItemSkillPacket(packet)
    local funcName = packet.funcName
    for _, class in pairs(skills) do
        local func = class[funcName]
        if type(func) == "function" then
            func(class, packet)
        end
    end
end

CSkillManager:init()--[[njsImzwk5CZBsBaeHpO16BOmzsiEyTMT8ME9LnmVxm]]