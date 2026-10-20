---@class GUILimitedTimeDrawWindow : IGUIWindow
local GUILimitedTimeDrawWindow = class("GUILimitedTimeDrawWindow", IGUIWindow)

---@type LimitedTimeDrawConfig
local LimitedTimeDrawConfig = T(Global, "LimitedTimeDrawConfig")
---@type LimitedTimeDrawAwardsConfig
local LimitedTimeDrawAwardsConfig = T(Global, "LimitedTimeDrawAwardsConfig")
---@type PayActivityRewardConfig
local PayActivityRewardConfig = T(Global, "PayActivityRewardConfig")

---@type ReportEvent
local ReportEvent = T(Global, "ReportEvent")

---@private
function GUILimitedTimeDrawWindow:ctor(...)
	self.super.ctor(self, "LimitedTimeDraw.json", ...)
end

---@private
function GUILimitedTimeDrawWindow:onLoad()
	self.siIcon = self:getChildWindowByName("LimitedTimeDraw-icon", GUIType.StaticImage)
	self.awActor = self:getChildWindowByName("LimitedTimeDraw-actor", GUIType.ActorWindow)
	self.awActor2 = self:getChildWindowByName("LimitedTimeDraw-actor2", GUIType.ActorWindow)
	self.btnHelp = self:getChildWindowByName("LimitedTimeDraw-help", GUIType.Button)
	self.stTitle = self:getChildWindowByName("LimitedTimeDraw-title", GUIType.StaticText)
	self.stTip = self:getChildWindowByName("LimitedTimeDraw-tip", GUIType.StaticText)
	self.btnPreview = self:getChildWindowByName("LimitedTimeDraw-preview", GUIType.Button)
	self.stPreviewText = self:getChildWindowByName("LimitedTimeDraw-previewText", GUIType.StaticText)
	self.siSinglePriceBg = self:getChildWindowByName("LimitedTimeDraw-single_price_bg", GUIType.StaticImage)
	self.siSinglePriceIcon = self:getChildWindowByName("LimitedTimeDraw-single_price_icon", GUIType.StaticImage)
	self.stSinglePriceNum = self:getChildWindowByName("LimitedTimeDraw-single_price_num", GUIType.StaticText)
	self.btnSingle = self:getChildWindowByName("LimitedTimeDraw-single", GUIType.Button)
	self.stSingleText = self:getChildWindowByName("LimitedTimeDraw-single_text", GUIType.StaticText)
	self.siTenPriceBg = self:getChildWindowByName("LimitedTimeDraw-ten_price_bg", GUIType.StaticImage)
	self.siTenPriceIcon = self:getChildWindowByName("LimitedTimeDraw-ten_price_icon", GUIType.StaticImage)
	self.stTenPriceNum = self:getChildWindowByName("LimitedTimeDraw-ten_price_num", GUIType.StaticText)
	self.stOff = self:getChildWindowByName("LimitedTimeDraw-off", GUIType.StaticText)
	self.btnTen = self:getChildWindowByName("LimitedTimeDraw-ten", GUIType.Button)
	self.stTenText = self:getChildWindowByName("LimitedTimeDraw-ten_text", GUIType.StaticText)
	self.pbGuarantee = self:getChildWindowByName("LimitedTimeDraw-guarantee", GUIType.ProgressBar)
	self.siBigPrize = self:getChildWindowByName("LimitedTimeDraw-bigPrize", GUIType.StaticImage)
	self.siBigPrizeIcon = self:getChildWindowByName("LimitedTimeDraw-bigPrizeIcon", GUIType.StaticImage)
	self.stGuaranteeProgress = self:getChildWindowByName("LimitedTimeDraw-guaranteeProgress", GUIType.StaticText)
	self.llActor_slide = self:getChildWindowByName("LimitedTimeDraw-actor_slide", GUIType.Layout)
	self.stTimeText = self:getChildWindowByName("LimitedTimeDraw-time_text", GUIType.StaticText)
	self:initView()
	self:initEvent()
end

