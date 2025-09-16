---
--- Author: stellahxhu
--- DateTime: 2022-08-16 15:45
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class CommPageTabHorTeamView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImageIcon UFImage
---@field ImageUnderline UFImage
---@field TabHorItem UFCanvasPanel
---@field TextName UFTextBlock
---@field ToggleButtonItem UToggleButton
---@field AnimSelect UWidgetAnimation
---@field AnimSelect_Short UWidgetAnimation
---@field AnimToLong UWidgetAnimation
---@field AnimToShort UWidgetAnimation
---@field AnimUnSelect UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommPageTabHorTeamView = LuaClass(UIView, true)
local LastSelected = nil-- 变量用于记录上次被点击CommPageTabHor
function CommPageTabHorTeamView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImageIcon = nil
	--self.ImageUnderline = nil
	--self.TabHorItem = nil
	--self.TextName = nil
	--self.ToggleButtonItem = nil
	--self.AnimSelect = nil
	--self.AnimSelect_Short = nil
	--self.AnimToLong = nil
	--self.AnimToShort = nil
	--self.AnimUnSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommPageTabHorTeamView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommPageTabHorTeamView:OnInit()
	if LastSelected == self then
		LastSelected = nil
	end

	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImageIcon) },
		{ "Num", UIBinderSetTextFormat.New(self, self.TextNum, "%d") },
		--{ "RedDotVisible", UIBinderSetIsVisible.New(self, self.Comm_RedDot_UIBP) },
		{ "TextVisible", UIBinderSetIsVisible.New(self, self.TextName) },
		{ "NumVisible", UIBinderSetIsVisible.New(self, self.TextNum) },
		{ "NumVisible", UIBinderSetIsVisible.New(self, self.SizeBoxNum) },
		{ "TextVisible", UIBinderSetIsVisible.New(self, self.ImageUnderline) },
	}
end

function CommPageTabHorTeamView:OnDestroy()

end

function CommPageTabHorTeamView:OnShow()

end

function CommPageTabHorTeamView:OnHide()

end

function CommPageTabHorTeamView:OnRegisterUIEvent()

end

function CommPageTabHorTeamView:OnRegisterGameEvent()

end

function CommPageTabHorTeamView:OnRegisterBinder()
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

function CommPageTabHorTeamView:OnSelectChanged(IsSelected)
	local Opacity = IsSelected and 1 or 0.5
	self.TabHorItem:SetRenderOpacity(Opacity)

	if IsSelected == true then

		if self.AnimSelect ~= nil then
			if nil ~= LastSelected then
				LastSelected:StopAnimation(LastSelected.AnimSelect_Short)
				LastSelected:PlayAnimation(LastSelected.AnimUnSelect)
			end
			self:PlayAnimation(self.AnimSelect_Short)
			LastSelected = self
		end
	end
end

return CommPageTabHorTeamView