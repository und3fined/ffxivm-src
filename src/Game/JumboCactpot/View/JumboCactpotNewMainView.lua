---
--- Author: Administrator
--- DateTime: 2023-09-18 09:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local EventID = require("Define/EventID")
local RichTextUtil = require("Utils/RichTextUtil")
local JumboCactpotVM = require("Game/JumboCactpot/JumboCactpotVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local JumboCactpotMgr = require("Game/JumboCactpot/JumboCactpotMgr")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local JumboCactpotDefine = require("Game/JumboCactpot/JumboCactpotDefine")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local NpcDialogMgr = require("Game/NPC/NpcDialogMgr")
local SysnoticeCfg = require("TableCfg/SysnoticeCfg")
local AudioUtil = require("Utils/AudioUtil")

local IconPath = JumboCactpotDefine.IconPath
local UIViewID = _G.UIViewID
local UIViewMgr = _G.UIViewMgr
local TimerMgr = _G.TimerMgr
local LSTR = _G.LSTR

---@class JumboCactpotNewMainView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAdd UFButton
---@field BtnBuff UFButton
---@field BtnBuy UFButton
---@field BtnClick UFButton
---@field BtnHelp_1 CommInforBtnView
---@field BtnResume UFButton
---@field BtnTips UFButton
---@field CloseBtn CommonCloseBtnView
---@field CommCurrency01_1 CommMoneySlotView
---@field CommCurrency02_1 CommMoneySlotView
---@field EFF_GridsCoverGlow UHorizontalBox
---@field FBtn_Key0 UFButton
---@field FBtn_Key1 UFButton
---@field FBtn_Key2 UFButton
---@field FBtn_Key3 UFButton
---@field FBtn_Key4 UFButton
---@field FBtn_Key5 UFButton
---@field FBtn_Key6 UFButton
---@field FBtn_Key7 UFButton
---@field FBtn_Key8 UFButton
---@field FBtn_Key9 UFButton
---@field FBtn_KeyDelete UFButton
---@field FBtn_Roll UFButton
---@field FText_Grid1 UFTextBlock
---@field FText_Grid2 UFTextBlock
---@field FText_Grid3 UFTextBlock
---@field FText_Grid4 UFTextBlock
---@field Grids UHorizontalBox
---@field ImgTicket02 UFImage
---@field ImgTicket03 UFImage
---@field InputItem01 JumboCactpotInputItemView
---@field InputItem02 JumboCactpotInputItemView
---@field InputItem03 JumboCactpotInputItemView
---@field InputItem04 JumboCactpotInputItemView
---@field Keys UFCanvasPanel
---@field PanelAddTips UFCanvasPanel
---@field PanelBottom UFCanvasPanel
---@field PanelBought UFCanvasPanel
---@field PanelCurrency UFCanvasPanel
---@field PanelNoTime UFCanvasPanel
---@field PanelResidualTips UFCanvasPanel
---@field RaidalCDWhite URadialImage
---@field RaidalCDYellow URadialImage
---@field RichTextBoxAddTips URichTextBox
---@field RichTextCountDown URichTextBox
---@field RichTextCurrency URichTextBox
---@field TableViewBoughtNumber UTableView
---@field TableViewTipsItem UTableView
---@field TextBought UFTextBlock
---@field TextBuff UFTextBlock
---@field TextBuy UFTextBlock
---@field TextNoTime UFTextBlock
---@field TextResidual UFTextBlock
---@field TextResidualNumber UFTextBlock
---@field TextResume UFTextBlock
---@field TextTime UFTextBlock
---@field TextTitle UFTextBlock
---@field ToggleGroupInput UToggleGroup
---@field AnimAgain UWidgetAnimation
---@field AnimBoughtIn UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimNumChange1 UWidgetAnimation
---@field AnimNumChange1Glow UWidgetAnimation
---@field AnimNumChange2 UWidgetAnimation
---@field AnimNumChange2Glow UWidgetAnimation
---@field AnimNumChange3 UWidgetAnimation
---@field AnimNumChange3Glow UWidgetAnimation
---@field AnimNumChange4 UWidgetAnimation
---@field AnimNumChange4Glow UWidgetAnimation
---@field AnimPurchased UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JumboCactpotNewMainView = LuaClass(UIView, true)

function JumboCactpotNewMainView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAdd = nil
	--self.BtnBuff = nil
	--self.BtnBuy = nil
	--self.BtnClick = nil
	--self.BtnHelp_1 = nil
	--self.BtnResume = nil
	--self.BtnTips = nil
	--self.CloseBtn = nil
	--self.CommCurrency01_1 = nil
	--self.CommCurrency02_1 = nil
	--self.EFF_GridsCoverGlow = nil
	--self.FBtn_Key0 = nil
	--self.FBtn_Key1 = nil
	--self.FBtn_Key2 = nil
	--self.FBtn_Key3 = nil
	--self.FBtn_Key4 = nil
	--self.FBtn_Key5 = nil
	--self.FBtn_Key6 = nil
	--self.FBtn_Key7 = nil
	--self.FBtn_Key8 = nil
	--self.FBtn_Key9 = nil
	--self.FBtn_KeyDelete = nil
	--self.FBtn_Roll = nil
	--self.FText_Grid1 = nil
	--self.FText_Grid2 = nil
	--self.FText_Grid3 = nil
	--self.FText_Grid4 = nil
	--self.Grids = nil
	--self.ImgTicket02 = nil
	--self.ImgTicket03 = nil
	--self.InputItem01 = nil
	--self.InputItem02 = nil
	--self.InputItem03 = nil
	--self.InputItem04 = nil
	--self.Keys = nil
	--self.PanelAddTips = nil
	--self.PanelBottom = nil
	--self.PanelBought = nil
	--self.PanelCurrency = nil
	--self.PanelNoTime = nil
	--self.PanelResidualTips = nil
	--self.RaidalCDWhite = nil
	--self.RaidalCDYellow = nil
	--self.RichTextBoxAddTips = nil
	--self.RichTextCountDown = nil
	--self.RichTextCurrency = nil
	--self.TableViewBoughtNumber = nil
	--self.TableViewTipsItem = nil
	--self.TextBought = nil
	--self.TextBuff = nil
	--self.TextBuy = nil
	--self.TextNoTime = nil
	--self.TextResidual = nil
	--self.TextResidualNumber = nil
	--self.TextResume = nil
	--self.TextTime = nil
	--self.TextTitle = nil
	--self.ToggleGroupInput = nil
	--self.AnimAgain = nil
	--self.AnimBoughtIn = nil
	--self.AnimIn = nil
	--self.AnimNumChange1 = nil
	--self.AnimNumChange1Glow = nil
	--self.AnimNumChange2 = nil
	--self.AnimNumChange2Glow = nil
	--self.AnimNumChange3 = nil
	--self.AnimNumChange3Glow = nil
	--self.AnimNumChange4 = nil
	--self.AnimNumChange4Glow = nil
	--self.AnimPurchased = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JumboCactpotNewMainView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnHelp_1)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommCurrency01_1)
	self:AddSubView(self.CommCurrency02_1)
	self:AddSubView(self.InputItem01)
	self:AddSubView(self.InputItem02)
	self:AddSubView(self.InputItem03)
	self:AddSubView(self.InputItem04)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JumboCactpotNewMainView:OnInit()
	self.InputItems = {
        --可选择的四个item
        self.InputItem01,
        self.InputItem02,
        self.InputItem03,
        self.InputItem04
    }
    self.FText_Grids = {
        --左侧票券对应数字
        self.FText_Grid1,
        self.FText_Grid2,
        self.FText_Grid3,
        self.FText_Grid4
    }


    self.SelectedIndex = 1 -- 当前选中的index 默认为第一个
    self.Roll = true

    self.BoughtNumberAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewBoughtNumber, nil, true)
    self.TipsAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTipsItem, nil, true)


    self.Binders = {
        { "PriceColor", UIBinderSetColorAndOpacityHex.New(self, self.RichTextCurrency)},
        { "NeedConsumptPrice", UIBinderSetText.New(self, self.RichTextCurrency)},
        { "RemainPurchases", UIBinderSetText.New(self, self.TextResidualNumber)},
        --{ "XCTickExchangeNums", UIBinderSetText.New(self, self.FTextBlock_1911)},
        -- { "OwnJDNum", UIBinderSetTextFormatForMoney.New(self, self.CommCurrency01_1.TextMoneyAmount)},
        -- { "XCTicksNum", UIBinderSetText.New(self, self.CommCurrency02_1.TextMoneyAmount)},
        { "RemainLotteryTime", UIBinderSetText.New(self, self.RichTextCountDown)},
		{ "BoughtNumberList", UIBinderUpdateBindableList.New(self, self.BoughtNumberAdapter)},
        { "TipsList", UIBinderUpdateBindableList.New(self, self.TipsAdapter)},

		{ "bBoughtMany", UIBinderSetIsVisible.New(self, self.ImgTicket03)},
		{ "bNoTime", UIBinderSetIsVisible.New(self, self.PanelNoTime)},
        { "bReaminTime", UIBinderSetIsVisible.New(self, self.Keys)},
        { "bReaminTime", UIBinderSetIsVisible.New(self, self.PanelBottom)},
    }

