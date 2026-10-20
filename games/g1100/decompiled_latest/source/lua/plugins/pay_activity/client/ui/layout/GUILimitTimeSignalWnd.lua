
---@class UILimitTimeSignalWndLayout : IGUILayout
local UILimitTimeSignalWndLayout = class("UILimitTimeSignalWndLayout", IGUILayout)

---@type LimitedTimeGiftSignalConfig
local LimitedTimeGiftSignalConfig = T(Global, "LimitedTimeGiftSignalConfig")

---@private
function UILimitTimeSignalWndLayout:ctor(parent)
	self.super.ctor(self, "LimitTimeSignalWnd.json", parent)
end

---@private
function UILimitTimeSignalWndLayout:isDelayLoad()
	return true
end

---@private
function UILimitTimeSignalWndLayout:onCreate()
	self:initCreateEvent()
end

---@private
function UILimitTimeSignalWndLayout:initCreateEvent()

end

---@private
function UILimitTimeSignalWndLayout:onLoad()
	self.llBackBg = self:getChildWindow("LimitTimeSignalWnd-BackBg", GUIType.Layout)
	self.llContentPanel = self:getChildWindow("LimitTimeSignalWnd-ContentPanel", GUIType.Layout)
	self.stTitleText = self:getChildWindow("LimitTimeSignalWnd-TitleText", GUIType.StaticText)
	self.siRemainBg = self:getChildWindow("LimitTimeSignalWnd-remainBg", GUIType.StaticImage)
	self.siRemainIcon = self:getChildWindow("LimitTimeSignalWnd-RemainIcon", GUIType.StaticImage)
	self.stRemainText = self:getChildWindow("LimitTimeSignalWnd-remainText", GUIType.StaticText)
	self.llItemPanel = self:getChildWindow("LimitTimeSignalWnd-ItemPanel", GUIType.Layout)
	self.btnCloseBtn = self:getChildWindow("LimitTimeSignalWnd-CloseBtn", GUIType.Button)
	self.llMaskPanel = self:getChildWindow("LimitTimeSignalWnd-MaskPanel", GUIType.Layout)
	self:initView()
	self:initEvent()
end

---@private
function UILimitTimeSignalWndLayout:initView()
	self.stTitleText:SetText(Lang:getString(Lang:getString("gui.limit.time.combined.title")))
	self.stRemainText:SetText(Lang:getString(""))
end

---@private
function UILimitTimeSignalWndLayout:initEvent()
	self.btnCloseBtn:registerEvent(GUIEvent.ButtonClick, function()
		self:hide()
	end)
end

---@param activity LimitedTimeGiftSignal
function UILimitTimeSignalWndLayout:onShow(activity)
	local lastActivity=self.activity
	self.activity=activity
	if not activity then
		return
	end

	self.needResetData=lastActivity and lastActivity.activityId~=activity.activityId
	self:updateGiftList()

	self.curTime = os.time()
	self.endTime = activity.cfg.endDate
	self:updateActivityTimeShow()
	self:startDownTimer()
	self:checkHasItem()
	self.siRemainBg:SetVisible(activity.cfg.hideTimeUI~=1)
end

function UILimitTimeSignalWndLayout:checkHasItem()
	if not self.activity then
		return
	end
	local giftBagList=LimitedTimeGiftSignalConfig:getCfgByActivityId(self.activity.cfg.id)
	if not giftBagList then
		return
	end

	local rewardIdList={}
	for _, giftBag in pairs(giftBagList) do
		if giftBag.giftContent  and next(giftBag.giftContent)~=nil then
			for i, v in pairs(giftBag.giftContent) do
				table.insert(rewardIdList,v)
			end
		end
	end

	--LogUtil.pv(rewardIdList)
	self.activity:requestCheckPlayerHasRewardItem(rewardIdList,function (ret)
		--LogUtil.pv(ret)
		self:updateGiftList()
	end)
end

function UILimitTimeSignalWndLayout:onHide()
	self:stopDownTimer()
end

function UILimitTimeSignalWndLayout:updateGiftList()
	if not self.activity then
		return
	end
	local itemsInActivity=LimitedTimeGiftSignalConfig:getCfgByActivityId(self.activity.cfg.id)
	if not itemsInActivity then
		return
	end

	if not self.giftAdapter then
		self.giftList = IGUIListView.new("LimitedTimeSignal-GiftListItems", self.llItemPanel, nil, Orientation.Horizontal)
		self.giftList:setItemSpace(16)
		---@type LimitedTimeSignalAdapter
		self.giftAdapter = UIHelper.newGameAdapter("LimitedTimeSignalAdapter")
		self.giftList:setAdapter(self.giftAdapter)
		local temp=TableUtil.copyTable(itemsInActivity)
		--print("-----------------UILimitTimeSignalWndLayout:updateGiftList:")
		--LogUtil.pv(temp)
		table.sort(temp,function (a,b)
			return a.order<b.order
		end)
		self.giftAdapter:setData(temp)
	elseif self.needResetData then
		local temp=TableUtil.copyTable(itemsInActivity)
		table.sort(temp,function (a,b)
			return a.order<b.order
		end)
		self.giftAdapter:setData(temp)
	end
end

local function timeFormatting(second)
	assert(tonumber(second), second)
	local timeHour = math.fmod(math.floor(second/3600), 24)
	local timeMinute = math.fmod(math.floor(second/60), 60)
	local timeSecond = math.fmod(second, 60)
	return timeHour, timeMinute, timeSecond
end

function UILimitTimeSignalWndLayout:updateActivityTimeShow()
	local remainTime = self.endTime - self.curTime
	if remainTime < 0 then
		--self:hide()
		return
	end

	local text = string.format("%02d:%02d:%02d",timeFormatting(remainTime))
	if remainTime > (3600*24) then
		local day = math.floor(remainTime/3600/24) or 0
		text = day .. "d " .. text
	end
	self.stRemainText:SetText(text)
end

function UILimitTimeSignalWndLayout:startDownTimer()
	self:stopDownTimer()
	self.downTimerKey=LuaTimer:scheduleTimer(function()
		self.curTime = self.curTime + 1
		self:updateActivityTimeShow()
	end, 1000)
end

function UILimitTimeSignalWndLayout:stopDownTimer()
	if self.downTimerKey then
		LuaTimer:cancel(self.downTimerKey)
		self.downTimerKey = nil
	end
end

return UILimitTimeSignalWndLayout
