---@class GameOverTask
local CGameOverTask = class("GameOverTask", ITask)

function CGameOverTask:onTick(ticks)
    if not GameConfig then
        return
    end
    if (ticks >= 10) then
        self:stop()
        return
    end
end

function CGameOverTask:start()
    if not self.hasStop then
        SecTimer.startTimer(self.timer)
    else
        SecTimer.restartTimer(self.timer)
    end
end

function CGameOverTask:stop()
    MsgSender.sendMsg(IMessages:msgGameResetHint())
    SecTimer.stopTimer(self.timer)
    local customGame = T(Global, "customGame")
    customGame:resetGame()
    self.hasStop = true
end

GameOverTask = CGameOverTask.new(Define.GameStatus.GameOver)

return GameOverTask
