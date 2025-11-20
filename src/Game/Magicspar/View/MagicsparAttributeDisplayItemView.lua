---
--- Author: jamiyang
--- DateTime: 2025-06-26 11:02
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TipsUtil = require("Utils/TipsUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class MagicsparAttributeDisplayItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnWarning UFButton
---@field ImgWarning UFImage
---@field TextDisplay UFTextBlock
---@field TextNum URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MagicsparAttributeDisplayItemView = LuaClass(UIView, true)

function MagicsparAttributeDisplayItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnWarning = nil
	--self.ImgWarning = nil
	--self.TextDisplay = nil
	--self.TextNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MagicsparAttributeDisplayItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MagicsparAttributeDisplayItemView:OnInit()
	self.Binders = {
		{ "AttrName", UIBinderSetText.New(self, self.TextDisplay) },
		{ "AttrValue", UIBinderSetText.New(self, self.TextNum) },
		{ "bShowWarning", UIBinderSetIsVisible.New(self, self.BtnWarning, false, true) },
	}
end

function MagicsparAttributeDisplayItemView:OnDestroy()

end

function MagicsparAttributeDisplayItemView:OnShow()

end

function MagicsparAttributeDisplayItemView:OnHide()

end

function MagicsparAttributeDisplayItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnWarning, self.OnClickBtnWarning)
end

function MagicsparAttributeDisplayItemView:OnRegisterGameEvent()

end

function MagicsparAttributeDisplayItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function MagicsparAttributeDisplayItemView:OnClickBtnWarning()
	TipsUtil.ShowInfoTips(self.ViewModel.ExceedText, self.BtnWarning, _G.UE.FVector2D(0, 0), _G.UE.FVector2D(0, 0))
end
return MagicsparAttributeDisplayItemView