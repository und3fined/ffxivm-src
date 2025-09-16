---
--- Author: Administrator
--- DateTime: 2024-06-28 10:42
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TipsUtil = require("Utils/TipsUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath =  require("Binder/UIBinderSetBrushFromAssetPath")
local CommHelpInfoJumpVM = require("Game/Common/Tips/VM/CommHelpInfoJumpVM")
local FVector2D = _G.UE.FVector2D

local InfoTipMargin = {
    Left = -35,
    Top = -26,
    Right = -35,
    Bottom = -15,
}

local InfoTipGap = 10

---@class CommHelpInfoTips3View : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommJumpWay CommJumpWayItem2View
---@field ImgBg UFImage
---@field PanelJump UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field RedDot CommonSubNormalRedDotView
---@field RichTextHeading URichTextBox
---@field RichTextTitle2 URichTextBox
---@field SizeBox USizeBox
---@field TableViewContent UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommHelpInfoTips3View = LuaClass(UIView, true)

function CommHelpInfoTips3View:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommJumpWay = nil
	--self.ImgBg = nil
	--self.PanelJump = nil
	--self.PanelTips = nil
	--self.PopUpBG = nil
	--self.RedDot = nil
	--self.RichTextHeading = nil
	--self.RichTextTitle2 = nil
	--self.SizeBox = nil
	--self.TableViewContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommHelpInfoTips3View:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommJumpWay)
	self:AddSubView(self.PopUpBG)
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommHelpInfoTips3View:OnInit()
	self.VM = CommHelpInfoJumpVM.New()
	self.TableViewContentAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewContent)
end

function CommHelpInfoTips3View:OnDestroy()

end

function CommHelpInfoTips3View:OnShow()
	if self.Params == nil then
		return
	end

	local Params = self.Params

	self:PlayAnimation(self.AnimShow)
	if Params.Data then
		self.VM:UpdateVM(Params.Data)
		self:UpteDateRedDot(Params.Data.HasJumpRedDot)
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
	UIUtil.SetRenderOpacity(self.PanelTips, 0)
	UIUtil.CanvasSlotSetPosition(self.PanelTips, FVector2D(0, 0))
	UIUtil.CanvasSlotSetAlignment(self.PanelTips, FVector2D(0, 0))
	self:RegisterTimer(function ()
		if Params.InTargetWidget then
			TipsUtil.AdjustTipsPosition(self.PanelTips, Params.InTargetWidget, Offset, Alignment)
		end
		self.TableViewContentAdapter:ScrollToTop()
		UIUtil.SetRenderOpacity(self.PanelTips, 1)
	end, 0.3)
end

function CommHelpInfoTips3View:OnHide()

end

function CommHelpInfoTips3View:UpteDateRedDot(Visible)
	UIUtil.SetIsVisible(self.RedDot.PanelYellowM, Visible)
end

function CommHelpInfoTips3View:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CommJumpWay.BtnGo, self.OnGoClicked)
end

function CommHelpInfoTips3View:OnRegisterGameEvent()
end

function CommHelpInfoTips3View:OnRegisterBinder()
	local Binders = {
		{"Title", UIBinderSetText.New(self, self.RichTextHeading)},
		{"TableViewContentList", UIBinderUpdateBindableList.New(self, self.TableViewContentAdapter)},
		{"SubTitle", UIBinderSetText.New(self, self.RichTextTitle2)},
		{"JumpIcon", UIBinderSetBrushFromAssetPath.New(self, self.CommJumpWay.ImgItemIcon)},
		{"JumpTitle", UIBinderSetText.New(self, self.CommJumpWay.TextQuestName)},
		{"JumpArrowVisible", UIBinderSetIsVisible.New(self, self.CommJumpWay.ImgArrow)},
		{"JumpWayVisible", UIBinderSetIsVisible.New(self, self.CommJumpWay)},
		{"JumpWayVisible", UIBinderSetIsVisible.New(self, self.PanelJump)},
		{"JumpWayVisible", UIBinderSetIsVisible.New(self, self.RichTextTitle2)},
	}

	self:RegisterBinders(self.VM, Binders)
end

function CommHelpInfoTips3View:OnGoClicked()
	--功能未实现
	local Params = self.Params
	if Params == nil then
		return
	end

	local Data = Params.Data

	if Data == nil then
		return
	end

	local JumpWay = Data.JumpWay

	if JumpWay == nil then
		return
	end

	if JumpWay.GoClickedCallback then
		JumpWay.GoClickedCallback(JumpWay.View, JumpWay.ClickedParams)
	end
end

return CommHelpInfoTips3View