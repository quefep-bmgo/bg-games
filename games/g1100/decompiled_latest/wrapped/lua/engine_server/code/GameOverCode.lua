--[[d0]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1174
                          local checkFileName = "GameOverCode.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[sLAL2Q8rm2btrIizIXCb328H9mJCnd6fqo8aiFmZCryuik9bntyVMLm9CvcUV6MqmTOCgnR0TnuA9npgWV7F]]---
--- Created by Jimmy.
--- DateTime: 2018/3/5 0005 16:33
---
GameOverCode = {}

GameOverCode.Success = 0
GameOverCode.GameOver = 1
GameOverCode.GameStarted = 2
GameOverCode.PlayerIsEnough = 3
GameOverCode.ReadyNoPlayer = 4
GameOverCode.NoThisTeam = 5
GameOverCode.LoadDBDataError = 6
GameOverCode.GameEnd = 14

return GameOverCode--[[flsuTsbH7zKv]]