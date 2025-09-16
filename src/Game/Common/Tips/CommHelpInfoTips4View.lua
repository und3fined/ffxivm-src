---
--- Author: Administrator
--- DateTime: 2023-11-07 19:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TipsUtil = require("Utils/TipsUtil")
local UKismetInputLibrary = UE.UKismetInputLibrary
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID

local InfoTipMargin = {
    Left = -35,
    Top = -26,
    Right = -35,
    Bottom = -31,
}

local InfoTipGap = 10

---@class CommHelpInfoTips4View : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBg UFImage
---@field ImgHeading UFImage
---@field PanelTips UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field RichTextContent URichTextBox
---@field RichTextHeading URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommHelpInfoTips4View = LuaClass(UIView, true)

function CommHelpInfoTips4View:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBg = nil
	--self.ImgHeading = nil
	--self.PanelTips = nil
	--self.PopUpBG = nil
	--self.RichTextContent = nil
	--self.RichTextHeading = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommHelpInfoTips4View:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommHelpInfoTips4View:OnInit()

end

function CommHelpInfoTips4View:OnDestroy()

end

function CommHelpInfoTips4View:OnShow()
	if self.Params == nil then
		return
	end

	local Params = self.Params

	self:PlayAnimation(self.AnimShow)
	if Params.Title then
		self.RichTextHeading:SetText(Params.Title)
	end

	if Params.Content then
		self.RichTextContent:SetText(Params.Content)
	end

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

	UIUtil.CanvasSlotSetPosition(self.PanelTips, _G.UE.FVector2D(0, 0))
	UIUtil.CanvasSlotSetAlignment(self.PanelTips, _G.UE.FVector2D(0, 0))
	UIUtil.SetRenderOpacity(self.PanelTips, 0)
	self:RegisterTimer(function ()
		if Params.InTargetWidget then
			TipsUtil.AdjustTipsPosition(self.PanelTips, Params.InTargetWidget, Offset, Alignment)
		end
		UIUtil.SetRenderOpacity(self.PanelTips, 1)
	end, 0.3)

end

function CommHelpInfoTips4View:OnHide()

end

function CommHelpInfoTips4View:OnRegisterUIEvent()

end

function CommHelpInfoTips4View:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
end

function CommHelpInfoTips4View:OnRegisterBinder()
end

function CommHelpInfoTips4View:OnPreprocessedMouseButtonDown(MouseEvent)
	local Params = self.Params

	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if UIUtil.IsUnderLocation(self.PanelTips, MousePosition) == false then
		if Params.HidePopUpBGCallback ~= nil then
			self.PopUpBG:OnClickButtonMask()
		else
			UIViewMgr:HideView(UIViewID.CommHelpInfoSimpleTipsView)
		end
	end
end

return CommHelpInfoTips4View