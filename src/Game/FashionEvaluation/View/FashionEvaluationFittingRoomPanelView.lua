---
--- Author: Administrator
--- DateTime: 2024-02-20 16:40
--- Description:试衣间界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsChecked  = require("Binder/UIBinderSetIsChecked")
local EquipmentDefine = require("Game/Equipment/EquipmentDefine")
local EquipmentMgr = require("Game/Equipment/EquipmentMgr")
local UIBinderSetActiveWidgetIndexBool = require("Binder/UIBinderSetActiveWidgetIndexBool")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local FashionEvaluationVM = require("Game/FashionEvaluation/VM/FashionEvaluationVM")
local FashionEvaluationMgr = require("Game/FashionEvaluation/FashionEvaluationMgr")
local FashionEvaluationVMUtils = require("Game/FashionEvaluation/FashionEvaluationVMUtils")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local FashionEvaluationDefine = require("Game/FashionEvaluation/FashionEvaluationDefine")

local RecommendTag = FashionEvaluationDefine.RecommendTag
---@class FashionEvaluationFittingRoomPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackBtn CommBackBtnView
---@field BtnAll UToggleButton
---@field BtnChallenge CommBtnLView
---@field BtnRecommend UToggleButton
---@field BtnRecord UFButton
---@field CommSearchBar3 CommSearchBarView
---@field CommSearchBtn3 CommSearchBtnView
---@field InforBtn CommInforBtnView
---@field PanelTab UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field SwitchInfo UFWidgetSwitcher
---@field TableViewTab UTableView
---@field TableViewThing UTableView
---@field Target FashionEvaluationTargetItemView
---@field TextAllFocus UFTextBlock
---@field TextAllNormal UFTextBlock
---@field TextCancel UFTextBlock
---@field TextHave UFTextBlock
---@field TextRecommendFocus UFTextBlock
---@field TextRecommendNormal UFTextBlock
---@field TextSetup UFTextBlock
---@field TextSubTitle UFTextBlock
---@field TextThingName UFTextBlock
---@field TextTips UFTextBlock
---@field TextTitle UFTextBlock
---@field TextTryiton UFTextBlock
---@field ToggleButton_144 UToggleButton
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionEvaluationFittingRoomPanelView = LuaClass(UIView, true)

function FashionEvaluationFittingRoomPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackBtn = nil
	--self.BtnAll = nil
	--self.BtnChallenge = nil
	--self.BtnRecommend = nil
	--self.BtnRecord = nil
	--self.CommSearchBar3 = nil
	--self.CommSearchBtn3 = nil
	--self.InforBtn = nil
	--self.PanelTab = nil
	--self.PanelTips = nil
	--self.SwitchInfo = nil
	--self.TableViewTab = nil
	--self.TableViewThing = nil
	--self.Target = nil
	--self.TextAllFocus = nil
	--self.TextAllNormal = nil
	--self.TextCancel = nil
	--self.TextHave = nil
	--self.TextRecommendFocus = nil
	--self.TextRecommendNormal = nil
	--self.TextSetup = nil
	--self.TextSubTitle = nil
	--self.TextThingName = nil
	--self.TextTips = nil
	--self.TextTitle = nil
	--self.TextTryiton = nil
	--self.ToggleButton_144 = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionEvaluationFittingRoomPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackBtn)
	self:AddSubView(self.BtnChallenge)
	self:AddSubView(self.CommSearchBar3)
	self:AddSubView(self.CommSearchBtn3)
	self:AddSubView(self.InforBtn)
	self:AddSubView(self.Target)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionEvaluationFittingRoomPanelView:OnInit()
	self.ThemePartsAdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewTab, self.OnThemePartSelected, true, false)
	self.AppsAdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewThing, self.OnAppearanceSelected, true, true)
	self.Binders = {
		{"PartThemeVMList", UIBinderUpdateBindableList.New(self, self.ThemePartsAdapterTableView)},
		{"AppearanceInfoVMlist", UIBinderUpdateBindableList.New(self, self.AppsAdapterTableView)},
		{"ThemeNameText", UIBinderSetText.New(self, self.TextSubTitle)},
		{"CurSelectPart", UIBinderValueChangedCallback.New(self, nil, self.OnSelectPartIDChanged)},
		{"CurSelectAppID", UIBinderValueChangedCallback.New(self, nil, self.OnSelectEquipResIDChanged)},
		{"CurSelectEquipName", UIBinderSetText.New(self, self.TextThingName)},
		{"CurSelectEquipIsOwn", UIBinderSetActiveWidgetIndexBool.New(self, self.SwitchInfo)},
		{"CurSelectEquipIsTracked", UIBinderSetIsChecked.New(self, self.ToggleButton_144)},
		{"IsFirstTimesEnter", UIBinderValueChangedCallback.New(self, nil, self.OnIsFirstTimesEnterChanged)},
		{"IsHistoryEmpty", UIBinderSetIsVisible.New(self, self.BtnRecord, true, true)},
	}

