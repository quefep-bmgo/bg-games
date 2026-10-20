--[[15hiLC]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1854
                          local checkFileName = "PotionItemID.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[fnc0PpLZb48aoREgtXT8z2NoYr9aoJMeWbqTcFd4sFl5ElsfxO31641sbCXAuGT1F6dNJLQNpOLPoR1mWVuO1Qum]]---
--- Created by Jimmy.
--- DateTime: 2018/1/22 0022 17:25
---

PotionItemID = {}

PotionItemID.POTION_MEDICINE_PACK = 483
PotionItemID.POTION_MEDICINE_POTION = 484
PotionItemID.POTION_INVISIBILITY  = 512
PotionItemID.POTION_LONG_INVISIBILITY  = 513
PotionItemID.POTION_JUMP  = 514
PotionItemID.POTION_LONG_JUMP = 515
PotionItemID.POTION_STRONG_JUMP  = 516
PotionItemID.POTION_HEAL  = 517
PotionItemID.POTION_STRONG_HEAL  = 518
PotionItemID.POTION_MOVE_SPEED  = 519
PotionItemID.POTION_LONG_MOVE_SPEED  = 520
PotionItemID.POTION_STRONG_MOVE_SPEED  = 521
PotionItemID.POTION_POISON  = 522
PotionItemID.POTION_LONG_POISON  = 523
PotionItemID.POTION_STRONG_POISON  = 524
PotionItemID.POTION_NIGHT_VISION  = 525
PotionItemID.POTION_LONG_NIGHT_VISION  = 526
PotionItemID.POTION_SPLASH_HEAL  = 527
PotionItemID.POTION_SPLASH_STRONG_HEAL  = 528
PotionItemID.POTION_SPLASH_POISON  = 529
PotionItemID.POTION_SPLASH_LONG_POISON  = 530
PotionItemID.POTION_SPLASH_STRONG_POISON  = 531


return PotionItemID--[[5D3OnD0bJ0xFGNEVrlnPz]]