---@class WaitingPlayerTask
local CWaitPlayerTask = class("WaitingPlayerTask", ITask)

function CWaitPlayerTask:onCreate()
    self.isEnoughPlayer = false
    self.enoughPlayerTick = 0
end

function CWaitPlayerTask:start()
    if not self.hasStop then
        SecTimer.startTimer(self.timer)
    else
        self.isEnoughPlayer = false
        self.enoughPlayerTick = 0
        SecTimer.restartTimer(self.timer)
    end
end

function CWaitPlayerTask:onTick(ticks)
    if not GameConfig then
        return
    end
    
    local gameSetting = GameConfig.gameSetting
    local curPlayerCount = PlayerManager:getPlayerCount()

    if curPlayerCount < gameSetting.startPlayers then
        if ticks % 30 == 0 or self.isEnoughPlayer then
            MsgSender.sendMsg(IMessages:msgWaitPlayer())
            MsgSender.sendMsg(IMessages:msgGamePlayerNum(curPlayerCount, gameSetting.startPlayers))
            if self.isEnoughPlayer then
                self.isEnoughPlayer = false
                self.enoughPlayerTick = 0
            end
        end
        return
    else
        if not self.isEnoughPlayer then
            self.enoughPlayerTick = ticks
            self.isEnoughPlayer = true
        end
    end

    local waitTime = gameSetting.waitingPlayerTime - (ticks - self.enoughPlayerTick)
    if waitTime <= 0 then
        self:stop()
        return
    end

    local seconds = waitTime
    if seconds >= 60 and seconds % 60 == 0 then
        MsgSender.sendMsg(IMessages:msgWaitPlayerEnough(seconds / 60, IMessages.UNIT_MINUTE, false))
    elseif seconds >= 10 and seconds % 10 == 0 then
        MsgSender.sendMsg(IMessages:msgWaitPlayerEnough((seconds * 10) / 10, IMessages.UNIT_SECOND, false))
    elseif seconds <= 10 and seconds > 0 then
        MsgSender.sendMsg(IMessages:msgWaitPlayerEnough(seconds, IMessages.UNIT_SECOND, false))
        if seconds <= 3 then
            HostApi.sendPlaySound(0, 12)
        else
            HostApi.sendPlaySound(0, 11)
        end
    end
end

function CWaitPlayerTask:stop()
    self.isEnoughPlayer = false
    self.enoughPlayerTick = 0
    local customGame = T(Global, "customGame")
    SecTimer.stopTimer(self.timer)
    HostApi.setAllowUseItemStatus(0, 1)
    customGame:startMatch()
    self.hasStop = true
end

WaitingPlayerTask = CWaitPlayerTask.new(Define.GameStatus.WaitingPlayer)

return WaitingPlayerTask