end

function FashionEvaluationFittingRoomPanelView:OnDestroy()

end

function FashionEvaluationFittingRoomPanelView:OnShow()
	self:SetLSTR()
	self.CurPart = 0
	self.NeedFocusAppearance = 0
	self.IsOpenSearchPanel = false
	self.IsSelectedSearchResult = false
	self:ShowSearchPanel(false)
	self.ThemePartsAdapterTableView:SetSelectedIndex(1)
	local IsEquipedHistory = self.FittingVM.IsEquipedHistory
	if not IsEquipedHistory then
		FashionEvaluationMgr:RestoreUICharacterAvatar()
	end
	UIUtil.SetIsVisible(self.InforBtn, true, true)
end

function FashionEvaluationFittingRoomPanelView:OnHide()
	if self.HideTipsTimer then
		self:UnRegisterTimer(self.HideTipsTimer)
		self.HideTipsTimer = nil
	end
end

function FashionEvaluationFittingRoomPanelView:OnRegisterUIEvent()
	self.BackBtn:AddBackClick(self, self.OnBtnCloseClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnRecord, self.OnBtnHistoryClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnChallenge, self.OnBtnStartEvaluateClicked)
	UIUtil.AddOnClickedEvent(self, self.CommSearchBtn3.BtnSearch, self.OnBtnSearchClicked)
	self.CommSearchBar3:SetCallback(self, nil, self.OnSearchTextCommitted, self.OnClickCancelSearchBar)
	self.CommSearchBar3.BtnCancelAlwaysVisible = true
	UIUtil.AddOnStateChangedEvent(self, self.ToggleButton_144, self.OnChangedToggleBtnTrack)
	UIUtil.AddOnStateChangedEvent(self, self.BtnAll, self.OnChangedToggleBtnAll)
	UIUtil.AddOnStateChangedEvent(self, self.BtnRecommend, self.OnChangedToggleBtnRecommend)
end

function FashionEvaluationFittingRoomPanelView:OnRegisterGameEvent()
	
end

function FashionEvaluationFittingRoomPanelView:OnRegisterBinder()
	self.FittingVM = FashionEvaluationVM:GetFittingVM()
	if self.FittingVM == nil then
		return
	end

	self:RegisterBinders(self.FittingVM, self.Binders)
end

function FashionEvaluationFittingRoomPanelView:SetLSTR()
	self.TextTitle:SetText(_G.LSTR(1120038)) -- 1120037("试衣间")
	self.BtnChallenge:SetBtnName(_G.LSTR(1120039)) --1120032("挑  战")
	self.TextTryiton:SetText(_G.LSTR(1120040))--1120040("试穿")
	self.TextHave:SetText(_G.LSTR(1120041))--1120041("衣橱拥有")
	self.TextSetup:SetText(_G.LSTR(1120042))--1120042("设为目标")
	self.TextCancel:SetText(_G.LSTR(1120043))--1120043("取消标记")
	self.TextRecommendFocus:SetText(_G.LSTR(1120044))--1120044("推荐")
	self.TextRecommendNormal:SetText(_G.LSTR(1120044))--1120044("推荐")
	self.TextAllNormal:SetText(_G.LSTR(1120045))--1120045("全部")
	self.TextAllFocus:SetText(_G.LSTR(1120045))--1120045("全部")
	self.TextTips:SetText(_G.LSTR(1120046))--1120046("推荐中有符合主题的外观哦")
