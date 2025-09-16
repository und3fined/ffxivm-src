---
--- Author: v_vvxinchen
--- DateTime: 2024-01-02 16:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromIconID = require("Binder/UIBinderSetBrushFromIconID")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local GatheringLogMapItemVM = require("Game/GatheringLog/ItemVM/GatheringLogMapItemVM")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ProtoCommon = require("Protocol/ProtoCommon")

---@class GatheringLogInfoPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClock CommBtnSView
---@field BtnSetAlarmClock CommBtnSView
---@field CommBtnL CommBtnLView
---@field CommLight152Slot CommLight152SlotView
---@field Condition1 GatheringLogConditionItemView
---@field Condition2 GatheringLogConditionItemView
---@field ImgCollect UFImage
---@field ImgLine1 UFImage
---@field ImgTag UFImage
---@field NoCondition URichTextBox
---@field PanelCondition UFCanvasPanel
---@field PanelInfo UFCanvasPanel
---@field PanelPlace UFCanvasPanel
---@field RichTextName URichTextBox
---@field TableViewPlace UTableView
---@field TextCondition UFTextBlock
---@field TextDescription UFTextBlock
---@field TextName UFTextBlock
---@field TextPlace UFTextBlock
---@field ToggleBtnAlarmClock UToggleButton
---@field ToggleBtnFavor UToggleButton
---@field AnimUpdate UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GatheringLogInfoPageView = LuaClass(UIView, true)

function GatheringLogInfoPageView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClock = nil
	--self.BtnSetAlarmClock = nil
	--self.CommBtnL = nil
	--self.CommLight152Slot = nil
	--self.Condition1 = nil
	--self.Condition2 = nil
	--self.ImgCollect = nil
	--self.ImgLine1 = nil
	--self.ImgTag = nil
	--self.NoCondition = nil
	--self.PanelCondition = nil
	--self.PanelInfo = nil
	--self.PanelPlace = nil
	--self.RichTextName = nil
	--self.TableViewPlace = nil
	--self.TextCondition = nil
	--self.TextDescription = nil
	--self.TextName = nil
	--self.TextPlace = nil
	--self.ToggleBtnAlarmClock = nil
	--self.ToggleBtnFavor = nil
	--self.AnimUpdate = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GatheringLogInfoPageView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClock)
	self:AddSubView(self.BtnSetAlarmClock)
	self:AddSubView(self.CommBtnL)
	self:AddSubView(self.CommLight152Slot)
	self:AddSubView(self.Condition1)
	self:AddSubView(self.Condition2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GatheringLogInfoPageView:OnInit()
    self.TableViewPlaceAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewPlace, nil, true)
    self.TableViewPlaceAdapter:InitCategoryInfo(GatheringLogMapItemVM, _G.GatheringLogVM.MapPredicate)
    self.Binders = {
        {"CurGatherPlaceVMList", UIBinderUpdateBindableList.New(self, self.TableViewPlaceAdapter)},
        {"bNoConditionVisible", UIBinderSetIsVisible.New(self, self.NoCondition)},
        {"bTextConditionVisible", UIBinderSetIsVisible.New(self, self.TextCondition)},
        {"bCondition1ImgBidVisible", UIBinderSetIsVisible.New(self, self.Condition1.ImgForbidden)},
        {"bCondition2ImgBidVisible", UIBinderSetIsVisible.New(self, self.Condition2.ImgForbidden)},
        {"TextContent1", UIBinderSetText.New(self, self.Condition1.TextContent)},
        {"TextContent2", UIBinderSetText.New(self, self.Condition2.TextContent)},
        {"Condition1Text", UIBinderSetText.New(self, self.Condition1.TextCondition)},
        {"Condition2Text", UIBinderSetText.New(self, self.Condition2.TextCondition)},
        {"bCondition1Visible", UIBinderSetIsVisible.New(self, self.Condition1)},
        {"bCondition2Visible", UIBinderSetIsVisible.New(self, self.Condition2)},
        {"bAozyImgVisible", UIBinderSetIsVisible.New(self, self.Condition1.PanelZone)},
        --{"bImgCollectVisible", UIBinderSetIsVisible.New(self, self.ImgCollect)},
        {"GatherItemTextName", UIBinderSetText.New(self, self.TextName)},
        {"TypeName", UIBinderSetText.New(self, self.TextDescription)},
        {"IconID", UIBinderSetBrushFromIconID.New(self, self.CommLight152Slot.Icon)},
        {"ItemQualityImg", UIBinderSetBrushFromAssetPath.New(self, self.CommLight152Slot.ImgBg)},
        {"bSetClock", UIBinderSetIsChecked.New(self, self.ToggleBtnAlarmClock)},
        {"bSetFavor", UIBinderSetIsChecked.New(self, self.ToggleBtnFavor)},
        {"bBtnSetAlarmVisible", UIBinderSetIsVisible.New(self, self.BtnSetAlarmClock)},
        {"bToggleBtnAlarmClockVisible", UIBinderSetIsVisible.New(self, self.ToggleBtnAlarmClock,false,true)},
        {"bLeveQuestMarked", UIBinderSetIsVisible.New(self, self.ImgTag)},
    }
