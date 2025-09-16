---
--- Author: Administrator
--- DateTime: 2023-12-14 10:54
--- Description:
---

local EventID = require("Define/EventID")
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local TimeUtil = require("Utils/TimeUtil")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local ProtoRes = require("Protocol/ProtoRes")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local ChocoboDefine = require("Game/Chocobo/ChocoboDefine")
local LocalizationUtil = require("Utils/LocalizationUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ChocoboRaceUtil = require("Game/Chocobo/Race/ChocoboRaceUtil")

local OVERVIEW_FILTER_TYPE = ChocoboDefine.OVERVIEW_FILTER_TYPE
local ChocoboMainVM = nil
local ChocoboMgr = nil
local ChocoboShowModelMgr = nil
local LSTR = nil

---@class ChocoboOverviewPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDefault CommBtnMView
---@field BtnEdit CommBtnMView
---@field BtnEditSkill CommBtnMView
---@field BtnFamilyRelationships UFButton
---@field BtnGO CommBtnMView
---@field BtnGo02 CommBtnMView
---@field BtnInfo CommInforBtnView
---@field BtnMore CommBtnMView
---@field BtnNone CommBtnMView
---@field BtnRealease CommBtnMView
---@field BtnRefresh UFButton
---@field BtnScreener UFButton
---@field CommBackpackEmpty CommBackpackEmptyView
---@field CommGesture_UIBP CommGestureView
---@field CommTabs_UIBP CommTabsView
---@field DropDown CommDropDownListView
---@field DropDownSort CommDropDownListView
---@field FeatherStage ChocoboFeatherStageItemView
---@field HorizontalRent UFHorizontalBox
---@field ImgColor UFImage
---@field ImgGender UFImage
---@field PanelColor UFCanvasPanel
---@field PanelInfo UFCanvasPanel
---@field PanelInfo02 UFCanvasPanel
---@field PanelLeftTop01 UFCanvasPanel
---@field PanelLeftTop02 UFCanvasPanel
---@field PanelName UFCanvasPanel
---@field PanelRIght01 UFCanvasPanel
---@field PanelRIght02 UFCanvasPanel
---@field PanelRoot UFCanvasPanel
---@field PanelStage UFCanvasPanel
---@field ProgBarExp UProgressBar
---@field RichTextBoxTime URichTextBox
---@field RichTextExp URichTextBox
---@field RichTextTime URichTextBox
---@field ScreenBtn UFButton
---@field SingleBoxReach1 CommSingleBoxView
---@field TableViewCarrySkill UTableView
---@field TableViewLeftList UTableView
---@field TableViewList UTableView
---@field TableViewRent UTableView
---@field TableViewSkill UTableView
---@field TableViewSurface UTableView
---@field TextColorName UFTextBlock
---@field TextLevel UFTextBlock
---@field TextLevel02 UFTextBlock
---@field TextName UFTextBlock
---@field TextRent UFTextBlock
---@field TextSkill UFTextBlock
---@field TextSkill02 UFTextBlock
---@field TextSurface UFTextBlock
---@field TextWeather01 UFTextBlock
---@field TextWeather02 UFTextBlock
---@field ToggleButtonCollect UToggleButton
---@field ToggleButtonSwitch UToggleButton
---@field ToggleButtonSwitch02 UToggleButton
---@field ToggleScreener UToggleButton
---@field AnimIn UWidgetAnimation
---@field AnimSwitch UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboOverviewPanelView = LuaClass(UIView, true)

function ChocoboOverviewPanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnDefault = nil
	--self.BtnEdit = nil
	--self.BtnEditSkill = nil
	--self.BtnFamilyRelationships = nil
	--self.BtnGO = nil
	--self.BtnGo02 = nil
	--self.BtnInfo = nil
	--self.BtnMore = nil
	--self.BtnNone = nil
	--self.BtnRealease = nil
	--self.BtnRefresh = nil
	--self.BtnScreener = nil
	--self.CommBackpackEmpty = nil
	--self.CommGesture_UIBP = nil
	--self.CommTabs_UIBP = nil
	--self.DropDown = nil
	--self.DropDownSort = nil
	--self.FeatherStage = nil
	--self.HorizontalRent = nil
	--self.ImgColor = nil
	--self.ImgGender = nil
	--self.PanelColor = nil
	--self.PanelInfo = nil
	--self.PanelInfo02 = nil
	--self.PanelLeftTop01 = nil
	--self.PanelLeftTop02 = nil
	--self.PanelName = nil
	--self.PanelRIght01 = nil
	--self.PanelRIght02 = nil
	--self.PanelRoot = nil
	--self.PanelStage = nil
	--self.ProgBarExp = nil
	--self.RichTextBoxTime = nil
	--self.RichTextExp = nil
	--self.RichTextTime = nil
	--self.ScreenBtn = nil
	--self.SingleBoxReach1 = nil
	--self.TableViewCarrySkill = nil
	--self.TableViewLeftList = nil
	--self.TableViewList = nil
	--self.TableViewRent = nil
	--self.TableViewSkill = nil
	--self.TableViewSurface = nil
	--self.TextColorName = nil
	--self.TextLevel = nil
	--self.TextLevel02 = nil
	--self.TextName = nil
	--self.TextRent = nil
	--self.TextSkill = nil
	--self.TextSkill02 = nil
	--self.TextSurface = nil
	--self.TextWeather01 = nil
	--self.TextWeather02 = nil
	--self.ToggleButtonCollect = nil
	--self.ToggleButtonSwitch = nil
	--self.ToggleButtonSwitch02 = nil
	--self.ToggleScreener = nil
	--self.AnimIn = nil
	--self.AnimSwitch = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboOverviewPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnDefault)
	self:AddSubView(self.BtnEdit)
	self:AddSubView(self.BtnEditSkill)
	self:AddSubView(self.BtnGO)
	self:AddSubView(self.BtnGo02)
	self:AddSubView(self.BtnInfo)
	self:AddSubView(self.BtnMore)
	self:AddSubView(self.BtnNone)
	self:AddSubView(self.BtnRealease)
	self:AddSubView(self.CommBackpackEmpty)
	self:AddSubView(self.CommGesture_UIBP)
	self:AddSubView(self.CommTabs_UIBP)
	self:AddSubView(self.DropDown)
	self:AddSubView(self.DropDownSort)
	self:AddSubView(self.FeatherStage)
	self:AddSubView(self.SingleBoxReach1)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboOverviewPanelView:OnInit()
    ChocoboMgr = _G.ChocoboMgr
    ChocoboShowModelMgr = _G.ChocoboShowModelMgr
    ChocoboMainVM = _G.ChocoboMainVM
    LSTR = _G.LSTR
    self.MatingTimer = nil
    self.SelectIndex = 1
    self.OverviewAttrList = UIAdapterTableView.CreateAdapter(self, self.TableViewList, nil, nil)
    self.OverviewRentAttrList = UIAdapterTableView.CreateAdapter(self, self.TableViewRent, nil, nil)
    self.ShowChocoboVMAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewLeftList, nil, true)
    self.ActiveSkillVMAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSkill, nil, nil)
    self.PassiveSkillVMAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewCarrySkill, nil, nil)
    self.ArmorVMAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSurface, nil, nil)

    self.ShowChocoboVMAdapter:SetOnSelectChangedCallback(self.OnChocoboItemChange)
    self.ActiveSkillVMAdapter:SetOnClickedCallback(self.OnActiveSkillVMAdapterChange)
    self.PassiveSkillVMAdapter:SetOnClickedCallback(self.OnPassiveSkillVMAdapterChange)
