--[[xadgHQEV62qyWvVG44e2De7]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 3558
                          local checkFileName = "GUIRankItem.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[JuCMb]]---@class GUIRankItemWindow : IGUIWindow
local GUIRankItemWindow = class("GUIRankItemWindow", IGUIWindow)

---@private
function GUIRankItemWindow:ctor(...)
    self.super.ctor(self, "RankItem.json", ...)
end

---@private
function GUIRankItemWindow:onLoad()
    self.stRank = self:getChildWindowByName("RankItem-Rank", GUIType.StaticText)
    self.stRankMe = self:getChildWindowByName("RankItem-Rank-Me", GUIType.StaticText)
    self.siTeamIcon = self:getChildWindowByName("RankItem-Team-Icon", GUIType.StaticImage)
    self.stTeamPX = self:getChildWindowByName("RankItem-Team-PX", GUIType.StaticText)
    self.stPlayerNum = self:getChildWindowByName("RankItem-PlayerNum", GUIType.StaticText)
    self.stScore = self:getChildWindowByName("RankItem-Score", GUIType.StaticText)
    self.siState = self:getChildWindowByName("RankItem-State", GUIType.StaticImage)
    self:initView()
    self:initEvent()
end

---@private
function GUIRankItemWindow:initView()
    self.stRank:SetText()
    self.stRankMe:SetText(Lang:getString("gui.text.me"))
    self.stRankMe:SetVisible(false)
    self.siTeamIcon:SetVisible(false)
    self.stTeamPX:SetText()
    self.stPlayerNum:SetText()
    self.stScore:SetText()
    self.siState:SetVisible(false)
end

---@private
function GUIRankItemWindow:initEvent()
end

---@param data table
function GUIRankItemWindow:onDataChanged(data)
    local teamId = 0
    local player = PlayerManager:getClientPlayer()
    if player then
        teamId = player.teamId
    end
    
    self.stRank:SetText(data.rank)
    self.stRankMe:SetVisible(data.id == teamId)

    if data.isTeamMatch then
        local maskId = data.id % 12
        if maskId == 0 then
            maskId = 12
        end
        local setting = Global.setting.teamUi[maskId]
        self.siTeamIcon:SetVisible(true)
        self.siTeamIcon:SetImage(setting.icon)
        self.stTeamPX:SetText("")
    else
        self.siTeamIcon:SetVisible(false)
        self.stTeamPX:SetText("P"..tostring(data.id))
    end
    
    self.stPlayerNum:SetText(data.num)

    if data.conditionType == Define.OverCondition.Marker or data.conditionType == Define.OverCondition.MarkerAndKill then
        self.stScore:SetText("")
        data.markerState = data.markerState or Define.MarkerState.Destroyed
        if data.markerState == Define.MarkerState.None then
            data.markerState = Define.MarkerState.Destroyed
        end
        local icon = Define.MarkerStateUIIcon[data.markerState]
        if icon and string.len(icon) > 0 then
            self.siState:SetVisible(true)
            self.siState:SetImage(icon)
        end
    else
        self.stScore:SetText(data.score)
        self.siState:SetVisible(false)
    end

end

return GUIRankItemWindow
--[[PiFXnV2PXoNKfarMSfBoqqu4TQgkag5eoPK49sN3kRHe6aawh]]