---
--- Author: Administrator
--- DateTime: 2025-07-04 22:05
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TipsUtil = require("Utils/TipsUtil")

local FLOG_WARNING = _G.FLOG_WARNING
local FVector2D = _G.UE.FVector2D

---@class CommReportTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnReport UFButton
---@field PanelBtnReportTips UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field TextReport UFTextBlock
---@field AnimShow UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommReportTipsView = LuaClass(UIView, true)

function CommReportTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnReport = nil
	--self.PanelBtnReportTips = nil
	--self.PopUpBG = nil
	--self.TextReport = nil
	--self.AnimShow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommReportTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommReportTipsView:OnInit()

end

function CommReportTipsView:OnDestroy()

end

function CommReportTipsView:OnShow()
	if self.Params == nil then
		FLOG_WARNING("CommReportTipsView Params is nil! ")
		return
	end

	local Params = self.Params
	local HidePopUpBG = Params.HidePopUpBG

	if HidePopUpBG then
		UIUtil.SetIsVisible(self.PopUpBG, false, false)
	end

	if not Params.HidePopUpBG and Params.View and self.Params.HidePopUpBGCallback  then
		UIUtil.SetIsVisible(self.PopUpBG, true, true)
		self.PopUpBG:SetCallback(self.Params.View, self.Params.HidePopUpBGCallback)
	end

	local Offset = Params.Offset
	local Alignment = Params.Alignment
	UIUtil.CanvasSlotSetPosition(self.PanelBtnReportTips, FVector2D(0, 0))
	UIUtil.CanvasSlotSetAlignment(self.PanelBtnReportTips, FVector2D(0, 0))
	UIUtil.SetRenderOpacity(self.PanelBtnReportTips, 0)

	self:RegisterTimer(function ()
		if Params.InTargetWidget then
			TipsUtil.AdjustTipsPosition(self.PanelBtnReportTips, Params.InTargetWidget, Offset, Alignment)
		else
			TipsUtil.AdjustTipsPositionByPos(self.PanelBtnReportTips, Offset, Alignment)
		end
		UIUtil.SetRenderOpacity(self.PanelBtnReportTips, 1)
		self:PlayAnimation(self.AnimShow)
	end, 0.3)
end

function CommReportTipsView:OnHide()

end

function CommReportTipsView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnReport, self.OnClickBtnReport)
end

function CommReportTipsView:OnRegisterGameEvent()
end

function CommReportTipsView:OnRegisterBinder()

end

function CommReportTipsView:OnClickBtnReport()
	local Params = self.Params
	if Params and Params.ClickCallback then
		Params.ClickCallback()
	end
    self:Hide()
end

return CommReportTipsView