end

function ChocoboOverviewPanelView:OnDestroy()

end

function ChocoboOverviewPanelView:OnShow()
    self:InitConstInfo()
    UIUtil.SetIsVisible(self.ScreenBtn, false, false)
    self.BtnNone:SetIsNormalState(true)
    self.BtnMore:SetIsNormalState(true)

    local TabList = {}
    -- LSTR string: 详情
    table.insert(TabList, {Name = LSTR(420013)})
    -- LSTR string: 编辑
    table.insert(TabList, {Name = LSTR(420014)})
    self.CommTabs_UIBP:UpdateItems(TabList, 1)
    
    ChocoboMainVM:InitOverviewChocoboList()
    self.BtnState = 1
    self.SelectIndex = ChocoboMainVM:GetSelectedIndex()
    local Types = ChocoboDefine.OVERVIEW_FILTER_TYPE
    local FilterTypes = { Types.LEVEL, Types.FEATHER_VALUE, Types.MAX_SPEED, Types.SPRINT_SPEED, Types.ACCELERATION, Types.STAMINA, Types.SKILL_STRENGTH }
    local FilterTypeList = {}
    for Index, FilterType in ipairs(FilterTypes) do
        FilterTypeList[Index] = {}
        FilterTypeList[Index].Name = ChocoboDefine.OVERVIEW_FILTER_TYPE_NAME[FilterType]
    end
    self.DropDown:UpdateItems(FilterTypeList, 1)

    ChocoboMainVM:FilterShowChocoboVMList()
    self.ShowChocoboVMAdapter:ScrollToIndex(self.SelectIndex)
    self.ShowChocoboVMAdapter:SetSelectedIndex(self.SelectIndex)
    self:ShowChocoboModelActor()
