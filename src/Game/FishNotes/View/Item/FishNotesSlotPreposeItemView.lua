---
--- Author: Administrator
--- DateTime: 2023-04-17 18:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class FishNotesSlotPreposeItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FishSlot FishNotesSlotItemView
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishNotesSlotPreposeItemView = LuaClass(UIView, true)

function FishNotesSlotPreposeItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FishSlot = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishNotesSlotPreposeItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.FishSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishNotesSlotPreposeItemView:OnInit()
	self.Binders = {
		{ "IoreIcon", UIBinderSetBrushFromAssetPath.New(self, self.FishSlot.ImgIcon) },
		{ "IoreNum", UIBinderSetText.New(self, self.FishSlot.RichTextNum) },
		{ "IoreName", UIBinderSetText.New(self, self.TextName) },
	}
end

function FishNotesSlotPreposeItemView:OnDestroy()

end

function FishNotesSlotPreposeItemView:OnShow()
	UIUtil.SetIsVisible(self.FishSlot.RichTextNum, true, false, false)
end

function FishNotesSlotPreposeItemView:OnHide()

end

function FishNotesSlotPreposeItemView:OnRegisterUIEvent()

end

function FishNotesSlotPreposeItemView:OnRegisterGameEvent()

end

function FishNotesSlotPreposeItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

return FishNotesSlotPreposeItemView