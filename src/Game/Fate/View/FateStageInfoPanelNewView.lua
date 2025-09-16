---
--- Author: chunfengluo
--- DateTime: 2023-05-16 16:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local FateVM = require("Game/Fate/VM/FateVM")
local FateMgr = require("Game/Fate/FateMgr")
local MainPanelVM = require("Game/Main/MainPanelVM")
local MainPanelConfig = require("Game/Main/MainPanelConfig")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderUpdateCountDown = require("Binder/UIBinderUpdateCountDown")
local UIAdapterCountDown = require("UI/Adapter/UIAdapterCountDown")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local AudioUtil = require("Utils/AudioUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")

local JoinMusicPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_INGAME/Play_UI_mission.Play_UI_mission'"
local LSTR = _G.LSTR
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local HelpTipsID = 11036 -- 帮助按钮弹出对应的ID
local NotBattleJobTipsID = 307101 -- 点击参与或者同步等级时，提示不是战斗职业

---@class FateStageInfoPanelNewView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnFateArchive UFButton
---@field BtnFold UToggleButton
---@field BtnHighrisk UFButton
---@field BtnJoinIn UFButton
---@field BtnTips CommInforBtnView
---@field CommTextSlide CommTextSlideView
---@field ImgArrow UFImage
---@field ImgDown UFImage
---@field ImgFateType UFImage
---@field ImgHighriskBuff UFImage
---@field ImgLevelSync UFImage
---@field ImgUp UFImage
---@field PanelFateArchive UFCanvasPanel
---@field PanelFateNew UFCanvasPanel
---@field PanelHighlight UFCanvasPanel
---@field PanelHighrisk UFCanvasPanel
---@field Paneltips UFCanvasPanel
---@field ProBar UProgressBar
---@field RichTextHighrisk URichTextBox
---@field RichTextHighrisk02 URichTextBox
---@field TextBtn UFTextBlock
---@field TextLevel UFTextBlock
---@field TextProgress UFTextBlock
---@field TextTime UFTextBlock
---@field AnimHighlightIn UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimProgressUpdate UWidgetAnimation
---@field AnimUnfold UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateStageInfoPanelNewView = LuaClass(UIView, true)

function FateStageInfoPanelNewView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnFateArchive = nil
	--self.BtnFold = nil
	--self.BtnHighrisk = nil
	--self.BtnJoinIn = nil
	--self.BtnTips = nil
	--self.CommTextSlide = nil
	--self.ImgArrow = nil
	--self.ImgDown = nil
	--self.ImgFateType = nil
	--self.ImgHighriskBuff = nil
	--self.ImgLevelSync = nil
	--self.ImgUp = nil
	--self.PanelFateArchive = nil
	--self.PanelFateNew = nil
	--self.PanelHighlight = nil
	--self.PanelHighrisk = nil
	--self.Paneltips = nil
	--self.ProBar = nil
	--self.RichTextHighrisk = nil
	--self.RichTextHighrisk02 = nil
	--self.TextBtn = nil
	--self.TextLevel = nil
	--self.TextProgress = nil
	--self.TextTime = nil
	--self.AnimHighlightIn = nil
	--self.AnimIn = nil
	--self.AnimProgressUpdate = nil
	--self.AnimUnfold = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY

    self.bNeedVM = true
end

function FateStageInfoPanelNewView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnTips)
	self:AddSubView(self.CommTextSlide)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateStageInfoPanelNewView:OnPreprocessedMouseButtonDown(MouseEvent)
    if (self.ShowPanelHighrisk == nil or self.ShowPanelHighrisk == false) then
        return
    end
    local MousePosition = UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
    if not UIUtil.IsUnderLocation(self.PanelHighrisk, MousePosition) then
        UIUtil.SetIsVisible(self.PanelHighrisk, false)
        self.ShowPanelHighrisk = false
    end
end

