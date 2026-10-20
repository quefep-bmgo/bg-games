--[[lqbBklXQnfB]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 3394
                          local checkFileName = "GUICustomSummaryItem.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[a]]---@class GUICustomSummaryItemWindow : IGUIWindow
local GUICustomSummaryItemWindow = class("GUICustomSummaryItemWindow", IGUIWindow)

---@private
function GUICustomSummaryItemWindow:ctor(...)
    self.super.ctor(self, "CustomSummaryItem.json", ...)
end

---@private
function GUICustomSummaryItemWindow:onLoad()
    self.siRankBg = self:getChildWindowByName("CustomSummaryItem-RankBg", GUIType.StaticImage)
    self.siRank = self:getChildWindowByName("CustomSummaryItem-Rank", GUIType.StaticImage)
    self.stName = self:getChildWindowByName("CustomSummaryItem-Name", GUIType.StaticText)
    self.siLine = self:getChildWindowByName("CustomSummaryItem-Line", GUIType.StaticImage)
    self.DoubleRank = self:getChildWindowByName("CustomSummaryItem-DoubleRank", GUIType.DefaultWindow)
    self.siDoubleRankTen = self:getChildWindowByName("CustomSummaryItem-DoubleRank-Ten", GUIType.StaticImage)
    self.siDoubleRankOne = self:getChildWindowByName("CustomSummaryItem-DoubleRank-One", GUIType.StaticImage)
    self.siResult = self:getChildWindowByName("CustomSummaryItem-Result", GUIType.StaticImage)
    self.stScore = self:getChildWindowByName("CustomSummaryItem-Score", GUIType.StaticText)
    self.siTeam = self:getChildWindowByName("CustomSummaryItem-Team", GUIType.StaticImage)
    self:initView()
    self:initEvent()
end

---@private
function GUICustomSummaryItemWindow:initView()

end

---@private
function GUICustomSummaryItemWindow:initEvent()

end

---@param data table
function GUICustomSummaryItemWindow:onDataChanged(data)
    local uiSetting = Global.setting.teamUi
    for _, setting in pairs(uiSetting) do
        local maskTeamId = data.teamId % 12
        if maskTeamId == 0 then
            maskTeamId = 12
        end
        if setting.id == maskTeamId then
            self.siTeam:SetImage(setting.icon)
            break
        end
    end
    self.siRank:SetVisible(data.rank < 10)
    self.DoubleRank:SetVisible(data.rank > 9)
    if data.rank < 10 then
        self.siRank:SetImage(Define.RankNum[tostring(data.rank)])
    else
        local one = data.rank % 10
        local ten = data.rank - one
        self.siDoubleRankOne:SetImage(Define.RankNum[tostring(one)])
        self.siDoubleRankTen:SetImage(Define.RankNum[tostring(ten)])
    end
    self.siRankBg:SetImage(Define.RankBg[data.rank] or Define.RankDefaultBg)
    self.stName:SetText(data.name)
    self.stScore:SetText(data.score)
    self.siResult:SetImage(data.isWin and "set:summary.json image:BigWinEN" or "set:summary.json image:BigLoseEN")
end

return GUICustomSummaryItemWindow
--[[teqGfufrALNESvWtqlOoi3jHR6GRPG9oCKwf2GLYNk0qH6mgxLhGxeNnnJM]]