end

function JumboCactpotNewMainView:OnDestroy()

end

function JumboCactpotNewMainView:OnShow()
    if JumboCactpotMgr:GetPurNumLocal() > 0 then
        self:PlayAnimation(self.AnimBoughtIn)
    end

    local MsgBody = {
        Cmd = ProtoCS.FairyColorGameCmd.QueryProgress,
    }
    JumboCactpotMgr:OnSendNetMsg(MsgBody)

    self:SetBuyBtnEnable(false)
    JumboCactpotMgr.bIsBuy = false
    JumboCactpotMgr.bClickBtnWaitOpen = false
    JumboCactpotMgr:SetRemainPurChases()
    JumboCactpotMgr:SetXCExchangeDetail()
    JumboCactpotMgr:SetJDNAndXCTickNum()
	self.TextTime:SetText(string.format(LSTR(240061), JumboCactpotMgr.Term)) -- %d期
    self.RichTextBoxAddTips:SetText(LSTR(240062))   -- 用仙彩券\n可兑换次数哦~
    self:ShowExTips()
	self:UpdateBoughtNumVisible()
    self:UpdateBoughtNumList()
	JumboCactpotMgr:SetNeedConsumptPrice()
    JumboCactpotMgr:CheckShowWaitLottery()
    self:UpdateRewardBonusPro()
    self.CloseBtn:SetCallback(self, self.OnBtnCloseClicked)

    UIUtil.SetIsVisible(self.BtnClick, false)

    local JDResID = ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE
	self.CommCurrency01_1:UpdateView(JDResID, true, -1, true)
    local XCTicketResID = ProtoRes.SCORE_TYPE.SCORE_TYPE_FAIRY_COLOR_COUPONS
    self.CommCurrency02_1:UpdateView(XCTicketResID, true, -1, true)

    UIUtil.SetIsVisible(self.EFF_GridsCoverGlow, false)
    self:ResetToggleBtnToDefault()
    AudioUtil.LoadAndPlayUISound(JumboCactpotDefine.JumboUIAudioPath.PurAnimInAudio)

    -- if not self.Roll then
    local function StopRoll()
        for i = 1, 4 do 
            self.InputItems[i]:ResetToDefault()
        end
    end
    self:RegisterTimer(StopRoll, 1)
    self.Roll = true
    -- end
    
    self:InitLSTRText()
