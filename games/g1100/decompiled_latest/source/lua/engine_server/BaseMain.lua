---
--- Created by Jimmy.
--- DateTime: 2018/10/9 0009 15:02
---
require "engine_base.Base"
require "engine_server.define.ScoreID"
require "engine_server.util.DynamicCast"
require "engine_server.util.EngineUtil"
require "engine_server.util.InventoryUtil"
require "engine_server.util.MerchantUtil"
require "engine_server.util.MsgSender"
require "engine_server.util.WalletUtils"
require "engine_server.util.BaseUtil"
require "engine_server.util.PointUtil"
require "engine_server.util.RectUtil"
require "engine_server.util.ServerHelper"
require "engine_server.util.RespawnHelper"
require "engine_server.util.ServerLang"
require "engine_server.util.Lang"
require "engine_server.config.SumRechargeConfig"
require "engine_server.recharge.SumRechargeHelper"
require "engine_server.event.CommonDataEvents"
require "engine_server.event.GameEvents"
require "engine_server.analytics.GameAnalytics"
require "engine_server.analytics.GameAnalyticsCache"
require "engine_server.cache.PlayerIdentityCache"
require "engine_server.code.GameOverCode"
require "engine_server.code.MailType"
require "engine_server.data.BaseBtTree"
require "engine_server.entity.IEntity"
require "engine_server.entity.EntityCache"
require "engine_server.data.BasePlayer"
require "engine_server.data.EngineWorld"
require "engine_server.exp.ExpRule"
require "engine_server.exp.UserExpManager"
require "engine_server.listener.BaseListener"
require "engine_server.messages.IMessages"
require "engine_server.pay.PayHelper"
require "engine_server.pay.OrderManager"
require "engine_server.prop.AppProps"
require "engine_server.rank.RankManager"
require "engine_server.season.SeasonManager"
require "engine_server.task.ITask"
require "engine_server.task.CommonTask"
require "engine_server.web.WebRequestType"
require "engine_server.web.WebService"
require "engine_server.GameServer"
require "engine_server.manager.DBManager"
require "engine_server.manager.GameGroupManager"
require "engine_server.manager.PlayerManager"
require "engine_server.manager.ReportManager"
require "engine_server.manager.RewardManager"
require "engine_server.packet.PacketChecker"
require "engine_server.packet.PacketSender"
require "engine_server.packet.PidPacketHandler"
require "engine_server.packet.PidPacketSender"
require "engine_server.helper.MaxRecordBuilder"
require "engine_server.helper.MaxRecordHelper"
require "engine_server.helper.ExchangeHelper"
require "engine_server.ai.AIPlayerManager"
require "engine_server.helper.GMHelper"

BaseListener:init()

BaseMain = {}
BaseMain.GameType = "g1001"
BaseMain.IsChina = false

function BaseMain:setGameType(GameType)
    self.GameType = GameType
    DBManager:setGameType(self.GameType)
    ReportManager:setGameType(self.GameType)
    RewardManager:setGameType(self.GameType)
    HostApi.setServerGameType(GameType)
end

function BaseMain:getGameType()
    return self.GameType
end

function BaseMain:setIsChina(isChina)
    self.IsChina = isChina
end

function BaseMain:isChina()
    return self.IsChina
end

require "engine_server.connector.ConnectorCenter"

-----表示当收集器在总使用内存数量达到上次垃圾收集时的1.2倍(默认2倍)时再开启新的收集周期
collectgarbage("setpause", 120)
-----表示垃圾收集器的运行速度是内存分配的5(默认2倍)倍
collectgarbage("setstepmul", 500)
