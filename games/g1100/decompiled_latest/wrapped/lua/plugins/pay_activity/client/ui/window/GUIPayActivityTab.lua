--[[SbfLUWWBZ4XZBLNBS28mxZ3UdWb6q9igNm4ZWkZbyi53ghpqQrTA1I3A0tQJFzOEJT1JFaBjy3d4U]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 2562
                          local checkFileName = "GUIPayActivityTab.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[zJAkKZTIkGp8muN4hPApAkMl4GgFuLPiGhTaCp5nx6lRPlXKADyDESuanJFwaDUXzovdeDeJUZmEvNPUtrj4Z25crZxve8Xv8pinbmLPAPVLuE]]---@class GUIPayActivityTabWindow : IGUIWindow
local GUIPayActivityTabWindow = class("GUIPayActivityTabWindow", IGUIWindow)

---@private
function GUIPayActivityTabWindow:ctor(...)
    self.super.ctor(self, "PayActivityTab.json", ...)
end

---@private
function GUIPayActivityTabWindow:onLoad()
    self.llRoot = DynamicCast.dynamicCastWindow(GUIType.Layout, self.root)
    self.stName = self:getChildWindowByName("PayActivityTab-Name", GUIType.StaticText)
    self.llSelected = self:getChildWindowByName("PayActivityTab-Selected", GUIType.Layout)
    self:initView()
    self:initEvent()
end

---@private
function GUIPayActivityTabWindow:initView()
    ---@type UIPayActivityLayout
    self.parent = UIHelper.newGameGUILayout("GUIPayActivity")
end

---@private
function GUIPayActivityTabWindow:initEvent()
    self.llRoot:registerEvent(GUIEvent.Click, function()
        SoundUtil.clickUI()
        self.parent:setCurSelectActivity(self.activity)
    end)
end

---@param activity IPayActivity
function GUIPayActivityTabWindow:onDataChanged(activity)
    if self.activity ~= activity then
        local key = "pay_activity:" .. activity.cfg.id
        Plugins.CallTargetPluginFunc("red_dot", "redDotBuild", self.llRoot, key, nil, {
            customImage = "set:limited_time_activity.json image:img_0_red_dot",
            offset = { x = -2, y = -6 }
        })
    end
    self.activity = activity
    self.stName:SetText(Lang:getString(activity.cfg.tabName))
    self.llRoot:SetBackImage(activity.cfg.tabImage)
    self.llSelected:SetVisible(activity == self.parent.curSelectActivity)
end

return GUIPayActivityTabWindow
--[[i9jsK]]