end

function JumboCactpotNewMainView:InitLSTRText()
    self.TextTitle:SetText(LSTR(240060)) -- 仙人仙彩
    self.TextBought:SetText(LSTR(240078)) -- 已购：
    self.TextNoTime:SetText(LSTR(240079)) -- 购买次数耗尽\n请耐心等待开奖
    self.TextBuy:SetText(LSTR(240080)) -- 购 买
    self.TextResidual:SetText(LSTR(240081)) -- 剩余次数：
    self.TextBuff:SetText(LSTR(240082)) -- 购买加成
    self.TextResume:SetText(LSTR(240083)) -- 中奖履历

    
    for i = 1, #self.FText_Grids do
        self.FText_Grids[i]:SetText("")
    end
end

function JumboCactpotNewMainView:OnHide()
    JumboCactpotMgr.bInBuying = false
    if not self.Roll then
        AudioUtil.LoadAndPlayUISound(JumboCactpotDefine.JumboUIAudioPath.StopRandom)
    end
end

function JumboCactpotNewMainView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleGroupInput, self.ChangeItemIsSecelected)
    for index = 0, 9 do
        UIUtil.AddOnClickedEvent(self, self[string.format("%s%d", "FBtn_Key", index)], self.OnNumberBtnClick, index)
    end
    UIUtil.AddOnClickedEvent(self, self.CommCurrency02_1.BtnAdd, self.OnBtnAddXCTicketClicked)
    -- UIUtil.AddOnClickedEvent(self, self.CommCurrency01_1.BtnAdd, self.OnBtnAddJDCoinClicked)

    UIUtil.AddOnClickedEvent(self, self.FBtn_Roll, self.OnRoll)
    UIUtil.AddOnClickedEvent(self, self.BtnBuy, self.OnBuyNumber)
    -- UIUtil.AddOnClickedEvent(self, self.BtnHelp, self.OnFBtnHelpClicked)
    UIUtil.AddOnClickedEvent(self, self.BtnAdd, self.OnBtnAddPurCountClick)
    UIUtil.AddOnClickedEvent(self, self.BtnTips, self.OnFBtnLookDetailsClicked)
    UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnFBtnMaskClicked)

    UIUtil.AddOnClickedEvent(self, self.FBtn_KeyDelete, self.OnFBtnDeleteClicked)
    UIUtil.AddOnClickedEvent(self, self.BtnResume, self.OnBtnLotteryCVClicked)
    UIUtil.AddOnClickedEvent(self, self.BtnBuff, self.OnBtnRewardBonusesClicked)
