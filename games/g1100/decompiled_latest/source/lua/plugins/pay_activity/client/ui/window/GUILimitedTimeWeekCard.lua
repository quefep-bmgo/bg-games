---@class GUILimitedTimeWeekCardWindow : IGUIWindow
local GUILimitedTimeWeekCardWindow = class("GUILimitedTimeWeekCardWindow", IGUIWindow)

---@type LimitedTimeMoonCardConfig
local LimitedTimeMoonCardConfig = T(Global, "LimitedTimeMoonCardConfig")

---@type ReportEvent
local ReportEvent = T(Global, "ReportEvent")

---@private
function GUILimitedTimeWeekCardWindow:ctor(...)
	self.super.ctor(self, "LimitedTimeWeekCard.json", ...)
end

---@private
function GUILimitedTimeWeekCardWindow:onLoad()
	self.btnHelp = self:getChildWindowByName("LimitedTimeWeeknCard-help", GUIType.Button)
	self.stTitle = self:getChildWindowByName("LimitedTimeWeeknCard-title", GUIType.StaticText)
	self.llCardPanelSingle = self:getChildWindowByName("LimitedTimeWeeknCard-card_panel_single", GUIType.Layout)
	self.llCardPanelList = self:getChildWindowByName("LimitedTimeWeeknCard-card_panel_list", GUIType.Layout)
	self:initView()
	self:initEvent()
end

---@private
function GUILimitedTimeWeekCardWindow:initView()
	self.stTitle:SetText(Lang:getString("gui.limit.time.activity.moon.card.title2"))
end

---@private
function GUILimitedTimeWeekCardWindow:initEvent()
	self.btnHelp:registerEvent(GUIEvent.ButtonClick, function()
		local params={}
		params.type=PayActivityDefine.LIMITED_TIME_ACTIVITY_COMMON_DIALOG_TYPE.TEXT
		params.dec="gui.limit.time.activity.moon.card.help"
		params.title="gui.limit.time.activity.help"
		UIHelper.showGameGUILayout("GUILimitedTimeActivityCommonDialog",params)
	end)
end

function GUILimitedTimeWeekCardWindow:onShow()
	ReportEvent.reportEvent(Game:getPlatformUserId(), "monthly_card_click")
end

---@param data table
function GUILimitedTimeWeekCardWindow:onDataChanged(activity)
	self.activity = activity
	self:initCardInf()
	if activity then
		activity:updateRedDot(false)
	end
end

function GUILimitedTimeWeekCardWindow:initCardInf()
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
			self.moonCardList = IGUIListView.new("LimitedTimeWeekCard-CardListItems", self.llCardPanelList, nil, Orientation.Horizontal)
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

return GUILimitedTimeWeekCardWindow
