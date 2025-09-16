---
--- Author: Administrator
--- DateTime: 2023-12-14 10:54
--- Description:
---

local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ProtoRes = require("Protocol/ProtoRes")
local ChocoboDefine = require("Game/Chocobo/ChocoboDefine")
local ChocoboRaceUtil = require("Game/Chocobo/Race/ChocoboRaceUtil")
local ChocoboUiActiontimelineCfg = require("TableCfg/ChocoboUiActiontimelineCfg")

local ChocoboMainVM = nil
local ChocoboMgr = nil
local ChocoboShowModelMgr = nil
local EquipmentMgr = nil
local LSTR = _G.LSTR

---@class ChocoboInfoPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnMount UFButton
---@field BtnReplace UFButton
---@field BtnReplace02 UFButton
---@field BtnSkill UFButton
---@field BtnTItle UFButton
---@field BtnTips UFButton
---@field CommGesture_UIBP CommGestureView
---@field FeatherStage ChocoboFeatherStageItemView
---@field IconSkill UFImage
---@field ImgCD URadialImage
---@field ImgGirlBoy UFImage
---@field NamedSlotChild UNamedSlot
---@field PanelAction UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field ProgBarExp UProgressBar
---@field RichTextExp URichTextBox
---@field ScreenBtn UFButton
---@field TableViewSkill UTableView
---@field TableViewSkill02 UTableView
---@field TableViewSwitchInfo UTableView
---@field TableViewSwitchStar UTableView
---@field Text01 UFTextBlock
---@field Text02 UFTextBlock
---@field Text03 UFTextBlock
---@field TextCD UTextBlock
---@field TextFeather UFTextBlock
---@field TextFeatherNumber UFTextBlock
---@field TextFeatherStage UFTextBlock
---@field TextLevel UFTextBlock
---@field TextLevelNumber UFTextBlock
---@field TextName UFTextBlock
---@field TextTips UFTextBlock
---@field TextTitle UFTextBlock
---@field ToggleButtonSwitch UToggleButton
---@field AnimIn UWidgetAnimation
---@field AnimProBarExpLight UWidgetAnimation
---@field AnimSwitch UWidgetAnimation
---@field AnimTipsIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboInfoPanelView = LuaClass(UIView, true)

function ChocoboInfoPanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnMount = nil
	--self.BtnReplace = nil
	--self.BtnReplace02 = nil
	--self.BtnSkill = nil
	--self.BtnTItle = nil
	--self.BtnTips = nil
	--self.CommGesture_UIBP = nil
	--self.FeatherStage = nil
	--self.IconSkill = nil
	--self.ImgCD = nil
	--self.ImgGirlBoy = nil
	--self.NamedSlotChild = nil
	--self.PanelAction = nil
	--self.PanelTips = nil
	--self.ProgBarExp = nil
	--self.RichTextExp = nil
	--self.ScreenBtn = nil
	--self.TableViewSkill = nil
	--self.TableViewSkill02 = nil
	--self.TableViewSwitchInfo = nil
	--self.TableViewSwitchStar = nil
	--self.Text01 = nil
	--self.Text02 = nil
	--self.Text03 = nil
	--self.TextCD = nil
	--self.TextFeather = nil
	--self.TextFeatherNumber = nil
	--self.TextFeatherStage = nil
	--self.TextLevel = nil
	--self.TextLevelNumber = nil
	--self.TextName = nil
	--self.TextTips = nil
	--self.TextTitle = nil
	--self.ToggleButtonSwitch = nil
	--self.AnimIn = nil
	--self.AnimProBarExpLight = nil
	--self.AnimSwitch = nil
	--self.AnimTipsIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboInfoPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommGesture_UIBP)
	self:AddSubView(self.FeatherStage)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboInfoPanelView:OnInit()
    ChocoboMainVM = _G.ChocoboMainVM
    EquipmentMgr = _G.EquipmentMgr
    ChocoboMgr = _G.ChocoboMgr
    ChocoboShowModelMgr = _G.ChocoboShowModelMgr
    self.InfoPageTextTable = UIAdapterTableView.CreateAdapter(self, self.TableViewSwitchInfo, nil, nil)
    self.InfoPageStarTable = UIAdapterTableView.CreateAdapter(self, self.TableViewSwitchStar, nil, nil)
    self.ActiveSkillVMAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSkill, nil, nil)
    self.PassiveSkillVMAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSkill02, nil, nil)
    self.ActiveSkillVMAdapter:SetOnClickedCallback(self.OnActiveSkillVMAdapterChange)
    self.PassiveSkillVMAdapter:SetOnClickedCallback(self.OnPassiveSkillVMAdapterChange)
