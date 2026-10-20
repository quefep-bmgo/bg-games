--[[aZ4Ii7xWTi1IeBWp3oRFR6WHsCU1nnjDjGTCDM3DsYlMyoNHUSxsXgj8YQ7ma1hTLPof3qnw8nwwXo9VvYNtYXdA90byiiLA]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 2439
                          local checkFileName = "MsgSender.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[rIOCCU]]--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

MsgSender = {}

function MsgSender.sendMsg(msg, args)
    if msg == nil then
        HostApi.log("Msg.sendMsg  is nil msg")
        return
    end
    if type(msg) == "number" then
        HostApi.sendMsgByType(0, 5, msg, args or "")
    else
        HostApi.sendMsg(0, 5, msg)
    end
end

function MsgSender.sendTopTips(time, msg, args)
    if msg == nil then
        HostApi.log("Msg.sendTopTips  is nil msg")
        return
    end

    if type(msg) == "number" then
        HostApi.sendMsgByType(1, time, msg, args or "")
    else
        HostApi.sendMsg(1, time, msg)
    end
end

function MsgSender.sendBottomTips(time, msg, args)
    if msg == nil then
        HostApi.log("Msg.sendBottomTips  is nil msg")
        return
    end

    if type(msg) == "number" then
        HostApi.sendMsgByType(2, time, msg, args or "")
    else
        HostApi.sendMsg(2, time, msg)
    end
end

function MsgSender.sendCenterTips(time, msg, args)
    if msg == nil then
        HostApi.log("Msg.sendCenterTips  is nil msg")
        return
    end

    if type(msg) == "number" then
        HostApi.sendMsgByType(3, time, msg, args or "")
    else
        HostApi.sendMsg(3, time, msg)
    end
end

function MsgSender.sendOtherTips(time, msg, args)
    if msg == nil then
        HostApi.log("Msg.sendOtherTips is nil msg")
        return
    end

    if type(msg) == "number" then
        HostApi.sendMsgByType(4, time, msg, args or "")
    else
        HostApi.sendMsg(4, time, msg)
    end
end

return MsgSender

--endregion
--[[9ilttXhGmpE6]]---