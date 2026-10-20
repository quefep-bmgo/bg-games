--[[ZX]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 3604
                          local checkFileName = "GUISelectTeam.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[XoD4BExDhRfsMc52Hm9dUTv]]---@class UISelectTeamLayout : IGUILayout
local UISelectTeamLayout = class("UISelectTeamLayout", IGUILayout)

local Color = require "engine_base.math.color"

---@private
function UISelectTeamLayout:ctor()
    self.super.ctor(self, "SelectTeam.json", GUIManager:getMainControl())
end

---@private
function UISelectTeamLayout:isDelayLoad()
    return true
end

---@private
function UISelectTeamLayout:onCreate()
    self:initCreateEvent()
end

---@private
function UISelectTeamLayout:initCreateEvent()

end

---@private
function UISelectTeamLayout:onLoad()
    self.siMaskTop = self:getChildWindow("SelectTeam-Mask-Top", GUIType.StaticImage)
    self.siMaskBottom = self:getChildWindow("SelectTeam-Mask-Bottom", GUIType.StaticImage)
    self.siMaskLeft = self:getChildWindow("SelectTeam-Mask-Left", GUIType.StaticImage)
    self.siMaskRight = self:getChildWindow("SelectTeam-Mask-Right", GUIType.StaticImage)
    self.btnCancel = self:getChildWindow("SelectTeam-Cancel", GUIType.Button)
    self.stTitle = self:getChildWindow("SelectTeam-Title", GUIType.StaticText)
    self.siFrame = self:getChildWindow("SelectTeam-Frame", GUIType.StaticImage)
    self:initView()
    self:initEvent()
end

---@private
function UISelectTeamLayout:initView()

end

---@private
function UISelectTeamLayout:initEvent()
    self.btnCancel:registerEvent(GUIEvent.ButtonClick, function()
        local result = {
            teamId = self.teamId,
            birthPoint = nil,
            msg = Lang:getString("custom_room_ugc_flag_or_marker_cancel"),
            code = 2
        }
        if self.type == Define.SelectTeam.Marker then
            ClientHelper.onAppActionTrigger(Define.GameToAppEvent.GAME_ACTION_CUSTOM_ROOM_SET_TEAM_MARKER, json.encode(result))
        else
            ClientHelper.onAppActionTrigger(Define.GameToAppEvent.GAME_ACTION_CUSTOM_ROOM_SET_TEAM_POS, json.encode(result))
        end
        self:hide()
        SoundUtil.clickUI()
    end)
end

function UISelectTeamLayout:onShow(type, teamId)
    self.type = type
    self.teamId = teamId
    local langKey = "gui.select.team.pos"
    if self.type == Define.SelectTeam.Marker then
        langKey = "gui.select.team.marker"
    end
    self.stTitle:SetText(Lang:format(langKey, teamId))
    self.stTitle:SetTextColor(Color.hex2color(Define.TeamFlagColor[teamId]));
    GUIManager:hideWindowByName("ToolBar.json")
    self.isFlying = PlayerManager:getClientPlayer().Player:getIsFlying()
end

function UISelectTeamLayout:onHide()
    GUIManager:showWindowByName("ToolBar.json")
    PlayerManager:getClientPlayer().Player:setFlying(self.isFlying)
    PlayerManager:getClientPlayer():sendPacket({
        pid = "selectTeamStatus",
        data = {teamId = 0, type = self.type},
    })
end

return UISelectTeamLayout
--[[mg87u2mwEP0EmicXqyjROQu7NVeTMazUI94qwiPdYhHuoXKbFMx3mQzcFpDXuF7]]