---@private
function GUILimitedTimeDrawWindow:initView()
	self.stTitle:SetText(Lang:getString("gui.limit.time.activity.draw.title"))
	self.stTip:SetText()
	self.stPreviewText:SetText(Lang:getString("gui.limit.time.activity.draw.preview"))
	self.stSinglePriceNum:SetText()
	self.stSingleText:SetText(Lang:getString("gui.limit.time.activity.draw.single"))
	self.stTenPriceNum:SetText()
	--self.stOff:SetText("10% off")
	self.stOff:SetText()
	self.stTenText:SetText(Lang:getString("gui.limit.time.activity.draw.ten"))
	self.stGuaranteeProgress:SetText()
	self.stTimeText:SetText()
	self.actorInitWidth = self.awActor2:GetPixelSize().x
end

---@private
function GUILimitedTimeDrawWindow:initEvent()
	self.btnHelp:registerEvent(GUIEvent.ButtonClick, function()
		local params={}
		params.type=PayActivityDefine.LIMITED_TIME_ACTIVITY_COMMON_DIALOG_TYPE.TEXT
		params.dec="gui.limit.time.activity.draw.help"
		params.title="gui.limit.time.activity.help"
		UIHelper.showGameGUILayout("GUILimitedTimeActivityCommonDialog",params)
	end)
	self.btnPreview:registerEvent(GUIEvent.ButtonClick, function()
		if not self.activity or not self.cfg then
			return
		end
		local pondAward=LimitedTimeDrawAwardsConfig:getCfgByPondId(self.cfg.pondId)
		if pondAward then
			local rewardList={}
			for _, v in pairs(pondAward) do
				if v.giftContent then
					local reward=v.giftContent[1]
					if reward then
						table.insert(rewardList,reward)
					end
				end
			end
			local params={}
			params.type=PayActivityDefine.LIMITED_TIME_ACTIVITY_COMMON_DIALOG_TYPE.POND
			params.rewardIdList=rewardList
			params.title="gui.limit.time.activity.draw.preview"
			UIHelper.showGameGUILayout("GUILimitedTimeActivityCommonDialog",params)
		end
	end)
	self.btnSingle:registerEvent(GUIEvent.ButtonClick, function()
		if self.activity then
			local statusRecord =self.activity.info:getValue("GiftDrawStatusRecord")
			if  statusRecord then
				self.activity:tryDraw("single",statusRecord["contentStartTime"])
			end
		end
	end)
	self.btnTen:registerEvent(GUIEvent.ButtonClick, function()
		if self.activity then
			local statusRecord =self.activity.info:getValue("GiftDrawStatusRecord")
			if  statusRecord then
				self.activity:tryDraw("ten",statusRecord["contentStartTime"])
			end
		end
	end)
	self.siBigPrize:registerEvent(GUIEvent.Click, function()
		if self.bigPrizeData then
			UIHelper.showGameGUILayout("GUIPayActivityRewardDetail", self.bigPrizeData.id,true)
		end
	end)
end

---@param activity LimitedTimeDraw
function GUILimitedTimeDrawWindow:onDataChanged(activity)
	self.activity = activity
	self.activity.info:addKeyObserver("GiftDrawStatusRecord", function()
		--local record =self.activity.info:getValue("GiftDrawStatusRecord")
		--print("---------------- GiftDrawStatusRecord :")
		--LogUtil.pv(record)
		self:updateShowInf()
		self:updateProgressInf()
	end)
	self.activity.info:addKeyObserver("GiftDrawRecord", function()
		--local record =self.activity.info:getValue("GiftDrawRecord")
		--print("---------------------------------------------------------------- GiftDrawRecord :")
		--LogUtil.pv(record)
		self:updateProgressInf()
	end)
	self:updateShowInf()
	self:updateProgressInf()
end

function GUILimitedTimeDrawWindow:updateShowInf()
	if not self.activity then
		return
	end
	local record =self.activity.info:getValue("GiftDrawStatusRecord")
	if not record then
		return
	end
	local cfg=LimitedTimeDrawConfig:getCfgById(record["id"])
	if not cfg then
		return
	end
	self.cfg=cfg

	self.stSinglePriceNum:SetText(cfg.singlePrice)
	self.stTenPriceNum:SetText(cfg.tenPrice)
	self.stTip:SetText(string.format(Lang:getString("gui.limit.time.activity.draw.tip"),cfg.guaranteeCount))
	self:updateExhibitionView()
	--print("------------  pool cfg:")
	--LogUtil.pv(cfg)
