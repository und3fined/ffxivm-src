---
--- Author: Administrator
--- DateTime: 2023-08-17 08:17
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromIconID = require("Binder/UIBinderSetBrushFromIconID")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local TipsUtil = require("Utils/TipsUtil")
local CurrencyTipsVM = require("Game/ItemTips/VM/CurrencyTipsVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local UKismetInputLibrary = UE.UKismetInputLibrary
local LSTR = _G.LSTR
---@class CurrencyTipsFrameView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnToGet UFButton
---@field CurrencyItem CurrencyTipsItemView
---@field ImgItem UFImage
---@field ImgShowBar UFImage
---@field PanelGo UFCanvasPanel
---@field PanelOwn UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field PanelToGet UFCanvasPanel
---@field RichTextOwn URichTextBox
---@field TextName UFTextBlock
---@field TextOwn UFTextBlock
---@field TextToGet UFTextBlock
---@field TextType UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimUpdate UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CurrencyTipsFrameView = LuaClass(UIView, true)

function CurrencyTipsFrameView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnToGet = nil
	--self.CurrencyItem = nil
	--self.ImgItem = nil
	--self.ImgShowBar = nil
	--self.PanelGo = nil
	--self.PanelOwn = nil
	--self.PanelTips = nil
	--self.PanelToGet = nil
	--self.RichTextOwn = nil
	--self.TextName = nil
	--self.TextOwn = nil
	--self.TextToGet = nil
	--self.TextType = nil
	--self.AnimIn = nil
	--self.AnimUpdate = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CurrencyTipsFrameView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CurrencyItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CurrencyTipsFrameView:OnInit()
	self.ViewModel = CurrencyTipsVM.New()
	self.Binders = {
		{ "TypeName", UIBinderSetText.New(self, self.TextType) },
		{ "ItemName", UIBinderSetText.New(self, self.TextName) },
		{ "IconID",	UIBinderSetBrushFromIconID.New(self, self.ImgItem) },
		{ "IntroText", UIBinderSetText.New(self, self.CurrencyItem.TextIntro) },
		{ "OwnRichText", UIBinderSetText.New(self, self.RichTextOwn) },
		{ "ToGetVisible", UIBinderSetIsVisible.New(self, self.PanelGo) },
	}
end

function CurrencyTipsFrameView:OnDestroy()

end

function CurrencyTipsFrameView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	self.HideCallback = Params.HideCallback

	local IsTopBar = Params.IsTopBar
	local ItemView = Params.ItemView
	if nil ~= ItemView then
		if IsTopBar then
			ItemTipsUtil.AdjustTopBarTipsPosition(self.PanelTips, ItemView, Params.Offset)
		else
			ItemTipsUtil.AdjustTipsPosition(self.PanelTips, ItemView, Params.Offset)
		end
	else
		if nil ~= Params.Offset then
			ItemTipsUtil.AdjustTipsPositionByPos(self.PanelTips, Params.Offset)
		end
	end

	local ItemData = Params.ItemData
	if nil ~= ItemData then
		self.ViewModel:UpdateVM(ItemData)
	end
	---部队战绩特殊需求
	local IsHidePanelOwn = Params.IsHidePanelOwn
	UIUtil.SetIsVisible(self.PanelOwn, not IsHidePanelOwn)
end

function CurrencyTipsFrameView:OnHide()
	local HideCallback = self.HideCallback
	if nil ~= HideCallback then
		HideCallback()
	end

	--UIViewMgr:HideView(UIViewID.CommGetWayTipsView)
	--UIViewMgr:HideView(UIViewID.ItemTipsStatus)
end

function CurrencyTipsFrameView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnToGet, self.OnClickedToGetBtn)
end

function CurrencyTipsFrameView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)

end

function CurrencyTipsFrameView:OnRegisterBinder()
	local ViewModel = self.ViewModel
	if ViewModel == nil then
		return
	end
	

	self:RegisterBinders(ViewModel, self.Binders)
	self.TextToGet:SetText(LSTR(1000056))
	self.TextOwn:SetText(LSTR(1020033))
end

function CurrencyTipsFrameView:OnPreprocessedMouseButtonDown(MouseEvent)
	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if UIUtil.IsUnderLocation(self.PanelTips, MousePosition) == false then
		UIViewMgr:HideView(UIViewID.CurrencyTips)
	end
end

function CurrencyTipsFrameView:OnClickedToGetBtn()
	local ViewModel = self.ViewModel
	if ViewModel == nil then
		return
	end

	local Params = {ViewModel = self.ViewModel, ForbidRangeWidget = self.PanelTips, InTagetView = self.BtnToGet}
	ItemTipsUtil.OnClickedToGetBtn(Params)

end

return CurrencyTipsFrameView