--[[zhTCXazdtxn6yGCBHtG3RCTd]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1205
                          local checkFileName = "ScoreID.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[iDrXBRM]]---
--- Created by Jimmy.
--- DateTime: 2017/12/26 0026 16:44
---
ScoreID = {}

ScoreID.KILL = "1"  -- 击杀
ScoreID.DIE = "2" -- 死亡
ScoreID.LIVE = "3" -- 生存
ScoreID.SERIAL_KILL = "4" -- 连续击杀
ScoreID.DESTROY_BED = "5" -- 破坏床
ScoreID.FLAG = "6" -- 夺旗
ScoreID.POINT = "7" -- 积分
ScoreID.WIN = "8" -- 胜局数

return ScoreID--[[nkHrhU0d1crfRP2BTmiJT3e5J1D8oQ3x3yJoYovw9Ju6hvqkN6NzaCVD0JJdc1hmy3YaYMCHvYkIg4oGKvm]]---