---
--- Author: anypkvcai
--- DateTime: 2023-04-04 17:17
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local WidgetCallback = require("UI/WidgetCallback")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local CommVerIconTabItemVM = require("Game/Common/Tab/CommVerIconTabItemVM")
local ObjectPoolMgr = require("Game/ObjectPool/ObjectPoolMgr")
local UIBindableList = require("UI/UIBindableList")
local UIUtil = require("Utils/UIUtil")
local EToggleButtonState = _G.UE.EToggleButtonState

---@class CommVerIconTabsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSwitch UToggleButton
---@field IconSwitchCheck UFImage
---@field IconSwitchUnCheck UFImage
---@field ImgMask UFImage
---@field ImgSwitchBG UFImage
---@field ImgTabBG UFImage
---@field PanelSwitch UFCanvasPanel
---@field TableViewTabs UTableView
---@field SelectShowType CommVerIconTabsSelectType
---@field ShowTabBg bool
---@field ShowMask bool
---@field ShowSwitchPanel bool
---@field ClickChangeSwitchIcon bool
---@field SwitchUncheckIconBrush SlateBrush
---@field SwitchCheckIcon SlateBrush
---@field SwitchBgIconBrush SlateBrush
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommVerIconTabsView = LuaClass(UIView, true)

function CommVerIconTabsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSwitch = nil
	--self.IconSwitchCheck = nil
	--self.IconSwitchUnCheck = nil
	--self.ImgMask = nil
	--self.ImgSwitchBG = nil
	--self.ImgTabBG = nil
	--self.PanelSwitch = nil
	--self.TableViewTabs = nil
	--self.SelectShowType = nil
	--self.ShowTabBg = nil
	--self.ShowMask = nil
	--self.ShowSwitchPanel = nil
	--self.ClickChangeSwitchIcon = nil
	--self.SwitchUncheckIconBrush = nil
	--self.SwitchCheckIcon = nil
	--self.SwitchBgIconBrush = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommVerIconTabsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommVerIconTabsView:OnInit()
	self.OnSelectionChanged = WidgetCallback.New()
	self.BindableList = UIBindableList.New(CommVerIconTabItemVM)
	self.AdapterTabs = UIAdapterTableView.CreateAdapter(self, self.TableViewTabs, self.OnSelectChanged)
	self:SetSelectShowType(self.SelectShowType)
end

function CommVerIconTabsView:SetSelectShowType(ShowType)
	if ShowType then
		local Param = {SelectShowType = ShowType}
		self.AdapterTabs:SetParams(Param)
	end
end

function CommVerIconTabsView:OnDestroy()
	self.BindableList:Clear()
	self.OnSelectionChanged:Clear()
	self.OnSelectionChanged = nil
end

function CommVerIconTabsView:OnShow()

end

function CommVerIconTabsView:OnHide()
	self.AdapterTabs:CancelSelected()
	self.LastChosed = nil
end

function CommVerIconTabsView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSwitch, self.OnClickButtonSwitch)
end

function CommVerIconTabsView:OnClickButtonSwitch()
	if not self.ClickChangeSwitchIcon then
		self:SetBtnSwitchCheckedState(EToggleButtonState.Unchecked)
	end

	if(self.ClickCallback ~= nil and self.CallbackView ~= nil) then
        self.ClickCallback(self.CallbackView)
    end
end

function CommVerIconTabsView:SetClickButtonSwitchCallback(TargetView, TargetCallback)
    self.CallbackView = TargetView
    self.ClickCallback = TargetCallback
end

function CommVerIconTabsView:GetBtnSwitchCheckedState()
	return self.BtnSwitch:GetCheckedState()
end

function CommVerIconTabsView:SetBtnSwitchCheckedState(EToggleButtonState)
	self.BtnSwitch:SetCheckedState(EToggleButtonState)
end

function CommVerIconTabsView:OnRegisterGameEvent()

end

function CommVerIconTabsView:OnRegisterBinder()

end

function CommVerIconTabsView:OnSelectChanged(Index, ItemData, ItemView, bClick)
	local bClick = bClick
	self.OnSelectionChanged:OnTriggered(Index, ItemData, ItemView, bClick)
end

---UpdateItems
---@param ListData table @ { {IconPath = "IconPath1", {IconPath = "IconPath2"  }
---@private SelectedIndex number @当前选中索引 从 1 开始
---@Param SelectShowType CommVerIconTabsSelectType 勾选表现类型 如需动态变化需传入
function CommVerIconTabsView:UpdateItems(ListData, SelectedIndex, SelectShowType)
	self:SetSelectShowType(SelectShowType)
	local MenuItems = {}
	local Data

	if ListData.Items ~= nil then
		Data = ListData.Items
	else
		Data = ListData
	end
	
	for i = 1, #Data do
		local ViewModel = ObjectPoolMgr:AllocObject(CommVerIconTabItemVM)
		ViewModel:UpdateVM(Data[i])
		table.insert(MenuItems, ViewModel)
	end
	self.BindableList:Update(MenuItems)
	---理论上AdapterTabs.BindableList = self.BindableList,不能重复Clear()
	self.AdapterTabs:UpdateAll(self.BindableList)
	self:SetSelectedIndex(SelectedIndex)
end

function CommVerIconTabsView:SetIsSwitchPanelVisible(IsVisible)
	UIUtil.SetIsVisible(self.PanelSwitch, IsVisible)
end

function CommVerIconTabsView:SetSelectedIndex(SelectedIndex)
	self.AdapterTabs:SetSelectedIndex(SelectedIndex)
end

function CommVerIconTabsView:ScrollIndexIntoView(SelectedIndex)
	self.AdapterTabs:ScrollIndexIntoView(SelectedIndex)
end

function CommVerIconTabsView:SetTabsItemUnlockState(Predicate, bLocked)
	local AdapterTabs = self.AdapterTabs
	if not AdapterTabs then
		return
	end
	local ItemVM = AdapterTabs:GetItemDataByPredicate(Predicate)
	if not ItemVM then
		return
	end

	ItemVM.IsModuleOpen = bLocked
end

function CommVerIconTabsView:SelectIndexPredicate(Pred)
	if self.AdapterTabs then
		local _, Index = self.AdapterTabs:GetItemDataByPredicate(Pred)
		if Index then
			self:SetSelectedIndex(Index)
		end
	end
end

return CommVerIconTabsView