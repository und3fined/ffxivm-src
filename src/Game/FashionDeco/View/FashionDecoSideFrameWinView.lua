---
--- Author: ccppeng
--- DateTime: 2024-10-29 10:32
--- Description:时尚配饰主面板
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local FashionDecoSideFrameWinVM = require("Game/FashionDeco/VM/FashionDecoSideFrameWinVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetViewParams = require("Binder/UIBinderSetViewParams")
local FashionDecoDefine = require("Game/FashionDeco/VM/FashionDecoDefine")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetText = require("Binder/UIBinderSetText")
local DataReportUtil = require("Utils/DataReportUtil")
local UIDefine = require("Define/UIDefine")
local CommonUtil = require("Utils/CommonUtil")
local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")
local LSTR = _G.LSTR
local CommBtnColorType = UIDefine.CommBtnColorType
--local MsgTipsUtil = require("Utils/MsgTipsUtil")
--local TutorialDefine = require("Game/Tutorial/TutorialDefine")
---@class FashionDecoSideFrameWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSetting UFButton
---@field BtnWear CommBtnMView
---@field CommEmpty CommBackpackEmptyView
---@field CommHorTabs_UIBP CommHorTabsView
---@field CommSelectSettingsTips_UIBP CommSelectSettingsTipsView
---@field PanelUI UFCanvasPanel
---@field TableViewAction UTableView
---@field TableViewSlot UTableView
---@field TextAction UFTextBlock
---@field TextSlotName UFTextBlock
---@field ToggleBtnCollect UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionDecoSideFrameWinView = LuaClass(UIView, true)

function FashionDecoSideFrameWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSetting = nil
	--self.BtnWear = nil
	--self.CommEmpty = nil
	--self.CommHorTabs_UIBP = nil
	--self.CommSelectSettingsTips_UIBP = nil
	--self.PanelUI = nil
	--self.TableViewAction = nil
	--self.TableViewSlot = nil
	--self.TextAction = nil
	--self.TextSlotName = nil
	--self.ToggleBtnCollect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionDecoSideFrameWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnWear)
	self:AddSubView(self.CommEmpty)
	self:AddSubView(self.CommHorTabs_UIBP)
	self:AddSubView(self.CommSelectSettingsTips_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

--初始化
function FashionDecoSideFrameWinView:OnInit()
	UIUtil.SetIsVisible(self.CommSelectSettingsTips_UIBP, false)
	--设置面板
	--self.CommSelectSettingsTips_UIBP:CustomSetProperties(FashionDecoSettingTipsVM.New())
	--自己的Model
	self.ViewModel = FashionDecoSideFrameWinVM.New()
	--注册选择面板
	self.SlotTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot,self.OnSelectChangedSlotItem,true)
	--播放面板内当前选中的技能
	self.ActionTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewAction,self.OnSelectChangedActionItem,true)

	self.Binders = {

		{ "FashionDecoSettingTipsVM", UIBinderSetViewParams.New(self, self.CommSelectSettingsTips_UIBP)},--设置主面板VM
		--{ "CommSideFrameTabsVM", UIBinderSetViewParams.New(self, self.CommTabs)},--右侧类型选择VM
		{ "ListSlotItemListVM", UIBinderUpdateBindableList.New(self, self.SlotTableView) },--当前选中类型的所有Item自己的主面板VM
		{ "ListActionItemListVM", UIBinderUpdateBindableList.New(self, self.ActionTableView) },--当前选中类型的所有技能Item自己的主面板VM
		{
			"SettingBtnVisible",
			UIBinderSetIsVisible.New(self, self.BtnSetting,false,true)--设置按钮显示与隐藏
		},
		{
			"TextActionVisible",
			UIBinderSetIsVisible.New(self, self.TextAction,false,true)--技能文字
		},
		{
			"BtnWearVisible",
			UIBinderSetIsVisible.New(self, self.BtnWear)--穿戴按钮
		},
		{
			"SettingPanelVisible",
			UIBinderSetIsVisible.New(self, self.CommSelectSettingsTips_UIBP)--设置面板
		},
		{
			"ToggleBtnCollectVisible",
			UIBinderSetIsVisible.New(self, self.ToggleBtnCollect,false,true)--收藏按钮显隐
		},
		{
			"CurrentSelectType",
			UIBinderValueChangedCallback.New(self,nil, self.OnCurrentSelectTypeChanged)--选择类型改变
		},
		{
			"CurrentSelectedIsCollect",
			UIBinderValueChangedCallback.New(self, nil, self.OnIsCollectUpdate)--当前选中item更新主面板的收藏按钮
		},
		{
			"CurrentWearBtnState",
			UIBinderValueChangedCallback.New(self, nil, self.OnUpdateCurrentWearBtnState)--更新空元素的面板显示与隐藏
		},
		{ "CurrentSelectedName", UIBinderSetText.New(self, self.TextSlotName) },--更新当前选中元素的名字
		{
			"UpdateToSelectFirstIndex",
			UIBinderValueChangedCallback.New(self, nil, self.OnUpdateToSelectFirstIndex)--更新空元素的面板显示与隐藏
		},
		{ "BtnWearName", UIBinderSetText.New(self, self.BtnWear.TextContent) },--按钮穿戴
	}


