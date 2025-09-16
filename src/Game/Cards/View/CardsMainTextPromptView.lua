---
--- Author: Administrator
--- DateTime: 2023-11-14 10:06
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GameRuleService = require("Game/MagicCard/Module/GameRuleService")
local MagicCardVMUtils = require("Game/MagicCard/MagicCardVMUtils")
local Async = require("Game/MagicCard/Module/AsyncUtils")
local PromptTextCfg = require("TableCfg/FantasyCardPromptTextCfg")
local Utils = require("Game/MagicCard/Module/CommonUtils")
local format = string.format

---@class CardsMainTextPromptView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RootPanel UCanvasPanel
---@field TextPrompt_RivalChoose UFCanvasPanel
---@field Text_TextPrompt_AllOpen URichTextBox
---@field Text_TextPrompt_Ascension URichTextBox
---@field Text_TextPrompt_BlueTurn URichTextBox
---@field Text_TextPrompt_BlueWins URichTextBox
---@field Text_TextPrompt_Chaos URichTextBox
---@field Text_TextPrompt_Combo URichTextBox
---@field Text_TextPrompt_CountDown URichTextBox
---@field Text_TextPrompt_Descension URichTextBox
---@field Text_TextPrompt_Draw URichTextBox
---@field Text_TextPrompt_FallenAce URichTextBox
---@field Text_TextPrompt_Order URichTextBox
---@field Text_TextPrompt_Plus URichTextBox
---@field Text_TextPrompt_RedTurn URichTextBox
---@field Text_TextPrompt_RedWins URichTextBox
---@field Text_TextPrompt_Reverse URichTextBox
---@field Text_TextPrompt_RivalChoose URichTextBox
---@field Text_TextPrompt_Same URichTextBox
---@field Text_TextPrompt_Start URichTextBox
---@field Text_TextPrompt_SuddenDeath URichTextBox
---@field Text_TextPrompt_Swap URichTextBox
---@field Text_TextPrompt_ThreeOpen URichTextBox
---@field AnimRuleText_AllOpen UWidgetAnimation
---@field AnimRuleText_Ascension UWidgetAnimation
---@field AnimRuleText_BlueTurn UWidgetAnimation
---@field AnimRuleText_BlueWins UWidgetAnimation
---@field AnimRuleText_Chaos UWidgetAnimation
---@field AnimRuleText_Combo UWidgetAnimation
---@field AnimRuleText_Descension UWidgetAnimation
---@field AnimRuleText_Draw UWidgetAnimation
---@field AnimRuleText_FallenAce UWidgetAnimation
---@field AnimRuleText_Order UWidgetAnimation
---@field AnimRuleText_Plus UWidgetAnimation
---@field AnimRuleText_RedTurn UWidgetAnimation
---@field AnimRuleText_RedWins UWidgetAnimation
---@field AnimRuleText_Reverse UWidgetAnimation
---@field AnimRuleText_Same UWidgetAnimation
---@field AnimRuleText_Start UWidgetAnimation
---@field AnimRuleText_SuddenDeath UWidgetAnimation
---@field AnimRuleText_Swap UWidgetAnimation
---@field AnimRuleText_ThreeOpen UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsMainTextPromptView = LuaClass(UIView, true)

function CardsMainTextPromptView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.RootPanel = nil
    -- self.TextPromptAllOpen = nil
    -- self.TextPromptAscension = nil
    -- self.TextPromptBlueTurn = nil
    -- self.TextPromptBlueWins = nil
    -- self.TextPromptChaos = nil
    -- self.TextPromptCombo = nil
    -- self.TextPromptDescension = nil
    -- self.TextPromptDraw = nil
    -- self.TextPromptFallenAce = nil
    -- self.TextPromptOrder = nil
    -- self.TextPromptPlus = nil
    -- self.TextPromptRedTurn = nil
    -- self.TextPromptRedWins = nil
    -- self.TextPromptReverse = nil
    -- self.TextPromptSame = nil
    -- self.TextPromptStart = nil
    -- self.TextPromptSuddenDeath = nil
    -- self.TextPromptSwap = nil
    -- self.TextPromptThreeOpen = nil
    -- self.AnimRuleTextAllOpen = nil
    -- self.AnimRuleTextAscension = nil
    -- self.AnimRuleTextBlueTurn = nil
    -- self.AnimRuleTextBlueWins = nil
    -- self.AnimRuleTextChaos = nil
    -- self.AnimRuleTextCombo = nil
    -- self.AnimRuleTextDescension = nil
    -- self.AnimRuleTextDraw = nil
    -- self.AnimRuleTextFallenAce = nil
    -- self.AnimRuleTextOrder = nil
    -- self.AnimRuleTextPlus = nil
    -- self.AnimRuleTextRedTurn = nil
    -- self.AnimRuleTextRedWins = nil
    -- self.AnimRuleTextReverse = nil
    -- self.AnimRuleTextSame = nil
    -- self.AnimRuleTextStart = nil
    -- self.AnimRuleTextSuddenDeath = nil
    -- self.AnimRuleTextSwap = nil
    -- self.AnimRuleTextThreeOpen = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsMainTextPromptView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsMainTextPromptView:OnInit()

end

function CardsMainTextPromptView:OnDestroy()

end

