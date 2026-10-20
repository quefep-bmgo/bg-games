--[[d3NBuyZJy80hnr7bfFFDp1UOAsu5SfZ]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 5755
                          local checkFileName = "GUICustomFriendsFollow.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[XoD4BExDhRfsMc52Hm9dUTv]]---@class UICustomFriendFollow : IGUILayout
local UICustomFriendFollow = class("UICustomFriendFollow", IGUILayout)
---@type FollowPlayerHelper
local FollowPlayerHelper = T(Global, "FollowPlayerHelper")

---@private
function UICustomFriendFollow:ctor(parent)
    self.super.ctor(self, "CustomFriendsFollow.json", GUIManager:getMainControl())
end

function UICustomFriendFollow:onLoad()
    self.lWatch = self:getChildWindow("CustomFriendsFollow-Watch", GUIType.Layout)
    self.stWatchName = self:getChildWindow("CustomFriendsFollow-Watch-Name", GUIType.StaticText)
    self.btnWatchLeft = self:getChildWindow("CustomFriendsFollow-Watch-Left", GUIType.Button)
    self.btnWatchRight = self:getChildWindow("CustomFriendsFollow-Watch-Right", GUIType.Button)

    self.mainControl = GUIManager:getWindowByName("Main-Control")
    self.flyControl = GUIManager:getWindowByName("Main-FlyingControls")
    self.jumpControl = GUIManager:getWindowByName("Main-Jump-Controls")
    self.flyBtn = GUIManager:getWindowByName("Main-Fly")
    self.poleControl = GUIManager:getWindowByName("Main-PoleControl")
    self.poleControlMove = GUIManager:getWindowByName("Main-PoleControl-Move")
    self.moveState = GUIManager:getWindowByName("Main-MoveState")

    self:register()
end

function UICustomFriendFollow:register()
    self.btnWatchLeft:registerEvent(GUIEvent.ButtonClick, function()
        PlayerManager:getClientPlayer():sendPacket({
            pid = "findPreviousFollower"
        })
    end)
    self.btnWatchRight:registerEvent(GUIEvent.ButtonClick, function()
        PlayerManager:getClientPlayer():sendPacket({
            pid = "findLatterFollower"
        })
    end)
end

function UICustomFriendFollow:followPlayer(followUserId, followNum)
    if self.followerId == followUserId then
        return
    end
    local follower = PlayerManager:getPlayerByUserId(followUserId)
    if follower then
        if not self:isShow() then
            self:show()
        end
        self.followerId = followUserId
        self.follower = follower
        self.followNum = followNum
        self.isDirty = true
    else
        if self:isShow() then
            self:hide()
        end
    end
end

function UICustomFriendFollow:cancelFollowPlayer()
    PlayerManager:getClientPlayer().Player:setWatchMode(false)
    self:hide()
end

function UICustomFriendFollow:onShow()
    self.userId = PlayerManager:getClientPlayer().userId
    ClientHelper.putBoolPrefs("RenderHeadText", false)
end

function UICustomFriendFollow:onHide()
    ClientHelper.putBoolPrefs("RenderHeadText", true)
    local player = PlayerManager:getClientPlayer().Player
    Blockman.Instance():setRenderViewEntity(player)
    player:setActorInvisible(false)
    self.followerId = 0
    self.follower = nil
    self.followNum = 0
    self.isDirty = false
end

function UICustomFriendFollow:onTick(frameTime, renderDt)
    if self.isDirty then
        self.isDirty = false
        local userInfo = UserInfoCache:GetCache(self.followerId)
        if userInfo then
            self.stWatchName:SetText(userInfo.nickName)
        else
            self.stWatchName:SetText(self.follower:getName())
        end

        local showBtn = self.followNum > 1
        self.btnWatchLeft:SetVisible(showBtn)
        self.btnWatchRight:SetVisible(showBtn)
    end
    self:checkMoveControlVisible()
    if self.userId ~= self.followerId then
        local follower = PlayerManager:getPlayerByUserId(self.followerId)
        FollowPlayerHelper:onUpdate(follower, frameTime, renderDt)
    else
        local player = PlayerManager:getClientPlayer().Player
        Blockman.Instance():setRenderViewEntity(player)
        player:setActorInvisible(false)
    end
end

function UICustomFriendFollow:checkMoveControlVisible()
    if self.userId == self.followerId then
        if Blockman.Instance().m_gameSettings.usePole == 0 then
            self.mainControl:SetVisible(true)
            self.poleControl:SetVisible(false)
            self.poleControlMove:SetVisible(false)
        else
            self.mainControl:SetVisible(false)
            self.poleControl:SetVisible(true)
            self.poleControlMove:SetVisible(true)
        end
        if PlayerManager:getClientPlayer().Player:getIsFlying() then
            self.flyBtn:SetVisible(false)
            self.jumpControl:SetVisible(false)
            self.flyControl:SetVisible(true)
        else
            self.flyBtn:SetVisible(true)
            self.jumpControl:SetVisible(true)
            self.flyControl:SetVisible(false)
        end
        self.moveState:SetVisible(true)
    else
        self.mainControl:SetVisible(false)
        self.jumpControl:SetVisible(false)
        self.flyBtn:SetVisible(false)
        self.flyControl:SetVisible(false)
        self.poleControl:SetVisible(false)
        self.poleControlMove:SetVisible(false)
        self.moveState:SetVisible(false)
    end
end

return UICustomFriendFollow--[[8fhVTJ5vsknueRa]]---