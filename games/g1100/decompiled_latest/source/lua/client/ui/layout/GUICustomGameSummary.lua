---@class UICustomGameSummaryLayout : IGUILayout
local UICustomGameSummaryLayout = class("UICustomGameSummaryLayout", IGUILayout)

---@private
function UICustomGameSummaryLayout:ctor(parent)
    self.super.ctor(self, "CustomGameSummary.json", parent)
end

---@private
function UICustomGameSummaryLayout:isDelayLoad()
    return true
end

---@private
function UICustomGameSummaryLayout:onCreate()
    self:initCreateEvent()
end

---@private
function UICustomGameSummaryLayout:initCreateEvent()

end

---@private
function UICustomGameSummaryLayout:onLoad()
    self.siBg = self:getChildWindow("CustomGameSummary-Bg", GUIType.StaticImage)
    self.llSelf = self:getChildWindow("CustomGameSummary-Self", GUIType.Layout)
    self.siSelfBg = self:getChildWindow("CustomGameSummary-Self_Bg", GUIType.StaticImage)
    self.siSelfDivideLine1 = self:getChildWindow("CustomGameSummary-Self-DivideLine1", GUIType.StaticImage)
    self.siSelfDivideLine2 = self:getChildWindow("CustomGameSummary-Self-DivideLine2", GUIType.StaticImage)
    self.SelfNameWindow = self:getChildWindow("CustomGameSummary-Self-NameWindow", GUIType.DefaultWindow)
    self.stSelfName = self:getChildWindow("CustomGameSummary-Self-Name", GUIType.StaticText)
    self.SelfRankWindow = self:getChildWindow("CustomGameSummary-Self-RankWindow", GUIType.DefaultWindow)
    self.stSelfRankTitle = self:getChildWindow("CustomGameSummary-Self-RankTitle", GUIType.StaticText)
    self.siSelfRankBg = self:getChildWindow("CustomGameSummary-Self-RankBg", GUIType.StaticImage)
    self.siSelfRank = self:getChildWindow("CustomGameSummary-Self-Rank", GUIType.StaticImage)
    self.SelfDoubleRank = self:getChildWindow("CustomGameSummary-Self-DoubleRank", GUIType.DefaultWindow)
    self.siSelfDoubleRankTen = self:getChildWindow("CustomGameSummary-Self-DoubleRank-Ten", GUIType.StaticImage)
    self.siSelfDoubleRankOne = self:getChildWindow("CustomGameSummary-Self-DoubleRank-One", GUIType.StaticImage)
    self.llAllRank = self:getChildWindow("CustomGameSummary-AllRank", GUIType.Layout)
    self.siAllRankBg = self:getChildWindow("CustomGameSummary-AllRank-Bg", GUIType.StaticImage)
    self.llAllRankTitle = self:getChildWindow("CustomGameSummary-AllRank-Title", GUIType.Layout)
    self.stAllRankTitleRank = self:getChildWindow("CustomGameSummary-AllRank-Title-Rank", GUIType.StaticText)
    self.stAllRankTitleScore = self:getChildWindow("CustomGameSummary-AllRank-Title-Score", GUIType.StaticText)
    self.siAllRankTitleLine = self:getChildWindow("CustomGameSummary-AllRank-Title-Line", GUIType.StaticImage)
    self.stAllRankTitleName = self:getChildWindow("CustomGameSummary-AllRank-Title-Name", GUIType.StaticText)
    self.llAllRankContent = self:getChildWindow("CustomGameSummary-AllRank-Content", GUIType.Layout)
    self.ltAllRankContentList = self:getChildWindow("CustomGameSummary-AllRank-Content-List", GUIType.List)
    self.Button = self:getChildWindow("CustomGameSummary-Button", GUIType.DefaultWindow)
    self.btnExit = self:getChildWindow("CustomGameSummary-Exit", GUIType.Button)
    self.btnContinue = self:getChildWindow("CustomGameSummary-Continue", GUIType.Button)
    self.siResult = self:getChildWindow("CustomGameSummary-Result", GUIType.StaticImage)
    self.stTitle = self:getChildWindow("CustomGameSummary-Title", GUIType.StaticText)
    self.siEffect = self:getChildWindow("CustomGameSummary-Effect", GUIType.StaticImage)
    self:initView()
    self:initEvent()
end

---@private
function UICustomGameSummaryLayout:initView()
    self.stSelfRankTitle:SetText(Lang:getString("dead.summary.rank"))
    self.stAllRankTitleRank:SetText(Lang:getString("final.summary.rank"))
    self.stAllRankTitleScore:SetText(Lang:getString("final.summary.score"))
    self.stAllRankTitleName:SetText(Lang:getString("final.summary.player"))
    self.stTitle:SetText(Lang:getString("wordart_settlement"))
    self.btnExit:SetText(Lang:getString("gui.exit"))
    self.btnContinue:SetText(Lang:getString("gui.continue"))

    self.gvRankList = IGUIGridView.new("CustomGameSummary-Rank-List", self.llAllRankContent)
    self.gvRankList:setConfig(0, 0, 1)
    ---@type SummaryItemAdapter
    self.rankAdapter = UIHelper.newGameAdapter("SummaryItemAdapter")
    self.gvRankList:setAdapter(self.rankAdapter)
end

---@private
function UICustomGameSummaryLayout:initEvent()
    self.btnExit:registerEvent(GUIEvent.ButtonClick, function()
        CEvents.GameActionTriggerEvent:invoke(Define.AppToGameEvent.GAME_ACTION_CUSTOM_ROOM_CLOSE_GAME)
    end)

    self.btnContinue:registerEvent(GUIEvent.ButtonClick, function()
        self:hide()
    end)
end

function UICustomGameSummaryLayout:onShow(data)
    self.root:SetLevel(0)
    local own = data.own
    self.siSelfRank:SetVisible(own.rank < 10)
    self.SelfDoubleRank:SetVisible(own.rank > 9)
    if own.rank < 10 then
        self.siSelfRank:SetImage(Define.RankNum[tostring(own.rank)])
    else
        local one = own.rank % 10
        local ten = own.rank - one
        self.siSelfDoubleRankOne:SetImage(Define.RankNum[tostring(one)])
        self.siSelfDoubleRankTen:SetImage(Define.RankNum[tostring(ten)])
    end
    self.siSelfRankBg:SetImage(Define.RankBg[own.rank] or Define.RankDefaultBg)
    self.stSelfName:SetText(own.name)
    self.siResult:SetImage(own.isWin and "set:summary.json image:BigWinEN" or "set:summary.json image:BigLoseEN")

    self.rankAdapter:setData(data.players)

    if self.timer then
        LuaTimer:cancel(self.timer)
        self.timer = nil
    end
    self.timer = LuaTimer:schedule(function()
        self:updateSec()
    end, 0, 1000)
end

function UICustomGameSummaryLayout:onHide()
    self.sec = nil
    if self.timer then
        LuaTimer:cancel(self.timer)
        self.timer = nil
    end
end

function UICustomGameSummaryLayout:updateSec()
    self.sec = self.sec or 10
    self.btnContinue:SetText(Lang:getString("gui.continue") .. "(" .. self.sec .. ")")
    self.sec = self.sec - 1
    if self.sec < 0 then
        self:hide()
    end
end

return UICustomGameSummaryLayout