function FateStageInfoPanelNewView:OnInit()
    self.ShowPanelHighrisk = false
    UIUtil.SetIsVisible(self.ImgArrow, false)
    self.LeftTimeAdapterCountDown = UIAdapterCountDown.CreateAdapter(self, self.TextTime, "mm:ss", nil, nil, self.OnTimeUpdateCallback)
    self.BtnTips.HelpInfoID = HelpTipsID

    self.Binders = {
        {"EndTimeMS", UIBinderUpdateCountDown.New(self, self.LeftTimeAdapterCountDown, 0.2, true, true)},
        {"Progress", UIBinderSetPercent.New(self, self.ProBar)},
        {"Level", UIBinderSetText.New(self, self.TextLevel)},
        {"LevelSyncState", UIBinderValueChangedCallback.New(self, nil, self.OnChangeLevelSyncState)},
        {"IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgFateType)},
        {"bIsExpanded", UIBinderValueChangedCallback.New(self, nil, self.OnSetIsExpanded)},
        {"ProgressTitleText", UIBinderSetText.New(self, self.TextProgress)},
        {"TargetName", UIBinderValueChangedCallback.New(self, nil, self.OnTextNameChanged)},
        {"bHighRisk", UIBinderSetIsVisible.New(self, self.ImgArrow)},
        {"bHighRisk", UIBinderSetIsVisible.New(self, self.BtnHighrisk, false, true)},
        {"HighRiskFateTtitle", UIBinderSetText.New(self, self.RichTextHighrisk)},
        {"HighRiskFateDesc", UIBinderSetText.New(self, self.RichTextHighrisk02)},
        {"TipsIconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgHighriskBuff)},
        {"bShowPanelFateArchive", UIBinderSetIsVisible.New(self, self.PanelFateArchive)},
    }
end

function FateStageInfoPanelNewView:OnTimeUpdateCallback(InLeftTime)
    local IntLeftTime = math.floor(InLeftTime)
    _G.FateMgr.CurFateLeftTime = IntLeftTime
    return LocalizationUtil.GetCountdownTime(IntLeftTime, "mm:ss")
end

-- 企鹅拼图那边在用
function FateStageInfoPanelNewView:SetNeedVM(InbNeedVM)
    self.bNeedVM = InbNeedVM
end

function FateStageInfoPanelNewView:OnDestroy()
end

function FateStageInfoPanelNewView:OnShow()
    UIUtil.SetIsVisible(self.Paneltips, false)

end

function FateStageInfoPanelNewView:OnHide()
    self.bNeedVM = true
end

function FateStageInfoPanelNewView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnJoinIn, self.OnClickButtonJoinIn)
    UIUtil.AddOnClickedEvent(self, self.BtnFold, self.OnClickButtonFold)
    UIUtil.AddOnClickedEvent(self, self.BtnFateArchive, self.OnClickBtnFateArchive)
    UIUtil.AddOnClickedEvent(self, self.BtnHighrisk, self.OnBtnHighriskClicked)
end

function FateStageInfoPanelNewView:OnBtnHighriskClicked()
    UIUtil.SetIsVisible(self.PanelHighrisk, true)
    self:PlayAnimation(self.AnimHighriskIn)
    self.ShowPanelHighrisk = true
end

function FateStageInfoPanelNewView:OnClickButtonJoinIn()
    -- 死亡的时候不能操作
    if (MajorUtil.IsMajorDead()) then
        return
    end

    local bIsJoinFate = FateMgr:IsJoinFate()
    if (bIsJoinFate) then
        _G.FLOG_INFO("[FATE] 主动退出了FATE")
        FateMgr:CancelLevelSync()
    else
        -- 新需求，如果角色的职业不是战斗职业，那么提示参加
        -- 当前选中职业类型
        local bIsCombatProf = MajorUtil.GetMajorProfSpecialization() == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT
        if (not bIsCombatProf) then
            _G.MsgTipsUtil.ShowTipsByID(NotBattleJobTipsID) -- 提示 "请切换至战斗职业再参与危命任务"
            return
        end
        AudioUtil.LoadAndPlayUISound(JoinMusicPath)
        FateMgr:RequireJoinFate()
    end
end

function FateStageInfoPanelNewView:OnClickButtonFold()
    if (self.ViewModel ~= nil) then
        self.ViewModel.bIsExpanded = not self.ViewModel.bIsExpanded
    end
end

function FateStageInfoPanelNewView:OnClickBtnFateArchive()
    if (self.ViewModel == nil) then
        _G.FLOG_ERROR("FateStageInfoPanelNewView:OnClickBtnFateArchive() 错误，self.ViewModel 为空，请检查")
        return
    end
    FateMgr:ShowFateArchive(self.ViewModel.FateID)
end

function FateStageInfoPanelNewView:OnSetIsExpanded(bIsExpanded)
    if (bIsExpanded == true) then
        MainPanelVM:SetFunctionVisible(false, MainPanelConfig.TopRightInfoType.FateStageInfo)
        UIUtil.SetIsVisible(self.PanelFateNew, true)
        self.BtnFold:SetIsChecked(false)
        self:PlayAnimation(self.AnimUnfold)
    else
        MainPanelVM:SetFunctionVisible(true, MainPanelConfig.TopRightInfoType.FateStageInfo)
        UIUtil.SetIsVisible(self.PanelFateNew, false)
        self.BtnFold:SetIsChecked(true)
    end
end

function FateStageInfoPanelNewView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
    self:RegisterGameEvent(EventID.SelectMainStageButtonSwitch, self.OnSelectMainStageButtonSwitch)
end

function FateStageInfoPanelNewView:OnSelectMainStageButtonSwitch()
    self:OnSetIsExpanded(false)
end

function FateStageInfoPanelNewView:OnRegisterBinder()
    if (self.ViewModel == nil) then
        self.ViewModel = _G.FateMgr.FateVM.StageInfoVM
    end
    if self.ViewModel ~= nil and self.bNeedVM == true then
        self:RegisterBinders(self.ViewModel, self.Binders)
    end
end

function FateStageInfoPanelNewView:OnTextNameChanged(NewValue, OldValue)
    self.CommTextSlide:ShowSliderText(NewValue)
    self:PlayAnimation(self.AnimProgressUpdate)
end

function FateStageInfoPanelNewView:OnChangeLevelSyncState(Value)
    if Value == FateMgr.ELevelSyncState.NotSynchronized then
        self.TextBtn:SetText(LSTR(190071))
        UIUtil.SetIsVisible(self.PanelHighlight, true)
        self:PlayAnimation(self.AnimHighlightIn)
        UIUtil.SetIsVisible(self.ImgLevelSync, false)
    elseif Value == FateMgr.ELevelSyncState.Synchronized then
        self.TextBtn:SetText(LSTR(190072))
        UIUtil.SetIsVisible(self.PanelHighlight, false)
        UIUtil.SetIsVisible(self.ImgLevelSync, true)
    elseif Value == FateMgr.ELevelSyncState.NotJoin then
        self.TextBtn:SetText(LSTR(190073))
        UIUtil.SetIsVisible(self.PanelHighlight, true)
        UIUtil.SetIsVisible(self.ImgLevelSync, false)
        self:PlayAnimation(self.AnimHighlightIn)
    elseif Value == FateMgr.ELevelSyncState.Join then
        self.TextBtn:SetText(LSTR(190074))
        UIUtil.SetIsVisible(self.PanelHighlight, false)
        UIUtil.SetIsVisible(self.ImgLevelSync, false)
    end
end

return FateStageInfoPanelNewView
