---
--- Author: Administrator
--- DateTime: 2023-12-05 10:29
--- Description:
---
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ArmyItemTipsVM = require("Game/Army/VM/ArmyItemTipsVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ArmyDefine = require("Game/Army/ArmyDefine")
local ArmyMgr = nil
local ArmyDepotPageVM = nil
local ArmyDepotPanelVM = nil
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local BagMgr = nil

local UE = _G.UE
local UKismetInputLibrary = UE.UKismetInputLibrary

--@class ArmyItemTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BagSlotTips ItemTipsFrameNewView
---@field BtnDeposit CommBtnLView
---@field BtnTake CommBtnLView
---@field PanelBtn UFCanvasPanel
---@field PanelDetail UFCanvasPanel
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyItemTipsView = LuaClass(UIView, true)

function ArmyItemTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BagSlotTips = nil
	--self.BtnDeposit = nil
	--self.BtnTake = nil
	--self.PanelBtn = nil
	--self.PanelDetail = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyItemTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BagSlotTips)
	self:AddSubView(self.BtnDeposit)
	self:AddSubView(self.BtnTake)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyItemTipsView:OnInit()
	self.ViewModel = ArmyItemTipsVM.New()
	self.ViewModel:OnInit()
	ArmyMgr = require("Game/Army/ArmyMgr")
	BagMgr = require("Game/Bag/BagMgr")
 	ArmyDepotPanelVM = ArmyMainVM:GetDepotPanelVM()
    ArmyDepotPageVM = ArmyDepotPanelVM:GetDepotPageVM()
end

function ArmyItemTipsView:OnDestroy()

end

function ArmyItemTipsView:OnShow()
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
		self:UpdateItem(ItemData, Params.DepotIndex)
	end

	-- LSTR string:存  入
	self.BtnDeposit:SetText(LSTR(910095))
	-- LSTR string:取  出
	self.BtnTake:SetText(LSTR(910080))
end

function ArmyItemTipsView:UpdateItem(Value, DepotIndex)
	--self.BagSlotTips:UpdateUI(Value)
	self.ViewModel:UpdateVM(Value, DepotIndex)
end


function ArmyItemTipsView:OnPreprocessedMouseButtonDown(MouseEvent)
	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if UIUtil.IsUnderLocation(self.PanelDetail, MousePosition) == false then
		UIViewMgr:HideView(UIViewID.ArmyItemTips)
	end
end

function ArmyItemTipsView:OnHide()
	local HideCallback = self.HideCallback
	if nil ~= HideCallback then
		HideCallback()
	end
end

function ArmyItemTipsView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnDeposit.Button, self.OnClickedDepositBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnTake.Button, self.OnClickedTakeBtn)
end

function ArmyItemTipsView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
end

function ArmyItemTipsView:OnRegisterBinder()
	self.Binders = {
		{"DepositBtnVisible", UIBinderSetIsVisible.New(self, self.BtnDeposit) },
		{"TakeBtnVisible", UIBinderSetIsVisible.New(self, self.BtnTake) },

		{ "DepositBtnEnabled", UIBinderSetIsEnabled.New(self, self.BtnDeposit, false, true) },
		{ "TakeBtnEnabled", UIBinderSetIsEnabled.New(self, self.BtnTake, false, true) },
		{ "bPanelBtn", UIBinderSetIsVisible.New(self, self.PanelBtn) }
	}
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function ArmyItemTipsView:OnClickedDepositBtn()
	local DepositBtnEnabled = self.ViewModel:GetDepositBtnEnabled()
	if DepositBtnEnabled == false then
		local IsAvailableCurDepot = self.ViewModel:GetIsAvailableCurDepot()
		if not IsAvailableCurDepot then
			---暂无权限，请联系管理者
			MsgTipsUtil.ShowTipsByID(145010)
		else
			---该物品不可存入
			MsgTipsUtil.ShowTipsByID(145083)
		end
		return
	end
	local CurIndex = ArmyDepotPageVM:GetCurDepotIndex()
	if ArmyDepotPanelVM:IsAvailableDepot(CurIndex) then
		if ArmyDepotPageVM:GetDepotNumState() == ArmyDefine.DepotNumState.Full then
			---判断是否有可堆叠的空间
			local NuFullItemNum = _G.ArmyMgr:GetGroupStoreItemNumberStacksByResID(self.ViewModel.Value.ResID, CurIndex)
			if NuFullItemNum ~= 0 then
				if self.ViewModel.Value.Num > 1 then
					UIViewMgr:ShowView(UIViewID.ArmySelectQuantityWin, {Item = self.ViewModel.Value, DepotIndex = CurIndex, IsTake = false, NuFullItemNum = NuFullItemNum})
				else
					ArmyMgr:SendGroupStoreDepositItemAndCheck(CurIndex, self.ViewModel.Value.GID, self.ViewModel.Value.Num, self.ViewModel.Value.ResID)
				end
			else
			---部队仓库空间不足
			MsgTipsUtil.ShowTipsByID(145031)
			end
		else
			if self.ViewModel.Value.Num > 1 then
				UIViewMgr:ShowView(UIViewID.ArmySelectQuantityWin, {Item = self.ViewModel.Value, DepotIndex = CurIndex, IsTake = false})
			else
				ArmyMgr:SendGroupStoreDepositItemAndCheck(CurIndex, self.ViewModel.Value.GID, self.ViewModel.Value.Num, self.ViewModel.Value.ResID)
			end
		end
	-- else
	-- 	-- LSTR string:没有该仓库权限
	-- 	MsgTipsUtil.ShowTips(LSTR(910171)) 
	end
	self:Hide()
end

function ArmyItemTipsView:OnClickedTakeBtn()
	local TakeBtnEnabled = self.ViewModel:GetTakeBtnEnabled()
	if TakeBtnEnabled == false then
		---暂无权限，请联系管理者 ---不可取出的物品理论上走到这里服务器数据就有问题，没有不可取出的提示，仅做拦截
		MsgTipsUtil.ShowTipsByID(145010)
		return
	end
	local CurIndex = ArmyDepotPageVM:GetCurDepotIndex()
	local IsBagFull = BagMgr:GetBagLeftNum() == 0
	if IsBagFull then
		---todo 背包堆叠判断，需要找背包要接口
		-- LSTR string:背包空间不足
		MsgTipsUtil.ShowTips(LSTR(910210)) 
	elseif ArmyDepotPanelVM:IsAvailableDepot(CurIndex) then
		if self.ViewModel.Value.Num > 1 then
			UIViewMgr:ShowView(UIViewID.ArmySelectQuantityWin, {Item = self.ViewModel.Value, DepotIndex = CurIndex, IsTake = true})
		else
			ArmyMgr:SendGroupStoreFetChItemAndCheck(CurIndex,self.ViewModel.Value.GID, self.ViewModel.Value.ResID, self.ViewModel.Value.Num )
		end
	else
		-- -- 没有该仓库权限
		-- MsgTipsUtil.ShowTipsByID(145084)
	end	
	self:Hide()
end


return ArmyItemTipsView