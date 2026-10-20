--[[N]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 2377
                          local checkFileName = "ScriptMain.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[7L1atrZvVP0Z5pl5J0n3Wywr6NuuPrfUugaLxWU]]
require("base.config.CustomRoomDefine")
require("base.util.CustomRoomUtil")
require("base.util.VersionUtil")
require "GMServer"
BaseListener.registerCallBack(CEvents.GameInitEvent, function(config)
    VersionUtil.printVersion()
    local startConfig = Server.Instance():getConfig()   -- C++ RoomGameConfig
    local customGameCls = {}
    if startConfig.customGameMode == Define.CustomGameMode.PVP then
        customGameCls = require "game.CustomGamePVP"
    elseif startConfig.customGameMode == Define.CustomGameMode.CREATIVE then
        customGameCls = require "game.CustomGameCreative"
    elseif startConfig.customGameMode == Define.CustomGameMode.RUN then
        customGameCls = require "game.CustomGameRunning"
    elseif startConfig.customGameMode == Define.CustomGameMode.EDIT then
        customGameCls = require "game.CustomGameUGC"
    else
        customGameCls = require "game.CustomGameSocial"
    end

    local ownerId = startConfig.customGameOwnerId
    local roomId = startConfig.roomId

    local customGame = customGameCls.new()
    T(Global, "customGame", customGame)
    customGame:init(ownerId, roomId, config, startConfig.extra)

    require "listener.PlayerListener"
    require "listener.BlockListener"
    require "listener.ChestListener"
    require "packet.PacketHandler"
    require "packet.PacketSender"
    require "util.RandomUtil"

    Plugins.CallTargetPluginFunc("item_skill", "enable")

    require "config.BridgeConfig"
    BridgeConfig:init(Global.setting.bridge)
end)--[[LDxdbfPf2NOwVuHasCMsQvw0BjGgvmIs3kDO0anAy5KjceUuMSW5MDR3JTsMM6BSNpF4aMvCtkZsD4suNVCi]]---