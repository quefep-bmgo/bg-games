--[[iaREwkLsLMY250hSebjlugy56tMvkSlk3ltrwxYspMSeExvkY1RZ13N55zmGv20iNMa]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1485
                          local checkFileName = "PluginMain.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[VPeLqNSF3qEQIOSN6C]]local PluginMain = {}
require("base.config.CustomRoomDefine")
require("base.util.CustomRoomUtil")
require "listener.GameListener"
require "listener.BlockListener"
require "packet.PacketHandler"
require "GMClient"

function PluginMain:init()
    BaseListener.registerCallBack(CEvents.GameInitEvent, self.onGameInit)
    ClientHelper.putBoolPrefs("DisableRenderClouds", true)
    if LogicSetting.setMinBrightness then
		LogicSetting.Instance():setMinBrightness({0.9, 0.9, 0.9, 1.0})
	end

    local customGame = require "CustomGame"
    T(Global, "customGame", customGame)
end

function PluginMain.onGameInit()
end

PluginMain:init()

return PluginMain--[[iCoFiCA9i]]---