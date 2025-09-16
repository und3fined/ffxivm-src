---
--- Author: Administrator
--- DateTime: 2023-09-18 09:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class JumboCactpotBoughtItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FCanvasPanel_17 UFCanvasPanel
---@field TextNumber UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JumboCactpotBoughtItemView = LuaClass(UIView, true)

function JumboCactpotBoughtItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FCanvasPanel_17 = nil
	--self.TextNumber = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JumboCactpotBoughtItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JumboCactpotBoughtItemView:OnInit()
	self.Binders = {
		{ "BoughtNum", UIBinderSetText.New(self, self.TextNumber)},
	}
end

function JumboCactpotBoughtItemView:OnDestroy()

end

function JumboCactpotBoughtItemView:OnShow()

end

function JumboCactpotBoughtItemView:OnHide()

end

function JumboCactpotBoughtItemView:OnRegisterUIEvent()

end

function JumboCactpotBoughtItemView:OnRegisterGameEvent()

end

function JumboCactpotBoughtItemView:OnRegisterBinder()
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

return JumboCactpotBoughtItemView