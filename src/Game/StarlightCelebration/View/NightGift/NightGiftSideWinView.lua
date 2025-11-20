---
--- Author: Administrator
--- DateTime: 2025-07-29 18:55
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local OpsStarlightDefine = require("Game/StarlightCelebration/OpsStarlightDefine")
local EToggleButtonState = _G.UE.EToggleButtonState
---@class NightGiftSideWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field BtnInfo UFButton
---@field BtnSwitch UToggleButton
---@field CommEmpty_1 CommBackpackEmptyView
---@field CommSideBarTabs_UIBP CommSideBarTabsView
---@field CommonTitle CommonTitleView
---@field EditQuantityItem CommEditQuantityItemView
---@field FHorizontalTitle UFHorizontalBox
---@field IconSwitchCheck UFImage
---@field IconSwitchUnCheck UFImage
---@field ImgSwitchBG UFImage
---@field Sidebar UFCanvasPanel
---@field TableViewSlot_1 UTableView
---@field TextName_1 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NightGiftSideWinView = LuaClass(UIView, true)

function NightGiftSideWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnInfo = nil
	--self.BtnSwitch = nil
	--self.CommEmpty_1 = nil
	--self.CommSideBarTabs_UIBP = nil
	--self.CommonTitle = nil
	--self.EditQuantityItem = nil
	--self.FHorizontalTitle = nil
	--self.IconSwitchCheck = nil
	--self.IconSwitchUnCheck = nil
	--self.ImgSwitchBG = nil
	--self.Sidebar = nil
	--self.TableViewSlot_1 = nil
	--self.TextName_1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NightGiftSideWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommEmpty_1)
	self:AddSubView(self.CommSideBarTabs_UIBP)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.EditQuantityItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NightGiftSideWinView:OnInit()
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot_1)
	self.TableViewAdapter:SetOnClickedCallback(self.OnItemClicked)

	self.Binders = {
		{"ItemNameText", UIBinderSetText.New(self, self.TextName_1)},
		{"EmptyVisible", UIBinderSetIsVisible.New(self, self.CommEmpty_1) },
		{"CurrentItemVMList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },
		{"IsToggleChecked", UIBinderSetIsChecked.New(self, self.BtnSwitch, true)},
		{"EditQuantityVisible", UIBinderSetIsVisible.New(self, self.EditQuantityItem) },
		{"BtnInfoVisible", UIBinderSetIsVisible.New(self, self.BtnInfo, false, true )},
	}
end

function NightGiftSideWinView:OnDestroy()

end

function NightGiftSideWinView:OnShow()
	self.EditQuantityItem:SetInputLowerLimit(1)
	self.EditQuantityItem:SetInputUpperLimit(1)

	self.EditQuantityItem:SetCurValue(1)

	self.EditQuantityItem:SetModifyValueCallback(function (ConfirmValue)
		if self.ViewModel.CurGiftItem then
			self.ViewModel.CurGiftItem.Num = ConfirmValue
			self.ViewModel:UpdateGiftItemList()
		end
	end)
end

function NightGiftSideWinView:OnHide()

end

function NightGiftSideWinView:OnSelectChanged(IsSelected)
	self.BtnSwitch:SetChecked(IsSelected, false)
end

function NightGiftSideWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSwitch, self.OnClickButtonSwitch)
	UIUtil.AddOnClickedEvent(self, self.BtnInfo, self.OnClickBtnInfoButton)
end

function NightGiftSideWinView:OnRegisterGameEvent()

end

function NightGiftSideWinView:OnClickBtnInfoButton()
	local CurGiftItem = self.ViewModel.CurGiftItem
	if CurGiftItem then
		local ItemTipsUtil = require("Utils/ItemTipsUtil")
		local BagItem = _G.BagMgr:GetItemDataByGID(CurGiftItem.GID)
		ItemTipsUtil.ShowTipsByItem(BagItem , self.BtnInfo)
	end
end

function NightGiftSideWinView:OnRegisterBinder()
	local ViewModel = self.Params
	self.ViewModel = ViewModel
	self:RegisterBinders(self.ViewModel, self.Binders)
	self.CommonTitle:SetTextTitleName(_G.LSTR(990052))
end

function NightGiftSideWinView:OnClickButtonSwitch()
	local CurChecked = self.ViewModel:GetIsChecked()
	if CurChecked == true then
		self.BtnSwitch:SetCheckedState(EToggleButtonState.Unchecked)
	else
		self.BtnSwitch:SetCheckedState(EToggleButtonState.Checked)
	end
	
	self.ViewModel:SetIsChecked(not CurChecked)
end

function NightGiftSideWinView:OnItemClicked(Index, ItemData, ItemView)
	local AddSucc = self.ViewModel:AddItemToGiftList(ItemData.GID, ItemData.Item)
	if AddSucc then
		self.EditQuantityItem:SetInputLowerLimit(1)
		self.EditQuantityItem:SetInputUpperLimit(ItemData.Item.Num)

		local CurGiftItem = self.ViewModel.CurGiftItem
		if CurGiftItem then
			self.EditQuantityItem:SetCurValue(CurGiftItem.Num)
		else
			self.EditQuantityItem:SetCurValue(1)
		end
	end

end

return NightGiftSideWinView