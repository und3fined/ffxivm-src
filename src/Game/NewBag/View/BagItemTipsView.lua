---
--- Author: Administrator
--- DateTime: 2023-09-13 14:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local BagItemTipsVM = require("Game/NewBag/VM/BagItemTipsVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local DepotVM = require("Game/Depot/DepotVM")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local TipsUtil = require("Utils/TipsUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local ItemUtil = require("Utils/ItemUtil")
--local RichTextUtil = require("Utils/RichTextUtil")
--local ItemCfg = require("TableCfg/ItemCfg")

local UE = _G.UE
local UKismetInputLibrary = UE.UKismetInputLibrary
local LSTR = _G.LSTR
local BagMgr = _G.BagMgr
---@class BagItemTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BagSlotTips ItemTipsFrameNewView
---@field BtnDeposit CommBtnLView
---@field BtnTake CommBtnLView
---@field PanelBtn UFCanvasPanel
---@field PanelDetail UFCanvasPanel
---@field AnimMoreIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BagItemTipsView = LuaClass(UIView, true)

function BagItemTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BagSlotTips = nil
	--self.BtnDeposit = nil
	--self.BtnTake = nil
	--self.PanelBtn = nil
	--self.PanelDetail = nil
	--self.AnimMoreIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BagItemTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BagSlotTips)
	self:AddSubView(self.BtnDeposit)
	self:AddSubView(self.BtnTake)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BagItemTipsView:OnInit()
	self.ViewModel = BagItemTipsVM.New()
	self.Binders = {
		{"DepositBtnVisible", UIBinderSetIsVisible.New(self, self.BtnDeposit) },
		{"TakeBtnVisible", UIBinderSetIsVisible.New(self, self.BtnTake) },
	
		{ "DepositBtnEnabled", UIBinderSetIsEnabled.New(self, self.BtnDeposit) },
		{ "TakeBtnEnabled", UIBinderSetIsEnabled.New(self, self.BtnTake) },
	
	}
end

function BagItemTipsView:OnDestroy()

end

function BagItemTipsView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.HideCallback = Params.HideCallback

	local ItemView = Params.SlotView
	if nil ~= ItemView then
		ItemTipsUtil.AdjustTipsPosition(self.PanelDetail, ItemView, Params.Offset)
	end

	local ItemData = Params.ItemData
	if nil ~= ItemData then
		self.ViewModel:UpdateVM(ItemData, Params.DepotIndex)	
	end
end


function BagItemTipsView:OnHide()
	local HideCallback = self.HideCallback
	if nil ~= HideCallback then
		HideCallback()
	end
end

function BagItemTipsView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnDeposit.Button, self.OnClickedDepositBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnTake.Button, self.OnClickedTakeBtn)
end

function BagItemTipsView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonUp, self.OnPreprocessedMouseButtonUp)
end

function BagItemTipsView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)

	self.BtnDeposit:SetButtonText(LSTR(990069))
	self.BtnTake:SetButtonText(LSTR(990070))
end

function BagItemTipsView:OnPreprocessedMouseButtonUp(MouseEvent)
	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if UIUtil.IsUnderLocation(self.PanelDetail, MousePosition) == false then
		if UIViewMgr:IsViewVisible(UIViewID.CommGetWayTipsView) == false then
			UIViewMgr:HideView(UIViewID.BagItemTips)
		end
	end
end

function BagItemTipsView:OnClickedDepositBtn()
	if self.ViewModel.Value.Num > 1 then
		UIViewMgr:ShowView(UIViewID.BagDepotTransfer, {Item = self.ViewModel.Value})
	else
		BagMgr:SendMsgBagTransDepot(self.ViewModel.Value.GID, DepotVM:GetCurDepotIndex(), 0)
	end
	self:Hide()
end

function BagItemTipsView:OnClickedTakeBtn()
	if self.ViewModel.Value.Num > 1 then
		UIViewMgr:ShowView(UIViewID.BagDepotTransfer, {Item = self.ViewModel.Value, DepotIndex = self.ViewModel.DepotIndex})
	else
		_G.DepotMgr:SendMsgDepotTransfer(DepotVM:GetCurDepotIndex(), self.ViewModel.DepotIndex, self.ViewModel.Value.GID)
	end
	self:Hide()
end

return BagItemTipsView