end

function ChocoboOverviewPanelView:InitConstInfo()
    if self.IsInitConstInfo then
        return
    end

    self.IsInitConstInfo = true

    -- LSTR string: 羽力值
    self.TextWeather01:SetText(LSTR(420005))
    -- LSTR string: 租借陆行鸟
    self.TextRent:SetText(LSTR(420034))
    -- LSTR string: 主动技能
    self.TextSkill:SetText(LSTR(420136))
    -- LSTR string: 被动技能
    self.TextSkill02:SetText(LSTR(420137))
    -- LSTR string: 外观
    self.TextSurface:SetText(LSTR(420138))
    -- LSTR string: 编辑外观
    self.BtnEdit:SetText(LSTR(420139))
    -- LSTR string: 配置技能
    self.BtnEditSkill:SetText(LSTR(420140))
    -- LSTR string: 放  生
    self.BtnRealease:SetText(LSTR(420141))
    -- LSTR string: 不再租借
    self.BtnNone:SetText(LSTR(420151))
    -- LSTR string: 租借更多
    self.BtnMore:SetText(LSTR(420152))

    self.CommBackpackEmpty:SetTipsContent(LSTR(420166))
end

function ChocoboOverviewPanelView:OnActive()
    if self.ShowChocoboVMAdapter then
        self.ShowChocoboVMAdapter:ScrollToIndex(self.SelectIndex)
        self.ShowChocoboVMAdapter:SetSelectedIndex(self.SelectIndex)
    end
    self:ShowChocoboModelActor()
end

function ChocoboOverviewPanelView:OnHide()
    self:CloseMatingTimer()
    ChocoboMainVM:ChangeOverviewData()
    ChocoboShowModelMgr:ShowChocobo(true)
end

function ChocoboOverviewPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnDefault, self.OnClickBtnDefault)
    UIUtil.AddOnClickedEvent(self, self.BtnEdit, self.OnClickBtnEdit)
    UIUtil.AddOnClickedEvent(self, self.BtnEditSkill, self.OnClickBtnEditSkill)
    UIUtil.AddOnClickedEvent(self, self.BtnGO, self.OnClickBtnGO)
    UIUtil.AddOnClickedEvent(self, self.BtnGo02, self.OnClickBtnGO)
    UIUtil.AddOnClickedEvent(self, self.BtnMore, self.OnClickBtnMore)
    UIUtil.AddOnClickedEvent(self, self.BtnNone, self.OnClickBtnNone)
    UIUtil.AddOnClickedEvent(self, self.BtnRealease, self.OnClickBtnRealease)
    UIUtil.AddOnClickedEvent(self, self.BtnRefresh, self.OnClickBtnRefresh)
    UIUtil.AddOnClickedEvent(self, self.BtnScreener, self.OnClickBtnScreener)
    UIUtil.AddOnClickedEvent(self, self.BtnFamilyRelationships, self.OnClickBtnFamily)
    UIUtil.AddOnClickedEvent(self, self.ScreenBtn, self.OnClickBtnScreen)

    self.CommTabs_UIBP:SetCallBack(self, self.OnStateChangedToggleGroup)
    UIUtil.AddOnSelectionChangedEvent(self, self.DropDown, self.OnSelectionChangedDropDownList)
    UIUtil.AddOnStateChangedEvent(self, self.ToggleButtonCollect, self.ToggleButtonCollectClick)
    UIUtil.AddOnStateChangedEvent(self, self.ToggleButtonSwitch, self.ToggleButtonSwitchClick)
    UIUtil.AddOnStateChangedEvent(self, self.ToggleButtonSwitch02, self.ToggleButtonSwitch02Click)
end

function ChocoboOverviewPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.ChocoboFree, self.OnGameEventChocoboFree)
    self:RegisterGameEvent(EventID.ChocoboOverviewItemSelect, self.OnChocoboOverviewItemSelect)
    --self:RegisterGameEvent(EventID.BuddyDyeUpdate, self.OnChocoboModelChange)
end

function ChocoboOverviewPanelView:OnRegisterBinder()
    self.ChocoboBinders = {
        { "Name", UIBinderSetText.New(self, self.TextName) },
        { "Generation", UIBinderSetText.New(self, self.TextLevel) },
        { "GenderPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgGender) },
        { "ExpSliderValue", UIBinderSetPercent.New(self, self.ProgBarExp) },
        { "LevelText", UIBinderSetText.New(self, self.TextLevel02) },
        { "ExpText", UIBinderSetText.New(self, self.RichTextExp) },
        { "FeatherValue", UIBinderSetText.New(self, self.TextWeather02) },

        { "IsRent", UIBinderValueChangedCallback.New(self, nil, self.IsRentChanged)},

        { "FeatherRankText", UIBinderSetText.New(self, self.FeatherStage.TextNumber) },
        { "FeatherIconPath", UIBinderSetBrushFromAssetPath.New(self, self.FeatherStage.ImgBG) },
        { "IsLike", UIBinderSetIsChecked.New(self, self.ToggleButtonCollect) },
        { "IsRent", UIBinderSetIsVisible.New(self, self.ToggleButtonCollect, true, true) },
        { "IsRacer", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedIsRacer) },

        { "ActiveSkillVMList", UIBinderUpdateBindableList.New(self, self.ActiveSkillVMAdapter) },
        { "PassiveSkillVMList", UIBinderUpdateBindableList.New(self, self.PassiveSkillVMAdapter) },
        { "ArmorVMList", UIBinderUpdateBindableList.New(self, self.ArmorVMAdapter) },
        { "RemainCountText", UIBinderSetText.New(self, self.RichTextTime) },
        { "RemainCountText", UIBinderSetText.New(self, self.RichTextBoxTime) },
        { "ColorName", UIBinderSetText.New(self, self.TextColorName) },
        { "Color", UIBinderSetColorAndOpacity.New(self, self.ImgColor) },
    }

    local PanelBinders = {
        { "CurSelectEntryID", UIBinderValueChangedCallback.New(self, nil, self.OnSelectEntryIDValueChanged) },
        { "ShowChocoboVMList", UIBinderUpdateBindableList.New(self, self.ShowChocoboVMAdapter) },
        { "IsShowSimpleAttrMode", UIBinderSetIsChecked.New(self, self.ToggleButtonSwitch) },
        { "IsMating", UIBinderValueChangedCallback.New(self, nil, self.OnStatusValueChanged) },
        { "OverviewAttrVMList", UIBinderUpdateBindableList.New(self, self.OverviewRentAttrList) },
        { "OverviewAttrVMList", UIBinderUpdateBindableList.New(self, self.OverviewAttrList) },
        { "IsChocoboVMListNotEmpty", UIBinderValueChangedCallback.New(self, nil, self.OnChocoboVMListEmpty) },
        { "ScreenerState", UIBinderSetIsChecked.New(self, self.ToggleScreener) },
    }
    self:RegisterBinders(ChocoboMainVM, PanelBinders)
end

function ChocoboOverviewPanelView:OnChocoboVMListEmpty(NewValue, OldValue)
    UIUtil.SetIsVisible(self.PanelRoot, NewValue)
    UIUtil.SetIsVisible(self.CommBackpackEmpty, not NewValue)
    ChocoboShowModelMgr:ShowChocobo(NewValue)
end

function ChocoboOverviewPanelView:OnSelectEntryIDValueChanged(NewValue, OldValue)
    if nil ~= OldValue then
        local ViewModel = ChocoboMainVM:FindChocoboVM(OldValue)
        if nil ~= ViewModel then
            self:UnRegisterBinders(ViewModel, self.ChocoboBinders)
        end
    end

    if nil ~= NewValue then
        local ViewModel = ChocoboMainVM:FindChocoboVM(NewValue)
        if nil ~= ViewModel then
            self.ViewModel = ViewModel
            self:RegisterBinders(ViewModel, self.ChocoboBinders)
            -- ViewModel:ResetAttrVMList()
            ViewModel:ResetSkillVMList()
            ViewModel:ResetArmorVMList()
            self:UpdateColorTips()
        end
    end
