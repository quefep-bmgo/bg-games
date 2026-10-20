--[[d34zMi6mxo9PbTLsGEvM]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 13053
                          local checkFileName = "GUILimitedTimeGoldWheel.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[UJVc4wEYDbO]]---@class GUILimitedTimeGoldWheelWindow : IGUIWindow
local GUILimitedTimeGoldWheelWindow = class("GUILimitedTimeGoldWheelWindow", IGUIWindow)

---@type ReportEvent
local ReportEvent = T(Global, "ReportEvent")

---@type LimitedTimeGoldWheelConfig
local LimitedTimeGoldWheelConfig = T(Global, "LimitedTimeGoldWheelConfig")

local WheelItemNum=6
local AngleSpeed=360
local AngleAcc=190
local Radius=180
local RotateTimeInterval=50
local RotateFlashTime=1000
local RoundNum=3
local SlowDownAngle=360
local SpeedUpAngle=360
local halfPriceCD=24

local GoldWheelState={
	Normal=1,
	WaitRotate=2,
	Rotating=3,
	WaitReward=4
}

---@private
function GUILimitedTimeGoldWheelWindow:ctor(...)
	self.super.ctor(self, "LimitedTimeGoldWheel.json", ...)
	self.itemList={}
	self.curPointIndex=1
	self.initOrder=2
	self.rotationAngle = {30,90,150,210,270,330}
	self.rotationChangeAngle = 0
	self.initFirstAngle=self.rotationAngle[1]
	self.curState=GoldWheelState.Normal
end

---@private
function GUILimitedTimeGoldWheelWindow:onLoad()
	self.btnHelp = self:getChildWindowByName("LimitedTimeGoldWheel-help", GUIType.Button)
	self.stTitle = self:getChildWindowByName("LimitedTimeGoldWheel-title", GUIType.StaticText)
	self.siWheel = self:getChildWindowByName("LimitedTimeGoldWheel-wheel", GUIType.StaticImage)
	self.siWheelFace = self:getChildWindowByName("LimitedTimeGoldWheel-wheel_face", GUIType.StaticImage)
	self.siHighlight = self:getChildWindowByName("LimitedTimeGoldWheel-highlight", GUIType.StaticImage)
	self.llItemPanel = self:getChildWindowByName("LimitedTimeGoldWheel-item_panel", GUIType.Layout)
	self.btnButtonGo = self:getChildWindowByName("LimitedTimeGoldWheel-button_go", GUIType.Button)
	self.stGo = self:getChildWindowByName("LimitedTimeGoldWheel-go", GUIType.StaticText)
	self.llNormalPrice = self:getChildWindowByName("LimitedTimeGoldWheel-normal_price", GUIType.Layout)
	self.siNormalPriceIcon = self:getChildWindowByName("LimitedTimeGoldWheel-normal_price_icon", GUIType.StaticImage)
	self.stNormalPriceText = self:getChildWindowByName("LimitedTimeGoldWheel-normal_price_text", GUIType.StaticText)
	self.llHalfPrice = self:getChildWindowByName("LimitedTimeGoldWheel-half_price", GUIType.Layout)
	self.siHalfPriceIconInit = self:getChildWindowByName("LimitedTimeGoldWheel-half_price_icon_init", GUIType.StaticImage)
	self.stHalfPriceInitText = self:getChildWindowByName("LimitedTimeGoldWheel-half_price_init_text", GUIType.StaticText)
	self.siPriceLine = self:getChildWindowByName("LimitedTimeGoldWheel-price_line", GUIType.StaticImage)
	self.stHalfPriceHalfText = self:getChildWindowByName("LimitedTimeGoldWheel-half_price_half_text", GUIType.StaticText)
	self.stNextHalfPrice = self:getChildWindowByName("LimitedTimeGoldWheel-next_half_price", GUIType.StaticText)
	self.stNextHalfPriceTime = self:getChildWindowByName("LimitedTimeGoldWheel-next_half_price_time", GUIType.StaticText)
	self.stTime = self:getChildWindowByName("LimitedTimeGoldWheel-time_text", GUIType.StaticText)
	self.llShowTime = self:getChildWindowByName("LimitedTimeGoldWheel-show_time", GUIType.Layout)
	self:initView()
	self:initEvent()
end

---@private
function GUILimitedTimeGoldWheelWindow:initView()
	self.stTitle:SetText(Lang:getString("gui.limit.time.activity.gold.wheel.title"))
	self.stGo:SetText("GO")
	self.stNormalPriceText:SetText()
	self.stHalfPriceInitText:SetText()
	self.stHalfPriceHalfText:SetText()
	self.stNextHalfPrice:SetText(Lang:getString("gui.limit.time.activity.gold.wheel.half.price"))
	self.stNextHalfPriceTime:SetText()
	self.siHighlight:SetVisible(false)
	self.stTime:SetText()
end

---@private
function GUILimitedTimeGoldWheelWindow:initEvent()
	self.btnHelp:registerEvent(GUIEvent.ButtonClick, function()
		local params={}
		params.type=PayActivityDefine.LIMITED_TIME_ACTIVITY_COMMON_DIALOG_TYPE.TEXT
		params.dec="gui.limit.time.activity.gold.wheel.help"
		params.title="gui.limit.time.activity.help"
		UIHelper.showGameGUILayout("GUILimitedTimeActivityCommonDialog",params)
	end)
	self.btnButtonGo:registerEvent(GUIEvent.ButtonClick, function()
		if self.activity and self.itemList and self.curState==GoldWheelState.Normal then
			self.activity:tryRotate(function (success)
				print("------------------ go result: ",success)
				if success then
					self.curState=GoldWheelState.WaitRotate
				end
			end)
		end
	end)
end

---@param activity LimitedTimeMGoldWheel
function GUILimitedTimeGoldWheelWindow:onDataChanged(activity)
	self.activity=activity
	if not activity or next(self.itemList)~=nil then
		return
	end
	if activity then
		activity:updateRedDot(false)
	end
	self.activity.info:addKeyObserver(PayActivityDefine.GoldWheelInf.GoldWheelRecord, function()
		local record =self.activity.info:getValue(PayActivityDefine.GoldWheelInf.GoldWheelRecord)
		--print("---------------- GoldWheelRecord :")
		--LogUtil.pv(record)
		local targetOrder=record["1"]
		if targetOrder and targetOrder > 0 then
			if self.curState == GoldWheelState.WaitRotate then
				self:startRotate()
			end
		else
			self.curState=GoldWheelState.Normal
		end
	end)
	self.activity.info:addKeyObserver(PayActivityDefine.GoldWheelInf.GoldWheelGetReward, function()
		--local record =self.activity.info:getValue(PayActivityDefine.GoldWheelInf.GoldWheelGetReward)
		--print("---------------- GoldWheelGetReward :")
		--LogUtil.pv(record)
		if self.curState == GoldWheelState.WaitReward then
			self:resetGoldWheel()
		end
	end)

	local wheelItems=LimitedTimeGoldWheelConfig:getCfgByActivityId(self.activity.cfg.id)
	if not wheelItems or  #wheelItems~=WheelItemNum then
		return
	end
	table.sort(wheelItems,function (a,b)
		return a.order<b.order
	end)
	for i = 1, #wheelItems do
		local item = UIHelper.newGameGUIWindow("GUILimitedTimeActivityGoldWheelItem")
		item:onDataChanged(wheelItems[i])
		self.llItemPanel:AddChildWindow(item.root)
		table.insert(self.itemList,item.root)
	end
	self:updateRoundPosWithAngle()
	self:updatePriceInf()
end

function GUILimitedTimeGoldWheelWindow:updatePriceInf()
	if not self.activity then
		return
	end
	local wheelItems=LimitedTimeGoldWheelConfig:getCfgByActivityId(self.activity.cfg.id)
	if not wheelItems or next(wheelItems)==0 then
		return
	end

	local record =self.activity.info:getValue(PayActivityDefine.GoldWheelInf.GoldWheelTime)
	if record then
		local time=record["1"]
		local isHalfPrice=not time or os.time()-time>=halfPriceCD*3600
		self.llNormalPrice:SetVisible(not isHalfPrice)
		self.llHalfPrice:SetVisible(isHalfPrice)
		if isHalfPrice then
			self.stNextHalfPriceTime:SetVisible(false)
			self.stHalfPriceInitText:SetText(wheelItems[1].finalPrice)
			self.stHalfPriceHalfText:SetText(math.floor(wheelItems[1].finalPrice/2))
		else
			self.stNextHalfPriceTime:SetVisible(true)
			self.stNormalPriceText:SetText(wheelItems[1].finalPrice)
			local countdown = time+halfPriceCD*3600 - os.time()
			self.stNextHalfPriceTime:SetText(DateUtil.getTimeByTwoPara(countdown))
		end
	end
end

-- 更新物品转盘角度和位置
function GUILimitedTimeGoldWheelWindow:updateRoundPosWithAngle()
	for i = 1, #self.itemList do
		local x,y = self:getPosByAngleAndRadius(self.rotationAngle[i]+self.rotationChangeAngle,  Radius )
		self.itemList[i]:SetXPosition({0, x})
		self.itemList[i]:SetYPosition({0, y})
	end
	self.siWheelFace:SetRotate(-(self.rotationAngle[1]+self.rotationChangeAngle-self.initFirstAngle))
end

-- 获取圆中心特定角度、半径的坐标
function GUILimitedTimeGoldWheelWindow:getPosByAngleAndRadius(angle, radius)
	local yaw = angle
	local value = -yaw * 3.14159 / 180
	local s = math.sin(value)
	local c = math.cos(value)
	return c*radius,s*radius
end

function GUILimitedTimeGoldWheelWindow:getChangeAngle(targetOrder)
	if targetOrder == self.initOrder then
		return 0
	end
	local step=0
	if targetOrder>self.initOrder then
		step= self.initOrder+WheelItemNum- targetOrder
		--print("===============>>getChangeAngle",step)
	else
		step=self.initOrder-targetOrder
		--print("===============>>getChangeAngle2",step)
	end
	local result=360/WheelItemNum*step
	--print("===============>>getChangeAngle,result",result)
	return result
end

function GUILimitedTimeGoldWheelWindow:startRotate()
	if not self.activity then
		return
	end
	local record =self.activity.info:getValue(PayActivityDefine.GoldWheelInf.GoldWheelRecord)
	if not record then
		return
	end
	self.curState=GoldWheelState.Rotating
	self.siHighlight:SetVisible(false)
	local targetOrder=record["1"]
	self.targetOrder=targetOrder
	self:stopRotateTimer()
	local changeAngle=self:getChangeAngle(targetOrder)+RoundNum*360
	self.changeAngle=changeAngle
	local speedUpAngle=math.min(SpeedUpAngle,changeAngle)
	local slowDownRotateAngle=math.max(changeAngle-SlowDownAngle,0)
	local step=AngleSpeed*RotateTimeInterval/1000
	print("-------------------startRotate",targetOrder,changeAngle,step)
	local rotateStage=1
	local curAngleSpeed=0
	local flashCtrl=true
	local flashTime=0
	self.rotateTimerKey=LuaTimer:scheduleTimer(function()
		if rotateStage == 1 then
			local stepSlow=curAngleSpeed*RotateTimeInterval/1000+AngleAcc*RotateTimeInterval*RotateTimeInterval/(2*1000*1000)
			self.rotationChangeAngle=math.min(self.rotationChangeAngle+stepSlow,speedUpAngle)
			curAngleSpeed=math.min(AngleSpeed,curAngleSpeed+AngleAcc*RotateTimeInterval/1000)
			--print("============================= speed up",stepSlow,curAngleSpeed)
			self:updateRoundPosWithAngle()
			if self.rotationChangeAngle==speedUpAngle then
				rotateStage=2
				curAngleSpeed=AngleSpeed
			end
		elseif rotateStage==2 then
			self.rotationChangeAngle=math.min(self.rotationChangeAngle+step,slowDownRotateAngle)
			self:updateRoundPosWithAngle()
			if self.rotationChangeAngle==slowDownRotateAngle then
				rotateStage=3
			end
		elseif rotateStage==3 then
			local stepSlow=curAngleSpeed*RotateTimeInterval/1000+AngleAcc*RotateTimeInterval*RotateTimeInterval/(2*1000*1000)
			self.rotationChangeAngle=math.min(self.rotationChangeAngle+stepSlow,changeAngle)
			curAngleSpeed=math.max(10,curAngleSpeed-AngleAcc*RotateTimeInterval/1000)
			--print("============================= show",stepSlow,curAngleSpeed)
			self:updateRoundPosWithAngle()
			if self.rotationChangeAngle==changeAngle then
				rotateStage=4
			end
		elseif rotateStage==4 then
			self.siHighlight:SetVisible(flashCtrl)
			flashCtrl=not flashCtrl
			flashTime=flashTime+RotateTimeInterval
			if flashTime >=RotateFlashTime then
				rotateStage=5
			end
		else
			self:rotateFinish(targetOrder)
		end
	end, RotateTimeInterval)
end

function GUILimitedTimeGoldWheelWindow:rotateFinish()
	self:stopRotateTimer()
	self.curState=GoldWheelState.WaitReward
	for i, _ in pairs(self.rotationAngle) do
		self.rotationAngle[i]=self.rotationAngle[i]+self.changeAngle
	end
	self.rotationChangeAngle=0
	self:updateRoundPosWithAngle()
	self.initOrder=self.targetOrder
	self.siHighlight:SetVisible(false)
	self.activity:getReward()
end

function GUILimitedTimeGoldWheelWindow:resetGoldWheel()
	self.curState=GoldWheelState.Normal
end

function GUILimitedTimeGoldWheelWindow:stopRotateTimer()
	print("++++++++++++++++++++++++ GUILimitedTimeGoldWheelWindow:stopRotateTimer  ",self.rotateTimerKey)
	if self.rotateTimerKey then
		LuaTimer:cancel(self.rotateTimerKey)
		self.rotateTimerKey = nil
	end
end

function GUILimitedTimeGoldWheelWindow:startDownTimer()
	self:stopDownTimer()
	self.downTimerKey=LuaTimer:scheduleTimer(function()
		self:updateActivityTimeShow()
		self:updatePriceInf()
	end, 1000)
end

function GUILimitedTimeGoldWheelWindow:stopDownTimer()
	if self.downTimerKey then
		print("--------------- GUILimitedTimeGoldWheelWindow:stopDownTimer ")
		LuaTimer:cancel(self.downTimerKey)
		self.downTimerKey = nil
	end
end

function GUILimitedTimeGoldWheelWindow:updateActivityTimeShow()
	local countdown = self.activity.cfg.endDate - os.time()
	self.stTime:SetText(DateUtil.getTimeByTwoPara(countdown))
end

function GUILimitedTimeGoldWheelWindow:onShow()
	ReportEvent.reportEvent(Game:getPlatformUserId(), "turntable_click")
	self:startDownTimer()
	if self.activity then
		self.llShowTime:SetVisible(self.activity.cfg.hideTimeUI~=1)
	end
end

function GUILimitedTimeGoldWheelWindow:onHide()
	self:stopDownTimer()
	if self.curState == GoldWheelState.Rotating then
		self:rotateFinish()
	end
end

return GUILimitedTimeGoldWheelWindow
--[[4A]]---