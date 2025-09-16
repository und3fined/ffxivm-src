---
--- Author: chriswang
--- DateTime: 2022-09-23 14:11
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TimerMgr = _G.TimerMgr

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
---@class MiniCactpotPayItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Check UFCanvasPanel
---@field Select UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MiniCactpotPayItemView = LuaClass(UIView, true)

function MiniCactpotPayItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Check = nil
	--self.Select = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MiniCactpotPayItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MiniCactpotPayItemView:OnInit()

end

function MiniCactpotPayItemView:OnDestroy()

end

function MiniCactpotPayItemView:OnShow()

end

function MiniCactpotPayItemView:OnHide()

end

function MiniCactpotPayItemView:OnRegisterUIEvent()

end

function MiniCactpotPayItemView:OnRegisterGameEvent()

end

function MiniCactpotPayItemView:OnRegisterBinder()
	self.ViewModel = self.Params.Data
	local Binders = {
		{ "Sum", UIBinderSetText.New(self, self.FText_SumValue) },
		{ "AwardNum", UIBinderSetText.New(self, self.FText_Reward) },

		{ "IsChecked", UIBinderSetIsVisible.New(self, self.Check) },
		{ "IsSelected", UIBinderSetIsVisible.New(self, self.Select) },
		{ "IsSelected", UIBinderValueChangedCallback.New(self, nil, self.PlayAnimCallBack) },

	}

	self:RegisterBinders(self.ViewModel, Binders)
end

function MiniCactpotPayItemView:PlayAnimCallBack(IsSelected)
	if IsSelected then
		self:PlayAnimation(self.Animselect, 0, 1)
		local function AnimLoop()
			self:PlayAnimation(self.Animselectloop, 0, 0)
		end
		self:RegisterTimer(AnimLoop, 0.67, 0, 1)
	-- else
	-- 	self:PlayAnimation(self.Animselectloop, 0, 1)
	end
end

return MiniCactpotPayItemView