end

function ChocoboOverviewPanelView:ShowChocoboModelActor()
    local CallBack = function(View)
        ChocoboShowModelMgr:ShowMajor(false)
        if View and View.ViewModel then
            ChocoboShowModelMgr:SetChocoboColor(View.ViewModel.ColorID)
            ChocoboShowModelMgr:SetChocoboArmor(View.ViewModel.Armor)
        end
        ChocoboShowModelMgr:ResetChocoboModelScale()
        ChocoboShowModelMgr:SetModelDefaultPos()
        ChocoboShowModelMgr:UpdateUIChocoboModel()
        ChocoboShowModelMgr:EnableRotator(true)
        --ChocoboShowModelMgr:BindCommGesture(self.CommGesture_UIBP)
    end

    ChocoboShowModelMgr:SetUIType(ProtoRes.CHOCOBO_MODE_SHOW_UI_TYPE.CHOCOBO_MODE_SHOW_UITYPE_OVERVIEW)
    if ChocoboShowModelMgr:IsCreateFinish() then
        CallBack(self)
    else
        ChocoboShowModelMgr:CreateModel(self, CallBack)
        ChocoboShowModelMgr:ShowMajor(false)
    end
end

function ChocoboOverviewPanelView:OnGameEventChocoboFree()
    if self.ShowChocoboVMAdapter:GetItemDataByIndex(self.SelectIndex) == nil then
        self.SelectIndex = 1
    end

    self.ShowChocoboVMAdapter:ScrollToIndex(self.SelectIndex)
    self.ShowChocoboVMAdapter:SetSelectedIndex(self.SelectIndex)
end

function ChocoboOverviewPanelView:IsRentChanged(NewValue)
    UIUtil.SetIsVisible(self.PanelRIght01, not NewValue)
    UIUtil.SetIsVisible(self.PanelRIght02, NewValue)
    UIUtil.SetIsVisible(self.ToggleButtonSwitch02, not NewValue)
end

function ChocoboOverviewPanelView:OnStatusValueChanged()
    local VM = ChocoboMainVM:FindChocoboVM(ChocoboMainVM.CurSelectEntryID)
    if VM == nil then
        return
    end

    --if VM.Status == ProtoCS.ChocoboStatus.StatusMating then 
    if ChocoboMainVM:IsMatingStatus() then
        self.BtnState = 0
        -- LSTR string: 配种占用
        self.BtnGo:SetButtonText(LSTR(420062))
        --self.BtnGo:SetIsEnabled(false, false)
        self.BtnGo:SetIsDisabledState(true, false)
        -- LSTR string: 配种占用
        self.BtnGo02:SetButtonText(LSTR(420062))
        --self.BtnGo02:SetIsEnabled(false, false)
        self.BtnGo02:SetIsDisabledState(true, false)

        self:CloseMatingTimer()
        self.MatingTimer = self:RegisterTimer(self.CountDownMatingTimer, 0, 0.1, -1)
    end
end

function ChocoboOverviewPanelView:OnChocoboOverviewItemSelect(Index)
    self.SelectIndex = Index
    self.ShowChocoboVMAdapter:ScrollToIndex(self.SelectIndex)
    self.ShowChocoboVMAdapter:SetSelectedIndex(self.SelectIndex)
end

