---
--- Author: chriswang
--- DateTime: 2024-07-02 10:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local EventID = require("Define/EventID")
local GatheringLogDefine = require("Game/GatheringLog/GatheringLogDefine")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetCheckedState = require("Binder/UIBinderSetCheckedState")

local GatheringJobPanelVM = require("Game/GatheringJob/GatheringJobPanelVM")
local MainPanelVM = require("Game/Main/MainPanelVM")
local GatherPlaceEffectCfg = require("TableCfg/GatherPlaceEffectCfg")

local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local UIViewID = require("Define/UIViewID")
local MsgTipsID = require("Define/MsgTipsID")
local MajorUtil = require("Utils/MajorUtil")

local USaveMgr
local SaveKey = require("Define/SaveKey")

---@class NewGatheringJobPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose UFButton
---@field CheckBox CommSingleBoxView
---@field GatheringJobBar GatheringJobBarItemView
---@field IconGardener UFImage
---@field IconMining UFImage
---@field ImgNotStarted UFImage
---@field ImgNotStarted2 UFImage
---@field ImgStarting UFImage
---@field ImgStarting2 UFImage
---@field MaterialItem NewGatheringJobMaterialItemView
---@field PanelGathering UFCanvasPanel
---@field PanelList UFCanvasPanel
---@field PanelMain UFCanvasPanel
---@field PanelStatus UFCanvasPanel
---@field PanelStatus2 UFCanvasPanel
---@field RichTextStatus URichTextBox
---@field RichTextStatus2 URichTextBox
---@field TableViewList UTableView
---@field TextModeTips UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimPanelGathering UWidgetAnimation
---@field AnimPanelList UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewGatheringJobPanelView = LuaClass(UIView, true)

function NewGatheringJobPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.CheckBox = nil
	--self.GatheringJobBar = nil
	--self.IconGardener = nil
	--self.IconMining = nil
	--self.ImgNotStarted = nil
	--self.ImgNotStarted2 = nil
	--self.ImgStarting = nil
	--self.ImgStarting2 = nil
	--self.MaterialItem = nil
	--self.PanelGathering = nil
	--self.PanelList = nil
	--self.PanelMain = nil
	--self.PanelStatus = nil
	--self.PanelStatus2 = nil
	--self.RichTextStatus = nil
	--self.RichTextStatus2 = nil
	--self.TableViewList = nil
	--self.TextModeTips = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimPanelGathering = nil
	--self.AnimPanelList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewGatheringJobPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CheckBox)
	self:AddSubView(self.GatheringJobBar)
	self:AddSubView(self.MaterialItem)
	self:AddSubView(self.CrafterTitleItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewGatheringJobPanelView:OnInit()
	USaveMgr = _G.UE.USaveMgr
    self.TableViewGatherNoteAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
end

function NewGatheringJobPanelView:OnDestroy()
    self.AnimOut = nil
end

local LSTR = _G.LSTR
local ConditionName = {
    [ProtoRes.CONDITION_TYPE.CONDITION_TYPE_GATHER_POWER] = LSTR(160056), --"采集力"
    [ProtoRes.CONDITION_TYPE.CONDITION_TYPE_OBTAIN_POWER] = LSTR(160057), --"获得力"
    [ProtoRes.CONDITION_TYPE.CONDITION_TYPE_IDENTIFY_POWER] = LSTR(160058) --"鉴别力"
}

local ConditionAttrID = {
    [ProtoRes.CONDITION_TYPE.CONDITION_TYPE_GATHER_POWER] = ProtoCommon.attr_type.attr_gp,
    [ProtoRes.CONDITION_TYPE.CONDITION_TYPE_OBTAIN_POWER] = ProtoCommon.attr_type.attr_gathering,
    [ProtoRes.CONDITION_TYPE.CONDITION_TYPE_IDENTIFY_POWER] = ProtoCommon.attr_type.attr_perception
}

local EffectTypeConfig = {
    [ProtoRes.EFFECT_TYPE.EFFECT_TYPE_GATHER_COUNT] = {Name = LSTR(160059), TipsID = MsgTipsID.GatherCount}, --"采集次数"
    [ProtoRes.EFFECT_TYPE.EFFECT_TYPE_GATHER_ITEM_NUM] = {Name = LSTR(160060), TipsID = MsgTipsID.GatherItemCount}, --"采集物数量"
    [ProtoRes.EFFECT_TYPE.EFFECT_TYPE_OBTAIN_GATE] = {Name = LSTR(160061), TipsID = MsgTipsID.GatherObtainGate}, --"获得率"
    [ProtoRes.EFFECT_TYPE.EFFECT_TYPE_EXTERN_DROP] = {Name = LSTR(160062), TipsID = MsgTipsID.GatherExternDrop} --"额外掉落概率"
}

function NewGatheringJobPanelView:OnShow()
    self.TextModeTips:SetText(LSTR(160028)) --"简易采集所选道具"
    _G.GatheringLogMgr:SendMsgQueryVersion()
    _G.GatheringLogMgr:SendMsgHistoryListinfo(GatheringLogDefine.GatheringLogNoteType)
    local Value = USaveMgr.GetInt(SaveKey.KeepSimpleGather, -1, true)
    if Value > -1 then
        -- self.CheckBox:SetChecked(true, false)
        GatheringJobPanelVM:SetCheckState(true)
    end
    
    UIUtil.SetIsVisible(self.PanelMain, true)
    if self.Params then
        if self.Params.bAnimIn then
            self:PlayAnimation(self.AnimBarIn)
            print("gather animin")
        else
            self:PlayAnimation(self.AnimBarInImmediate)
            print("gather animin immediate")
        end
    
        GatheringJobPanelVM:OnShow(self.Params.FuncList)
        local BonusMap = self.Params.BonusMap or {}
        local FixBonusID = self.Params.FixBonusID
        local TipList = {}
        for BonusID, BonusValidVal in pairs(BonusMap) do
            local PlaceEffCfg = GatherPlaceEffectCfg:FindCfgByKey(BonusID)

            FLOG_INFO("	====Gather PlaceEffect ID:%d, ValidVal:%d", BonusID, BonusValidVal)

            if PlaceEffCfg then
                -- local Value = GatheringJobPanelVM:GetCondValue(ConditionAttrID[PlaceEffCfg.BonusCond])
                local Tip = nil
                local EffectTypeName = EffectTypeConfig[PlaceEffCfg.BonusType].Name
                --配置了第2条件的   上升型的
                if PlaceEffCfg.BonusCondValMax > 0 then
                    --Cond满足第2条件，必然是发动中的
                    -- if Value >= PlaceEffCfg.BonusCondValMax then
                    if BonusValidVal == 2 then
                        Tip =
                            string.format(
                            LSTR(160063), --'%s%d以上->%s%s（上升型）<span color="#89BD88FF">[发动中]</>'
                            ConditionName[PlaceEffCfg.BonusCond],
                            PlaceEffCfg.BonusCondValMax,
                            EffectTypeName,
                            GatheringJobPanelVM:GetBonusPointStr(PlaceEffCfg.BonusType, PlaceEffCfg.BonusPointMax)
                        )
                    end
                end

                if not Tip then
                    local BonusPointStr =
                        GatheringJobPanelVM:GetBonusPointStr(PlaceEffCfg.BonusType, PlaceEffCfg.BonusPoint)
                    if BonusValidVal >= 1 then
                        Tip =
                            string.format(
                            LSTR(160064), --'%s%d以上->%s%s<span color="#89BD88FF">[发动中]</>'
                            ConditionName[PlaceEffCfg.BonusCond],
                            PlaceEffCfg.BonusCondVal,
                            EffectTypeName,
                            BonusPointStr
                        )
                    else
                        Tip =
                            string.format(
                            LSTR(160065), --'%s%d以上->%s%s<span color="#828282FF">[未发动]</>'
                            ConditionName[PlaceEffCfg.BonusCond],
                            PlaceEffCfg.BonusCondVal,
                            EffectTypeName,
                            BonusPointStr
                        )
                    end
                end

                if BonusValidVal >= 1 then
                    _G.MsgTipsUtil.ShowTipsByID(EffectTypeConfig[PlaceEffCfg.BonusType].TipsID)
                end

                local SortPriority = 100
                if BonusID == FixBonusID then
                    SortPriority = 1
                end
                table.insert(TipList, {Tip = Tip, IsValid = BonusValidVal >= 1, SortPriority = SortPriority})
            end
        end

        local function SetTipBG(NotStartImg, StartingImg, bValid)
            if bValid then
                UIUtil.SetIsVisible(NotStartImg, false)
                UIUtil.SetIsVisible(StartingImg, true)
            else
                UIUtil.SetIsVisible(NotStartImg, true)
                UIUtil.SetIsVisible(StartingImg, false)
            end
        end

        local TipCount = #TipList
        if TipCount == 2 then
            table.sort(
                TipList,
                function(a, b)
                    return a.SortPriority < b.SortPriority
                end
            )
        end

        if TipCount > 0 then
            UIUtil.SetIsVisible(self.PanelStatus, true)
            self.RichTextStatus:SetText(TipList[1].Tip)
            SetTipBG(self.ImgNotStarted, self.ImgStarting, TipList[1].IsValid)

            if TipCount > 1 then
                UIUtil.SetIsVisible(self.PanelStatus2, true)
                self.RichTextStatus2:SetText(TipList[2].Tip)
                SetTipBG(self.ImgNotStarted2, self.ImgStarting2, TipList[2].IsValid)
            else
                UIUtil.SetIsVisible(self.PanelStatus2, false)
            end
        else
            UIUtil.SetIsVisible(self.PanelStatus, false)
            UIUtil.SetIsVisible(self.PanelStatus2, false)
        end
    end

    UIUtil.SetRenderOpacity(self.PanelList, 1)

    self.TopLeftUIVisible = MainPanelVM:GetTopLeftMainTeamPanelVisible()
    if self.TopLeftUIVisible then
        MainPanelVM:SetTopLeftMainTeamPanelVisible(false)
    end
    
    self.TopRightUIVisible = MainPanelVM:GetPanelTopRightVisible()
    if self.TopRightUIVisible then
        MainPanelVM:SetPanelTopRightVisible(false)
    end

    UIUtil.SetIsVisible(self.GatheringJobBar, true)

    local CurGatherEntityID = _G.InteractiveMgr.CurInteractEntityID or 0
    self.GatheringJobBar:RefreshBarViewByEntityID(CurGatherEntityID)

    self.CheckBox:SetIsEnabled(true)
    -- local IconPath = "PaperSprite'/Game/UI/Atlas/GatheringJob/Frames/UI_GatheringJob_Btn_Interrupt_Normal_png.UI_GatheringJob_Btn_Interrupt_Normal_png'"
    -- local DisableIconPath = "PaperSprite'/Game/UI/Atlas/GatheringJob/Frames/UI_GatheringJob_Btn_Interrupt_Disabled_png.UI_GatheringJob_Btn_Interrupt_Disabled_png'"
	-- UIUtil.ImageSetBrushFromAssetPath(self.MaterialItem.IconNormal, IconPath, true)
	-- UIUtil.ImageSetBrushFromAssetPath(self.MaterialItem.IconDisbled, DisableIconPath, true)
    
    self.CrafterTitleItem:SetTitle(GatheringJobPanelVM.SetTextTitle)
    FLOG_INFO("GatherMgr CurInteractEntityID:%d", CurGatherEntityID)
end

function NewGatheringJobPanelView:OnHide(Params)
    if _G.GatherMgr.TopLeftUIVisible then
        MainPanelVM:SetTopLeftMainTeamPanelVisible(true)
    end

    if _G.GatherMgr.TopRightUIVisible then
        MainPanelVM:SetPanelTopRightVisible(true)
    end

    if Params and Params.bAnimOut then  --离开采集状态的隐藏
        self.AnimOut = self.AnimOutAll
        -- self:PlayAnimation(self.AnimOutAll)
    else
        self.AnimOut = self.AnimOutLeft
        -- self:PlayAnimation(self.AnimOutLeft)
    end
    
    GatheringJobPanelVM:ResetUIMode()
end

function NewGatheringJobPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnClose, self.OnBtnCloseClicked)
    -- UIUtil.AddOnClickedEvent(self, self.BtnBreak, self.OnBtnBreakClicked)
    UIUtil.AddOnClickedEvent(self, self.CheckBox.ToggleButton, self.OnBtnCheckBoxClick)
