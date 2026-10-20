--[[KZtrLR2vi1lNCIh0fKWz88MN4fAH4Y1f6haFZ5uYsMW1lQ6he2WUxdwgY9jmg0vPVy13aU6bbPsR7u38LlPWhfTux2Bcyw8gj96eouJmTiYxw3CXmLCryB9K1z5r8iuOYstr1zATppHfe2alVbhNii4gBbL9mAPU]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1539
                          local checkFileName = "AntiHacker.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[FNVuUgZdI9wTsUdXjh4zYLFepJZe4QBld4bTUAkkXxb]]require "engine_server.antihack.vm.code_encoder"
require "engine_server.antihack.vm.LuaVM"
require "engine_server.antihack.dynamic_script.check_client_lua"
require "engine_server.antihack.APKChecker"
require "engine_server.antihack.NewChecker"
require "engine_server.antihack.SandboxolChecker"
require "engine_server.antihack.ClientFileChecker"
require "engine_server.antihack.HackReport"
require "engine_server.antihack.AntiHackConfig"
require "engine_server.antihack.dynamic_script.dynamic_script_mgr"
require "engine_server.antihack.HandleClientLuaCheckResult"--[[HgAp685chSirR8USFvEAAMqc5eWuj3Gs]]---