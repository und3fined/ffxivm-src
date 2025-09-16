---
--- Author: v_zanchang
--- DateTime: 2023-12-02 14:12
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TipsUtil = require("Utils/TipsUtil")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

local InfoTipMargin = {
    Left = -10,
    Top = 0,
    Right = -10,
    Bottom = -12,
}

local InfoTipGap = 10

---@class CommJumpWayTitleTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonPopUpBG CommonPopUpBGView
---@field PanelGetWayTips UFCanvasPanel
---@field TableViewList UTableView
---@field TextGetWay UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommJumpWayTitleTipsView = LuaClass(UIView, true)

function CommJumpWayTitleTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonPopUpBG = nil
	--self.PanelGetWayTips = nil
	--self.TableViewList = nil
	--self.TextGetWay = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommJumpWayTitleTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonPopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommJumpWayTitleTipsView:OnInit()
	self.TableViewListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
	self.Binders = {
		{ "DataList", UIBinderUpdateBindableList.New(self, self.TableViewListAdapter)},
	}
end

function CommJumpWayTitleTipsView:OnDestroy()
	local ViewModel = self.ViewModel
	if nil == ViewModel then
		return
	end

	self:UnRegisterBinder(ViewModel, self.Binders)
end

function CommJumpWayTitleTipsView:OnShow()
    local Params = self.Params

	if Params == nil then
		return
	end

	if Params.Data ~= nil then
		self.AdapterTabs:UpdateAll(Params.Data)
	end

	local HidePopUpBG = self.Params.HidePopUpBG

	if HidePopUpBG then
		UIUtil.SetIsVisible(self.CommonPopUpBG, false, false)
	end

	if not Params.HidePopUpBG and Params.View and self.Params.HidePopUpBGCallback  then
		UIUtil.SetIsVisible(self.PopUpBG, true, true)
		self.PopUpBG:SetCallback(self, self.HidePopUpBGCallBack)
	end

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

	if Params.InTargetWidget then
		TipsUtil.AdjustTipsPosition(self.PanelTips, Params.InTargetWidget, Offset, Alignment)
	end

end

function CommJumpWayTitleTipsView:OnHide()

end

function CommJumpWayTitleTipsView:OnRegisterUIEvent()

end

function CommJumpWayTitleTipsView:OnRegisterGameEvent()

end

function CommJumpWayTitleTipsView:OnRegisterBinder()
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
end

function CommJumpWayTitleTipsView:UpdateVM(VM)
	self.TableViewListAdapter:UpdateAll(VM)
end

function CommJumpWayTitleTipsView:UpdateView(DataList)
	self.TableViewListAdapter:UpdateAll(DataList)
end

return CommJumpWayTitleTipsView