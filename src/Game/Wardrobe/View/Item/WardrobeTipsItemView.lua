---
--- Author: Administrator
--- DateTime: 2024-02-22 15:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local TipsUtil = require("Utils/TipsUtil")
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local UKismetInputLibrary = _G.UE.UKismetInputLibrary
local WardrobeMainPanelVM = require("Game/Wardrobe/VM/WardrobeMainPanelVM")

---@class WardrobeTipsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonPopUpBG CommonPopUpBGView
---@field PanelGetWayTips UFCanvasPanel
---@field TableViewList UTableView
---@field TextGetWay UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeTipsItemView = LuaClass(UIView, true)

function WardrobeTipsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonPopUpBG = nil
	--self.PanelGetWayTips = nil
	--self.TableViewList = nil
	--self.TextGetWay = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeTipsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonPopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeTipsItemView:OnInit()
	-- 装备菜单列表
	self.EquipementListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList, nil, true)

	self.Binders = {
		{"SameEquipmentList", UIBinderUpdateBindableList.New(self, self.EquipementListAdapter)},
	}
end

function WardrobeTipsItemView:OnDestroy()

end

function WardrobeTipsItemView:OnShow()
	if self.Params == nil then
		return
	end
	local TargetView = self.Params.TargetView
	local Offset = self.Params.Offset
	local Alignment = self.Params.Alignment
	UIUtil.SetRenderOpacity(self.PanelGetWayTips, 0)
	if self.Params.TargetView ~= nil and self.Params.Offset ~= nil and self.Params.Alignment then
		self:RegisterTimer(function ()
			local MaxSize = UIUtil.GetWidgetSize(self.PanelGetWayTips)
			TipsUtil.AdjustTipsPosition(self.PanelGetWayTips, TargetView, Offset, Alignment, MaxSize)
			UIUtil.SetRenderOpacity(self.PanelGetWayTips, 1)
		end, 0.3)
	end

	self.TextGetWay:SetText(_G.LSTR(1080081))
end

function WardrobeTipsItemView:OnHide()
end

function WardrobeTipsItemView:OnRegisterUIEvent()
end

function WardrobeTipsItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
	self:RegisterGameEvent(_G.EventID.WardrobeTipOpenGetWayView, self.OnWardrobeTipOpenGetWayView)
	self:RegisterGameEvent(_G.EventID.BagUpdate, self.OnUpdateBag)
end

function WardrobeTipsItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function WardrobeTipsItemView:SetCallback(View, Callback)
	self.View = View
	self.Callback = Callback
end

function WardrobeTipsItemView:OnUpdateBag()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	local ItemVM = WardrobeMainPanelVM:UpdateSameEquipmentList(ViewModel.ApperanceID)
	ViewModel.SameEquipmentList = ItemVM.SameEquipmentList
end


function WardrobeTipsItemView:UpdateSameEquipmentListSelectIndex(Index)
	self.EquipementListAdapter:SetSelectedIndex(Index)
end

function WardrobeTipsItemView:OnPreprocessedMouseButtonDown(MouseEvent)
	local Params = self.Params
	-- local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	-- if UIUtil.IsUnderLocation(self.PanelGetWayTips, MousePosition) == false then
	-- 	UIViewMgr:HideView(UIViewID.WardrobeTips)
	-- end
end

function WardrobeTipsItemView:OnWardrobeTipOpenGetWayView()
	self:Hide()
end


return WardrobeTipsItemView