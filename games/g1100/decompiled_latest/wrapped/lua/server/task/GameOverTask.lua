--[[O3bJSklb9s0DwCoKThfEsvZnhW7EYMWunwmavOftqFNguVOQhpGqBpkApwYVp24W0PQEUdxgim1r7Lp]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1758
                          local checkFileName = "GameOverTask.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[Bt5fvdKVtcYtNyKxIKGZccOa2ONkhcrDVXrKYsOiUGp]]---@class GameOverTask
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
--[[yCHuc8XKUyA3HIZK22Ae9bSJhHHAVy12hmJIpfPjjlczgRPpPcNaPNELuOGoHBrIJ5KlWVTFxGYrnTiQvQiEIHQiWhEimOLxkzBXkicui6L77PeU6B5HOefKIOLB3prBD63OeTlgTNYKRVUmOYg3ussvIMUa0RbDa4TY1inUzpWcyZrg0leVJQHO7ycweZP]]