end

function ChocoboInfoPanelView:OnDestroy()

end

function ChocoboInfoPanelView:OnShow()
    self:InitConstInfo()
    UIUtil.SetIsVisible(self.PanelAction, false)
    UIUtil.SetIsVisible(self.ScreenBtn, false, false)
    self.ToggleButtonSwitch:SetChecked(ChocoboMainVM.IsShowAttrInfo)
    UIUtil.SetIsVisible(self.TableViewSwitchInfo, ChocoboMainVM.IsShowAttrInfo)
    UIUtil.SetIsVisible(self.TableViewSwitchStar, not ChocoboMainVM.IsShowAttrInfo)

    self:ShowChocoboModelActor()
end

function ChocoboInfoPanelView:InitConstInfo()
    if self.IsInitConstInfo then
        return
    end

    self.IsInitConstInfo = true

    -- LSTR string: 羽力
    self.Text01:SetText(LSTR(420004))
    -- LSTR string: 羽力值
    self.TextFeather:SetText(LSTR(420005))
    -- LSTR string: 羽力赛段
    self.TextFeatherStage:SetText(LSTR(420006))
    -- LSTR string: 属性星级
    self.Text02:SetText(LSTR(420007))
    -- LSTR string: 携带技能
    self.Text03:SetText(LSTR(420008))
    self.TextCD:SetText("")  -- TODO: 按钮CD
end

function ChocoboInfoPanelView:OnActive()
    self:ShowChocoboModelActor()
end

function ChocoboInfoPanelView:OnInactive()
    if self.PlayActionTimerID ~= nil then
        self:UnRegisterTimer(self.PlayActionTimerID)
        self.PlayActionTimerID = nil
    end
end

function ChocoboInfoPanelView:OnHide()
end

function ChocoboInfoPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnMount, self.OnClickBtnMount)
    UIUtil.AddOnClickedEvent(self, self.BtnReplace, self.OnClickBtnChangeRaceChocobo)
    UIUtil.AddOnClickedEvent(self, self.BtnReplace02, self.OnClickBtnArmor)
    UIUtil.AddOnClickedEvent(self, self.BtnSkill, self.OnClickBtnSkill)
    UIUtil.AddOnClickedEvent(self, self.BtnTItle, self.OnClickBtnTitle)
    UIUtil.AddOnClickedEvent(self, self.BtnTips, self.OnClickBtnRankTips)
    UIUtil.AddOnClickedEvent(self, self.ScreenBtn, self.OnClickBtnScreen)
    UIUtil.AddOnStateChangedEvent(self, self.ToggleButtonSwitch, self.OnStateChangedToggleAttr)
end

function ChocoboInfoPanelView:OnRegisterGameEvent()
    --self:RegisterGameEvent(EventID.BuddyEquipmentUpdate, self.OnChocoboModelChange)
    --self:RegisterGameEvent(EventID.BuddyDyeUpdate, self.OnChocoboModelChange)
end