function ChocoboOverviewPanelView:OnChocoboItemChange(Index, ItemData, ItemView, IsByClick)
    self.SelectIndex = Index
    local VM = ChocoboMainVM:FindChocoboVM(ItemData.ChocoboID)
    if VM == nil then return end
    
    ChocoboMainVM:ChangeOverviewSelectID(ItemData.ChocoboID)
    ChocoboMainVM:ChangeOverviewData(VM)
    if ChocoboShowModelMgr:IsCreateFinish() then
        ChocoboShowModelMgr:SetChocoboColor(self.ViewModel.ColorID)
        ChocoboShowModelMgr:SetChocoboArmor(self.ViewModel.Armor)
        ChocoboShowModelMgr:UpdateUIChocoboModel()
    end

    --if VM.Status == ProtoCS.ChocoboStatus.StatusMating then
    if ChocoboMainVM:IsMatingStatus() then
        self.BtnState = 0
        -- LSTR string: 配种占用
        self.BtnGo:SetButtonText(LSTR(420062))
        --self.BtnGo:SetIsEnabled(false, false)
        self.BtnGo:SetIsDisabledState(true, false)
        -- LSTR string: 配种占用
        self.BtnGo02:SetButtonText(LSTR(420062))
        --self.BtnGo02:SetIsEnabled(false, false)
        self.BtnGo02:SetIsDisabledState(true, false)

        self:CloseMatingTimer()
        self.MatingTimer = self:RegisterTimer(self.CountDownMatingTimer, 0, 0.1, -1)
    else
        self.BtnState = 1
        -- LSTR string: 前往配种
        self.BtnGo:SetButtonText(LSTR(420063))
        -- LSTR string: 前往配种
        self.BtnGo02:SetButtonText(LSTR(420063))
        -- LSTR string: 可配种次数 %d
        local Color = "#d5d5d5"
        if VM.RemainCount <= 0 then
            Color = "#dc5868"
        end
        local Str = string.format("<span color=\"%s\">%s</>", Color, tostring(VM.RemainCount))
        VM.RemainCountText = string.format(LSTR(420185), Str)

        local bSetGray = false
        local IsChocoboOpen = _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDChocobo)
        if not IsChocoboOpen then
            bSetGray = true
        end
        
        if VM.RemainCount < 1 then
            bSetGray = true
        end

        if not VM.IsRent and VM.Level < ChocoboMgr.MatingLevel then
            self.BtnGo:SetButtonText(string.format(LSTR(420184), tostring(ChocoboMgr.MatingLevel)))
            self.BtnGo02:SetButtonText(string.format(LSTR(420184), tostring(ChocoboMgr.MatingLevel)))
            bSetGray = true
        end

        local MatesChocoboVM = ChocoboMainVM:FindMatesChocoboVM(ItemData.ChocoboID)
        if MatesChocoboVM == nil then
            bSetGray = true
        end

        if bSetGray then
            --self.BtnGo:SetIsEnabled(false, true)
            self.BtnGo:SetIsDisabledState(true, true)
            --self.BtnGo02:SetIsEnabled(false, true)
            self.BtnGo02:SetIsDisabledState(true, true)
        else
            --self.BtnGo:SetIsEnabled(true, true)
            self.BtnGo:SetIsNormalState(true)
            --self.BtnGo02:SetIsEnabled(true, true)
            self.BtnGo02:SetIsNormalState(true)
        end
    end
    _G.ObjectMgr:CollectGarbage(false)
end

function ChocoboOverviewPanelView:CloseMatingTimer()
    if self.MatingTimer ~= nil then
        self:UnRegisterTimer(self.MatingTimer)
        self.MatingTimer = nil
    end
end

function ChocoboOverviewPanelView:CountDownMatingTimer()
    if not ChocoboMainVM:IsMatingStatus() then
        return
    end

    local VM = ChocoboMainVM:FindChocoboVM(ChocoboMainVM.CurSelectEntryID)
    if VM == nil then
        return
    end

    local CurrentTime = TimeUtil.GetServerLogicTime()
    local MatingEndTime = ChocoboMainVM.MatingTime + ChocoboMgr.MatingNeedTime
    if CurrentTime >= MatingEndTime then
        self.BtnState = 2
        -- LSTR string: 前往领取
        self.BtnGo:SetButtonText(LSTR(420065))
        --self.BtnGo:SetIsEnabled(true, true)
        self.BtnGo:SetIsNormalState(true)
        -- LSTR string: 前往领取
        self.BtnGo02:SetButtonText(LSTR(420065))
        --self.BtnGo02:SetIsEnabled(true, true)
        self.BtnGo02:SetIsNormalState(true)
        -- LSTR string: 可领取幼鸟
        VM.RemainCountText = LSTR(420066)
        self:CloseMatingTimer()
        return
    end

    local RemainSec = MatingEndTime - CurrentTime
    --local ReaminMin = math.floor(RemainSec / 60)
    --local NeedSec = math.floor(RemainSec % 60)
    VM.RemainCountText = LocalizationUtil.GetCountdownTimeForShortTime(RemainSec, "hh:mm:ss") or ""
end

--function ChocoboOverviewPanelView:OnChocoboModelChange(Params)
--    if Params.ID == self.ViewModel.ChocoboID then
--        if ChocoboShowModelMgr:IsCreateFinish() then
--            ChocoboShowModelMgr:SetChocoboColor(self.ViewModel.ColorID)
--            ChocoboShowModelMgr:SetChocoboArmor(self.ViewModel.Armor)
--            ChocoboShowModelMgr:UpdateUIChocoboModel()
--        end
--    end
--end

