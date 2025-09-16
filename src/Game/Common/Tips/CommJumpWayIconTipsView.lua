---
--- Author: Administrator
--- DateTime: 2023-09-25 14:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local TipsUtil = require("Utils/TipsUtil")
local CommonUtil = require("Utils/CommonUtil")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

local InfoTipMargin = {
    Left = -10,
    Top = 0,
    Right = -10,
    Bottom = 0,
}

local InfoTipGap = 10

---@class CommJumpWayIconTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonPopUpBG CommonPopUpBGView
---@field PanelTips UFCanvasPanel
---@field SizeBoxIcon USizeBox
---@field TableViewIcon UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommJumpWayIconTipsView = LuaClass(UIView, true)

function CommJumpWayIconTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonPopUpBG = nil
	--self.PanelTips = nil
	--self.SizeBoxIcon = nil
	--self.TableViewIcon = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommJumpWayIconTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonPopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommJumpWayIconTipsView:OnInit()
	self.AdapterTabs = UIAdapterTableView.CreateAdapter(self, self.TableViewIcon, self.OnClickedItem)
	local Callback = function()
		self:Hide()
	end
	self.CommonPopUpBG:SetCallback(self, Callback)
	self.View = nil

	UIUtil.CanvasSlotSetZOrder(self.PanelTips, 1)

end

function CommJumpWayIconTipsView:OnDestroy()
end

function CommJumpWayIconTipsView:OnShow()
	local Params = self.Params
	if Params == nil then
		return
	end

	local HidePopUpBG = self.Params.HidePopUpBG

	if HidePopUpBG then
		UIUtil.SetIsVisible(self.CommonPopUpBG, false)
	end

	if not Params.HidePopUpBG and Params.View and self.Params.HidePopUpBGCallback  then
		UIUtil.SetIsVisible(self.PopUpBG, true, true)
		self.PopUpBG:SetCallback(self.Params.View, self.Params.HidePopUpBGCallback)
	end

	if Params.View then
		self.View = Params.View
	end

	if Params.Data then
		self:UpdateView(Params.Data, Params.SelectedIndex)
	end

	if Params.ViewModel then
		self:UpdateViewByVM(Params.ViewModel, Params.SelectedIndex)
	end

end

function CommJumpWayIconTipsView:OnHide()
	self.AdapterTabs:CancelSelected()
end

function CommJumpWayIconTipsView:OnRegisterUIEvent()

end

function CommJumpWayIconTipsView:OnRegisterGameEvent()
end

function CommJumpWayIconTipsView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.ViewModel = Params.ViewModel

	if nil == self.ViewModel or not CommonUtil.IsA(self.ViewModel, UIViewModel) then
		return
	end

	local Binders = {
		{"DataList", UIBinderUpdateBindableList.New(self, self.AdapterTabs)},
	}

	self:RegisterBinders(self.ViewModel, Binders)
end

function CommJumpWayIconTipsView:SetTipsSize(DataList)
	UIUtil.CanvasSlotSetAutoSize(self.SizeBoxIcon, false)
	local ItemSize = 110 -- 格子宽高一样
	local Row = math.ceil(#DataList / 5)
	local Col = #DataList > 5 and 5 or DataList
	local RowHeight = Row * ItemSize + 10
	local ColHeight = Col * ItemSize + 20
	UIUtil.CanvasSlotSetSize(self.SizeBoxIcon, _G.UE.FVector2D(ColHeight, RowHeight))
	return _G.UE.FVector2D(ColHeight, RowHeight)
end

function CommJumpWayIconTipsView:SetSelectedIndex(SelectedIndex)
	self.AdapterTabs:SetSelectedIndex(SelectedIndex)
end

function CommJumpWayIconTipsView:OnClickedItem(Index, ItemData, ItemView)
	local Params = self.Params
	if nil ~= Params and nil ~= Params.ClickItemCallback and nil ~= self.View then
		Params.ClickItemCallback(self.View, Index, ItemData, ItemView)
	end
end

---UpdateItems
---@param ListData table @ { {Icon = "IconPath1", {Icon = "IconPath2"  }}
---@private SelectedIndex number @当前选中索引 从 1 开始
function CommJumpWayIconTipsView:UpdateView(ListData, SelectedIndex)
	SelectedIndex = SelectedIndex or 1
	local Size = self:SetTipsSize(ListData)
	self.AdapterTabs:UpdateAll(ListData)
	self:SetSelectedIndex(SelectedIndex)

	local InTargetWidget = self.Params.InTargetWidget
	local Offset = self.Params.Offset
	local Alignment = self.Params.Alignment

	if Alignment.X == 0.0 and Alignment.Y  == 0.0 then
		Offset.X = Offset.X - InfoTipMargin.Left - InfoTipGap
		Offset.Y = Offset.Y - InfoTipMargin.Top
	elseif Alignment.X == 1.0 and Alignment.Y == 1.0 then
		Offset.X = Offset.X + InfoTipMargin.Right - InfoTipGap
		Offset.Y = Offset.Y + InfoTipMargin.Bottom
	elseif Alignment.X == 1.0 and Alignment.Y == 0.0 then
		Offset.X = Offset.X + InfoTipMargin.Right - InfoTipGap
		Offset.Y = Offset.Y - InfoTipMargin.Top
	elseif Alignment.X == 0.0 and Alignment.Y == 1.0 then
		Offset.X = Offset.X - InfoTipMargin.Left - InfoTipGap
		Offset.Y = Offset.Y + InfoTipMargin.Bottom
	end

	if InTargetWidget then
		TipsUtil.AdjustTipsPosition(self.PanelTips, InTargetWidget, Offset, Alignment, Size)
	end
end

function CommJumpWayIconTipsView:UpdateViewByVM(VM, SelectedIndex)
	SelectedIndex = SelectedIndex or 1

	local Size = self:SetTipsSize(VM.DataList)
	self.AdapterTabs:UpdateAll(VM.DataList)
	self:SetSelectedIndex(SelectedIndex)

	local InTargetWidget = self.Params.InTargetWidget
	local Offset = self.Params.Offset
	local Alignment = self.Params.Alignment
	if InTargetWidget then
		TipsUtil.AdjustTipsPosition(self.PanelTips, InTargetWidget, Offset, Alignment, Size)
	end
end

return CommJumpWayIconTipsView