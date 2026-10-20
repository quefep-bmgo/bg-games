--[[ZWI9qBmjauTNXjYhevmfjN1fGqQDAuLEv5IvoHkNUS1sja1s5x0wK7i3i72i5AJLjGKqNCv6px4KwKDbioD4kOSzBcqIYb382mfybxO8gJP0nHsVeWxI0sOdWJWXwDKRPjV2Of3wh8LryUqcPGF]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1475
                          local checkFileName = "MailType.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[wqXdcTNzDY]]MailType = {}

MailType.Explore        = 1     -- 探险奖励邮件
MailType.Invite         = 2     -- 邀请人(发送邀请的人)奖励邮件
MailType.BeInvited      = 3     -- 被邀请人(接受邀请的人)奖励邮件
MailType.EveryDaySend   = 4     -- 每日互赠 发送者(发送的人)奖励邮件
MailType.EveryDayBeSend = 5     -- 每日互赠 被送者(接受的人)奖励邮件
MailType.Task           = 6     -- 任务奖励邮件
MailType.LevelUp        = 7     -- 玩家等级提升奖励
MailType.Praise         = 8     -- 点赞--[[jCV0AyhcghAbNeF3sSadCSYiDxTKag]]---