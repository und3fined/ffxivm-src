---
--- Author: Administrator
--- DateTime: 2024-02-22 15:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ItemUtil = require("Utils/ItemUtil")

---@class WardrobeTipsListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BagSlot BagSlotView
---@field BtnList UFButton
---@field ImgSelect UFImage
---@field PanelList UFCanvasPanel
---@field TextBag UFTextBlock
---@field TextName UFTextBlock
---@field TextNum UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeTipsListItemView = LuaClass(UIView, true)

function WardrobeTipsListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BagSlot = nil
	--self.BtnList = nil
	--self.ImgSelect = nil
	--self.PanelList = nil
	--self.TextBag = nil
	--self.TextName = nil
	--self.TextNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeTipsListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BagSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeTipsListItemView:OnInit()
	self.Binders = {
		{ "EquipmentName", UIBinderSetText.New(self, self.TextName)},
		{ "BagNum", UIBinderSetText.New(self, self.TextNum)},
		{ "IsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect)},
	}
end

function WardrobeTipsListItemView:OnDestroy()
end

function WardrobeTipsListItemView:OnShow()
	self.TextBag:SetText(_G.LSTR(1080082))
end

function WardrobeTipsListItemView:OnHide()
end

function WardrobeTipsListItemView:OnRegisterUIEvent()
	-- UIUtil.AddOnClickedEvent(self, self.BtnList, self.OnClickItemView)
	UIUtil.AddOnClickedEvent(self, self.BagSlot.BtnSlot, self.OnClickBagItem)
end

function WardrobeTipsListItemView:OnRegisterGameEvent()
end

function WardrobeTipsListItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
	self.BagSlot:SetParams({Data = ViewModel.BagSlotVM})
end

function WardrobeTipsListItemView:OnClickBagItem()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	local ResID = ViewModel.ID
	if ResID ~= nil and ResID ~= 0 then
		_G.UIViewMgr:HideView(_G.UIViewID.CommGetWayTipsView)
		if Params.Adapter then
			Params.Adapter:CancelSelected()
		end
		ItemTipsUtil.ShowTipsByResID(ResID, self.PanelList, {X = 5,Y = 0})
	end

end

function WardrobeTipsListItemView:OnSelectChanged(bSelected)
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	_G.UIViewMgr:HideView(_G.UIViewID.CommGetWayTipsView)

	ViewModel.IsSelected = bSelected
	ViewModel.ResID = ViewModel.ID
	if ViewModel.IsSelected then
		local ItemList = ItemUtil.GetItemGetWayList(ViewModel.ResID)
		if not table.is_nil_empty(ItemList) then

			local Size = UIUtil.GetWidgetSize(self.PanelList)
			-- local Params = {ViewModel = ViewModel, nil, InTagetView = self.PanelList, Offset =  _G.UE.FVector2D(-Size.X - 20, 96), Alignment = _G.UE.FVector2D(0, 1), HidePopUpBG = true, ParentViewID = _G.UIViewID.WardrobeTips}
			local Params = {ViewModel = ViewModel, nil, InTagetView = self.PanelList, Offset =  _G.UE.FVector2D(-Size.X - 40 , 96), Alignment = _G.UE.FVector2D(1, 1), HidePopUpBG = true, ParentViewID = _G.UIViewID.WardrobeTips}
			Params.AdjustTips = true
			-- self:RegisterTimer(function()
				ItemTipsUtil.OnClickedToGetBtn(Params)
			-- end, 0.3, 0, 1)
		end
	end
end

return WardrobeTipsListItemView