--[[d0IpUkwy31bUU0NksLFmHDdPib6Ell1G70yPZZtzMax935DFk60nGAHlzoMRdEOAsvZYNv0ksr]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 4620
                          local checkFileName = "PidPacketHandler.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[gtlkAFZGPH]]---@class SPacketHandlers : SBasePlayer
local PacketHandlers = T(Global, "PacketHandlers")
---@type function[]
local Session = T(Global, "Session")
---@type table<string, number>
local HashId2Name = T(Global, "C2SPid_HashId2Name")
---@type PacketChecker
local PacketChecker = T(Global, "PacketChecker")
---@type SBasePlayer
local SBasePlayer = BasePlayer

---@param packet PidPacket
function SBasePlayer:sendPacket(packet, resp, ignoreReady)
    assert(not packet.__session__)
    if not self.entityPlayerMP or not packet.pid then
        return
    end
    if resp then
        assert(type(resp) == "function")
        local session = #Session + 1
        Session[session] = resp
        packet.__session__ = session
    end
    PacketSender:sendPidPacket(self.rakssid, packet, ignoreReady)
end

---@param packet PidPacket
function SBasePlayer:broadCastPacket(packet, ignoreReady)
    if not self.entityPlayerMP or not packet.pid then
        return
    end
    PacketSender:broadCastPidPacket(packet, ignoreReady)
end

---@param packet PidPacket
function SBasePlayer:sendTrackingPacket(packet, ignoreReady)
    if not self.entityPlayerMP or not packet.pid then
        return
    end
    PacketSender:sendPidPacketToTracking(self:getEntityId(), packet, ignoreReady)
end

---@private
---@param player SBasePlayer
---@param packet PidPacket
function PacketHandlers.__on_pid_packet_handler__(player, packet)
    local func = PacketHandlers[packet.pid]
    if not func then
        LogUtil.logWarning("[PacketHandlers] can not find func, pid=" .. packet.pid)
        return
    end
    local ret = func(player, packet)
    if packet.__session__ ~= nil then
        player:sendPacket({
            pid = "resp",
            session = packet.__session__,
            ret = ret
        })
    end
end

CommonDataEvents:registerCallBack("pid", function(userId, packet)
    if not packet then
        LogUtil.logError("[PacketHandlers] packet = nil.", "userId = " .. userId)
        PacketChecker:addErrorTimes(userId)
        return
    end
    if not packet.pid then
        LogUtil.logError("[PacketHandlers] can not find pid.", "userId = " .. userId, StringUtil.v2s(packet))
        PacketChecker:addErrorTimes(userId)
        return
    end
    packet.pid = HashId2Name[packet.pid] or packet.pid
    local player = PlayerManager:getPlayerByUserId(userId)
    if not player or (player.isKickOut) then
        LogUtil.logWarning("[PacketHandlers] can not find player or player.isKickOut, pid=" .. packet.pid)
        return
    end
    PacketHandlers.__on_pid_packet_handler__(player, packet)
end, SerializeBuilderProcessor)

function PacketHandlers:resp(packet)
    Session[packet.session](packet.ret)
    Session[packet.session] = nil
end

---@param player SBasePlayer
function PacketHandlers.GMOpenInputBack(player, packet)
    if player.GMCallBack then
        player.GMCallBack(unpack(packet.params))
        player.GMCallBack = nil
    end
end

---@param self SBasePlayer
function PacketHandlers.PerformanceReport(self, packet)
    self.performance = { fps = packet.fps, netPing = packet.netPing, logicPing = packet.logicPing }
end

---@param self SBasePlayer
function PacketHandlers.onWatchAdSuccess(self, packet)
    if isTest then
        CEvents.WatchAdvertFinishedEvent:invoke(self.rakssid, packet.type, packet.params, 1)
    end
end

function PacketHandlers:SyncBlockmanSkins(packet)
    if not isLocalWin then
        return
    end
    for _, skin in pairs(packet.skins) do
        if type(skin.master) == "string" then
            if not skin.unload then
                self:changeClothes(skin.master, tonumber(skin.slave))
            else
                self:changeClothes(skin.master, 0)
            end
        end
    end
end

return PacketHandlers
--[[nkZ3EjUC3vivempvsp3AI6]]