end

function FashionEvaluationFittingRoomPanelView:SetRender2DView(Render2DView)
	self.Render2DView = Render2DView
end

function FashionEvaluationFittingRoomPanelView:OnBtnCloseClicked()
	--清空外观
	local FittingVM = FashionEvaluationVM:GetFittingVM()
	if FittingVM then
		FittingVM:UpdateThemePartList()
	end
	FashionEvaluationMgr:RestoreUICharacterAvatar()
	FashionEvaluationMgr:ShowFittingView(false, true)
end

---@type 所有外观
function FashionEvaluationFittingRoomPanelView:OnChangedToggleBtnAll(ToggleButton, State)
	if State == _G.UE.EToggleButtonState.Checked then
		self.BtnRecommend:SetChecked(false, false)
	end 
	self.FittingVM:UpdateAppearanceInfoListByTag(self.CurPart, RecommendTag.All)
	if self.IsSelectedSearchResult then
		local AppList = self.FittingVM:GetCurAppearanceInfoList()
		local AppInfo, Index = table.find_item(AppList, self.NeedFocusAppearance, "AppearanceID")
		if AppInfo then
			self.AppsAdapterTableView:ScrollToIndex(Index)
		end
	else
		self.AppsAdapterTableView:ScrollToTop()
	end
end

---@type 推荐外观
function FashionEvaluationFittingRoomPanelView:OnChangedToggleBtnRecommend(ToggleButton, State)
	if State == _G.UE.EToggleButtonState.Checked then
		self.BtnAll:SetChecked(false, false)
	end 
	self.FittingVM:UpdateAppearanceInfoListByTag(self.CurPart, RecommendTag.Recommend)
	self.AppsAdapterTableView:ScrollToTop()
end

---@type 历史记录
function FashionEvaluationFittingRoomPanelView:OnBtnHistoryClicked()
	FashionEvaluationMgr:ShowHistoryScoreView(true)
end

---@type 开始挑战
function FashionEvaluationFittingRoomPanelView:OnBtnStartEvaluateClicked()
	FashionEvaluationMgr:OnStartEvaluateClicked()
end

---@type 主题部位被选中
function FashionEvaluationFittingRoomPanelView:OnThemePartSelected(Index, ItemData, ItemView)
	if self.CurPart == ItemData.Part then
		return
	end
	self.CurPart = ItemData.Part
	self.FittingVM:OnThemePartItemSelected(Index, ItemData)
	self.AppsAdapterTableView:ScrollToTop()
	_G.ObjectMgr:CollectGarbage(false)
	self:OnClickCancelSearchBar()
end 

---@type 外观被选中
function FashionEvaluationFittingRoomPanelView:OnAppearanceSelected(Index, ItemData, ItemView)
	self.CurSelectAppID = ItemData.AppearanceID
	local CurThemePart = self.FittingVM:GetCurSelectThemePart()
	local NewAppID = self.CurSelectAppID
	--如果试穿外观和当前一样，则穿上默认外观
	if CurThemePart and CurThemePart.AppearanceID == self.CurSelectAppID then
		NewAppID = CurThemePart.DefaultAppearanceID
	end
	
	local UIComplexCharacter = FashionEvaluationMgr:GetUIComplexCharacter()
	--如果默认外观未配置，则取玩家身上的装备
    if NewAppID == nil or NewAppID == 0 then
        local Equip = EquipmentMgr:GetEquipedItemByPart(ItemData.Part)
        --如果当前部位有装备，则装上
        if Equip then
            local EquipID = Equip.ResID
			if EquipID and EquipID > 0 then
				UIComplexCharacter:PreViewEquipment(EquipID, ItemData.Part)
			end
        else
			UIComplexCharacter:PreViewEquipment(0, ItemData.Part)
        end
    else
		FashionEvaluationMgr:WearAppearance(ItemData.Part, NewAppID)
    end
	self.FittingVM:OnEquipItemSelected(Index, ItemData)
	_G.ObjectMgr:CollectGarbage(false)
	if self.IsOpenSearchPanel then
		self.IsSelectedSearchResult = true
	end
