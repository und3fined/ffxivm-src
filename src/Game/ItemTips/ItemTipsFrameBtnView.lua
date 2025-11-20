---
--- Author: Administrator
--- DateTime: 2025-05-30 20:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local TipsUtil = require("Utils/TipsUtil")

local UE = _G.UE
local UKismetInputLibrary = UE.UKismetInputLibrary

---@class ItemTipsFrameBtnView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BagSlotTips ItemTipsFrameNewView
---@field BtnMore UFButton
---@field CommBtnXSL1 CommBtnXSLView
---@field CommBtnXSL2 CommBtnXSLView
---@field PanelBtn UFCanvasPanel
---@field PanelMore UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field RedDot CommonRedDotView
---@field AnimUpdate UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ItemTipsFrameBtnView = LuaClass(UIView, true)

function ItemTipsFrameBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BagSlotTips = nil
	--self.BtnMore = nil
	--self.CommBtnXSL1 = nil
	--self.CommBtnXSL2 = nil
	--self.PanelBtn = nil
	--self.PanelMore = nil
	--self.PanelTips = nil
	--self.RedDot = nil
	--self.AnimUpdate = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ItemTipsFrameBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BagSlotTips)
	self:AddSubView(self.CommBtnXSL1)
	self:AddSubView(self.CommBtnXSL2)
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ItemTipsFrameBtnView:OnInit()

end

function ItemTipsFrameBtnView:OnDestroy()

end

function ItemTipsFrameBtnView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.HideCallback = Params.HideCallback

	local ItemView = Params.ItemView
	if nil ~= ItemView then
		ItemTipsUtil.AdjustTipsPosition(self.PanelTips, ItemView, Params.Offset, Params.CustomBottomMargin)
	else
		if nil ~= Params.Offset then
			ItemTipsUtil.AdjustTipsPositionByPos(self.PanelTips, Params.Offset, Params.CustomBottomMargin)
		end
	end

	self:UpdateBtnInfo(Params.BtnInfoArray)

end

function ItemTipsFrameBtnView:UpdateBtnInfo(BtnInfoArray)
	UIUtil.SetIsVisible(self.PanelBtn, false)
	if BtnInfoArray == nil or #BtnInfoArray == 0 then
		return
	end

	UIUtil.SetIsVisible(self.PanelBtn, true)

	if #BtnInfoArray == 1 then
		UIUtil.SetIsVisible(self.CommBtnXSL2, false)
		UIUtil.SetIsVisible(self.PanelMore, false)
		self.CommBtnXSL1:SetButtonText(BtnInfoArray[1].BtnText)
		
	elseif #BtnInfoArray == 2 then
		UIUtil.SetIsVisible(self.CommBtnXSL2, true)
		UIUtil.SetIsVisible(self.PanelMore, false)
		self.CommBtnXSL1:SetButtonText(BtnInfoArray[1].BtnText)
		self.CommBtnXSL2:SetButtonText(BtnInfoArray[2].BtnText)
		
	else
		UIUtil.SetIsVisible(self.CommBtnXSL2, false)
		UIUtil.SetIsVisible(self.PanelMore, true)
		self.CommBtnXSL1:SetButtonText(BtnInfoArray[1].BtnText)
	end
end


function ItemTipsFrameBtnView:OnHide()
	local HideCallback = self.HideCallback
	if nil ~= HideCallback then
		HideCallback()
	end
end

function ItemTipsFrameBtnView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CommBtnXSL1.Button, self.OnClickedCommBtnXSL1)
	UIUtil.AddOnClickedEvent(self, self.CommBtnXSL2.Button, self.OnClickedCommBtnXSL2)
	UIUtil.AddOnClickedEvent(self, self.BtnMore, self.OnClickedBtnMore)

end

function ItemTipsFrameBtnView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonUp, self.OnPreprocessedMouseButtonUp)
end

function ItemTipsFrameBtnView:OnPreprocessedMouseButtonUp(MouseEvent)
	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if UIUtil.IsUnderLocation(self.PanelTips, MousePosition) == false then
		if UIViewMgr:IsViewVisible(UIViewID.CommGetWayTipsView) == false then
			UIViewMgr:HideView(UIViewID.ItemBtnTips)
		end
	end
end

function ItemTipsFrameBtnView:OnRegisterBinder()
end

function ItemTipsFrameBtnView:OnClickedCommBtnXSL1()
	self:OnClickBtnIndex(1)

end

function ItemTipsFrameBtnView:OnClickedCommBtnXSL2()
	self:OnClickBtnIndex(2)
end


function ItemTipsFrameBtnView:OnClickedBtnMore()
	local Params = self.Params
	if nil == Params then
		return
	end

	local BtnInfoArray = Params.BtnInfoArray
	if BtnInfoArray == nil or #BtnInfoArray < 2 then
		return
	end

	if UIViewMgr:IsViewVisible(UIViewID.CommStorageTipsView) then
		UIViewMgr:HideView(UIViewID.CommStorageTipsView)
	else
		local BtnList = {}
		for i = 2, #BtnInfoArray do
			table.insert(BtnList, {Content = BtnInfoArray[i].BtnText, ClickItemCallback = self.OnClickedBtn, View = self, Value = BtnInfoArray[i]})
		end
		local BtnSize = UIUtil.CanvasSlotGetSize(self.BtnMore)
		TipsUtil.ShowStorageBtnsTips(BtnList, self.BtnMore, _G.UE.FVector2D(-BtnSize.X /2, 0), _G.UE.FVector2D(0.5, 1), false)
	end
end



function ItemTipsFrameBtnView:OnClickedBtn(ItemData)
	local Value = ItemData.Value
	if Value and Value.ClickedCallBack then
		Value.ClickedCallBack(Value.ListenView)
	end

	UIViewMgr:HideView(UIViewID.CommStorageTipsView)
	UIViewMgr:HideView(UIViewID.ItemBtnTips)
end



function ItemTipsFrameBtnView:OnClickBtnIndex(Index)
	local Params = self.Params
	if nil == Params then
		return
	end

	local BtnInfoArray = Params.BtnInfoArray
	if BtnInfoArray == nil or #BtnInfoArray < Index then
		return
	end
	
	if BtnInfoArray[Index].ClickedCallBack then
		BtnInfoArray[Index].ClickedCallBack(BtnInfoArray[Index].ListenView)
	end

	self:Hide()
end

return ItemTipsFrameBtnView