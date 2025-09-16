---
--- Author: xingcaicao
--- DateTime: 2023-05-05 10:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class CommPlayerSimpleJobSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgEmpty UFImage
---@field ImgJob UFImage
---@field TextLevel UFTextBlock
---@field TextLevelVisibility ESlateVisibility
---@field TextLevelPosition Vector2D
---@field TextLevelFontInfo SlateFontInfo
---@field TextLevelColor SlateColor
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommPlayerSimpleJobSlotView = LuaClass(UIView, true)

function CommPlayerSimpleJobSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgEmpty = nil
	--self.ImgJob = nil
	--self.TextLevel = nil
	--self.TextLevelVisibility = nil
	--self.TextLevelPosition = nil
	--self.TextLevelFontInfo = nil
	--self.TextLevelColor = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommPlayerSimpleJobSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommPlayerSimpleJobSlotView:OnInit()

end

function CommPlayerSimpleJobSlotView:OnDestroy()

end

function CommPlayerSimpleJobSlotView:OnShow()

end

function CommPlayerSimpleJobSlotView:OnHide()

end

function CommPlayerSimpleJobSlotView:OnRegisterUIEvent()

end

function CommPlayerSimpleJobSlotView:OnRegisterGameEvent()

end

function CommPlayerSimpleJobSlotView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	local Binders = {
		{ "ProfID", 	UIBinderSetProfIcon.New(self, 	self.ImgJob) },
		{ "LevelDesc", 	UIBinderSetText.New(self, 		self.TextLevel) },
		{ "IsEmpty", 	UIBinderSetIsVisible.New(self, 	self.ImgEmpty) },
		{ "IsEmpty", 	UIBinderSetIsVisible.New(self, 	self.ImgJob, true) },
	}

	self:RegisterBinders(ViewModel, Binders)
end

return CommPlayerSimpleJobSlotView