end

function GatheringLogInfoPageView:OnRegisterBinder()
    self:RegisterBinders(_G.GatheringLogVM, self.Binders)
end

function GatheringLogInfoPageView:OnShow()
    self.TextCondition:SetText(_G.LSTR(70045))--采集条件
    self.TextPlace:SetText(_G.LSTR(70044))--采集点
    self.BtnSetAlarmClock:SetText(_G.LSTR(70056))--闹钟设置
    self.CommBtnL:SetButtonText(_G.LSTR(80065))--前往转职
    UIUtil.SetIsVisible(self.CommLight152Slot.RichTextNum, false)
end

function GatheringLogInfoPageView:OnHide()
end

function GatheringLogInfoPageView:OnDestroy()
end

function GatheringLogInfoPageView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnSetAlarmClock, self.OnBtnSetAlarmClockClick)
    UIUtil.AddOnClickedEvent(self, self.ToggleBtnAlarmClock, self.OnToggleBtnAlarmClockClick)
    UIUtil.AddOnClickedEvent(self, self.ToggleBtnFavor, self.OnToggleBtnFavorClick)
    UIUtil.AddOnClickedEvent(self, self.CommBtnL.Button, self.GoToSwichProf)
    self.CommLight152Slot:SetClickButtonCallback(self.CommLight152Slot, self.OnIconClick)
end


---@type 当点击采集物的头像
function GatheringLogInfoPageView:OnIconClick(ItemView)
    local GatherID = _G.GatheringLogVM:GetSelectGatherID()
    local ItemData = _G.GatheringLogVM:GetItemDataByID(GatherID)
	if ItemData.ItemID > 0 then
	ItemTipsUtil.ShowTipsByItem({ResID = ItemData.ItemID}, ItemView, {X = -2, Y = 0})
	end
end

---@type 点击闹钟设置按钮
function GatheringLogInfoPageView:OnBtnSetAlarmClockClick()
    _G.UIViewMgr:ShowView(_G.UIViewID.GatheringLogSetAlarmClockWinView)
end

---@type 点击闹钟
function GatheringLogInfoPageView:OnToggleBtnAlarmClockClick()
    local fail =_G.GatheringLogVM:SetClock(false)
    if fail == false  then
        self.ToggleBtnAlarmClock:SetCheckedState(_G.UE.EToggleButtonState.UnChecked)
    end
end

---@type 点击收藏
function GatheringLogInfoPageView:OnToggleBtnFavorClick()
    local ItembSetFavor = _G.GatheringLogVM:SetFavor()
    if ItembSetFavor == true then
        self.ToggleBtnFavor:SetCheckedState(_G.UE.EToggleButtonState.Checked)
    else
        self.ToggleBtnFavor:SetCheckedState(_G.UE.EToggleButtonState.UnChecked)
    end