function ChocoboOverviewPanelView:OnActiveSkillVMAdapterChange(Index, ItemData, ItemView, IsByClick)
    self.PassiveSkillVMAdapter:CancelSelected()
    if ItemData.SkillID == 0 then
        UIViewMgr:ShowView(UIViewID.ChocoboSkillSideWinView, { ChocoboID = ChocoboMainVM.CurSelectEntryID })
    else
        self.SkillTipsHandleID = ChocoboRaceUtil.ShowSkillTips(ItemData.SkillID, ItemView)
        if self.SkillTipsHandleID then
            UIUtil.SetIsVisible(self.ScreenBtn, true, true)
        end
    end
end

function ChocoboOverviewPanelView:OnPassiveSkillVMAdapterChange(Index, ItemData, ItemView, IsByClick)
    self.ActiveSkillVMAdapter:CancelSelected()
    if ItemData.SkillID == 0 then
        UIViewMgr:ShowView(UIViewID.ChocoboSkillSideWinView, { ChocoboID = ChocoboMainVM.CurSelectEntryID })
    else
        self.SkillTipsHandleID = ChocoboRaceUtil.ShowSkillTips(ItemData.SkillID, ItemView)
        if self.SkillTipsHandleID then
            UIUtil.SetIsVisible(self.ScreenBtn, true, true)
        end
    end
end

function ChocoboOverviewPanelView:OnClickBtnScreen()
    _G.SkillTipsMgr:HideChocoboRaceSkillTips()
    UIUtil.SetIsVisible(self.ScreenBtn, false, false)
end

function ChocoboOverviewPanelView:OnSelectionChangedDropDownList(Index)
    local FilterType = { OVERVIEW_FILTER_TYPE.LEVEL, OVERVIEW_FILTER_TYPE.FEATHER_VALUE, OVERVIEW_FILTER_TYPE.MAX_SPEED, OVERVIEW_FILTER_TYPE.SPRINT_SPEED,
                         OVERVIEW_FILTER_TYPE.ACCELERATION, OVERVIEW_FILTER_TYPE.STAMINA, OVERVIEW_FILTER_TYPE.SKILL_STRENGTH}
    ChocoboMainVM:SetCurFilterType(FilterType[Index])
end

function ChocoboOverviewPanelView:OnClickBtnDefault()
    --ChocoboMainVM:ChangeRaceEntryVM(ChocoboMainVM.CurSelectEntryID)
    ChocoboMgr:ReqOut(ChocoboMainVM.CurSelectEntryID, true)
end

function ChocoboOverviewPanelView:OnClickBtnEdit()
    UIViewMgr:ShowView(UIViewID.BuddySurfacePanel, { ID = ChocoboMainVM.CurSelectEntryID, FromViewID = UIViewID.ChocoboMainPanelView })
end

function ChocoboOverviewPanelView:OnClickBtnEditSkill()
    UIViewMgr:ShowView(UIViewID.ChocoboSkillSideWinView, { ChocoboID = ChocoboMainVM.CurSelectEntryID })
end


function ChocoboOverviewPanelView:OnClickBtnGO()
    if self.BtnState == 1 then
        --ChocoboMgr:OpenChocoboTransferPanel(true)
        ----UIViewMgr:HideView(UIViewID.ChocoboMainPanelView)
        ----ChocoboMgr:OpenChocoboBreedPanel({SelectIndex=self.SelectIndex})
        if not self.ViewModel then
            return
        end

        local IsChocoboOpen = _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDChocobo)
        if not IsChocoboOpen then
            --配种功能未解锁，需拥有30级竞赛陆行鸟后完成任务解锁
            MsgTipsUtil.ShowTips(LSTR(420181))
            return
        end

        if self.ViewModel.RemainCount < 1 then
            -- LSTR string: 陆行鸟配种次数不足
            MsgTipsUtil.ShowTips(LSTR(420093))
            return
        end

        if not self.ViewModel.IsRent and self.ViewModel.Level < ChocoboMgr.MatingLevel then
            -- LSTR string: 陆行鸟等级不足，不能配种
            MsgTipsUtil.ShowTips(LSTR(420094))
            return
        end

        local MatesChocoboVM = ChocoboMainVM:FindMatesChocoboVM(self.ViewModel.ChocoboID)
        if MatesChocoboVM == nil then
            -- LSTR string: 没有符合条件的陆行鸟
            MsgTipsUtil.ShowTips(LSTR(420096))
            return
        end

        ChocoboMgr:OpenChocoboTransferPanel()
    elseif self.BtnState == 2 then
        ChocoboMgr:OpenChocoboTransferPanel(false)
        --UIViewMgr:HideView(UIViewID.ChocoboMainPanelView)
    end