end

function FashionDecoSideFrameWinView:OnDestroy()

end

function FashionDecoSideFrameWinView:OnShow()
	if self.Params ~= nil and self.Params.bOpen then
		self.Params.bOpen = false
		--流水上报 二级界面进入
		DataReportUtil.ReportFashiondecoData("FashionAccessoriesFlow", 1,1)
	else
		--流水上报 快捷页签切换过来
		DataReportUtil.ReportFashiondecoData("FashionAccessoriesFlow", 1,2)
	end
end

function FashionDecoSideFrameWinView:IsForceGC()
	local Platform = CommonUtil.GetPlatformName()
	if Platform == "Android" then
		return false
	elseif Platform == "IOS" then
		return true
	end
end
function FashionDecoSideFrameWinView:OnHide()
	UIUtil.SetIsVisible(self.CommSelectSettingsTips_UIBP,false)
	self.ViewModel:ClearData()
end

function FashionDecoSideFrameWinView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.CommHorTabs_UIBP, self.OnGroupTabsSelectionChanged)
	UIUtil.AddOnClickedEvent(self, self.BtnSetting, self.OnBtnSetting)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnCollect, self.OnBtnCollect)
	UIUtil.AddOnClickedEvent(self, self.BtnWear, self.OnBtnWearClicked)
end
function FashionDecoSideFrameWinView:OnGroupTabsSelectionChanged(Index, ItemData, ItemView)
    if self.ViewModel ~= nil then
	    self.ViewModel:SetTabsSelectionIndex(Index)
    end
end
function FashionDecoSideFrameWinView:OnRegisterGameEvent()

end

function FashionDecoSideFrameWinView:OnRegisterBinder()
	--self.ViewModel:OnSelectChangedItem(1)
	self.TextAction:SetText(LSTR(1030012)) 
	--self.SlotTableView:SetScrollEnabled(false)
	self:RegisterBinders(self.ViewModel, self.Binders)

end
function FashionDecoSideFrameWinView:PostShowView()
    if self.CommHorTabs_UIBP ~= nil then
	    self.CommHorTabs_UIBP:SetSelectedIndex(FashionDecoSideFrameWinVM:GetBestFirstIndex())
    end
end
--点击收藏按钮
function FashionDecoSideFrameWinView:OnBtnCollect()
    --收藏
	if self.ViewModel ~= nil then
		self.ViewModel:OnBtnCollect();
	end

end

function FashionDecoSideFrameWinView:OnUpdateCurrentWearBtnState(NewValue,OldValue)
	if self.BtnWear ~= nil and NewValue ~= nil then
		if NewValue then
			self.BtnWear:SetColorType(CommBtnColorType.Recommend)
		else
			self.BtnWear:SetColorType(CommBtnColorType.Normal)
		end
	end
