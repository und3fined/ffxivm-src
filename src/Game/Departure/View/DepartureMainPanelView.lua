---
--- Author: Administrator
--- DateTime: 2025-03-13 14:19
--- Description:光之启程主界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local AudioUtil = require("Utils/AudioUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsChecked  = require("Binder/UIBinderSetIsChecked")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local DepartOfLightMgr = require("Game/Departure/DepartOfLightMgr")
local DepartOfLightDefine = require("Game/Departure/DepartOfLightDefine")
local DepartOfLightVMUtils = require("Game/Departure/DepartOfLightVMUtils")
local DepartOfLightVM = require("Game/Departure/VM/DepartOfLightVM")

---@class DepartureMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGoto CommBtnLView
---@field CloseBtn CommonCloseBtnView
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field CommonTitle CommonTitleView
---@field DepartureBigBannerItem_UIBP DepartureBigBannerItemView
---@field ImgSlotBG UFImage
---@field PanelProBar UFCanvasPanel
---@field PanelTime UFHorizontalBox
---@field PanlBtnText UFCanvasPanel
---@field ProBar UFProgressBar
---@field RichTextAward URichTextBox
---@field TableViewBanner UTableView
---@field TableViewSlot UTableView
---@field TableViewTab UTableView
---@field TextBtnHint UFTextBlock
---@field TextTime UFTextBlock
---@field AnimBack UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimOut1 UWidgetAnimation
---@field AnimProBar UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local DepartureMainPanelView = LuaClass(UIView, true)

function DepartureMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGoto = nil
	--self.CloseBtn = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.CommonTitle = nil
	--self.DepartureBigBannerItem_UIBP = nil
	--self.ImgSlotBG = nil
	--self.PanelProBar = nil
	--self.PanelTime = nil
	--self.PanlBtnText = nil
	--self.ProBar = nil
	--self.RichTextAward = nil
	--self.TableViewBanner = nil
	--self.TableViewSlot = nil
	--self.TableViewTab = nil
	--self.TextBtnHint = nil
	--self.TextTime = nil
	--self.AnimBack = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimOut1 = nil
	--self.AnimProBar = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function DepartureMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnGoto)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.DepartureBigBannerItem_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function DepartureMainPanelView:OnInit()
	self.ActivityTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTab, self.OnActivitySelected, true, false)
	self.RewardTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot, nil, true, false)
	self.DescTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewBanner, self.OnDescSelected, true, false)
	self.Binders = {
		{"ActivityInfoVMList", UIBinderUpdateBindableList.New(self, self.ActivityTableViewAdapter)},
		{"CurrNodeInfoVMList", UIBinderUpdateBindableList.New(self, self.RewardTableViewAdapter)},
		{"CurrActivityDescVMList", UIBinderUpdateBindableList.New(self, self.DescTableViewAdapter)},
		{"Info", UIBinderSetText.New(self, self.DepartureBigBannerItem_UIBP.TextBanner)},
		{"ProgressPercent", UIBinderSetPercent.New(self, self.ProBar)},
		{"GoToBtnDesc", UIBinderSetText.New(self, self.TextBtnHint)},
		{"GoToBtnDescVisible", UIBinderSetIsVisible.New(self, self.PanlBtnText)},
		{"GoToBtnName", UIBinderSetText.New(self, self.BtnGoto.TextContent)},
		{"BGIcon", UIBinderSetBrushFromAssetPath.New(self, self.DepartureBigBannerItem_UIBP.ImgBanner)},
		{"NodeHeadDesc", UIBinderSetText.New(self, self.RichTextAward)},
		{"IsReadyClose", UIBinderSetIsVisible.New(self, self.PanelTime)},
		{"ForeverCloseTimeText", UIBinderSetText.New(self, self.TextTime)},
		{"IsCurActivityPreQuestFinished", UIBinderValueChangedCallback.New(self, nil, self.OnActivityUnlockChanged)},
		{"IsCurActivityUnlock", UIBinderSetIsVisible.New(self, self.ImgSlotBG, true)},
		-- {"CurSelectAppID", UIBinderValueChangedCallback.New(self, nil, self.OnSelectEquipResIDChanged)},
		-- {"CurSelectEquipName", UIBinderSetText.New(self, self.TextThingName)},
		-- {"CurSelectEquipIsOwn", UIBinderSetActiveWidgetIndexBool.New(self, self.SwitchInfo)},
		-- {"CurSelectEquipIsTracked", UIBinderSetIsChecked.New(self, self.ToggleButton_144)},
		-- {"IsFirstTimesEnter", UIBinderValueChangedCallback.New(self, nil, self.OnIsFirstTimesEnterChanged)},
	}

