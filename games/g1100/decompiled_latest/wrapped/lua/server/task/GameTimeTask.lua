--[[qaDj3pq8CPJE45KdUJLXj6gDgjolV1QmKqLAsbBuuk0i9DetLqNE6hYZXgUnT]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 2350
                          local checkFileName = "GameTimeTask.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[Anxw7B6o5PkUiGsIhWJjZ0fc7tn3GnmlkjbMvjuQudEmdXRrbBxmG9elYjIBiF1Bw0BbH1n5r6ROeFHVg6n7kABHMMvyTBI3aLfjRVi2Wxa9qv3DutrzKZPmFFUZ80kkUyz0MQlrsU0mbu4kz433HTM]]local CGameTimeTask = class("GameTimeTask", ITask)

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
--[[Xh13wZXgOr9WefXXFNobeHbB2G7ZLFof3UqM6W06pprf1pI4Rqj96mxU7nNas9cpvDPcJmMXAo38IJDTqZTIiojpYmYkGcCLq7Jwl7SEwdufeHlPWqqUlLPUyj4npVtnCIgX24U6kvlBsXLW1jmYFvXIbhOkNUXoTjUHAg0fl2MKTj2Ay5ik7S6ZLUt]]