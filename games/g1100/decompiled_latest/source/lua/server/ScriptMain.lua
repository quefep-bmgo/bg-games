
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
end)