end

function JumboCactpotNewMainView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.JumboCactpotBuyCallBack, self.RefushBuy)
    self:RegisterGameEvent(EventID.JumboCactpotChangeTogGroup, self.ChangeToggleGroup)
    self:RegisterGameEvent(EventID.JumboCactpotUpdateBouns, self.UpdateRewardBonusPro)

end

function JumboCactpotNewMainView:OnRegisterBinder()
    self:RegisterBinders(JumboCactpotVM, self.Binders)
end

-- --- @type 点击显示通用提示
-- function JumboCactpotNewMainView:OnFBtnHelpClicked()
--     -- TODO 显示通用规则
-- end

--- @type 查看详细剩余次数
function JumboCactpotNewMainView:OnFBtnLookDetailsClicked()
    JumboCactpotMgr:UpdateDetailTipList()
    UIUtil.SetIsVisible(self.PanelResidualTips, true)
    UIUtil.SetIsVisible(self.BtnClick, true, true)

end

--- @type 点击mask提示消失
function JumboCactpotNewMainView:OnFBtnMaskClicked()
    UIUtil.SetIsVisible(self.PanelResidualTips, false)
    UIUtil.SetIsVisible(self.BtnClick, false)
end

-- @type 点击增加购买次数
function JumboCactpotNewMainView:OnBtnAddPurCountClick()
    JumboCactpotMgr:OnBtnAddPurCountClick()
end

