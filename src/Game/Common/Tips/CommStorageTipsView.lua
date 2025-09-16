---
--- Author: Administrator
--- DateTime: 2023-09-25 11:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TipsUtil = require("Utils/TipsUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UKismetInputLibrary = UE.UKismetInputLibrary
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID

local InfoTipMargin = {
    Left = -10,
    Top = -11,
    Right = -10,
    Bottom = -12,
}

local InfoTipGap = 10

---@class CommStorageTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelTips UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field TableViewArrange1 UTableView
---@field TableViewArrange2 UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommStorageTipsView = LuaClass(UIView, true)

function CommStorageTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelTips = nil
	--self.PopUpBG = nil
	--self.TableViewArrange1 = nil
	--self.TableViewArrange2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommStorageTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommStorageTipsView:OnInit()
	self.AdapterList1 = UIAdapterTableView.CreateAdapter(self, self.TableViewArrange1)
	self.AdapterList2 = UIAdapterTableView.CreateAdapter(self, self.TableViewArrange2)
	self.Mid = 0
end

function CommStorageTipsView:OnDestroy()
end

function CommStorageTipsView:OnShow()
	local Params = self.Params
	if Params == nil then
		return
	end

	if Params.View then
		self.View = Params.View
	end
	UIUtil.SetRenderOpacity(self.PanelTips, 0)
	self:UpdateView(Params.Data)

	if Params.HidePopUpBG then
		UIUtil.SetIsVisible(self.PopUpBG, false, false)
	end

	if not Params.HidePopUpBG and Params.View and self.Params.HidePopUpBGCallback  then
		UIUtil.SetIsVisible(self.PopUpBG, true, true)
		self.PopUpBG:SetCallback(self.Params.View, self.Params.HidePopUpBGCallback)
	end
	self:RegisterTimer(function ()
		UIUtil.SetRenderOpacity(self.PanelTips, 1)
	end, 0.1)
end

function CommStorageTipsView:OnHide()
end

function CommStorageTipsView:OnRegisterUIEvent()
end

function CommStorageTipsView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
end

function CommStorageTipsView:OnRegisterBinder()
end

function CommStorageTipsView:UpdateView(ListData)
	local MaxRow = 6
	if ListData then
		local List1 = {} -- {Content,Callback}
		local List2 = {}
		if #ListData <= MaxRow then
			List1 = ListData
			UIUtil.SetIsVisible(self.AdapterList2, false)
		else
			UIUtil.SetIsVisible(self.AdapterList2, true)
			self.Mid = math.ceil(#ListData / 2)

			for index, value in ipairs(ListData) do
				if index <= self.Mid then
					table.insert(List1, value)
				else
					table.insert(List2, value)
				end
			end
		end

		self.AdapterList1:UpdateAll(List1)
		self.AdapterList2:UpdateAll(List2)
	end

	if self.Params == nil then
		return
	end

	local InTargetWidget = self.Params.InTargetWidget
	local Offset = self.Params.Offset or _G.UE.FVector2D(0, 0)
	local Alignment = self.Params.Alignment or _G.UE.FVector2D(0, 0)

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

	local ListDataLen = ListData ~= nil and #ListData or 0
	local X = ListDataLen > MaxRow and self.AdapterList1.EntryWidth * 2 or self.AdapterList1.EntryWidth
	local Y = self.AdapterList1:GetNum() * self.AdapterList1.EntryHeight

	if InTargetWidget then
		TipsUtil.AdjustTipsPosition(self.PanelTips, InTargetWidget, _G.UE.FVector2D(Offset.X, Offset.Y), Alignment, _G.UE.FVector2D(X, Y))
	end

end

function CommStorageTipsView:SetParams(Params)

	if Params == nil then
		return
	end
	
	if Params.View then
		self.View = Params.View
	end

	if Params.HidePopUpBG then
		UIUtil.SetIsVisible(self.PopUpBG, false, false)
	end

	if not Params.HidePopUpBG and Params.View and self.Params.HidePopUpBGCallback  then
		UIUtil.SetIsVisible(self.PopUpBG, true, true)
		self.PopUpBG:SetCallback(self.Params.View, self.Params.HidePopUpBGCallback)
	end
end

function CommStorageTipsView:HidePopUpBGCallBack()
	if self.Params.View and self.Params.HidePopUpBGCallback then
		self.Params.HidePopUpBGCallback(self.Params.View)
	end

	self:Hide()
end

function CommStorageTipsView:OnPreprocessedMouseButtonDown(MouseEvent)
	local Params = self.Params

	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if UIUtil.IsUnderLocation(self.PanelTips, MousePosition) == false then
		if Params ~= nil and Params.HidePopUpBGCallback ~= nil then
			self.PopUpBG:OnClickButtonMask()
		else
			UIViewMgr:HideView(UIViewID.CommStorageTipsView)
		end
	end
end




return CommStorageTipsView