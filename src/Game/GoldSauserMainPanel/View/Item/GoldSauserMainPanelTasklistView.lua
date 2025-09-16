---
--- Author: Administrator
--- DateTime: 2024-01-08 20:42
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require(("Binder/UIBinderSetText"))
local UIBinderSetIsVisible = require(("Binder/UIBinderSetIsVisible"))
local UIBinderSetActiveWidgetIndex = require("Binder/UIBinderSetActiveWidgetIndex")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class GoldSauserMainPanelTasklistView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FWidgetSwitcher_0 UFWidgetSwitcher
---@field TextInterval UFTextBlock
---@field TextQuantity UFTextBlock
---@field TextTitle UFTextBlock
---@field TextTotal UFTextBlock
---@field AnimRefresh UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserMainPanelTasklistView = LuaClass(UIView, true)

function GoldSauserMainPanelTasklistView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FWidgetSwitcher_0 = nil
	--self.TextInterval = nil
	--self.TextQuantity = nil
	--self.TextTitle = nil
	--self.TextTotal = nil
	--self.AnimRefresh = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelTasklistView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelTasklistView:OnInit()

end

function GoldSauserMainPanelTasklistView:OnDestroy()

end

function GoldSauserMainPanelTasklistView:OnShow()

end

function GoldSauserMainPanelTasklistView:OnHide()

end

function GoldSauserMainPanelTasklistView:OnRegisterUIEvent()
	
end

function GoldSauserMainPanelTasklistView:OnRegisterGameEvent()

end

function GoldSauserMainPanelTasklistView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	local Binders = {
		{ "DescriptionStr", UIBinderSetText.New(self, self.TextTitle) },
		{ "CompletePercentText", UIBinderSetText.New(self, self.TextQuantity) },
		--{ "MaxNum", UIBinderSetText.New(self, self.TextTotal) },
		{ "RightWidgetIndex", 	UIBinderSetActiveWidgetIndex.New(self, self.FWidgetSwitcher_0) },
		{ "ProcessVisible", 	UIBinderSetIsVisible.New(self, self.FWidgetSwitcher_0) },
		{ "TextColorHex", 	UIBinderSetColorAndOpacityHex.New(self, self.TextTitle) },
		{ "bNeedRefresh", 	UIBinderValueChangedCallback.New(self, nil, self.OnPlayAnimRefresh) },
	}

	self:RegisterBinders(VM, Binders)
end

function GoldSauserMainPanelTasklistView:OnPlayAnimRefresh(NewValue)
	if NewValue then
		self:PlayAnimation(self.AnimRefresh)
	end
end

return GoldSauserMainPanelTasklistView