--- @type 更新购买号码的列表
function JumboCactpotNewMainView:UpdateBoughtNumVisible()
	local PurchasedNumList = JumboCactpotMgr.PurchasedNumList
	if #PurchasedNumList == 0 then
        UIUtil.SetIsVisible(self.PanelBought, false)
    else
		UIUtil.SetIsVisible(self.PanelBought, true)
    end
end

--- @type 刷新购买列表
function JumboCactpotNewMainView:UpdateBoughtNumList()
    local PurchasedNumList = JumboCactpotMgr.PurchasedNumList
    if #PurchasedNumList > 0 then
        JumboCactpotVM:UpdateList(JumboCactpotVM.BoughtNumberList, PurchasedNumList)
    end
end

function JumboCactpotNewMainView:ChangeItemIsSecelected(Param1, Param2, Index)
    self.SelectedIndex = Index + 1
end

--- 数字按钮对应更改选中item icon
--- @Param Number number 	文件路径数字编号
function JumboCactpotNewMainView:OnNumberBtnClick(Number, ReverseStartTime)
	if nil == self.InputItems[self.SelectedIndex] then
		return
	end
    if JumboCactpotMgr.bInBuying then
        MsgTipsUtil.ShowActiveTips(LSTR(240063)) -- 号码购买中~
        return
    end

    local path = tostring(JumboCactpotDefine.ChangeNumberPath(Number))
    local Time = type(ReverseStartTime) == "number" and ReverseStartTime or 0
	if path then
		UIUtil.ImageSetBrushFromAssetPath(self.InputItems[self.SelectedIndex].IconNumber, path)
		self.InputItems[self.SelectedIndex].number = Number
    end
	self.SelectedIndex = self.SelectedIndex < 4 and self.SelectedIndex + 1 or 4
	self.ToggleGroupInput:SetCheckedIndex(self.SelectedIndex - 1)

    local CanBuy = self:CheckIsCanBuy()
    self:SetBuyBtnEnable(CanBuy)
end

function JumboCactpotNewMainView:CheckIsCanBuy()
    local bCanBuy = true
    local InputItems = self.InputItems
    for _, v in pairs(InputItems) do
        if v.number < 0 then
            bCanBuy = false
            break;
        end
    end
    return bCanBuy
end

--- @type 点击增加仙彩券
function JumboCactpotNewMainView:OnBtnAddXCTicketClicked()
    JumboCactpotMgr:OnBtnAddXCTick()
end

--- @type 点击出现增加金碟币提示
function JumboCactpotNewMainView:OnBtnAddJDCoinClicked()
    -- local ScoreType = ProtoRes.SCORE_TYPE
    -- local JDCoinID = ScoreType.SCORE_TYPE_KING_DEE
    -- local FunDesc = JumboCactpotMgr:GetAccessByID(JDCoinID)
    local Content = LSTR(240056) -- 参与金碟游乐场玩法可获取金碟币
    -- 购买提示
    JumboCactpotMgr:ShowCommTips(LSTR(240014), Content, JumboCactpotMgr.OnGoGetJDCoinCallBack, nil, false)
end


-- Index == nil
-- 正向四个正向播放动画
-- 四个设置数字
-- Index ~= nil
-- 左侧Index正向播放动画
-- 左侧Index设置数字
-- 左侧item动画回调
-- 播放左侧动画
function JumboCactpotNewMainView:AnimTimerItemLeft(Index)
            -- self:PlayAnimation(self.AnimNumChangeEnd)
    if nil ~= Index then
        self:PlayAnimation(self[string.format("%s%d", "AnimNumChange", Index)])
        self.FText_Grids[Index]:SetText(tonumber(self.InputItems[Index].number) or 0)
    else
        for i = 1, 4 do
            self:PlayAnimation(self[string.format("%s%d", "AnimNumChange", i)])
            self.FText_Grids[i]:SetText(tonumber(self.InputItems[i].number) or 0)
        end
    end
end

