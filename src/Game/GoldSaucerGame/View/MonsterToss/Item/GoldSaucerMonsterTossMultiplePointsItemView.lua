---
--- Author: Administrator
--- DateTime: 2024-02-19 15:05
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class GoldSaucerMonsterTossMultiplePointsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextMagnification1 UFTextBlock
---@field TextMagnification2 UFTextBlock
---@field TextScore1 UFTextBlock
---@field TextScore2 UFTextBlock
---@field AnimScoreMultiple2 UWidgetAnimation
---@field AnimScoreMultiple3 UWidgetAnimation
---@field AnimScoreMultiple5 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerMonsterTossMultiplePointsItemView = LuaClass(UIView, true)

function GoldSaucerMonsterTossMultiplePointsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextMagnification1 = nil
	--self.TextMagnification2 = nil
	--self.TextScore1 = nil
	--self.TextScore2 = nil
	--self.AnimScoreMultiple2 = nil
	--self.AnimScoreMultiple3 = nil
	--self.AnimScoreMultiple5 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerMonsterTossMultiplePointsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerMonsterTossMultiplePointsItemView:OnInit()
	self.Binders = {
		{"TextScore1Text", UIBinderSetText.New(self, self.TextMagnification1)},
		{"TextScore1Text", UIBinderSetText.New(self, self.TextMagnification2)},

		{"bTextScore1TipVisible", UIBinderSetIsVisible.New(self, self.TextScore1)},
		{"bTextScore1TipVisible", UIBinderSetIsVisible.New(self, self.TextMagnification1)},
		
		{"bTextScore2TipVisible", UIBinderSetIsVisible.New(self, self.TextScore2)},
		{"bTextScore2TipVisible", UIBinderSetIsVisible.New(self, self.TextMagnification2)},
	}
end

function GoldSaucerMonsterTossMultiplePointsItemView:OnDestroy()

end

function GoldSaucerMonsterTossMultiplePointsItemView:OnShow()
	local LSTR = _G.LSTR
	self.TextScore1:SetText(LSTR(270049)) -- 分球!
	self.TextScore2:SetText(LSTR(270049)) -- 分球!

end

function GoldSaucerMonsterTossMultiplePointsItemView:OnHide()

end

function GoldSaucerMonsterTossMultiplePointsItemView:OnRegisterUIEvent()

end

function GoldSaucerMonsterTossMultiplePointsItemView:OnRegisterGameEvent()

end

function GoldSaucerMonsterTossMultiplePointsItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end
	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end
	self:RegisterBinders(ViewModel, self.Binders)
end

return GoldSaucerMonsterTossMultiplePointsItemView