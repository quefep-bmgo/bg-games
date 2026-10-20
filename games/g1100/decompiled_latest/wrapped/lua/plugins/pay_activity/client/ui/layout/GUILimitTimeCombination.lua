--[[xYwtpgg28KhElJE]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 9104
                          local checkFileName = "GUILimitTimeCombination.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[ApehaxfE17rCTt5ZIUwtkwIGGz20Akc1C2ACVlU90PA8R5VCyogEYItXWpoBLC6SLnK3DSWZvZeHJtk]]---@class UILimitTimeCombinationLayout : IGUILayout
local UILimitTimeCombinationLayout = class("UILimitTimeCombinationLayout", IGUILayout)

---@type LimitedTimeGiftCombinedConfig
local LimitedTimeGiftCombinedConfig = T(Global, "LimitedTimeGiftCombinedConfig")

---@type PayActivityRewardConfig
local PayActivityRewardConfig = T(Global, "PayActivityRewardConfig")

---@private
function UILimitTimeCombinationLayout:ctor(parent)
	self.super.ctor(self, "LimitTimeCombination.json", parent)
end

---@private
function UILimitTimeCombinationLayout:isDelayLoad()
	return true
end

---@private
function UILimitTimeCombinationLayout:onCreate()
	self:initCreateEvent()
end

---@private
function UILimitTimeCombinationLayout:initCreateEvent()

end

---@private
function UILimitTimeCombinationLayout:onLoad()
	self.llBackBg = self:getChildWindow("LimitTimeCombination-BackBg", GUIType.Layout)
	self.llContentPanel = self:getChildWindow("LimitTimeCombination-ContentPanel", GUIType.Layout)
	self.siBG = self:getChildWindow("LimitTimeCombination-BG", GUIType.StaticImage)
	self.btnCloseBtn = self:getChildWindow("LimitTimeCombination-CloseBtn", GUIType.Button)
	self.siCloseIcon = self:getChildWindow("LimitTimeCombination-CloseIcon", GUIType.StaticImage)
	self.stTitleText = self:getChildWindow("LimitTimeCombination-TitleText", GUIType.StaticText)
	self.siRemainIcon = self:getChildWindow("LimitTimeCombination-remainIcon", GUIType.StaticImage)
	self.stRemainText = self:getChildWindow("LimitTimeCombination-remainText", GUIType.StaticText)
	self.stOFFText = self:getChildWindow("LimitTimeCombination-OFFText", GUIType.StaticText)
	self.stPerText = self:getChildWindow("LimitTimeCombination-PerText", GUIType.StaticText)
	self.llItemPanel = self:getChildWindow("LimitTimeCombination-ItemPanel", GUIType.Layout)
	self.siBubbleIcon = self:getChildWindow("LimitTimeCombination-BubbleIcon", GUIType.StaticImage)
	self.stLimitText = self:getChildWindow("LimitTimeCombination-LimitText", GUIType.StaticText)
	self.btnBuyBtn = self:getChildWindow("LimitTimeCombination-BuyBtn", GUIType.Button)
	self.siFinalDiaIcon = self:getChildWindow("LimitTimeCombination-FinalDiaIcon", GUIType.StaticImage)
	self.stFinalPrice = self:getChildWindow("LimitTimeCombination-FinalPrice", GUIType.StaticText)
	self.siInitDiaIcon = self:getChildWindow("LimitTimeCombination-InitDiaIcon", GUIType.StaticImage)
	self.stInitPrice = self:getChildWindow("LimitTimeCombination-InitPrice", GUIType.StaticText)
	self.siInitLine = self:getChildWindow("LimitTimeCombination-InitLine", GUIType.StaticImage)
	self.llMaskPanel = self:getChildWindow("LimitTimeCombination-MaskPanel", GUIType.Layout)
	self:initView()
	self:initEvent()
end

---@private
function UILimitTimeCombinationLayout:initView()
	self.stTitleText:SetText(Lang:getString(""))
	self.stRemainText:SetText(Lang:getString(""))
	self.stPerText:SetText(Lang:getString(""))
	self.stLimitText:SetText(string.format(Lang:getString("gui.limit.time.combined.limit"),1))
	self.stFinalPrice:SetText(Lang:getString(""))
	self.stInitPrice:SetText(Lang:getString(""))
	self.stOFFText:SetText("OFF")
end

---@private
function UILimitTimeCombinationLayout:initEvent()
	self.btnCloseBtn:registerEvent(GUIEvent.ButtonClick, function()
		self:hide()
	end)

	self.btnBuyBtn:registerEvent(GUIEvent.ButtonClick, function()
		if self.activity then
			local giftBag=LimitedTimeGiftCombinedConfig:getCfgByActivityId(self.activity.cfg.id)
			if giftBag then
				self.activity:tryBuyGiftBag(giftBag.id)
			end
		end
	end)

	self:registerEvent(Events.PayActivityGiftCombinedRecord,function ()
		self:updateBoughtBtnShow()
	end)
end

---@param activity LimitedTimeGiftCombined
function UILimitTimeCombinationLayout:onShow(activity)
	self.activity=activity
	if not activity then
		return
	end

	self:updateShowInf()
	self:updateGiftList()
	self:updateBoughtBtnShow()

	self.curTime = os.time()
	self.endTime = activity.cfg.endDate
	self:updateActivityTimeShow()
	self:startDownTimer()
	self:checkHasItem()
	self.siRemainIcon:SetVisible(activity.cfg.hideTimeUI~=1)
end

function UILimitTimeCombinationLayout:checkHasItem()
	if not self.activity then
		return
	end
	local giftBag=LimitedTimeGiftCombinedConfig:getCfgByActivityId(self.activity.cfg.id)
	if not giftBag or not giftBag.giftContent  or next(giftBag.giftContent)==nil then
		return
	end
	self.activity:requestCheckPlayerHasRewardItem(giftBag.giftContent,function (ret)
		self:updateGiftList(ret)
		self:updateBoughtBtnShow(ret)
	end)
end

function UILimitTimeCombinationLayout:updateShowInf()
	local giftCfg=LimitedTimeGiftCombinedConfig:getCfgByActivityId(self.activity.activityId)
	if not giftCfg then
		return
	end
	if giftCfg.giftName and giftCfg.giftName ~= "#" then
		self.stTitleText:SetText(Lang:getString(giftCfg.giftName))
	else
		self.stTitleText:SetText(Lang:getString("gui.limit.time.combined.title"))
	end
	self.stPerText:SetText(giftCfg.percent)
end

function UILimitTimeCombinationLayout:updateGiftList(hasRewardItemInf)
	if not self.activity then
		return
	end
	local giftBag=LimitedTimeGiftCombinedConfig:getCfgByActivityId(self.activity.cfg.id)
	if not giftBag then
		return
	end

	if not self.giftAdapter then
		self.gvGiftList = IGUIGridView.new("ChallengeTask-List", self.llItemPanel)
		self.gvGiftList:setArea({ 0, 0 }, { 0, 0 }, { 1, 0 }, { 1, 0 })
		self.gvGiftList:setConfig(15, 25, 3)
		---@type LimitedTimeCombinedAdapter
		self.giftAdapter = UIHelper.newGameAdapter("LimitedTimeCombinedAdapter")
		self.gvGiftList:setAdapter(self.giftAdapter)
	end
	local giftList={}
	for _, v in pairs(giftBag.giftContent) do
		local reward=PayActivityRewardConfig:getCfgById(v)
		if reward then
			local temp=TableUtil.copyTable(reward)
			if hasRewardItemInf then
				temp.isHave=hasRewardItemInf[reward.id]
			end
			table.insert(giftList,temp)
		end
	end
	--LogUtil.pv(giftList)
	self.giftAdapter:setData(giftList)
end

function UILimitTimeCombinationLayout:updateBoughtBtnShow(hasRewardItemInf)
	if not self.activity then
		return
	end

	local giftCfg=LimitedTimeGiftCombinedConfig:getCfgByActivityId(self.activity.activityId)
	if not giftCfg then
		return
	end

	local allBought=false
	if hasRewardItemInf then
		local buyCount=0
		for _, v in pairs(hasRewardItemInf) do
			if v then
				buyCount=buyCount+1
			end
		end
		allBought=buyCount >= #giftCfg.giftContent
		--print(">>>>>>>>>>>>> allBought,buyCount=",buyCount)
	end

	if self.activity:hasBought(giftCfg.giftKey) or allBought  then
		self.btnBuyBtn:SetText(Lang:getString("gui.limit.time.combined.purchased"))
		self.siInitDiaIcon:SetVisible(false)
		self.siFinalDiaIcon:SetVisible(false)
		self.btnBuyBtn:SetEnabled(false)
		self.btnBuyBtn:SetTouchable(false)
	else
		self.btnBuyBtn:SetEnabled(true)
		self.btnBuyBtn:SetTouchable(true)
		self.btnBuyBtn:SetText("")
		self.siInitDiaIcon:SetVisible(true)
		self.siFinalDiaIcon:SetVisible(true)

		self.stFinalPrice:SetText(giftCfg.finalPrice)
		self.stInitPrice:SetText(giftCfg.initPrice)
		--local strW = self.txtInitPrice:GetFont():GetStringWidth(self.activityData.initPrice)
		--self.imgInitLine:SetWidth({0, strW + 35})
	end
end

local function timeFormatting(second)
	assert(tonumber(second), second)
	local timeHour = math.fmod(math.floor(second/3600), 24)
	local timeMinute = math.fmod(math.floor(second/60), 60)
	local timeSecond = math.fmod(second, 60)
	return timeHour, timeMinute, timeSecond
end

function UILimitTimeCombinationLayout:updateActivityTimeShow()
	local remainTime = self.endTime - self.curTime
	if remainTime < 0 then
		--self:onHide()
		return
	end

	local text = string.format("%02d:%02d:%02d",timeFormatting(remainTime))
	if remainTime > (3600*24) then
		local day = math.floor(remainTime/3600/24) or 0
		text = day .. "d " .. text
	end
	self.stRemainText:SetText(text)
end

function UILimitTimeCombinationLayout:startDownTimer()
	self:stopDownTimer()
	self.downTimerKey=LuaTimer:scheduleTimer(function()
		self.curTime = self.curTime + 1
		self:updateActivityTimeShow()
	end, 1000)
end

function UILimitTimeCombinationLayout:stopDownTimer()
	if self.downTimerKey then
		LuaTimer:cancel(self.downTimerKey)
		self.downTimerKey = nil
	end
end

function UILimitTimeCombinationLayout:onHide()
	self:stopDownTimer()
end

return UILimitTimeCombinationLayout
--[[4A]]