---@type 点击骰子按钮
function JumboCactpotNewMainView:OnRoll()
    if JumboCactpotMgr.bInBuying then
        MsgTipsUtil.ShowActiveTips(LSTR(240063)) -- 号码购买中~
        return
    end
    if self.Roll then
        self.Roll = false
        local selfInputItems = self.InputItems
        math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 6)))
        for index = 1, 4 do
            selfInputItems[index]:PlayAnimation(selfInputItems[index].AnimRollStart)
            -- self:PlayAnimation(self.AnimNumChangeStart)
            -- self:PlayAnimation(self[string.format("%s%d", "AnimNumChange", index)], 0, 1, _G.UE.EUMGSequencePlayMode.Reverse)
            self:RegisterTimer(self.AnimTimerItemRight, 1, 0, 1, index)
            -- self:RegisterTimer(self.AnimTimerItemLeft, 0.92, 0, 1)
            local RandomNum = math.random(0, 9)
            UIUtil.ImageSetBrushFromAssetPath(
                selfInputItems[index].IconNumber,
                tostring(JumboCactpotDefine.ChangeNumberPath(RandomNum))
            )
            selfInputItems[index].number = RandomNum
            -- for i = 1, #self.FText_Grids do
                -- self.FText_Grids[index]:SetText(tostring(RandomNum))
            -- end
        end
        AudioUtil.LoadAndPlayUISound(JumboCactpotDefine.JumboUIAudioPath.RandomNum)

        self:RegisterTimer(self.OnRollEnd, 1)
    else
        local Str = LSTR(240064) -- 您点击的太快了！
        MsgTipsUtil.ShowTips(Str)
    end
end

function JumboCactpotNewMainView:OnRollEnd()
    self.Roll = true
    AudioUtil.LoadAndPlayUISound(JumboCactpotDefine.JumboUIAudioPath.StopRandom)

    local CanBuy = self:CheckIsCanBuy()
    self:SetBuyBtnEnable(CanBuy)
end

-- 右侧item动画回调
function JumboCactpotNewMainView:AnimTimerItemRight(index)
    self.InputItems[index]:PlayAnimation(self.InputItems[index].AnimRollEnd)
end

--- @type 展示气泡提示
function JumboCactpotNewMainView:ShowExTips()
    local function HideTips()
        UIUtil.SetIsVisible(self.PanelAddTips, false)
    end
    self:RegisterTimer(HideTips, 3, nil, nil, nil)
end

--- @type 刷新时间
function JumboCactpotNewMainView:RefushBuy(ReverseStartTime)
    local DelayTime = 0
    if tonumber(JumboCactpotMgr:GetPurNumLocal()) > 1 then
        self:PlayAnimation(self.AnimAgain)
        AudioUtil.LoadAndPlayUISound(JumboCactpotDefine.JumboUIAudioPath.LottoryPaper) -- 翻动彩票音效
        DelayTime = self.AnimAgain:GetEndTime()
    end
    self:RegisterTimer(self.OnRefushAfterBuy, 0.6)
end

---@type 购买后刷新页面
function JumboCactpotNewMainView:OnRefushAfterBuy()
    self:SetBuyBtnEnable(false)
    self:PlayLeftHighLightAnim()
    local InputItems = self.InputItems
    for i = 1, #InputItems do
        local Num = InputItems[i].number
        self.FText_Grids[i]:SetText(Num)
    end

    local ShowLeftNumTime = 1
    self:RegisterTimer(self.ShowLeftNumByAnim, ShowLeftNumTime, 0, 1, true)

    local function ChangeBoughtNumList()
        self:ResetToggleBtnToDefault()
        local RefrushPurListTime
        if tonumber(JumboCactpotMgr:GetPurNumLocal()) == 1 then
            self:PlayAnimation(self.AnimBoughtIn)
            self:UpdateBoughtNumVisible()
            self:UpdateBoughtNumList()
            RefrushPurListTime = self.AnimBoughtIn:GetEndTime()
        else
            self:PlayAnimation(self.AnimPurchased)
            AudioUtil.LoadAndPlayUISound(JumboCactpotDefine.JumboUIAudioPath.PurEffectAudio)
            RefrushPurListTime = self.AnimPurchased:GetEndTime()
            self:RegisterTimer(function() self:UpdateBoughtNumList() end, RefrushPurListTime)
        end
        JumboCactpotMgr.bInBuying = false
    end
    self:RegisterTimer(ChangeBoughtNumList, ShowLeftNumTime + 1)

    self.SelectedIndex = 1
    if JumboCactpotMgr.RemainPurchases == 0 and #JumboCactpotMgr.PurchasedNumList < 6 then
        self:ShowExTips()
    end
