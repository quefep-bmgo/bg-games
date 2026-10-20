--[[15hiLC]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1955
                          local checkFileName = "PotionID.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[6IYeYAsgeuLtDjWiH9UKfHpZJxZ8rzQGbBrDxQaOrxSjgu2nEnSwkqYXKsxQvGlm0mhzTTFWhI43xDzBtZvo4R7iiCTgVUqgALbEIsJMN85rGlz1x1t2YGnchc60DaDeJPUcyzmeZSgU9QponDtCCjtZLXfSOa2okMHvJBDESmt9wgHzykAN1FXKy8pBY3lOWtLngLtPsz0avAjMSWGa1uTfFgDui5RQHf2wuvvDzO1sUCtz8qRLCG2ZW13]]---
--- Created by Jimmy.
--- DateTime: 2018/1/15 0015 12:08
---
PotionID = {}

PotionID.MOVE_SPEED             = 1
PotionID.MOVE_SLOWDOWN          = 2
PotionID.DIG_SPEED              = 3
PotionID.DIG_SLOWDOWN           = 4
PotionID.DAMAGE_BOOST           = 5
PotionID.HEAL                   = 6
PotionID.HARM                   = 7
PotionID.JUMP                   = 8
PotionID.CONFUSION              = 9
PotionID.REGENERATION           = 10
PotionID.RESISTANCE             = 11
PotionID.FIRE_REGISTANCE        = 12
PotionID.WATER_BREATHING        = 13
PotionID.INVISIBILITY           = 14
PotionID.BLINDNESS              = 15
PotionID.NIGHT_VISION           = 16
PotionID.HUNGER                 = 17
PotionID.WEAKNESS               = 18
PotionID.POISON                 = 19
PotionID.WITHER                 = 20
PotionID.HEALTH_BOOST           = 21
PotionID.ABSORPTION             = 22
PotionID.SATURATION             = 23

return PotionID--[[5D3OnD0bJ0xFGNEVrlnPz]]---