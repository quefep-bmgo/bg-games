--[[2BsR6dDlKSBiSmVmhE4SLwJglvlBBHgW1zHlmf5ZZd]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1673
                          local checkFileName = "ITask.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[OhyejRmjzuB]]--region *.lua
ITask = class() ---@class ITask
ITask.timer = 0
ITask.status = 0
ITask.created = false

function ITask:ctor(status, period)
    self.taskFunc = function(ticks)
        if not self.created then
            self.created = true
            self:onCreate()
        end
        self:onTick(ticks)
    end
    if not period then
        self.timer = SecTimer.createTimer(self.taskFunc)
    else
        self.timer = SecTimer.createTimerWithPeriod(self.taskFunc, period)
    end
    self.status = status
end

function ITask:onCreate()

end

function ITask:onTick(ticks)

end

function ITask:start()
    SecTimer.startTimer(self.timer)
end

function ITask:stop()
    SecTimer.stopTimer(self.timer)
end

function ITask:pureStop()
    SecTimer.stopTimer(self.timer)
end

return ITask
--endregion
--[[nkHrhU0d1crfRP2BTmiJT3e5J1D8oQ3x3yJoYovw9Ju6hvqkN6NzaCVD0JJdc1hmy3YaYMCHvYkIg4oGKvm]]---