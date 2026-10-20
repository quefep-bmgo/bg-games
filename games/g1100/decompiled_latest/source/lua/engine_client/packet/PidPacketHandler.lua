---@class CPacketHandlers : CBasePlayer
local PacketHandlers = T(Global, "PacketHandlers")
---@type function[]
local Session = T(Global, "Session")
---@type table<string, number>
local HashId2Name = T(Global, "S2CPid_HashId2Name")
---@type CBasePlayer
local CBasePlayer = BasePlayer
---@type table<number, number>
local VipRecord = T(Global, "VipRecord")
---@type table<number, number>
local UserPrivilegeGrade = T(Global, "UserPrivilegeGrade")
---@type table<number, number>
local UserPrivilegeCfg = T(Global, "UserPrivilegeCfg")
UserPrivilegeCfg[1] = 1
UserPrivilegeCfg[2] = 5

---@param packet PidPacket
function CBasePlayer:sendPacket(packet, resp)
    assert(not packet.__session__)
    if not packet.pid then
        return
    end
    if resp then
        assert(type(resp) == "function")
        local session = #Session + 1
        Session[session] = resp
        packet.__session__ = session
    end
    PacketSender:sendPidPacket(packet)
end

---@private
---@param packet PidPacket
function PacketHandlers.__on_pid_packet_handler__(packet)
    local func = PacketHandlers[packet.pid]
    if not func then
        LogUtil.logWarning("[PacketHandlers] can not find func, pid=" .. packet.pid)
        return
    end
    local player = PlayerManager:getClientPlayer()
    local ret = func(player, packet)
    if packet.__session__ ~= nil then
        player:sendPacket({
            pid = "resp",
            session = packet.__session__,
            ret = ret
        })
    end
end

CommonDataEvents:registerCallBack("pid", function(packet)
    if not packet.pid then
        LogUtil.logScriptException("[PacketHandlers] can not find pid.", StringUtil.v2s(packet))
        return
    end
    packet.pid = HashId2Name[packet.pid] or packet.pid
    PacketHandlers.__on_pid_packet_handler__(packet)
end, SerializeBuilderProcessor)

function PacketHandlers:resp(packet)
    Session[packet.session](packet.ret)
    Session[packet.session] = nil
end

function PacketHandlers:openGMHelper()
    GMHelper:enableGM()
end

function PacketHandlers:openErrorLog()
    local ErrorLogIds = T(Global, "ErrorLogIds")
    table.insert(ErrorLogIds, Game:getPlatformUserId())
end

function PacketHandlers:AddEventToDialog(packet)
    if GUIGMMain then
        GUIGMMain:addEventToDialog(packet.event_map)
    else
        LuaTimer:schedule(function()
            PacketHandlers.AddEventToDialog(self, packet)
        end, 1000)
    end
end

function PacketHandlers:showToast(packet)
    local content
    local params = packet.params
    if params then
        for i, param in pairs(params) do
            params[i] = Lang:getString(param)
        end
        content = Lang:format(packet.content, table.unpack(params))
    else
        content = Lang:getString(packet.content)
    end
    if packet.isCenter then
        UIHelper.showCenterToast(content, packet.time)
    else
        UIHelper.showToast(content, packet.time)
    end
end

function PacketHandlers:showDialogTip(packet)
    if CustomDialog.isShow() then
        CustomDialog.hide()
    end
    CustomDialog.builder()
    if packet.title then
        CustomDialog.setTitleText(packet.title)
    end
    if packet.content and packet.params then
        local params = packet.params
        if type(params) == "table" then
            for i, param in pairs(params) do
                params[i] = Lang:getString(param)
            end
            CustomDialog.setContentText(Lang:format(packet.content, table.unpack(params)))
        else
            CustomDialog.setContentText(Lang:format(packet.content, params))
        end
    elseif packet.content then
        CustomDialog.setContentText(Lang:getString(packet.content))
    end
    CustomDialog.show()
end

function PacketHandlers:playSound(packet)
    if packet.position then
        SoundUtil.playSound3D(packet.type, packet.position.x, packet.position.y, packet.position.z)
    else
        SoundUtil.playSound(packet.type)
    end
end

function PacketHandlers:setShowName(packet)
    local player = PlayerManager:getPlayerByUserId(packet.userId)
    if not player or not player.Player then
        return
    end
    player.Player:setShowName(packet.showName)
    player.Player:setUserName(packet.name)
end

function PacketHandlers:GMOpenInput(packet)
    GUIGMControlPanel:openInput(packet.paramTexts, function(...)
        self:sendPacket({
            pid = "GMOpenInputBack",
            params = { ... }
        })
    end)
end

function PacketHandlers:TotalRechargeCube(packet)
    PlayerManager:getClientPlayer().total_recharge_cube = packet.gcube
end

function PacketHandlers:DebugCmd(packet)
    ---@type DebugCmd
    local DebugCmd = T(Global, "DebugCmd")
    DebugCmd:doCmd({}, packet.line, false)
    return T(Global, "PrintCache")
end

function PacketHandlers:SyncPlayerMoney(packet)
    PlayerWallet:setMoneyCount(CurrencyId.GCube, packet.gDiamonds)
    PlayerWallet:setMoneyCount(CurrencyId.Diamonds, packet.gDiamonds)
    PlayerWallet:setMoneyCount(CurrencyId.Golds, packet.golds)
    PlayerWallet:setMoneyCount(CurrencyId.GameCashCoupon, packet.gameCashCoupon)
    local wallet = Game:getPlayer():getWallet()
    if wallet then
        wallet.m_diamondBlues = packet.diamonds
        wallet.m_diamondGolds = packet.gDiamonds
        wallet:setGolds(packet.golds)
    end
end

function PacketHandlers:UseGameCashCoupon(packet)
    local content = Lang:format("use.game.cash.coupon", packet.gameCashCoupon, packet.diamonds)
    UIHelper.showCenterToast(content)
end

function PacketHandlers:SyncPlayerPersonalityItems(packet)
    UserInfoCache:UpdateUserInfos({ { userId = packet.userId, personalityItems = packet.personalityItems } })
end

function PacketHandlers:SkyBoxChange(packet)
    if packet.skybox then
        HostApi.setSky(packet.skybox)
    end
end

function PacketHandlers:SyncVipInfo(packet)
    LogUtil.logInfo("[SyncVipInfo] userId=" .. packet.userId .. ", vip=" .. packet.vip)
    VipRecord[packet.userId] = packet.vip
    PlayerManager:getClientPlayer().vipExpireDate = packet.expireDate
    CEvents.PlayerVipChangeEvent:invoke(packet.userId, packet.vip)
end

function PacketHandlers:SyncUserPrivilege(packet)
    LogUtil.logInfo("[SyncUserPrivilege] userId=" .. packet.userId .. ", vip=" .. packet.vip .. ", vipLv=" .. packet.vipLv)
    UserPrivilegeGrade[packet.userId] = packet.vip
    if packet.cfg then
        for _, cfg in pairs(packet.cfg) do
            UserPrivilegeCfg[cfg.gameLv] = cfg.startVipLv
        end
    end
    PlayerManager:getClientPlayer().vipLv = packet.vipLv
    CEvents.PrivilegeGradeChangeEvent:invoke(packet.userId, packet.vip, packet.vipLv)
end

function PacketHandlers:SyncServerLog(packet)
    ClientHelper.onSetClipboard(packet.content)
    UIHelper.showToast("拷贝成功，请粘贴到钉钉上自动生成文件发送到群里")
end

return PacketHandlers