end

function NewGatheringJobPanelView:OnRegisterGameEvent()
    -- self:RegisterGameEvent(EventID.TargetChangeMajor, self.OnGameEventTargetChangeMajor)
    self:RegisterGameEvent(EventID.SkillStart, self.OnSkillStart)
    self:RegisterGameEvent(EventID.SkillEnd, self.OnSkillEnd)
end

function NewGatheringJobPanelView:OnRegisterBinder()
    local Binders = {
        {"ItemVMList", UIBinderUpdateBindableList.New(self, self.TableViewGatherNoteAdapter)},
        {"bGatherItemList", UIBinderSetIsVisible.New(self, self.PanelList)}, --常规采集，显示采集物list
        {"bSimpleGatherPanel", UIBinderSetIsVisible.New(self, self.PanelGathering)}, --简易采集
        -- {"bSimpleGatherStatus", UIBinderSetIsVisible.New(self, self.PanelStatus)},	--简易采集
        {"CheckState", UIBinderSetCheckedState.New(self, self.CheckBox.ToggleButton)},
        {"BreakBtnEnable", UIBinderValueChangedCallback.New(self, nil, self.SetBreakBtnEnable)},
		{ "SetTextTitle", UIBinderValueChangedCallback.New(self, nil, self.OnSetTextTitle) },
    }

    self:RegisterBinders(GatheringJobPanelVM, Binders)

    --子蓝图的绑定
    self.MaterialItem:SetParams({ Data = GatheringJobPanelVM.SimpleGatherItemVM })
