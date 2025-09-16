---
--- Author: Administrator
--- DateTime: 2023-12-19 09:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

---@class JumboCactpotRewardNumberItemUIView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Text01 UFTextBlock
---@field Text02 UFTextBlock
---@field Text03 UFTextBlock
---@field Text04 UFTextBlock
---@field Text05 UFTextBlock
---@field TextRewardBuff UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JumboCactpotRewardNumberItemUIView = LuaClass(UIView, true)

function JumboCactpotRewardNumberItemUIView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Text01 = nil
	--self.Text02 = nil
	--self.Text03 = nil
	--self.Text04 = nil
	--self.Text05 = nil
	--self.TextRewardBuff = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JumboCactpotRewardNumberItemUIView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JumboCactpotRewardNumberItemUIView:OnInit()
	self.Binders = {
		{ "bBuffVisible", UIBinderSetIsVisible.New(self, self.TextRewardBuff)},

		{ "RewardBuff01", UIBinderSetText.New(self, self.Text01)},
		{ "RewardBuff02", UIBinderSetText.New(self, self.Text02)},
		{ "RewardBuff03", UIBinderSetText.New(self, self.Text03)},
		{ "RewardBuff04", UIBinderSetText.New(self, self.Text04)},
		{ "RewardBuff05", UIBinderSetText.New(self, self.Text05)},

		{ "TextColor", UIBinderSetColorAndOpacityHex.New(self, self.Text01)},
		{ "TextColor", UIBinderSetColorAndOpacityHex.New(self, self.Text02)},
		{ "TextColor", UIBinderSetColorAndOpacityHex.New(self, self.Text03)},
		{ "TextColor", UIBinderSetColorAndOpacityHex.New(self, self.Text04)},
		{ "TextColor", UIBinderSetColorAndOpacityHex.New(self, self.Text05)},
	}
end

function JumboCactpotRewardNumberItemUIView:OnDestroy()

end

function JumboCactpotRewardNumberItemUIView:OnShow()
	self.TextRewardBuff:SetText(_G.LSTR(240082))
end

function JumboCactpotRewardNumberItemUIView:OnHide()

end

function JumboCactpotRewardNumberItemUIView:OnRegisterUIEvent()

end

function JumboCactpotRewardNumberItemUIView:OnRegisterGameEvent()

end

function JumboCactpotRewardNumberItemUIView:OnRegisterBinder()
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

return JumboCactpotRewardNumberItemUIView