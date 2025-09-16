---
--- Author: Administrator
--- DateTime: 2023-09-25 16:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class JumboCactpotTipsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JumboCactpotTipsItemView = LuaClass(UIView, true)

function JumboCactpotTipsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JumboCactpotTipsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JumboCactpotTipsItemView:OnInit()
	self.Binders = {
		{ "TipContent", UIBinderSetText.New(self, self.TextName)},
	}
end

function JumboCactpotTipsItemView:OnDestroy()

end

function JumboCactpotTipsItemView:OnShow()

end

function JumboCactpotTipsItemView:OnHide()

end

function JumboCactpotTipsItemView:OnRegisterUIEvent()

end

function JumboCactpotTipsItemView:OnRegisterGameEvent()

end

function JumboCactpotTipsItemView:OnRegisterBinder()
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

return JumboCactpotTipsItemView