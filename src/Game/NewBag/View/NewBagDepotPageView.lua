---
--- Author: Administrator
--- DateTime: 2023-08-29 03:11
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local DepotVM = require("Game/Depot/DepotVM")
local DepotMgr = _G.DepotMgr
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID

local UIBinderSetCheckedState = require("Binder/UIBinderSetCheckedState")

local UE = _G.UE
local UKismetInputLibrary = UE.UKismetInputLibrary
---@class NewBagDepotPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BagDepotListPage NewBagDepotListPageView
---@field BtnBack CommBackBtnView
---@field BtnRename UFButton
---@field BtnTrim UFButton
---@field CommonRedDot_UIBP CommonRedDotView
---@field DepotPageItem NewBagDepotPageItemView
---@field ImgDepotBg UFImage
---@field ImgIcon UFImage
---@field PanelBagName UFCanvasPanel
---@field TextCapacity UFTextBlock
---@field TextName URichTextBox
---@field TextStorehouse UFTextBlock
---@field ToggleBtnName UToggleButton
---@field AnimBagDepotListIn UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewBagDepotPageView = LuaClass(UIView, true)

function NewBagDepotPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BagDepotListPage = nil
	--self.BtnBack = nil
	--self.BtnRename = nil
	--self.BtnTrim = nil
	--self.CommonRedDot_UIBP = nil
	--self.DepotPageItem = nil
	--self.ImgDepotBg = nil
	--self.ImgIcon = nil
	--self.PanelBagName = nil
	--self.TextCapacity = nil
	--self.TextName = nil
	--self.TextStorehouse = nil
	--self.ToggleBtnName = nil
	--self.AnimBagDepotListIn = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewBagDepotPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BagDepotListPage)
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.CommonRedDot_UIBP)
	self:AddSubView(self.DepotPageItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewBagDepotPageView:OnInit()
	self.Binders = {
		{ "CapacityText", UIBinderSetText.New(self, self.TextCapacity) },
		{ "PageName", UIBinderSetText.New(self, self.TextName) },
		{ "PageIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "IconColor", UIBinderSetColorAndOpacityHex.New(self, self.ImgIcon) },
		{ "DepotListVisible", UIBinderSetIsVisible.New(self, self.BagDepotListPage) },
		{ "CurrentPage", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedPage) },
		{ "ToggleBtnNameState", UIBinderSetCheckedState.New(self, self.ToggleBtnName) },
	}
end

function NewBagDepotPageView:OnDestroy()

end

function NewBagDepotPageView:OnShow()
	local PageIndex = DepotVM:GetCurDepotIndex()
	DepotMgr:QueryDepotDetailInfo(PageIndex)
end

function NewBagDepotPageView:OnHide()

end

function NewBagDepotPageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnTrim, self.OnClickedTrim)
	UIUtil.AddOnClickedEvent(self, self.BtnRename, self.OnClickedRename)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnName, self.OnClickedExpand)
end

function NewBagDepotPageView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
end

function NewBagDepotPageView:OnRegisterBinder()
	self:RegisterBinders(DepotVM, self.Binders)

	self.TextStorehouse:SetText(_G.LSTR(990036))
end

function NewBagDepotPageView:OnClickedExpand()
	DepotVM:SetDepotListVisible(not DepotVM:GetDepotListVisible())
end

function NewBagDepotPageView:OnClickedTrim()
	DepotMgr:SendMsgDepotTrim(DepotVM:GetCurDepotIndex())
end

function NewBagDepotPageView:OnClickedRename()
	UIViewMgr:ShowView(UIViewID.BagDepotRename)
end

function NewBagDepotPageView:OnValueChangedPage(Value)
	self:PlayAnimation(self.AnimBagDepotListIn)
end

function NewBagDepotPageView:OnPreprocessedMouseButtonDown(MouseEvent)
	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if UIUtil.IsUnderLocation(self.BagDepotListPage, MousePosition) == false  and UIUtil.IsUnderLocation(self.PanelBagName, MousePosition) == false then
		DepotVM:SetDepotListVisible(false)
	end
end

return NewBagDepotPageView