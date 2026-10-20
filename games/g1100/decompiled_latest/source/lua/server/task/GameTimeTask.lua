local CGameTimeTask = class("GameTimeTask", ITask)

-- self.hasStop
-- self.curTicks
-- self.gameTicks

function CGameTimeTask:onTick(ticks)
    if not GameConfig then
        return
    end
    self.curTicks = ticks
    self:onGameTick(ticks)
    if ticks >= self.gameTicks then
        self:stop()
        return
    end
end

function CGameTimeTask:start()
    if not self.hasStop then
        SecTimer.startTimer(self.timer)
    else
        SecTimer.restartTimer(self.timer)
    end
    self.hasStop = nil
    self.curTicks = 0
    self.gameTicks = GameConfig.gameSetting.gameTime * 60
end

function CGameTimeTask:onGameTick(ticks)
    local customGame = T(Global, "customGame")
    customGame:onTick(ticks)
    Plugins.CallTargetPluginFunc("resources", "onTick", ticks)
end

function CGameTimeTask:stop()
    if self.hasStop then
        return
    end
    local customGame = T(Global, "customGame")
    SecTimer.stopTimer(self.timer)
    customGame:endMatch()
    self.hasStop = true
end

function CGameTimeTask:onCreate()
end

function CGameTimeTask:getRemainingTime()
    return self.gameTicks - self.curTicks
end

GameTimeTask = CGameTimeTask.new(Define.GameStatus.GameRunning)

return GameTimeTask
