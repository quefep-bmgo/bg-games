--[[V]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1270
                          local checkFileName = "WebRequestType.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[RtH5HJD6eIqpor8ljqAtvcYUpuhUPrYm66kIA6YPWS2JiHFYaLn3f]]---
--- Created by Jimmy.
--- DateTime: 2018/6/28 0028 11:42
---
WebRequestType = {}

-- email status --
WebRequestType.EMAIL_STATUS_UNREAD = "UNREAD"
WebRequestType.EMAIL_STATUS_READ = "READ"
WebRequestType.EMAIL_STATUS_RECEIVED = "RECEIVED"
WebRequestType.EMAIL_STATUS_DELETED = "DELETED"--[[iB6SFScjjHv7pOmUfXFKqbIPumySnjKT4CPLAQG2jZMcT18DYCxCqMPuw8uoMD4CTcX829ltRtWONZb2KcksQNGRKjpN1c8SuQ96mJubCknzfZebvmffaydojYABeBbwomVY7MuZ07dXSjjMBOiEmEmyeQx1cRW9U0UA8TXGjE3hPdAnSaVto]]