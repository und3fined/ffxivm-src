---
--- Author: Administrator
--- DateTime: 2023-09-18 09:33
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class JumboCactpotRewardBonusItem02View : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextBuff URichTextBox
---@field TextNO1 UFTextBlock
---@field TextNumber UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JumboCactpotRewardBonusItem02View = LuaClass(UIView, true)

function JumboCactpotRewardBonusItem02View:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextBuff = nil
	--self.TextNO1 = nil
	--self.TextNumber = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JumboCactpotRewardBonusItem02View:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JumboCactpotRewardBonusItem02View:OnInit()
	self.Binders = {
		{ "IncreaseReward", UIBinderSetText.New(self, self.RichTextBuff)},
		{ "Level", UIBinderSetText.New(self, self.TextNO1)},
		{ "BaseReward", UIBinderSetText.New(self, self.TextNumber)},
	}
end

function JumboCactpotRewardBonusItem02View:OnDestroy()

end

function JumboCactpotRewardBonusItem02View:OnShow()

end

function JumboCactpotRewardBonusItem02View:OnHide()

end

function JumboCactpotRewardBonusItem02View:OnRegisterUIEvent()

end

function JumboCactpotRewardBonusItem02View:OnRegisterGameEvent()

end

function JumboCactpotRewardBonusItem02View:OnRegisterBinder()
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

return JumboCactpotRewardBonusItem02View