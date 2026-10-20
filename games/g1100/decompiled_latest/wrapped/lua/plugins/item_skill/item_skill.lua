--[[KZB3tjWSkKcdPfSk3LrpyBikwbtKAaBPeO3Rz5LplZbfxs2LJQn0fVeva5Cm33q65Avbg5P7XxfYTJYe2ac5]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1522
                          local checkFileName = "item_skill.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[UKCPXenzCJXkRKF]]---起床专属插件 ， 为了功能模块化
local handlers = {}

Plugins.Require("item_skill", "common.define.ItemSkillDefine")
Plugins.Require("item_skill", "common.event.ItemSkillEvents")
Plugins.Require("item_skill", "common.config.MonsterConfig")
Plugins.Require("item_skill", "common.config.MountConfig")
Plugins.Require("item_skill", "common.config.SkillConfig")

if isClient then
    handlers = Plugins.Require("item_skill", "client.item_skill_client")
else
    handlers = Plugins.Require("item_skill", "server.item_skill_server")
end

return function(name, ...)
    if type(handlers[name]) ~= "function" then
        return
    end
    handlers[name](...)
end--[[mgovMlKOC79]]