end

function ChocoboOverviewPanelView:OnClickBtnMore()
    UIViewMgr:ShowView(UIViewID.ChocoboBorrowPanelView, { FromViewID = UIViewID.ChocoboMainPanelView })
end

function ChocoboOverviewPanelView:OnClickBtnNone()
    local function CallBack()
        _G.ChocoboMgr:ReqRent(0, _G.ChocoboMainVM.CurSelectEntryID, 0, 0)
    end

    -- LSTR string: 陆行鸟不再租借
    MsgBoxUtil.ShowMsgBoxTwoOp(self, _G.LSTR(420151), _G.LSTR(420170), CallBack)
end

function ChocoboOverviewPanelView:OnClickBtnRealease()
    local function CallBack()
        _G.ChocoboMgr:ReqFree(_G.ChocoboMainVM.CurSelectEntryID)
    end

    -- LSTR string: 陆行鸟放生
    MsgBoxUtil.ShowMsgBoxTwoOp(self, _G.LSTR(420069), _G.LSTR(420070), CallBack)
end

function ChocoboOverviewPanelView:OnClickBtnRefresh()
    ChocoboMainVM:RefreshByCurFilterType()
end

function ChocoboOverviewPanelView:OnClickBtnScreener()
    _G.UIViewMgr:ShowView(UIViewID.ChocoboScreenerView)
end

function ChocoboOverviewPanelView:OnClickBtnFamily()
    UIViewMgr:ShowView(UIViewID.ChocoboRelationPageView)
end

function ChocoboOverviewPanelView:ToggleButtonCollectClick(ToggleButton, ButtonState)
    local IsLike = self.ViewModel.IsLike
    ChocoboMgr:ReqLike(ChocoboMainVM.CurSelectEntryID, not IsLike)
end

function ChocoboOverviewPanelView:ToggleButtonSwitchClick(ToggleButton, ButtonState)
    ChocoboMainVM:ChangeShowSimpleAttrMode()
end

function ChocoboOverviewPanelView:ToggleButtonSwitch02Click(ToggleButton, ButtonState)
    ChocoboMainVM:ChangeShowSimpleAttrMode()
end

function ChocoboOverviewPanelView:OnStateChangedToggleGroup(Index)
    UIUtil.SetIsVisible(self.PanelInfo, 1 == Index)
    UIUtil.SetIsVisible(self.PanelInfo02, 2 == Index)

    self:PlayAnimation(self.AnimSwitch)
    self:UpdateColorTips()
end

function ChocoboOverviewPanelView:OnValueChangedIsRacer(NewValue, OldValue)
    if NewValue then
        -- LSTR string: 已为默认
        self.BtnDefault:SetButtonText(LSTR(420067))
        --self.BtnDefault:SetIsEnabled(false, false)
        --self.BtnRealease:SetIsEnabled(false, false)
        self.BtnDefault:SetIsDisabledState(true, false)
        self.BtnRealease:SetIsDisabledState(true, false)
    else
        -- LSTR string: 设为默认
        self.BtnDefault:SetButtonText(LSTR(420068))
        --self.BtnDefault:SetIsEnabled(true, true)
        --self.BtnRealease:SetIsEnabled(true, true)
        self.BtnDefault:SetIsNormalState(true)
        self.BtnRealease:SetIsNormalState(true)
    end
end

function ChocoboOverviewPanelView:UpdateColorTips()
    if self.ViewModel == nil then
        return
    end

    if self.CommTabs_UIBP:GetSelectedIndex() == 1 then
        UIUtil.SetIsVisible(self.PanelColor, self.ViewModel.IsRent)
        UIUtil.SetIsVisible(self.PanelStage, not self.ViewModel.IsRent)
    else
        UIUtil.SetIsVisible(self.PanelColor, true)
        UIUtil.SetIsVisible(self.PanelStage, false)
    end
end

return ChocoboOverviewPanelView