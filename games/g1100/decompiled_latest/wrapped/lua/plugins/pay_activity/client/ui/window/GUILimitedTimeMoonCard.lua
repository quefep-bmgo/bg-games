--[[V2ISDbbV5nNDaPihTWIZAYQvn6kDb2hDf8dQ2]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 3987
                          local checkFileName = "GUILimitedTimeMoonCard.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[EJKAhFLvVx74CoCt6t56TiWgto]]---@class GUILimitedTimeMoonCardWindow : IGUIWindow
local GUILimitedTimeMoonCardWindow = class("GUILimitedTimeMoonCardWindow", IGUIWindow)

---@type LimitedTimeMoonCardConfig
local LimitedTimeMoonCardConfig = T(Global, "LimitedTimeMoonCardConfig")

---@type ReportEvent
local ReportEvent = T(Global, "ReportEvent")

---@private
function GUILimitedTimeMoonCardWindow:ctor(...)
	self.super.ctor(self, "LimitedTimeMoonCard.json", ...)
end

---@private
function GUILimitedTimeMoonCardWindow:onLoad()
	self.btnHelp = self:getChildWindowByName("LimitedTimeMoonCard-help", GUIType.Button)
	self.stTitle = self:getChildWindowByName("LimitedTimeMoonCard-title", GUIType.StaticText)
	self.llShowTime = self:getChildWindowByName("LimitedTimeMoonCard-show_time", GUIType.Layout)
	self.siTimeIcon = self:getChildWindowByName("LimitedTimeMoonCard-time_icon", GUIType.StaticImage)
	self.llCardPanelSingle = self:getChildWindowByName("LimitedTimeMoonCard-card_panel_single", GUIType.Layout)
	self.llCardPanelList = self:getChildWindowByName("LimitedTimeMoonCard-card_panel_list", GUIType.Layout)
	self:initView()
	self:initEvent()
end

---@private
function GUILimitedTimeMoonCardWindow:initView()
	self.stTitle:SetText(Lang:getString("gui.limit.time.activity.moon.card.title"))
end

---@private
function GUILimitedTimeMoonCardWindow:initEvent()
	self.btnHelp:registerEvent(GUIEvent.ButtonClick, function()
		local params={}
		params.type=PayActivityDefine.LIMITED_TIME_ACTIVITY_COMMON_DIALOG_TYPE.TEXT
		params.dec="gui.limit.time.activity.moon.card.help"
		params.title="gui.limit.time.activity.help"
		UIHelper.showGameGUILayout("GUILimitedTimeActivityCommonDialog",params)
	end)
end

function GUILimitedTimeMoonCardWindow:onShow()
	ReportEvent.reportEvent(Game:getPlatformUserId(), "monthly_card_click")
end

---@param activity LimitedTimeMoonCard
function GUILimitedTimeMoonCardWindow:onDataChanged(activity)
	self.activity = activity
	self:initCardInf()
	if activity then
		activity:updateRedDot(false)
	end
end

function GUILimitedTimeMoonCardWindow:initCardInf()
	if not self.activity then
		return
	end
	local cardList=LimitedTimeMoonCardConfig:getCfgByActivityId(self.activity.activityId)
	self.llCardPanelSingle:SetVisible(#cardList==1)
	self.llCardPanelList:SetVisible(#cardList~=1)
	if #cardList==1 then
		local item = UIHelper.newGameGUIWindow("GUILimitedTimeMoonCardItem")
		item:onDataChanged(cardList[1])
		--item:setArea({ 0, (pos[2] - 1) * 109 }, { 0, (pos[1] - 1) * 110 }, { 0, 109 }, { 0, 110 })
		self.llCardPanelSingle:AddChildWindow(item.root)
	else
		if not self.moonCardAdapter then
			self.moonCardList = IGUIListView.new("LimitedTimeMoonCard-CardListItems", self.llCardPanelList, nil, Orientation.Horizontal)
			self.moonCardList:setItemSpace(140)
			---@type LimitedTimeSignalAdapter
			self.moonCardAdapter = UIHelper.newGameAdapter("LimitedTimeMoonCardAdapter")
			self.moonCardList:setAdapter(self.moonCardAdapter)
		end
		local temp=TableUtil.copyTable(cardList)
		table.sort(temp,function (a,b)
			return a.order<b.order
		end)
		self.moonCardAdapter:setData(temp)
	end
end



return GUILimitedTimeMoonCardWindow
--[[KAAUlhGr9aqzOQKVRJiHkBRMZPDuItvsCY35bVTJZ]]---