function CardsMainTextPromptView:SetLSTR()
	self.Text_TextPrompt_Start:SetText(_G.LSTR(1130060))--1130060("开始")
    self.Text_TextPrompt_BlueTurn:SetText(_G.LSTR(1130061))--1130061("蓝方出牌")
	self.Text_TextPrompt_RedTurn:SetText(_G.LSTR(1130062))--1130062("红方出牌:")
	self.Text_TextPrompt_BlueWins:SetText(_G.LSTR(1130063))---("蓝方胜利")
	self.Text_TextPrompt_RedWins:SetText(_G.LSTR(1130064))---("红方胜利")
	self.Text_TextPrompt_Draw:SetText(_G.LSTR(1130065))--("不分胜负")
    self.Text_TextPrompt_AllOpen:SetText(_G.LSTR(1130066))--("全明牌")
    self.Text_TextPrompt_ThreeOpen:SetText(_G.LSTR(1130067))--("三明牌")
    self.Text_TextPrompt_Reverse:SetText(_G.LSTR(1130068))--("逆转")
    self.Text_TextPrompt_Chaos:SetText(_G.LSTR(1130069))--("混乱")
    self.Text_TextPrompt_Order:SetText(_G.LSTR(1130070))--("秩序")
    self.Text_TextPrompt_Swap:SetText(_G.LSTR(1130071))--("交换")
    self.Text_TextPrompt_Combo:SetText(_G.LSTR(1130072))--("连携")
    self.Text_TextPrompt_Plus:SetText(_G.LSTR(1130073))--("加算")
    self.Text_TextPrompt_Same:SetText(_G.LSTR(1130074))--("同数")
    self.Text_TextPrompt_FallenAce:SetText(_G.LSTR(1130075))--("王牌杀手")
    self.Text_TextPrompt_Ascension:SetText(_G.LSTR(1130076))--("同类强化")
	self.Text_TextPrompt_Descension:SetText(_G.LSTR(1130077))--("同类弱化")
    self.Text_TextPrompt_SuddenDeath:SetText(_G.LSTR(1130078))--("不胜不休")
    local WaitTipText = MagicCardVMUtils.GetWaitForOpponentText()
    self.Text_TextPrompt_RivalChoose:SetText(WaitTipText)
end

function CardsMainTextPromptView:OnShow()
    self:SetLSTR()
    --UIUtil.SetIsVisible(self.RootPanel, false)
end

function CardsMainTextPromptView:OnHide()

end

function CardsMainTextPromptView:OnRegisterUIEvent()

end

function CardsMainTextPromptView:OnRegisterGameEvent()

end

function CardsMainTextPromptView:OnRegisterBinder()

end

function CardsMainTextPromptView:__PlayByCfg(PromptCfg, Callback)
    local function OnAnimFinished()
        if not _G.UIViewMgr:IsViewVisible(_G.UIViewID.MagicCardMainPanel) then
            return
        end

        if _G.UE.UCommonUtil.IsObjectValid(self) and _G.UE.UCommonUtil.IsObjectValid(self.RootPanel) then
            UIUtil.SetIsVisible(self.RootPanel, false)
        end
        if Callback then
            Callback()
        end
    end

    UIUtil.SetIsVisible(self.RootPanel, true)
    if PromptCfg then
        local _finalTextKey = format("TextPrompt_%s", PromptCfg.KeyText)
        local TextBox = self[_finalTextKey]
        if TextBox then
            TextBox:SetText(PromptCfg.DisplayText)
            _G.FLOG_INFO("播放 Text ，名字是：" .. PromptCfg.DisplayText)
            OnAnimFinished()
            return
        end

        local _finalAnimKey = format("AnimRuleText_%s", PromptCfg.KeyText)
        local Anim = self[_finalAnimKey]
        if Anim then
            Utils.PlayUIAnimation(self, Anim, OnAnimFinished)
            _G.FLOG_INFO("播放 Anim ，名字是：" .. PromptCfg.KeyText)
            return
        else
            _G.FLOG_ERROR("错误，无法播放 Anim，名字是：" .. PromptCfg.KeyText)
        end
    else
        _G.FLOG_ERROR("传入的表格数据为空，请检查")
    end

    OnAnimFinished()
end

function CardsMainTextPromptView:PlayKeyText(KeyText, Callback)
    local _data = PromptTextCfg:FindCfgByKeyText(KeyText)
    if (_data == nil) then
        _G.FLOG_ERROR("无法获取数据，传入的KeyText是 : " .. KeyText)
        if (Callback ~= nil)then
            Callback()
        end
    else
        self:__PlayByCfg(_data, Callback)
    end
end

function CardsMainTextPromptView:PlayRule(Rule, Callback)
    local _data = PromptTextCfg:FindCfgByRule(Rule)
    if (_data == nil) then
        _G.FLOG_ERROR("无法获取数据，传入的 Rule 是 : " .. tostring(Rule))
        if (Callback ~= nil) then
            Callback()
        end
    else
        self:__PlayByCfg(_data, Callback)
    end
end

function CardsMainTextPromptView:UpdateWaitCountdown(CDText)
    self.Text_TextPrompt_CountDown:SetText(CDText)
end

function CardsMainTextPromptView:UpdateWaitText(TipText)
    self.Text_TextPrompt_RivalChoose:SetText(TipText)
end

CardsMainTextPromptView.PlayKeyTextAsyc = Async.Wrap(CardsMainTextPromptView.PlayKeyText)

CardsMainTextPromptView.PlayRuleAsyc = Async.Wrap(CardsMainTextPromptView.PlayRule)

return CardsMainTextPromptView