end

---@type 购买按钮
function JumboCactpotNewMainView:OnBuyNumber()
    if JumboCactpotMgr.bInBuying then
        MsgTipsUtil.ShowActiveTips(LSTR(240065)) -- 你购买的太快啦~
        return
    end
    local bSuccess = JumboCactpotMgr:PurchaseLotteryTicket(self.InputItems)
    JumboCactpotMgr.bInBuying = bSuccess
    if bSuccess then
        self:SetBuyBtnEnable(false)
    end
end

--- @type 点击删除按钮
function JumboCactpotNewMainView:OnFBtnDeleteClicked()
    if nil == self.InputItems[self.SelectedIndex] then
        return
    end
    local path = tostring(JumboCactpotDefine.ChangeNumberPath(0))
    if path then
        UIUtil.ImageSetBrushFromAssetPath(self.InputItems[self.SelectedIndex].IconNumber, path)
        self.InputItems[self.SelectedIndex].number = 0
    end
    self.SelectedIndex = self.SelectedIndex > 1 and self.SelectedIndex - 1 or 1
    self.ToggleGroupInput:SetCheckedIndex(self.SelectedIndex - 1)

    local CanBuy = self:CheckIsCanBuy()
    self:SetBuyBtnEnable(CanBuy)
end

function JumboCactpotNewMainView:OnBtnLotteryCVClicked()
    if JumboCactpotMgr.bClickBtnWaitOpen then
        return
    end
    local MaxDataNum = 9
    local MsgBody = {
        Cmd = ProtoCS.FairyColorGameCmd.QueryWinningList,
        WinningList = { Limit = MaxDataNum }
    }
    JumboCactpotMgr:OnSendNetMsg(MsgBody)
    JumboCactpotMgr.bClickBtnWaitOpen = true
end

function JumboCactpotNewMainView:OnBtnRewardBonusesClicked()
    if JumboCactpotMgr.bClickBtnWaitOpen then
        return
    end
    local CurTerm = JumboCactpotMgr.Term
    local MsgBody = {
        Cmd = ProtoCS.FairyColorGameCmd.QueryRewardBonus,
        RewardBonus = { Term = CurTerm }
    }
    JumboCactpotMgr:OnSendNetMsg(MsgBody)
    JumboCactpotMgr.bClickBtnWaitOpen = true
    UIViewMgr:ShowView(UIViewID.JumboCactpotRewardBonusNew)
end

--- @type 点击关闭按钮
function JumboCactpotNewMainView:OnBtnCloseClicked()
    self:Hide()
    if JumboCactpotMgr.bIsBuy then
        local DialogLibID = JumboCactpotDefine.DialogLibID
        local function DialogCallBack()
            local EndKey = 40261
            MsgTipsUtil.ShowTipsByID(EndKey)
            -- local Cfg = SysnoticeCfg:FindCfgByKey(EndKey)
            -- if Cfg ~= nil then
            --     local Content = Cfg.Content[1]
            --     local ShowTime = Cfg.ShowTime
            --     MsgTipsUtil.ShowMissionTips(Content, ShowTime, nil, 10002, nil)
            -- end
            NpcDialogMgr:EndInteraction()
        end
        NpcDialogMgr:PlayDialogLib(DialogLibID.IsBuy, nil, false, DialogCallBack)
    else
        NpcDialogMgr:EndInteraction()
    end
