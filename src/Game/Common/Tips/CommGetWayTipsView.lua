---
--- Author: v_zanchang
--- DateTime: 2021-12-02 14:12
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local TipsUtil = require("Utils/TipsUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local ItemUtil = require("Utils/ItemUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")

---@class CommGetWayTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonPopUpBG CommonPopUpBGView
---@field PanelGetWayTips UFCanvasPanel
---@field TableViewList UTableView
---@field TextGetWay UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommGetWayTipsView = LuaClass(UIView, true)

function CommGetWayTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonPopUpBG = nil
	--self.PanelGetWayTips = nil
	--self.TableViewList = nil
	--self.TextGetWay = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommGetWayTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonPopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommGetWayTipsView:OnInit()
	self.TableViewListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
	self.Binders = {
		{ "ResID", UIBinderValueChangedCallback.New(self, nil, self.OnItemChanged) },
	}

	self.CommonPopUpBG:SetCallback(self, self.OnClickedCallback)
end

function CommGetWayTipsView:OnDestroy()
	local ViewModel = self.ViewModel
	if nil == ViewModel then
		return
	end

	self:UnRegisterBinder(ViewModel, self.Binders)
end

function CommGetWayTipsView:OnClickedCallback()
	UIViewMgr:HideView(UIViewID.CommGetWayTipsView)
end

function CommGetWayTipsView:OnShow()
	self.CommonPopUpBG.Hide = function()
		self:OnClickedCallback()
	end

	local Params = self.Params
	if nil == Params then
		return
	end
	local InTagetView = Params.InTagetView
	local ForbidRangeWidget = Params.ForbidRangeWidget
	if InTagetView ~= nil then
		ItemTipsUtil.AdjustSecondaryTipsPosition(self.PanelGetWayTips, ForbidRangeWidget, InTagetView)
		if ForbidRangeWidget == nil then
			if Params.AdjustTips == nil then
				local Pos = UIUtil.CanvasSlotGetPosition(self.PanelGetWayTips)
				UIUtil.CanvasSlotSetPosition(self.PanelGetWayTips, Pos + Params.Offset)
				UIUtil.CanvasSlotSetAlignment(self.PanelGetWayTips, Params.Alignment)
			else
				-- 延迟才能获取大小
				TipsUtil.AdjustTipsPosition(self.PanelGetWayTips, InTagetView, Params.Offset, Params.Alignment)
			end
		end
	end

	local HidePopUpBG = Params.HidePopUpBG
	if HidePopUpBG then
		UIUtil.SetIsVisible(self.CommonPopUpBG, false, false)
	else
		UIUtil.SetIsVisible(self.CommonPopUpBG, true, true)
	end

	if not Params.HidePopUpBG and Params.View and self.Params.HidePopUpBGCallback  then
		UIUtil.SetIsVisible(self.PopUpBG, true, true)
		self.PopUpBG:SetCallback(self.Params.View, self.Params.HidePopUpBGCallback)
	end

end

function CommGetWayTipsView:OnHide()
	UIViewMgr:HideView(UIViewID.ItemTips)
	UIViewMgr:HideView(UIViewID.BagItemTips)
	UIViewMgr:HideView(UIViewID.CommHelpInfoTipsView)
end

function CommGetWayTipsView:OnRegisterUIEvent()

end

function CommGetWayTipsView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
end

function CommGetWayTipsView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.ViewModel
	if nil == ViewModel then
		return
	end

	self.ViewModel = ViewModel
	self.Source = ViewModel.Source

	self:RegisterBinders(ViewModel, self.Binders)

	self.TextGetWay:SetText(_G.LSTR(1020057))
end

function CommGetWayTipsView:UpdateVM(VM)
	self.TableViewListAdapter:UpdateAll(VM)
end

function CommGetWayTipsView:UpdateView(DataList)
	self.TableViewListAdapter:UpdateAll(DataList)
end

function CommGetWayTipsView:OnItemChanged(NewValue, OldValue)
	local CommGetWayItems = ItemUtil.GetItemGetWayList(NewValue) or {}
	if self.Params and self.Params.Alignment then
		for i, v in ipairs(CommGetWayItems) do
			CommGetWayItems[i].Alignment = self.Params.Alignment
			CommGetWayItems[i].Source = self.Source
		end
	end
	
	self.TableViewListAdapter:UpdateAll(CommGetWayItems)
end


function CommGetWayTipsView:OnPreprocessedMouseButtonDown(MouseEvent)
	local ViewModel = self.ViewModel
	if ViewModel == nil then
		return
	end
	
	local MousePosition = _G.UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if UIUtil.IsUnderLocation(self.PanelGetWayTips, MousePosition) == false then
		UIViewMgr:HideView(UIViewID.CommGetWayTipsView)
	end
end


return CommGetWayTipsView