end

function NewGatheringJobPanelView:OnSetTextTitle(Title)
    self.CrafterTitleItem:SetTitle(Title)
end

function NewGatheringJobPanelView:OnBtnCloseClicked()
    _G.GatherMgr:TryExitGatherState(self, self.DoClose)
end

function NewGatheringJobPanelView:DoClose()
    if _G.GatherMgr:GetIsSimpleGather() then
        -- _G.MsgTipsUtil.ShowTips(LSTR("正在停止采集，请稍等片刻。"))
        GatheringJobPanelVM:BreakSimpleGather()
    else
    end

    _G.GatherMgr:SetIsMoveExit()
    -- self:Hide()
    -- _G.GatherMgr:SendExitGatherState()
    -- _G.GatherMgr:BackToInteractiveEntrance()
end

function NewGatheringJobPanelView:OnBtnBreakClicked()
    --等本次采集结束，再中断简易采集
    GatheringJobPanelVM:BreakSimpleGather()
end

--ui界面切换 0:忽略 1：切换到常规采集  2：切换到简易采集
function NewGatheringJobPanelView:ShowGatherUIMode(UIMode)
    if UIMode == 1 then
        self:PlayAnimation(self.AnimPanelList)
    elseif UIMode == 2 then
        self:PlayAnimation(self.AnimPanelGathering)
    end
end

function NewGatheringJobPanelView:SetBreakBtnEnable(IsEnable)
    if IsEnable then
        -- self.BtnBreak:SetIsEnabled(true)
        UIUtil.TextBlockSetColorAndOpacityHex(self.TextBreak, "#fffcf1")
    else
        -- self.BtnBreak:SetIsEnabled(false)
        UIUtil.TextBlockSetColorAndOpacityHex(self.TextBreak, "#828282")
    end
end

function NewGatheringJobPanelView:OnBtnCheckBoxClick()
    local IsChecked = self.CheckBox:GetChecked()
    if not IsChecked then
        GatheringJobPanelVM:SetCheckState(false)
        USaveMgr.SetInt(SaveKey.KeepSimpleGather, -1, true)
    else
        USaveMgr.SetInt(SaveKey.KeepSimpleGather, 1, true)
        GatheringJobPanelVM:SetCheckState(true)
    end
end

-- function NewGatheringJobPanelView:OnGameEventTargetChangeMajor(TargetID)
--     self.GatheringJobBar:RefreshBarViewByEntityID(TargetID)
-- end

function NewGatheringJobPanelView:OnSkillStart(Params)
    local EntityID = Params.ULongParam1
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    if EntityID == MajorUtil.GetMajorEntityID() then
        self.CheckBox:SetIsEnabled(false)
    end
end

function NewGatheringJobPanelView:OnSkillEnd(Params)
    local EntityID = Params.ULongParam1
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    if MajorEntityID == EntityID then
        self.CheckBox:SetIsEnabled(true)
    end
end

return NewGatheringJobPanelView