---
--- Author: zimuyi
--- DateTime: 2023-03-23 19:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local RechargingHelpVM = require("Game/Recharging/VM/RechargingHelpVM")

local LSTR = _G.LSTR
local StepCount = 5

---@class RechargingHelpWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameLView
---@field BtnConfirm CommBtnLView
---@field BtnLeft UFButton
---@field BtnRight UFButton
---@field ImgFoldLeft UFImage
---@field ImgFoldRight UFImage
---@field ImgHelp1 UFImage
---@field ImgHelp3 UFImage
---@field ImgHelp5 UFImage
---@field ImgNormal1 UFImage
---@field ImgNormal2 UFImage
---@field ImgNormal3 UFImage
---@field ImgSelect1 UFImage
---@field ImgSelect2 UFImage
---@field ImgSelect3 UFImage
---@field ImgStep2 UFImage
---@field ImgStep4 UFImage
---@field PanelDisplay UFCanvasPanel
---@field PanelHelp1 UFCanvasPanel
---@field PanelHelp2 UFCanvasPanel
---@field PanelHelp3 UFCanvasPanel
---@field PanelStep1 UFCanvasPanel
---@field PanelStep2 UFCanvasPanel
---@field PanelStep3 UFCanvasPanel
---@field PanelStep4 UFCanvasPanel
---@field PanelStep5 UFCanvasPanel
---@field TextHelp1 UFTextBlock
---@field TextHelp2 UFTextBlock
---@field TextHelp3 UFTextBlock
---@field TextHelp4 UFTextBlock
---@field TextHelp5 UFTextBlock
---@field TextSort1 UFTextBlock
---@field TextSort2 UFTextBlock
---@field TextSort3 UFTextBlock
---@field TextSort4 UFTextBlock
---@field TextSort5 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local RechargingHelpWinView = LuaClass(UIView, true)

function RechargingHelpWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnConfirm = nil
	--self.BtnLeft = nil
	--self.BtnRight = nil
	--self.ImgFoldLeft = nil
	--self.ImgFoldRight = nil
	--self.ImgHelp1 = nil
	--self.ImgHelp3 = nil
	--self.ImgHelp5 = nil
	--self.ImgNormal1 = nil
	--self.ImgNormal2 = nil
	--self.ImgNormal3 = nil
	--self.ImgSelect1 = nil
	--self.ImgSelect2 = nil
	--self.ImgSelect3 = nil
	--self.ImgStep2 = nil
	--self.ImgStep4 = nil
	--self.PanelDisplay = nil
	--self.PanelHelp1 = nil
	--self.PanelHelp2 = nil
	--self.PanelHelp3 = nil
	--self.PanelStep1 = nil
	--self.PanelStep2 = nil
	--self.PanelStep3 = nil
	--self.PanelStep4 = nil
	--self.PanelStep5 = nil
	--self.TextHelp1 = nil
	--self.TextHelp2 = nil
	--self.TextHelp3 = nil
	--self.TextHelp4 = nil
	--self.TextHelp5 = nil
	--self.TextSort1 = nil
	--self.TextSort2 = nil
	--self.TextSort3 = nil
	--self.TextSort4 = nil
	--self.TextSort5 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function RechargingHelpWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnConfirm)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function RechargingHelpWinView:OnInit()
	self.MaxPage = self.PanelDisplay:GetChildrenCount()
	RechargingHelpVM.MaxPage = self.MaxPage

	self.Binders = {
		{ "IsConfirm", UIBinderSetIsVisible.New(self, self.BtnConfirm, false, true, true) },
		{ "IsLeft", UIBinderSetIsVisible.New(self, self.BtnLeft, false, true, true) },
		{ "IsRight", UIBinderSetIsVisible.New(self, self.BtnRight, false, true, true) },
		{ "CurrentPage", UIBinderValueChangedCallback.New(self, nil, self.OnPageChanged) },
	}
end

function RechargingHelpWinView:OnDestroy()

end

function RechargingHelpWinView:OnShow()
	self.BG:SetTitleText(LSTR(940026))
	self.BtnConfirm:SetBtnName(LSTR(940027))
	for Index = 1, StepCount do
		local SortKey = string.format("TextSort%d", Index)
		local HelpKey = string.format("TextHelp%d", Index)
		self[SortKey]:SetText(tostring(Index))
		self[HelpKey]:SetText(LSTR(940028 + Index))
	end
	self.BG.PopUpBG:SetHideOnClick(false)
	RechargingHelpVM:ChangePage(1)
end

function RechargingHelpWinView:OnHide()

end

function RechargingHelpWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnLeft, self.OnLeftClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnRight, self.OnRightClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnConfirm, self.OnConfirmClicked)
end

function RechargingHelpWinView:OnRegisterGameEvent()

end

function RechargingHelpWinView:OnRegisterBinder()
	self:RegisterBinders(RechargingHelpVM, self.Binders)
end

function RechargingHelpWinView:OnPageChanged(CurrentPage)
	for Page = 1, self.MaxPage do
		local Visible = Page == CurrentPage
		-- 页面内容切换
		local PagePanel = string.format("PanelHelp%d", Page)
		UIUtil.SetIsVisible(self[PagePanel], Visible, false, false)
		for _, SubPanel in ipairs(self[PagePanel]:GetAllChildren():ToTable()) do
			UIUtil.SetIsVisible(SubPanel, Visible, false, false)
		end
		-- 小圆点切换
		local SelectPoint = string.format("ImgSelect%d", Page)
		UIUtil.SetIsVisible(self[SelectPoint], Visible, false, false)
	end
end

function RechargingHelpWinView:OnLeftClicked()
	RechargingHelpVM:GoLeftPage()
end

function RechargingHelpWinView:OnRightClicked()
	RechargingHelpVM:GoRightPage()
end

function RechargingHelpWinView:OnConfirmClicked()
	self:Hide()
end

return RechargingHelpWinView