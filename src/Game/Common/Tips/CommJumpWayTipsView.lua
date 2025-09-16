---
--- Author: Administrator
--- DateTime: 2023-09-25 14:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local TipsUtil = require("Utils/TipsUtil")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")
local UIViewModel = require("UI/UIViewModel")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UKismetInputLibrary = _G.UE.UKismetInputLibrary
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID

local InfoTipMargin = {
    Left = -10,
    Top = -2,
    Right = -10,
    Bottom = -15,
}

local InfoTipGap = 10

---@class CommJumpWayTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonPopUpBG CommonPopUpBGView
---@field PanelTips UFCanvasPanel
---@field TableViewList UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommJumpWayTipsView = LuaClass(UIView, true)

function CommJumpWayTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonPopUpBG = nil
	--self.PanelTips = nil
	--self.TableViewList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommJumpWayTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonPopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommJumpWayTipsView:OnInit()
	self.AdapterTabs = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnItemSelectChanged)
end

function CommJumpWayTipsView:OnDestroy()
end

function CommJumpWayTipsView:OnShow()
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
		self.PopUpBG:SetCallback(self.Params.View, self.Params.HidePopUpBGCallback)
	end

	local Offset = self.Params.Offset
	local Alignment = self.Params.Alignment

	if Alignment.X == 0.0 and Alignment.Y  == 0.0 then
		Offset.X = Offset.X - InfoTipMargin.Left - InfoTipGap + 5
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
		local SizeX = self.AdapterTabs.EntryWidth
		local SizeY = self.AdapterTabs:GetNum() * self.AdapterTabs.EntryHeight
		TipsUtil.AdjustTipsPosition(self.PanelTips, Params.InTargetWidget, Offset, Alignment, _G.UE.FVector2D(SizeX, SizeY))
	end

end

function CommJumpWayTipsView:OnHide()
end

function CommJumpWayTipsView:OnRegisterUIEvent()
end

function CommJumpWayTipsView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
end

function CommJumpWayTipsView:OnRegisterBinder()

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

---OnItemSelectChanged
---@param Index number
---@param ItemData any
---@param ItemView UIView
function CommJumpWayTipsView:OnItemSelectChanged(Index, ItemData, ItemView)
	self.AdapterTabs:SetSelectedIndex(Index)
end

function CommJumpWayTipsView:UpdateView(ListData)
	self.AdapterTabs:UpdateAll(ListData)
end

function CommJumpWayTipsView:UpdateViewByVM(VM)
	self.AdapterTabs:UpdateAll(VM)
end

function CommJumpWayTipsView:OnPreprocessedMouseButtonDown(MouseEvent)
	local Params = self.Params

	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if UIUtil.IsUnderLocation(self.PanelTips, MousePosition) == false then
		if Params ~= nil and Params.HidePopUpBGCallback ~= nil then
			self.PopUpBG:OnClickButtonMask()
		else
			UIViewMgr:HideView(UIViewID.CommJumpWayTipsView)
		end
	end
end


return CommJumpWayTipsView