end

function FashionDecoSideFrameWinView:OnBtnWearClicked()
	self.ViewModel:WearCurrentFashionDeco();
end

--设置按钮
function FashionDecoSideFrameWinView:OnBtnSetting()
	if UIUtil.IsVisible(self.CommSelectSettingsTips_UIBP) == true then
		if self.ViewModel ~= nil then
			self.ViewModel:SetSettingPanel(false)
		end
		--UIUtil.SetIsVisible(self.CommSelectSettingsTips_UIBP, false)
	else
		self.ViewModel:UpdateFashionDecoSettingTipsVM()
		self.CommSelectSettingsTips_UIBP:UpdateViewModel(self.ViewModel:GetSettingVM())
		if self.ViewModel ~= nil then
			self.ViewModel:SetSettingPanel(true)
		end
		--UIUtil.SetIsVisible(self.CommSelectSettingsTips_UIBP,true)
	end
end

--选择类型改变，隐藏设置面板
function FashionDecoSideFrameWinView:OnCurrentSelectTypeChanged(NewValue,OldValue)
	if NewValue == nil  then
		NewValue = FashionDecoSideFrameWinVM:GetBestFirstIndex()
	end
	self.ViewModel:OnSelectChangedItem(NewValue)
    if NewValue == FashionDecoDefine.FashionDecoType.Wing then
		UIUtil.SetIsVisible(self.CommSelectSettingsTips_UIBP,false)
    end
	self:UpdateRedDot(NewValue)
end
function FashionDecoSideFrameWinView:UpdateRedDot(NewTypeValue)
	local TypeReadStatus = self.ViewModel:GetAllReadStatus()
	if self.CommHorTabs_UIBP ~= nil and self.CommHorTabs_UIBP.AdapterTabs ~= nil then
		for i = FashionDecoDefine.FashionDecoType.Max-1, 1, -1 do
			local Child = self.CommHorTabs_UIBP.AdapterTabs:GetChildren(i)
			if i~= NewTypeValue and TypeReadStatus[i] == true then
				Child.RedDot:SetRedDotText(LSTR(10030))
				Child.RedDot:SetRedDotUIIsShow(true)
				Child.RedDot:SetStyle(RedDotDefine.RedDotStyle.TextStyle)
			else
				Child.RedDot:SetRedDotUIIsShow(false)
			end

		end
	end

end

--更新空元素的面板显示与隐藏，且默认选中第一个元素
function FashionDecoSideFrameWinView:OnUpdateToSelectFirstIndex(NewValue,OldValue)

	if NewValue == nil then
		return
	end
	self.SlotTableView:SetSelectedIndex(1)
	local curvalue = self.ViewModel:GetElementNumOnCurrentType()
	UIUtil.SetIsVisible(self.CommEmpty,false)
	UIUtil.SetIsVisible(self.CommEmpty.PanelBtn,false)
end

--更新选中的收藏按钮状态
function FashionDecoSideFrameWinView:OnIsCollectUpdate(NewValue,OldValue)
if NewValue ~= nil then
	if NewValue  then
		self.ToggleBtnCollect:SetCheckedState(_G.UE.EToggleButtonState.Checked)
	else
		self.ToggleBtnCollect:SetCheckedState(_G.UE.EToggleButtonState.Unchecked)
	end
end

end

--点击技能按钮
function FashionDecoSideFrameWinView:OnSelectChangedActionItem(InIndex, ItemData, ItemView)
	self.ViewModel:ClickCurrentAction(ItemData)
	ItemView:PlayAnimation(ItemView.AnimClick)
end

--更新主面板当前选择的饰品
function FashionDecoSideFrameWinView:OnSelectChangedSlotItem(Index, ItemData, ItemView)
	self.ViewModel:SetCurrentSelectedItem(ItemData)
	ItemData:OnSelectedChange(true)
end
return FashionDecoSideFrameWinView