function ChocoboInfoPanelView:OnRegisterBinder()
    self.ChocoboBinders = {
        { "Level", UIBinderSetText.New(self, self.TextLevel) },
        { "Name", UIBinderSetText.New(self, self.TextName) },
        { "Generation", UIBinderSetText.New(self, self.TextLevelNumber) },
        { "GenderPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgGirlBoy) },
        { "ExpSliderValue", UIBinderSetPercent.New(self, self.ProgBarExp) },
        { "ExpSliderValue", UIBinderValueChangedCallback.New(self, nil, self.OnExpProgressChanged) },
        { "ExpText", UIBinderSetText.New(self, self.RichTextExp) },
        { "FeatherValue", UIBinderSetText.New(self, self.TextFeatherNumber) },
        { "FeatherRankText", UIBinderSetText.New(self, self.FeatherStage.TextNumber) },
        { "FeatherLimitText", UIBinderSetText.New(self, self.TextTips) },
        { "FeatherIconPath", UIBinderSetBrushFromAssetPath.New(self, self.FeatherStage.ImgBG) },
        { "ActiveSkillVMList", UIBinderUpdateBindableList.New(self, self.ActiveSkillVMAdapter) },
        { "PassiveSkillVMList", UIBinderUpdateBindableList.New(self, self.PassiveSkillVMAdapter) },
        { "AttrVMList", UIBinderUpdateBindableList.New(self, self.InfoPageTextTable) },
        { "AttrVMList", UIBinderUpdateBindableList.New(self, self.InfoPageStarTable) },
    }

    local PanelBinders = {
        { "CurRaceEntryID", UIBinderValueChangedCallback.New(self, nil, self.OnRaceEntryIDValueChanged) },
    }
    self:RegisterBinders(ChocoboMainVM, PanelBinders)

    local TitleBinders = {
        { "CurTitleText", UIBinderSetText.New(self, self.TextTitle) },
    }
    self:RegisterBinders(ChocoboMainVM:GetTitlePanelVM(), TitleBinders)
end

function ChocoboInfoPanelView:OnRaceEntryIDValueChanged(NewValue, OldValue)
    if nil ~= OldValue and 0 ~= OldValue then
        local ViewModel = ChocoboMainVM:FindChocoboVM(OldValue)
        if nil ~= ViewModel then
            self:UnRegisterBinders(ViewModel, self.ChocoboBinders)
        end
    end

    if nil ~= NewValue and 0 ~= NewValue then
        local ViewModel = ChocoboMainVM:FindChocoboVM(NewValue)
        if nil ~= ViewModel then
            self.ViewModel = ViewModel
            self:RegisterBinders(self.ViewModel, self.ChocoboBinders)
            self.ViewModel:ResetAttrVMList()
            self.ViewModel:ResetSkillVMList()
        end
    end
end

--function ChocoboInfoPanelView:OnChocoboModelChange(Params)
--    if Params.ID == self.ViewModel.ChocoboID then
--        if ChocoboShowModelMgr:IsCreateFinish() then
--            ChocoboShowModelMgr:SetChocoboColor(self.ViewModel.ColorID)
--            ChocoboShowModelMgr:SetChocoboArmor(self.ViewModel.Armor)
--            ChocoboShowModelMgr:UpdateUIChocoboModel()
--        end
--    end
--end

function ChocoboInfoPanelView:ShowChocoboModelActor()
    local CallBack = function(View)
        ChocoboShowModelMgr:ShowMajor(true)
        if View and View.ViewModel then
            ChocoboShowModelMgr:SetChocoboColor(View.ViewModel.ColorID)
            ChocoboShowModelMgr:SetChocoboArmor(View.ViewModel.Armor)
            View:OpenTimerPlayAtl()
        end
        ChocoboShowModelMgr:ResetChocoboModelScale(true)
        ChocoboShowModelMgr:SetModelDefaultPos()
        ChocoboShowModelMgr:UpdateUIChocoboModel()
        ChocoboShowModelMgr:EnableRotator(true)
        --ChocoboShowModelMgr:BindCommGesture(self.CommGesture_UIBP)
    end

    ChocoboShowModelMgr:SetUIType(ProtoRes.CHOCOBO_MODE_SHOW_UI_TYPE.CHOCOBO_MODE_SHOW_UITYPE_INFO)
    if ChocoboShowModelMgr:IsCreateFinish() then
        CallBack(self)
    else
        ChocoboShowModelMgr:CreateModel(self, CallBack)
        ChocoboShowModelMgr:ShowMajor(true)
    end
end

function ChocoboInfoPanelView:OnClickBtnMount()
    UIViewMgr:ShowView(UIViewID.BuddySurfacePanel, { ID = ChocoboMainVM.CurRaceEntryID, FromViewID = UIViewID.ChocoboMainPanelView})
end

function ChocoboInfoPanelView:OnClickBtnChangeRaceChocobo()
    EventMgr:SendEvent(EventID.ChocoboMainTabSelect, { Index = ChocoboDefine.PAGE_INDEX.LIST_PAGE })
end

function ChocoboInfoPanelView:OnClickBtnArmor()
    UIViewMgr:ShowView(UIViewID.BuddySurfacePanel, { ID = ChocoboMainVM.CurRaceEntryID, FromViewID = UIViewID.ChocoboMainPanelView})
end

function ChocoboInfoPanelView:OnClickBtnSkill()
    UIViewMgr:ShowView(UIViewID.ChocoboSkillSideWinView, { ChocoboID = ChocoboMainVM.CurRaceEntryID })
end

function ChocoboInfoPanelView:OnClickBtnTitle()
    UIViewMgr:ShowView(UIViewID.ChocoboTitleWinView)
end

function ChocoboInfoPanelView:OnClickBtnRankTips()
    local bTipsVisible = UIUtil.IsVisible(self.PanelTips)
    UIUtil.SetIsVisible(self.PanelTips, not bTipsVisible)
    self:PlayAnimation(self.AnimTipsIn)
end

function ChocoboInfoPanelView:OnClickBtnScreen()
    _G.SkillTipsMgr:HideChocoboRaceSkillTips()
    UIUtil.SetIsVisible(self.ScreenBtn, false, false)
end

function ChocoboInfoPanelView:OnStateChangedToggleAttr(ToggleButton, State)
    local IsChecked = UIUtil.IsToggleButtonChecked(State)

    if IsChecked then
        -- LSTR string: 属性数值
        self.Text02:SetText(LSTR(420155))
    else
        -- LSTR string: 属性星级
        self.Text02:SetText(LSTR(420156))
    end
    ChocoboMainVM:SetIsShowAttrInfo(IsChecked)
    UIUtil.SetIsVisible(self.TableViewSwitchInfo, IsChecked)
    UIUtil.SetIsVisible(self.TableViewSwitchStar, not IsChecked)

    self:PlayAnimation(self.AnimSwitch)
end

function ChocoboInfoPanelView:OnActiveSkillVMAdapterChange(Index, ItemData, ItemView)
    self.PassiveSkillVMAdapter:CancelSelected()
    if ItemData.SkillID == 0 then
        UIViewMgr:ShowView(UIViewID.ChocoboSkillSideWinView, { ChocoboID = ChocoboMainVM.CurRaceEntryID })
    else
        self.SkillTipsHandleID = ChocoboRaceUtil.ShowSkillTips(ItemData.SkillID, ItemView)
        if self.SkillTipsHandleID then
            UIUtil.SetIsVisible(self.ScreenBtn, true, true)
        end
    end
end

function ChocoboInfoPanelView:OnPassiveSkillVMAdapterChange(Index, ItemData, ItemView)
    self.ActiveSkillVMAdapter:CancelSelected()
    if ItemData.SkillID == 0 then
        UIViewMgr:ShowView(UIViewID.ChocoboSkillSideWinView, { ChocoboID = ChocoboMainVM.CurRaceEntryID })
    else
        self.SkillTipsHandleID = ChocoboRaceUtil.ShowSkillTips(ItemData.SkillID, ItemView)
        if self.SkillTipsHandleID then
            UIUtil.SetIsVisible(self.ScreenBtn, true, true)
        end
    end
end

function ChocoboInfoPanelView:OnExpProgressChanged(NewExpProgress)
    if NewExpProgress <= 0 then
        self:StopAnimationsAndLatentActions(self.AnimProBarExpLight)
    else
        self:PlayAnimationTimeRange(self.AnimProBarExpLight, 0, self.AnimProBarExpLight:GetEndTime() * NewExpProgress, 1, nil, 1.0, false)
    end
end

function ChocoboInfoPanelView:PlayActionTimeline(IsPlayDefault)
    local AllCfg = ChocoboUiActiontimelineCfg:FindAllCfg()
    local MajorCfg = {}
    local ChocoboCfg = {}
    local MajorKey = 1
    local ChocoboKey = 1
    
    for __, Value in ipairs(AllCfg) do
        if Value.PlayerAtlID > 0 then
            table.insert(MajorCfg, Value.PlayerAtlID)
        end
        if Value.ChocoboAtlID > 0 then
            table.insert(ChocoboCfg, Value.ChocoboAtlID)
        end
    end
    
    if #MajorCfg <= 0 or #ChocoboCfg <= 0 then
        return
    end

    if not IsPlayDefault then
        MajorKey = math.random(#MajorCfg)
        ChocoboKey = math.random(#ChocoboCfg)
    end
   
    local MajorAnimComp = ChocoboShowModelMgr:GetMajorAnimComp()
    local ChocoboAnimComp = ChocoboShowModelMgr:GetChocoboAnimComp()

    --主角
    if MajorAnimComp ~= nil then
        MajorAnimComp:PlayActionTimeline(MajorCfg[MajorKey])
    end
    --坐骑
    if ChocoboAnimComp ~= nil then
        ChocoboAnimComp:PlayActionTimeline(ChocoboCfg[ChocoboKey])
    end
end

function ChocoboInfoPanelView:OpenTimerPlayAtl()
    if self.PlayActionTimerID ~= nil then
        self:UnRegisterTimer(self.PlayActionTimerID)
        self.PlayActionTimerID = nil
    end
    --self:PlayActionTimeline(true)
    self.PlayActionTimerID = self:RegisterTimer(self.PlayActionTimeline, 10, 10, 0)
end

return ChocoboInfoPanelView