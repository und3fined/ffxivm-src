---
--- Author: qibaoyiyi
--- DateTime: 2023-03-13 17:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterCountDown = require("UI/Adapter/UIAdapterCountDown")
local UIBinderUpdateCountDown = require("Binder/UIBinderUpdateCountDown")
local DateTimeTools = require("Common/DateTimeTools")
local ArmyDefine = require("Game/Army/ArmyDefine")
local LocalizationUtil = require("Utils/LocalizationUtil")

---@class ArmyMemberListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FCanvasPanel_14 UFCanvasPanel
---@field FHorizontalBox_133 UFHorizontalBox
---@field ImgClass UFImage
---@field ImgCrossZone UFImage
---@field ImgHead UFImage
---@field ImgJob UFImage
---@field ImgListItemBG UFImage
---@field ImgSelect UImage
---@field TextClassName UFTextBlock
---@field TextCountDown UFTextBlock
---@field TextJobNum UFTextBlock
---@field TextName UFTextBlock
---@field TextRcord UFTextBlock
---@field ToggleBtn UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyMemberListItemView = LuaClass(UIView, true)

function ArmyMemberListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FCanvasPanel_14 = nil
	--self.FHorizontalBox_133 = nil
	--self.ImgClass = nil
	--self.ImgCrossZone = nil
	--self.ImgHead = nil
	--self.ImgJob = nil
	--self.ImgListItemBG = nil
	--self.ImgSelect = nil
	--self.TextClassName = nil
	--self.TextCountDown = nil
	--self.TextJobNum = nil
	--self.TextName = nil
	--self.TextRcord = nil
	--self.ToggleBtn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyMemberListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyMemberListItemView:OnInit()
	self.Binders = {
		{ "RoleName", UIBinderSetText.New(self, self.TextName)},
		{ "JobName", UIBinderSetText.New(self, self.TextJobNum)},
		{ "State", UIBinderSetText.New(self, self.TextRcord)},
		{ "CategoryName", UIBinderSetText.New(self, self.TextClassName)},
		{ "OnlineStatusIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgHead)},
		{ "JobIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgJob)},
		{ "PlaceIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgPlace)},
		{ "CategoryIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgClass)},
		{ "bSelected", UIBinderSetIsChecked.New(self, self.ToggleBtn, true) },
		{ "bOnline", UIBinderValueChangedCallback.New(self, nil, self.OnlineStateChanged)},
		{ "IsShowCrossIcon", UIBinderSetIsVisible.New(self, self.ImgCrossZone)},
	}
	self.TextRcord:SetRenderTranslation(_G.UE.FVector2D(-10, 0))
end

function ArmyMemberListItemView:OnDestroy()
end

function ArmyMemberListItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end
	UIUtil.SetIsVisible(self.TextCountDown, false)
end


function ArmyMemberListItemView:OnHide()
end

function ArmyMemberListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtn, self.OnClickedItem)
end

function ArmyMemberListItemView:OnRegisterGameEvent()

end

function ArmyMemberListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function ArmyMemberListItemView:OnlineStateChanged(Value)
	--UIUtil.SetRenderOpacity(self.FCanvasPanel_14, Value and 1 or 0.5)
	UIUtil.SetRenderOpacity(self.FHorizontalBox_133, Value and 1 or 0.5)
	UIUtil.SetRenderOpacity(self.ImgListItemBG, Value and 1 or 0.5)
end

function ArmyMemberListItemView:OnClickedItem()
	local Params = self.Params
	if nil == Params then
		return
	end
	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end
	Adapter:OnItemClicked(self, Params.Index)
end

---@field IsSelected boolean
function ArmyMemberListItemView:OnSelectChanged(IsSelected)
	self.ToggleBtn:SetChecked(IsSelected, false)
end

return ArmyMemberListItemView