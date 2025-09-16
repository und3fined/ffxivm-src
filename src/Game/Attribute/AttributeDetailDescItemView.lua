---
--- Author: enqingchen
--- DateTime: 2021-12-31 16:03
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class AttributeDetailDescItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field DescItem UFVerticalBox
---@field FImg_Closed UFButton
---@field FImg_Open UFButton
---@field ImgLevelSync UFImage
---@field Img_Cutline2 UFImage
---@field OpenBtn UToggleButton
---@field PanelDesc UFCanvasPanel
---@field Spacer4Topic USpacer
---@field Text_Attri UFTextBlock
---@field Text_AttriValue UFTextBlock
---@field Text_Desc URichTextBox
---@field Text_Gain UFTextBlock
---@field Text_MainTag UFTextBlock
---@field Text_Type UFTextBlock
---@field TitleItem UFCanvasPanel
---@field VerticalItem UFVerticalBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AttributeDetailDescItemView = LuaClass(UIView, true)

function AttributeDetailDescItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.DescItem = nil
	--self.FImg_Closed = nil
	--self.FImg_Open = nil
	--self.ImgLevelSync = nil
	--self.Img_Cutline2 = nil
	--self.OpenBtn = nil
	--self.PanelDesc = nil
	--self.Spacer4Topic = nil
	--self.Text_Attri = nil
	--self.Text_AttriValue = nil
	--self.Text_Desc = nil
	--self.Text_Gain = nil
	--self.Text_MainTag = nil
	--self.Text_Type = nil
	--self.TitleItem = nil
	--self.VerticalItem = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AttributeDetailDescItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AttributeDetailDescItemView:OnInit()

end

function AttributeDetailDescItemView:OnDestroy()

end

function AttributeDetailDescItemView:OnShow()

end

function AttributeDetailDescItemView:OnHide()

end

function AttributeDetailDescItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.OpenBtn, self.OnOpenBtnChange)
end

function AttributeDetailDescItemView:OnRegisterGameEvent()

end

function AttributeDetailDescItemView:OnRegisterBinder()
	self.ViewModel = self.Params.Data
	local Binders = {
		{ "ItemType", UIBinderValueChangedCallback.New(self, nil, self.OnItemTypeChange) },
		{ "bOpen", UIBinderValueChangedCallback.New(self, nil, self.OnItemOpenChange) },
		{ "LeftText", UIBinderSetText.New(self, self.Text_Attri) },
		{ "LeftText", UIBinderSetText.New(self, self.Text_Type) },
		{ "LeftSubText", UIBinderSetText.New(self, self.Text_MainTag) },
		{ "RightText", UIBinderSetText.New(self, self.Text_AttriValue) },
		{ "RightSubText", UIBinderSetText.New(self, self.Text_Gain) },
		{ "RightSubTextColor", UIBinderSetColorAndOpacityHex.New(self, self.Text_Gain) },
		{ "DescText", UIBinderSetText.New(self, self.Text_Desc) },
		{ "bIsLastItem", UIBinderSetIsVisible.New(self, self.Img_Cutline2, true) },
		{ "bInLevelSync", UIBinderSetIsVisible.New(self, self.ImgLevelSync) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function AttributeDetailDescItemView:OnItemTypeChange()
	if self.ViewModel.ItemType == 0 then
		--Title
		UIUtil.SetIsVisible(self.DescItem, false)
		UIUtil.SetIsVisible(self.TitleItem, true)
		UIUtil.SetIsVisible(self.Spacer4Topic, true)
	elseif self.ViewModel.ItemType == 1 then
		--Desc
		UIUtil.SetIsVisible(self.DescItem, true)
		UIUtil.SetIsVisible(self.TitleItem, false)
	end
end

function AttributeDetailDescItemView:OnItemOpenChange()
	UIUtil.SetIsVisible(self.Text_Desc, self.ViewModel.bOpen)
	self.OpenBtn:SetChecked(self.ViewModel.bOpen, false)
end

function AttributeDetailDescItemView:OnOpenBtnChange(ToggleButton, ButtonState)
	local bOpen = ButtonState == _G.UE.EToggleButtonState.Checked

	local Params = _G.EventMgr:GetEventParams()
	Params.IntParam1 = self.ViewModel.Index
	Params.BoolParam1 = bOpen
	_G.EventMgr:SendEvent(_G.EventID.AttributeDetailOpen, Params)
end

return AttributeDetailDescItemView