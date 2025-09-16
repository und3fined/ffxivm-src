---
--- Author: Administrator
--- DateTime: 2024-10-25 16:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
---@class OpsCommTabParentItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconNewcomers UFImage
---@field IconNormal UFImage
---@field IconSelect UFImage
---@field ImgNormal UFImage
---@field ImgNormalDown UFImage
---@field ImgNormalDown_Selected UFImage
---@field ImgNormalUp UFImage
---@field ImgSelect UFImage
---@field ImgUnlock UFImage
---@field NormalDown_Node UCanvasPanel
---@field RedDot CommonRedDotView
---@field TextName UFTextBlock
---@field AnimCheck UWidgetAnimation
---@field AnimFold UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimUncheck UWidgetAnimation
---@field AnimUnfold UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsCommTabParentItemView = LuaClass(UIView, true)
local MenuGetSelectKeyFun = nil
function OpsCommTabParentItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconNewcomers = nil
	--self.IconNormal = nil
	--self.IconSelect = nil
	--self.ImgNormal = nil
	--self.ImgNormalDown = nil
	--self.ImgNormalDown_Selected = nil
	--self.ImgNormalUp = nil
	--self.ImgSelect = nil
	--self.ImgUnlock = nil
	--self.NormalDown_Node = nil
	--self.RedDot = nil
	--self.TextName = nil
	--self.AnimCheck = nil
	--self.AnimFold = nil
	--self.AnimIn = nil
	--self.AnimUncheck = nil
	--self.AnimUnfold = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsCommTabParentItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsCommTabParentItemView:OnInit()
	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "NameColor", UIBinderSetColorAndOpacityHex.New(self, self.TextName) },
		{ "ImgPic", UIBinderSetBrushFromAssetPath.New(self, self.IconNormal) },
		{ "SelectImgPic", UIBinderSetBrushFromAssetPath.New(self, self.IconSelect) },
		{ "DownArrowVisible", UIBinderSetIsVisible.New(self, self.NormalDown_Node) },
		{ "UpArrowVisible", UIBinderSetIsVisible.New(self, self.ImgNormalUp) },
		{ "NewcomersVisible", UIBinderSetIsVisible.New(self, self.IconNewcomers) },
		{ "SelectVisible", UIBinderSetIsVisible.New(self, self.ImgSelect) },
		{ "SelectVisible", UIBinderSetIsVisible.New(self, self.IconSelect) },
		{ "SelectVisible", UIBinderSetIsVisible.New(self, self.ImgNormalDown_Selected) },
		{ "IsExpanded", UIBinderValueChangedCallback.New(self, nil, self.OnExpandedChanged) },
	}
	
end

function OpsCommTabParentItemView:OnDestroy()

end

function OpsCommTabParentItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	ViewModel:UpdateArrowVisible()

	self.RedDot:SetRedDotNameByString(_G.OpsActivityMgr:GetRedDotName(ViewModel.Classcify))
end

function OpsCommTabParentItemView:OnHide()
	UIUtil.SetIsVisible(self.ImgNormalUp, false)
	UIUtil.SetIsVisible(self.NormalDown_Node, false)
	self:StopAllAnimations()
end

function OpsCommTabParentItemView:OnRegisterUIEvent()

end

function OpsCommTabParentItemView:OnRegisterGameEvent()

end

function OpsCommTabParentItemView:OnRegisterBinder()
	local Params = self.Params
	if not Params then return end
		
	local ViewModel = Params.Data

	self:RegisterBinders(ViewModel, self.Binders)
end

function OpsCommTabParentItemView:OnSelectChanged(IsSelected)
	local Params = self.Params
	if not Params then return end
	local ViewModel = Params.Data
	if not ViewModel then return end
	if IsSelected then
		self:PlayAnimation(self.AnimCheck)
	else
		self:PlayAnimation(self.AnimUncheck)
	end

end


function OpsCommTabParentItemView:OnExpandedChanged(IsExpanded, OldValue)
	local Params = self.Params
	if not Params then return end
	local ViewModel = Params.Data
	if not ViewModel then return end

	if IsExpanded then
		_G.OpsActivityMgr:RecordRedDotClicked(ViewModel:GetFirstActivityID(), _G.TimeUtil.GetServerLogicTime())
	end
end


return OpsCommTabParentItemView