end

function GatheringLogInfoPageView:SelectToggle(Index)
    _G.MusicPerformanceMgr:SetTimbre(Index)
    self:ChangeTimbre(Index)
    self.VM.PerformName = _G.MusicPerformanceMgr:GetSelectedPerformData().Name
    self:UpdateToggles()
end

function GatheringLogInfoPageView:OnRegisterGameEvent()
    --设置SpacerInterval和播放动画
    self:RegisterGameEvent(_G.EventID.GatheringLogSetMapSpaceAndAnim, self.GatheringLogSetMapSpaceAndAnim)
end

---@type 设置第一个Mapitem的SpacerInterval控件消失
---@param FirstMapID number @第一个采集地图的ID
function GatheringLogInfoPageView:GatheringLogSetMapSpaceAndAnim(FirstMapID)
    self:PlayAnimation(self.AnimPanelIn3)
    -- local AllVM = self.TableViewPlaceAdapter.CategoryVMItemMap
    -- if AllVM and AllVM[FirstMapID] then
    --     AllVM[FirstMapID].bSpaceVisible = false
    -- end
end

function GatheringLogInfoPageView:GoToSwichProf()
    local Prof = _G.GatheringLogMgr:GetChoiceProfID()
    if _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDJobQuest) then
        _G.AdventureCareerMgr:JumpToTargetProf(Prof)
        return
    end
    local StartQuestCfg = _G.AdventureCareerMgr:GetCurProfChangeProfData(Prof)
	if not StartQuestCfg or not next(StartQuestCfg) then
        FLOG_ERROR("CraftingLogVM:GoToSwichProf StartQuestCfg is nil")
        return
    end
    local MapID = StartQuestCfg.AcceptMapID
    --如果是沙都乌尔达哈，打开地图
    if MapID == 12001 or MapID == 12002 then
        _G.WorldMapMgr:ShowWorldMapQuest(MapID, StartQuestCfg.AcceptUIMapID, StartQuestCfg.StartQuestID)
        if self.MapAnimationTimer and self.MapAnimationTimer ~= 0 then
            _G.TimerMgr:CancelTimer(self.MapAnimationTimer)
        end
        local WorldMapPanel = _G.UIViewMgr:FindView(_G.UIViewID.WorldMapPanel)
        local MarkerView = WorldMapPanel.MapContent:GetMapMarkerByID(StartQuestCfg.StartQuestID)
        self.MapAnimationTimer = _G.TimerMgr:AddTimer(self, function()
            if MarkerView then
                MarkerView:playAnimation(MarkerView.AnimNew)
            end
        end, 0, 2.97, 3)
    else
        MsgTipsUtil.ShowTips(LSTR(80068))--"冒险笔记尚未解锁，完成10级主线任务后可查看"
    end
end

function GatheringLogInfoPageView:SetSwichProfState(IsLock, Prof)
    UIUtil.SetIsVisible(self.CommBtnL, IsLock, IsLock)
    if not IsLock then return end
    --设置按钮状态
    if not _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDJobQuest) then
        local StartQuestCfg = _G.AdventureCareerMgr:GetCurProfChangeProfData(Prof)
        if StartQuestCfg and StartQuestCfg.AcceptMapID and StartQuestCfg.AcceptMapID ~= 12001 and StartQuestCfg.AcceptMapID ~= 12002 then
            self.CommBtnL:SetIsDisabledState(true, true)
            UIUtil.TextBlockSetColorAndOpacityHex(self.CommBtnL.TextContent, "#828282")
            return
        end
    end
    self.CommBtnL:SetIsRecommendState(true)	
    UIUtil.TextBlockSetColorAndOpacityHex(self.CommBtnL.TextContent, "#fffcf1")
end

return GatheringLogInfoPageView
