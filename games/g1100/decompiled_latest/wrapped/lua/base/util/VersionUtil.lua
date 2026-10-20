--[[KcaeoBaNhkv6ztyHGIB7J3y2FlREyXsuZ085B7UFy7SOZ]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1099
                          local checkFileName = "VersionUtil.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[6IFR0tO6ccSbzLnzt77TqESCV3q5nyHW3TP3XRA7wiO7US97aPCQ1zoIHxSQYDs2QYoQNvzyllHxcrTgBkiGV]]VersionUtil = {}

local DEV_VERSION = "2026.04.17.3"

function VersionUtil.printVersion()
    print(" ++++++++++++++++++++++++++++++++++ Version: " .. DEV_VERSION)
end

return VersionUtil
--[[aAKw7N8SvG8vqJ6JspdZ19bGLwXd17cRp7x3Fmb]]---