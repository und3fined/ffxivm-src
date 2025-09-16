---
--- Author: Administrator
--- DateTime: 2023-11-14 10:03
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MagicCardVMUtils = require("Game/MagicCard/MagicCardVMUtils")
local MagicCardMgr = nil ---@class MagicCardMgr
local TipsUtil = require("Utils/TipsUtil")
local MagicCardTourneyVM = require("Game/MagicCardTourney/VM/MagicCardTourneyVM")
local MagicCardTourneyMgr = _G.MagicCardTourneyMgr
local FVector2D = _G.UE.FVector2D
local UUIUtil = _G.UE.UUIUtil

---@class CardsStageInfoPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnInfo UFButton
---@field BtnRule UFButton
---@field EnemyName URichTextBox
---@field HorizonBoxStage UHorizontalBox
---@field RichTextDesc UTextBlock
---@field RichTextWinStage URichTextBox
---@field RuleTextPanel UFCanvasPanel
---@field TextMate URichTextBox
---@field TextRule URichTextBox
---@field TextStage URichTextBox
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsStageInfoPanelView = LuaClass(UIView, true)

function CardsStageInfoPanelView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.BtnRule = nil
    -- self.EnemyName = nil
    -- self.RichTextDesc = nil
    -- self.RuleTextPanel = nil
    -- self.TextMate = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
    MagicCardMgr = _G.MagicCardMgr
end

function CardsStageInfoPanelView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsStageInfoPanelView:OnInit()

end

function CardsStageInfoPanelView:OnDestroy()

end

function CardsStageInfoPanelView:SetLSTR()
	self.TextMate:SetText(_G.LSTR(1130034))--("对手")
    self.TextRule:SetText(_G.LSTR(1130079))--("规则")
end

function CardsStageInfoPanelView:OnShow()
    self:SetLSTR()
    local OpponentInfo = MagicCardMgr:GetOpponentInfo()
    if OpponentInfo then
        self.EnemyName:SetText(OpponentInfo.Name)
        local _rules = MagicCardVMUtils.GetBrefRulesInGame(true)
        self.RichTextDesc:SetText(_rules)
    end

    -- 处于幻卡大赛时显示阶段信息
    if MagicCardTourneyMgr:GetIsInTourney() == true then
        UIUtil.SetIsVisible(self.HorizonBoxStage, true)
        UIUtil.SetIsVisible(self.RichTextWinStage, true)
        local StageName = MagicCardTourneyVM.CurStageName
        if StageName then
            self.TextStage:SetText(StageName)
        end
        local EffectName = MagicCardTourneyVM.CurEffectName
        local ProgressText = MagicCardTourneyVM.ProgressText
        if EffectName and ProgressText then
            local EffectProgressText =  EffectName..ProgressText
            self.RichTextWinStage:SetText(EffectProgressText)
        end
    end
    
end

function CardsStageInfoPanelView:OnHide()

end

function CardsStageInfoPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnRule, self.OnClickBtnRule)
    UIUtil.AddOnClickedEvent(self, self.BtnInfo, self.OnClickBtnInfo)
end

--显示一下规则详情界面
function CardsStageInfoPanelView:OnClickBtnRule()
    _G.UIViewMgr:ShowView(_G.UIViewID.MagicCardRulePanelView)
end

--显示幻卡大赛阶段详情
function CardsStageInfoPanelView:OnClickBtnInfo()
    local Offset = FVector2D( 0, 0)
	local TargetWidgetSize = UUIUtil.GetLocalSize(self.BtnInfo)
	if self.BtnInfo then
		TargetWidgetSize = UUIUtil.GetLocalSize(self.BtnInfo)
		Offset = FVector2D( - TargetWidgetSize.X, 0)
	end

	local Alignment = FVector2D(0, 0)
	Offset.Y = Offset.Y  + TargetWidgetSize.Y
    Offset.X = Offset.X + TargetWidgetSize.X
    local ContentData = {}
    local Data = {}
    Data.Title = MagicCardTourneyVM.CurStageName
    Data.Content = {}
    table.insert(Data.Content, MagicCardTourneyVM.EffectAndProgressText) --阶段名
    table.insert(Data.Content, MagicCardTourneyVM.CurEffectDesc) --阶段与效果进度
    table.insert(ContentData, Data) --效果说明
	TipsUtil.ShowInfoTitleTips(ContentData, self.BtnInfo, Offset, Alignment, false)
end

function CardsStageInfoPanelView:OnRegisterGameEvent()

end

function CardsStageInfoPanelView:OnRegisterBinder()

end

return CardsStageInfoPanelView