end

--- @type 变换ToggleGroup
function JumboCactpotNewMainView:ChangeToggleGroup(bDisable)
    local Path = JumboCactpotDefine.Path
    local NeedPath
    local bImgEditVisible
    local selfInputItems = self.InputItems
    if bDisable then
        self.ToggleGroupInput:SetIsEnabled(false)
        NeedPath = Path.NoTime
        bImgEditVisible = false

        for index = 1, 4 do
            UIUtil.ImageSetBrushFromAssetPath(selfInputItems[index].IconNumber, NeedPath)
            for i = 1, #self.FText_Grids do
                self.FText_Grids[i]:SetText("")
            end
        end
    else
        self.ToggleGroupInput:SetCheckedIndex(0)
        self.ToggleGroupInput:SetIsEnabled(true)
        -- NeedPath = JumboCactpotDefine.ChangeNumberPath(0)
        bImgEditVisible = true
    end

 

    for i = 1, 4 do
        UIUtil.SetIsVisible(selfInputItems[i].ImgEditing, bImgEditVisible)
    end
end

function JumboCactpotNewMainView:UpdateRewardBonusPro()
    local CurrStage = JumboCactpotMgr.CurrStage
    local CurStagePro = JumboCactpotMgr.CurStagePro

    if CurStagePro == nil then
        CurStagePro = 0
    end
    self.RaidalCDYellow:SetPercent(math.clamp(CurrStage / 7, 0, 1))
    self.RaidalCDWhite:SetPercent(math.clamp(CurStagePro, 0, 1))
end

--- 动画结束统一回调
function JumboCactpotNewMainView:OnAnimationFinished(Animation)
	if Animation == self.AnimIn then
	end
end

function JumboCactpotNewMainView:ResetToggleBtnToDefault()
    local Path = JumboCactpotDefine.Path
    for index = 1, 4 do
        UIUtil.ImageSetBrushFromAssetPath(self.InputItems[index].IconNumber, Path.NoTime)
        self.InputItems[index].number = -1
    end
end

function JumboCactpotNewMainView:ShowLeftNumByAnim(bShow, bImmed)
    local PlayMode = _G.UE.EUMGSequencePlayMode.Reverse
    if bShow then
        PlayMode = _G.UE.EUMGSequencePlayMode.Forward
    end

    local StartTime = 0
    if bImmed == true then -- 通过Timer传过来可能是个数字
        StartTime = self.AnimNumChange1:GetEndTime()
    end

    for i = 1, 4 do
        self:PlayAnimation(self[string.format("AnimNumChange%d", i)], StartTime, 1, PlayMode)
    end
    if bShow then
        AudioUtil.LoadAndPlayUISound(JumboCactpotDefine.JumboUIAudioPath.LotteryBoard)
    end
end

function JumboCactpotNewMainView:PlayLeftHighLightAnim(Animation)
    UIUtil.SetIsVisible(self.EFF_GridsCoverGlow, true)
	for i = 1, 4 do
        self:PlayAnimation(self[string.format("AnimNumChange%dGlow", i)])
    end
end

function JumboCactpotNewMainView:SetBuyBtnEnable(bEnable)
    local NeedPath = IconPath.PurBtnGreyImg
    if bEnable then
        NeedPath = IconPath.PurBtnNormalImg
    end
    local BtnBuy = self.BtnBuy
    UIUtil.ButtonSetBrush(BtnBuy, NeedPath, "Normal")
    UIUtil.ButtonSetBrush(BtnBuy, NeedPath, "Hovered")
    UIUtil.ButtonSetBrush(BtnBuy, NeedPath, "Pressed")
    UIUtil.ButtonSetBrush(BtnBuy, NeedPath, "Disabled")
    -- BtnBuy:SetIsEnabled(bEnable)
end

return JumboCactpotNewMainView