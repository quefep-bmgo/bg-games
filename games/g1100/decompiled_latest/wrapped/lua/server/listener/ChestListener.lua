--[[W4f286gO1Adh8fCEgScrXPfE6HH6PzOgaji3F1kBps0L0C0D70T1zMftJZm1n2S3SAJ1FIHNyyZbsmuB70TaqoZZVr9fkzsnAi5acgdNpFdnpmAC]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1364
                          local checkFileName = "ChestListener.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[BtnQNNtwrJhb8aZDwKwjnZ1DCSehaZhUwoPA8tzSa1lMKT3I5Y69M5QAJHtK2yeAkY2qjwpKNK]]ChestListener = {}

function ChestListener:init()
    CEvents.ChestOpenEvent:registerCallBack(self.onChestOpen)
end

function ChestListener.onChestOpen(vec3, inv, rakssid)
    local customGame = T(Global, "customGame")
    customGame:onChestOpen(vec3, inv, rakssid)
end

ChestListener:init()

return ChestListener--[[aDjW2tDLpeOOMZbr3kxrN3qbf54Xp3Jwki1hSomQmihJAtaoUdTVKzlxOZCJ1AmyRhmnDt9eEABYJj1LKva9xzFNT6IcAGqhsuGe4Bwg01CQJ2i9e87sNtpaE]]