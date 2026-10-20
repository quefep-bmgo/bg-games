--[[t3DQiN]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 3716
                          local checkFileName = "GUIFaceSlapQueue.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[6IxETdxZaJbKlx1FU7ndz93se762hw7lWmws9Rlq1UKUI1FTv1xtJ544F0zSAAxMpJxtJJgSrDWsGTy7VvVjxVBnCusXZWTgyprms16oV0Su2bAxc7F9wmDhFM]]---@class UIFaceSlapQueueLayout : IGUILayout
local UIFaceSlapQueueLayout = class("UIFaceSlapQueueLayout", IGUILayout)

---@private
function UIFaceSlapQueueLayout:ctor(parent)
    self.super.ctor(self, "PayActivityFaceSlapQueue.json", parent)
end

---@private
function UIFaceSlapQueueLayout:isDelayLoad()
    return true
end

---@private
function UIFaceSlapQueueLayout:onCreate()
    self.queue = {}
    self:initCreateEvent()
end

---@private
function UIFaceSlapQueueLayout:initCreateEvent()

end

---@private
function UIFaceSlapQueueLayout:isShowAnim()
    return false
end

---@private
function UIFaceSlapQueueLayout:onLoad()
    self.root:SetLevel(1)
    self.llImage = self:getChildWindow("FaceSlapQueue-Image", GUIType.Layout)
    self.stTitle = self:getChildWindow("FaceSlapQueue-Title", GUIType.StaticText)
    self.btnClose = self:getChildWindow("FaceSlapQueue-Close", GUIType.Button)
    self:initView()
    self:initEvent()
end

---@private
function UIFaceSlapQueueLayout:initView()

end

---@private
function UIFaceSlapQueueLayout:initEvent()
    self.btnClose:registerEvent(GUIEvent.ButtonClick, function()
        self:next()
        SoundUtil.clickUI()
    end)
    self.llImage:registerEvent(GUIEvent.Click, function()
        self:onGoActivity()
        SoundUtil.clickUI()
    end)
end

---@param activity IActivity
---@param params string[]
function UIFaceSlapQueueLayout:show(activity, params)
    if activity then
        table.insert(self.queue, {
            activity = activity,
            params = params,
        })
    end
    if UIHelper.isGameGUILayoutShow("GUIPayActivity") then
        return
    end
    if next(self.queue) then
        self.super.show(self)
    end
end

function UIFaceSlapQueueLayout:onGoActivity()
    if not self.activity then
        self:hide()
        return
    end
    if not next(self.gameType) or TableUtil.tableContain(self.gameType, GameType) then
        if self.openUI and self.openUI ~= "#" then
            UIHelper.showGameGUILayout(table.unpack(StringUtil.split(self.openUI, "#")))
        else
            UIHelper.showGameGUILayout("GUIPayActivity", self.activity)
        end
    end
    self:hide()
end

function UIFaceSlapQueueLayout:next()
    self:onShow()
end

function UIFaceSlapQueueLayout:onShow()
    if #self.queue == 0 then
        self:hide()
        return
    end
    ---@type ActivityLoginUIData
    local item = table.remove(self.queue, 1)
    ---@type IActivity
    self.activity = item.activity
    self.openUI = item.params[2]
    self.gameType = StringUtil.split(item.params[3], "#")
    self.llImage:SetBackImage(item.params[1])
    if self.activity.cfg.tabName == "#" then
        self.stTitle:SetText("")
    else
        self.stTitle:SetText(Lang:getString(self.activity.cfg.tabName))
    end
end

return UIFaceSlapQueueLayout
--[[bDQJVbmonMX7ACq9fkc]]