end

function GUILimitedTimeDrawWindow:updateProgressInf()
	if not self.activity then
		return
	end
	local record =self.activity.info:getValue("GiftDrawRecord")
	if not record then
		return
	end
	local statusRecord =self.activity.info:getValue("GiftDrawStatusRecord")
	if not statusRecord then
		return
	end

	local curCount=record[tostring(statusRecord["contentStartTime"])] or 0
	local maxCount = self.cfg.guaranteeCount
	if curCount >= maxCount then
		curCount = 0
	end
	self.stGuaranteeProgress:SetText(curCount .. "/" .. maxCount)
	self.pbGuarantee:SetProgress(curCount/maxCount)
end

function GUILimitedTimeDrawWindow:updateExhibitionView()
	if not self.activity or not self.cfg then
		return
	end
	local bigPrizeInfo = self:getCurPondBigPrizeInfo()
	if not bigPrizeInfo then
		return
	end
	self.siBigPrizeIcon:SetImage(bigPrizeInfo.image)
	self.awActor2:SetWidth({ 0, self.actorInitWidth })
	PayActivityRewardConfig:setRewardDetailUI(bigPrizeInfo, self.siIcon, nil, nil, self.awActor2, self.llActor_slide)
end

---@return PayActivityRewardConfigData
function GUILimitedTimeDrawWindow:getCurPondBigPrizeInfo()
	self.bigPrizeData = nil
	if not self.activity or not self.cfg then
		return
	end
	local pondId = self.cfg.pondId
	local awardPopup = LimitedTimeDrawAwardsConfig:getCfgByPondId(pondId)
	local bigPrize
	local item
	for _, v in pairs(awardPopup) do
		if v.isBigPrize then
			bigPrize = v
			break
		end
	end
	local giftContent = bigPrize.giftContent or {}
	local awardId = giftContent[1]
	if awardId then
		item = PayActivityRewardConfig:getCfgById(awardId)
		self.bigPrizeData = item
	end
	return item
end

function GUILimitedTimeDrawWindow:onShow()
	ReportEvent.reportEvent(Game:getPlatformUserId(), "limited_draw_click")
	self:startDownTimer()
end

function GUILimitedTimeDrawWindow:onHide()
	self:stopDownTimer()
end

function GUILimitedTimeDrawWindow:startDownTimer()
	self:stopDownTimer()
	self.downTimerKey=LuaTimer:scheduleTimer(function()
		self:updateActivityTimeShow()
	end, 1000)
end

function GUILimitedTimeDrawWindow:stopDownTimer()
	if self.downTimerKey then
		LuaTimer:cancel(self.downTimerKey)
		self.downTimerKey = nil
	end
end

function GUILimitedTimeDrawWindow:updateActivityTimeShow()
	local statusRecord =self.activity.info:getValue("GiftDrawStatusRecord")
	if not statusRecord or not  statusRecord["contentStartTime"]then
		return
	end

	local countdown = statusRecord["contentStartTime"]+self.activity.cfg.updateTime - os.time()
	self.stTimeText:SetText(DateUtil.getTimeByTwoPara(countdown))
end

local function getCountDown(self)
	if not self.curEndTime then
		return 0
	end
	local curTime = LimitedTimeActivityGameMgr:getServerTime()
	local surplus = self.curEndTime - curTime
	if surplus < 0 then
		return 0
	end
	local d = math.floor(surplus / (60 * 60 * 24))
	local h, m ,s = Lib.timeFormatting(surplus % (60 * 60 * 24))
	if d > 0 then
		return d .. "d " .. h .. "hour "
	end
	if h > 0 then
		return h .. "h " .. m .. "min "
	end
	return m .. "min " .. s .."s "
end

return GUILimitedTimeDrawWindow
