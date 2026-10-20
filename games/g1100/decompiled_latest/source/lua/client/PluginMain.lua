local PluginMain = {}
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

return PluginMain