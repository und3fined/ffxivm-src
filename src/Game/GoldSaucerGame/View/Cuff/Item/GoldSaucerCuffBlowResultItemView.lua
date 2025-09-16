---
--- Author: Administrator
--- DateTime: 2024-02-04 11:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class GoldSaucerCuffBlowResultItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelExcellent UFCanvasPanel
---@field PanelFail UFCanvasPanel
---@field PanelPerfect UFCanvasPanel
---@field PanelperfectCombo UFCanvasPanel
---@field TextExcellent UFTextBlock
---@field TextFail UFTextBlock
---@field TextPerfect UFTextBlock
---@field TextPerfect1 UFTextBlock
---@field TextQuantity UFTextBlock
---@field TextX UFTextBlock
---@field AnimExcellent UWidgetAnimation
---@field AnimFail UWidgetAnimation
---@field AnimPerfect UWidgetAnimation
---@field AnimperfectCombo UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerCuffBlowResultItemView = LuaClass(UIView, true)

function GoldSaucerCuffBlowResultItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelExcellent = nil
	--self.PanelFail = nil
	--self.PanelPerfect = nil
	--self.PanelperfectCombo = nil
	--self.TextExcellent = nil
	--self.TextFail = nil
	--self.TextPerfect = nil
	--self.TextPerfect1 = nil
	--self.TextQuantity = nil
	--self.TextX = nil
	--self.AnimExcellent = nil
	--self.AnimFail = nil
	--self.AnimPerfect = nil
	--self.AnimperfectCombo = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerCuffBlowResultItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerCuffBlowResultItemView:OnInit()
	self.Binders = {
		{"bPerfectVisible", UIBinderSetIsVisible.New(self, self.PanelPerfect)},
		{"bPerfectComboVisible", UIBinderSetIsVisible.New(self, self.PanelperfectCombo)},
		{"bExcellentVisible", UIBinderSetIsVisible.New(self, self.PanelExcellent)},
		{"bFailVisible", UIBinderSetIsVisible.New(self, self.PanelFail)},
		{"bComboVisible", UIBinderSetIsVisible.New(self, self.TextQuantity)},
		{"ComboNum", UIBinderSetText.New(self, self.TextQuantity)},
	}
end

function GoldSaucerCuffBlowResultItemView:OnDestroy()

end

function GoldSaucerCuffBlowResultItemView:OnShow()
	local LSTR = _G.LSTR
	self.TextPerfect:SetText(LSTR(250018)) 		-- 完美
	self.TextPerfect1:SetText(LSTR(250018))		-- 完美
	self.TextExcellent:SetText(LSTR(250019))  		-- 优秀
	self.TextFail:SetText(LSTR(250020))	--失误
	self.TextX:SetText("x")	--连击×

end

function GoldSaucerCuffBlowResultItemView:OnHide()

end

function GoldSaucerCuffBlowResultItemView:OnRegisterUIEvent()

end

function GoldSaucerCuffBlowResultItemView:OnRegisterGameEvent()

end

function GoldSaucerCuffBlowResultItemView:OnRegisterBinder()
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

return GoldSaucerCuffBlowResultItemView