end

function DepartureMainPanelView:OnDestroy()

end

function DepartureMainPanelView:OnShow()
	self:SetLSTR()
	self.CurActivityIndex = 0
	self.ActivityTableViewAdapter:SetSelectedIndex(1)
	AudioUtil.LoadAndPlayUISound(DepartOfLightDefine.UISoundPath.MainPanel)
end

function DepartureMainPanelView:OnHide()

end

function DepartureMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGoto.Button, self.OnBtnGotoClicked)
end

function DepartureMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.DepartOfLightBaseInfoUpdate, self.OnDepartOfLightBaseInfoUpdate)
	self:RegisterGameEvent(_G.EventID.OnDepartRecycleViewVisibleChange, self.OnRecycleViewVisibleChange)
	self:RegisterGameEvent(_G.EventID.HideUI, self.OnGameEventHideUI)
end

function DepartureMainPanelView:OnRegisterBinder()
	self:RegisterBinders(DepartOfLightVM, self.Binders)
end

function DepartureMainPanelView:SetLSTR()
	self.CommonTitle:SetTextTitleName(_G.LSTR(1620001)) --1620001("光之启程")
end

---@type 玩法被选中
function DepartureMainPanelView:OnActivitySelected(Index, ItemData, ItemView)
	if self.CurActivityIndex == Index then
		DepartOfLightMgr:OnActivityClicked(Index)
		return
	end
	
	self.CurActivityIndex = Index
	self.CurActivityID = ItemData and ItemData.ActivityID
	DepartOfLightMgr:OnActivityClicked(Index)
	local ActivityDescInfo = DepartOfLightVMUtils.GetActivityDescInfoByActivityID(self.CurActivityID)
    local GameID = ActivityDescInfo and ActivityDescInfo.GameID
	DepartOfLightMgr:SendGetTaskProgressReq(GameID)
	self.DepartureBigBannerItem_UIBP:OnActivityClicked(self.CurActivityID)
	AudioUtil.LoadAndPlayUISound(DepartOfLightDefine.UISoundPath.Switch)
end

---@type 玩法说明被选中
function DepartureMainPanelView:OnDescSelected(Index, ItemData, ItemView)
	DepartOfLightMgr:OnDescIconClicked(Index)
end

function DepartureMainPanelView:OnBtnGotoClicked()
	DepartOfLightMgr:OnGotoPlayStyle(self.CurActivityIndex)
end

function DepartureMainPanelView:OnDepartOfLightBaseInfoUpdate()
	self.ActivityTableViewAdapter:SetSelectedIndex(1)
end

function DepartureMainPanelView:OnRecycleViewVisibleChange(IsVisible)
	local Anim = IsVisible and self.AnimOut1 or self.AnimBack
	if Anim then
		self:PlayAnimation(Anim)
	end
end

function DepartureMainPanelView:OnActivityUnlockChanged(IsUnlock)
	self.BtnGoto:SetIsNormalState(not IsUnlock)
end

function DepartureMainPanelView:OnGameEventHideUI(Params)
	local ActivityID = DepartOfLightVM.ActivityID
	local ActivityDescInfo = DepartOfLightVMUtils.GetActivityDescInfoByActivityID(ActivityID)
    local GameID = ActivityDescInfo and ActivityDescInfo.GameID
	DepartOfLightMgr:SendGetTaskProgressReq(GameID)
end

return DepartureMainPanelView