end

---@type 选中外观ID变更
function FashionEvaluationFittingRoomPanelView:OnSelectEquipResIDChanged(NewEquipResID)
	self.CurSelectAppID = NewEquipResID
	local IsSelectEquip = NewEquipResID and NewEquipResID ~= 0
	UIUtil.SetIsVisible(self.ToggleButton_144, IsSelectEquip, true)
	UIUtil.SetIsVisible(self.SwitchInfo, IsSelectEquip, true)
end

---@type 选中主题部位变更
function FashionEvaluationFittingRoomPanelView:OnSelectPartIDChanged(PartID)
	if PartID == nil then
		return
	end
	--更新搜索提示
	local PartName = FashionEvaluationVMUtils.GetPartName(PartID)
    if PartName then
		local HintText = string.format(FashionEvaluationDefine.SearchHint, PartName)
		self.CommSearchBar3:SetHintText(HintText)
	end
	--筛选标签
	self.BtnAll:SetChecked(false, false)
	self.BtnRecommend:SetChecked(true, false)
end

---@type 外观提示
function FashionEvaluationFittingRoomPanelView:OnIsFirstTimesEnterChanged(IsFirstTimesEnter)
	UIUtil.SetIsVisible(self.PanelTips, IsFirstTimesEnter)
	if IsFirstTimesEnter then
		if self.HideTipsTimer then
			self:UnRegisterTimer(self.HideTipsTimer)
		end

		self.HideTipsTimer = self:RegisterTimer(function()
			UIUtil.SetIsVisible(self.PanelTips, false)
			FashionEvaluationVM:OnFirstTimesEnterMainView(false)
		end, 3)
	end

end

---@type 打开搜索框
function FashionEvaluationFittingRoomPanelView:OnBtnSearchClicked()
	self.CommSearchBar3:SetText('')
	self:ShowSearchPanel(true)
end

---@type 提交搜索
function FashionEvaluationFittingRoomPanelView:OnSearchTextCommitted(SearchText)
	--self.AppsAdapterTableView:CancelSelected()
	self.FittingVM:OnSearchEquip(SearchText)
	self.IsOpenSearchPanel = true
end

---@type 关闭搜索框
function FashionEvaluationFittingRoomPanelView:OnClickCancelSearchBar()
	self.CommSearchBar3:SetText('')
	self:ShowSearchPanel(false)
	-- 如果有选中搜索出来的外观，则切换到“全部”标签页
	if self.IsSelectedSearchResult then
		self.BtnAll:SetChecked(true, false)
		self.NeedFocusAppearance = self.FittingVM.CurSelectAppID
		self:OnChangedToggleBtnAll(self.BtnAll, _G.UE.EToggleButtonState.Checked)
	else
		self.FittingVM:OnCancelSearchEquip()
	end
	
	self.IsOpenSearchPanel = false
	self.IsSelectedSearchResult = false
end

function FashionEvaluationFittingRoomPanelView:ShowSearchPanel(IsVisible)
	UIUtil.SetIsVisible(self.CommSearchBar3, IsVisible)
	UIUtil.SetIsVisible(self.CommSearchBtn3, not IsVisible, true)
	UIUtil.SetIsVisible(self.PanelTab, not IsVisible, true)
end

---@type 追踪按钮状态改变
function FashionEvaluationFittingRoomPanelView:OnChangedToggleBtnTrack(ToggleButton, State)
	if self.CurSelectAppID == nil or self.CurSelectAppID <= 0 then
		return
	end

	local IsChecked = self.ToggleButton_144:GetChecked()
	if not FashionEvaluationMgr:OnEquipTrackClicked(self.CurSelectAppID, IsChecked) then
		if self.ToggleButton_144:GetChecked() then
			self.ToggleButton_144:SetChecked(false)
		end
	end 
end

---@type 清除装备TableView
function FashionEvaluationFittingRoomPanelView:ClearTableView()
	if self.AppsAdapterTableView then
		self.AppsAdapterTableView:ReleaseAllItem(true)
	end
end

return FashionEvaluationFittingRoomPanelView