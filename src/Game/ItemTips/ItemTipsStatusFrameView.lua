---
--- Author: anypkvcai
--- DateTime: 2022-03-24 09:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local LSTR = _G.LSTR
---@class ItemTipsStatusFrameView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bind UFCanvasPanel
---@field CommonPopUpBG CommonPopUpBGView
---@field Improve UFCanvasPanel
---@field Line USizeBox
---@field Line1 USizeBox
---@field PanelRoot UFCanvasPanel
---@field TextBind UFTextBlock
---@field TextBindDesc UFTextBlock
---@field TextImprove UFTextBlock
---@field TextImproveDesc UFTextBlock
---@field TextOnly UFTextBlock
---@field TextOnlyDesc UFTextBlock
---@field Unique UFCanvasPanel
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ItemTipsStatusFrameView = LuaClass(UIView, true)

function ItemTipsStatusFrameView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bind = nil
	--self.CommonPopUpBG = nil
	--self.Improve = nil
	--self.Line = nil
	--self.Line1 = nil
	--self.PanelRoot = nil
	--self.TextBind = nil
	--self.TextBindDesc = nil
	--self.TextImprove = nil
	--self.TextImproveDesc = nil
	--self.TextOnly = nil
	--self.TextOnlyDesc = nil
	--self.Unique = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ItemTipsStatusFrameView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonPopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ItemTipsStatusFrameView:OnInit()
	self.Binders = {
		{ "ShowBindTips", UIBinderSetIsVisible.New(self, self.Bind) },
		{ "ShowOnlyTips", UIBinderSetIsVisible.New(self, self.Unique) },
		{ "ShowImproveTips", UIBinderSetIsVisible.New(self, self.Improve) },
	}
end

function ItemTipsStatusFrameView:OnDestroy()

end

function ItemTipsStatusFrameView:OnShow()
	self.CommonPopUpBG.Hide = function()
		UIViewMgr:HideView(UIViewID.ItemTipsStatus)
		local Params = self.Params
		if nil == Params then
			return
		end

		local ViewModel = Params.ViewModel
		if nil == ViewModel then
			return
		end
		ViewModel:SetShowOnlyTips(false)
		ViewModel:SetShowBindTips(false)
	end

	local Params = self.Params
	if nil == Params then
		return
	end
	UIUtil.SetIsVisible(self.Line, false)
	UIUtil.SetIsVisible(self.Line1, false)
	
	self.ClickPos = Params.ClickPos
	if self.ClickPos ~= nil then
		self.ClickPos.X = self.ClickPos.X - 500
		self.ClickPos.Y = self.ClickPos.Y + 30
		local Slot = _G.UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Object)
		Slot:SetPosition(self.ClickPos)
	end

	local ShowState = Params.ShowState
	if nil ~= ShowState then
		UIUtil.SetIsVisible(self.Bind,ShowState.ShowBindTips)
		UIUtil.SetIsVisible(self.Unique,ShowState.ShowOnlyTips)
	end

	local InTagetView = Params.InTagetView
	if nil ~= InTagetView then
		ItemTipsUtil.AdjustSecondaryTipsPosition(self.PanelRoot, Params.ForbidRangeWidget, InTagetView)
	end

	local HidePopUpBG = Params.HidePopUpBG
	if HidePopUpBG then
		UIUtil.SetIsVisible(self.CommonPopUpBG, false, false)
	else
		UIUtil.SetIsVisible(self.CommonPopUpBG, true, true)
	end

	if not Params.HidePopUpBG and Params.View and self.Params.HidePopUpBGCallback  then
		UIUtil.SetIsVisible(self.PopUpBG, true, true)
		self.PopUpBG:SetCallback(self.Params.View, self.Params.HidePopUpBGCallback)
	end

end

function ItemTipsStatusFrameView:OnHide()

end

function ItemTipsStatusFrameView:OnRegisterUIEvent()

end

function ItemTipsStatusFrameView:OnRegisterGameEvent()

end

function ItemTipsStatusFrameView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.ViewModel
	if nil == ViewModel then
		return
	end


	self:RegisterBinders(ViewModel, self.Binders)

	self.TextBind:SetText(LSTR(1020052))
	self.TextBindDesc:SetText(LSTR(1020053))
	self.TextOnly:SetText(LSTR(1020054))
	self.TextOnlyDesc:SetText(LSTR(1020055))
	self.TextImprove:SetText(LSTR(1020045))
	self.TextImproveDesc:SetText(LSTR(1020056))
end

return ItemTipsStatusFrameView