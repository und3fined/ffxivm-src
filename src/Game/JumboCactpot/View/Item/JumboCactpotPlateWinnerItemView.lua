---
--- Author: Administrator
--- DateTime: 2023-09-18 09:33
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class JumboCactpotPlateWinnerItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextNumber URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JumboCactpotPlateWinnerItemView = LuaClass(UIView, true)

function JumboCactpotPlateWinnerItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextNumber = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JumboCactpotPlateWinnerItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JumboCactpotPlateWinnerItemView:OnInit()
	self.Binders = {
		{ "BoughtNum", UIBinderSetText.New(self, self.RichTextNumber)},
	}
end

function JumboCactpotPlateWinnerItemView:OnDestroy()

end

function JumboCactpotPlateWinnerItemView:OnShow()

end

function JumboCactpotPlateWinnerItemView:OnHide()

end

function JumboCactpotPlateWinnerItemView:OnRegisterUIEvent()

end

function JumboCactpotPlateWinnerItemView:OnRegisterGameEvent()

end

function JumboCactpotPlateWinnerItemView:OnRegisterBinder()
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

return JumboCactpotPlateWinnerItemView