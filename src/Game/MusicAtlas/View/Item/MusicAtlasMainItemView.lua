---
--- Author: Administrator
--- DateTime: 2023-12-21 10:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local EventID = require("Define/EventID")



---@class MusicAtlasMainItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSelect UFButton
---@field ImgGrey UFImage
---@field ImgGreySlect UFImage
---@field ImgGreySlect2 UFImage
---@field ImgNormal UFImage
---@field ImgNormalSelect UFImage
---@field ImgNormalSelect2 UFImage
---@field PanelGrey UFCanvasPanel
---@field PanelNormal UFCanvasPanel
---@field RedDot CommonRedDot2View
---@field TextGreyName UFTextBlock
---@field TextNarmalName UFTextBlock
---@field AnimSelect UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MusicAtlasMainItemView = LuaClass(UIView, true)

function MusicAtlasMainItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSelect = nil
	--self.ImgGrey = nil
	--self.ImgGreySlect = nil
	--self.ImgGreySlect2 = nil
	--self.ImgNormal = nil
	--self.ImgNormalSelect = nil
	--self.ImgNormalSelect2 = nil
	--self.PanelGrey = nil
	--self.PanelNormal = nil
	--self.RedDot = nil
	--self.TextGreyName = nil
	--self.TextNarmalName = nil
	--self.AnimSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MusicAtlasMainItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MusicAtlasMainItemView:OnInit()
	self.Binders = {
		{ "GreyName", UIBinderSetText.New(self, self.TextGreyName) },
		{ "NarmalName", UIBinderSetText.New(self, self.TextNarmalName) },
		{ "PanelGreyVisible", UIBinderSetIsVisible.New(self, self.PanelGrey) },
		{ "PanelNormalVisible", UIBinderSetIsVisible.New(self, self.PanelNormal) },
		{ "GreySlect", UIBinderSetIsVisible.New(self, self.ImgGreySlect) },
		{ "NormalSelect", UIBinderSetIsVisible.New(self, self.ImgNormalSelect) },
		{ "GreySlect2", UIBinderSetIsVisible.New(self, self.ImgGreySlect2) },
		{ "NormalSelect2", UIBinderSetIsVisible.New(self, self.ImgNormalSelect2) },
		{ "ImgGreyType", UIBinderSetBrushFromAssetPath.New(self, self.ImgGrey) },
		{ "ImgGreySeleceType", UIBinderSetBrushFromAssetPath.New(self, self.ImgGreySlect) },
		{ "ImgGreySelece2Type", UIBinderSetBrushFromAssetPath.New(self, self.ImgGreySlect2) },
		{ "ImgNormalType", UIBinderSetBrushFromAssetPath.New(self, self.ImgNormal) },
		{ "ImgNormalSelectType", UIBinderSetBrushFromAssetPath.New(self, self.ImgNormalSelect) },
		{ "ImgNormalSelect2Type", UIBinderSetBrushFromAssetPath.New(self, self.ImgNormalSelect2) },
		
	}
end

function MusicAtlasMainItemView:OnDestroy()

end

function MusicAtlasMainItemView:OnShow()
	--红点
	self.MusicID = self.ViewModel.MusicID
	if table.contain(_G.MusicPlayerMgr.RedDotList, self.MusicID) then
		self.RedDotName = _G.MusicPlayerMgr.RedDotName.. "/".. self.MusicID
		self.RedDot:SetRedDotNameByString(self.RedDotName)
	end
end

function MusicAtlasMainItemView:OnHide()

end

function MusicAtlasMainItemView:OnRegisterUIEvent()

end

function MusicAtlasMainItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.UpdateAtlasItemRed, self.UpdateRed)

end

function MusicAtlasMainItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

function MusicAtlasMainItemView:OnSelectChanged(NewValue, IsByClick)
	if NewValue then
		self:PlayAnimation(self.AnimSelect)
	end
	self.ViewModel:UpdateSelectState(NewValue)
	-- if self.ViewModel.IsUnLock then
	-- 	UIUtil.SetIsVisible(self.ImgNormalSelect, NewValue)
	-- else
	-- 	UIUtil.SetIsVisible(self.ImgGreySlect, NewValue)
	-- end
end

function MusicAtlasMainItemView:UpdateRed(MusicID)
	if MusicID == self.ViewModel.MusicID then
		self.RedDotName = _G.MusicPlayerMgr.RedDotName.. "/".. MusicID
		self.RedDot:SetRedDotNameByString(self.RedDotName)
	end
end

return MusicAtlasMainItemView