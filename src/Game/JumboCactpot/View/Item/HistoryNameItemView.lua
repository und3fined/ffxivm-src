---
--- Author: Administrator
--- DateTime: 2023-09-18 09:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class HistoryNameItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextName URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HistoryNameItemView = LuaClass(UIView, true)

function HistoryNameItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HistoryNameItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HistoryNameItemView:OnInit()
	self.Binders = {
		{ "Nickname", UIBinderSetText.New(self, self.RichTextName)},

	}
end

function HistoryNameItemView:OnDestroy()

end

function HistoryNameItemView:OnShow()

end

function HistoryNameItemView:OnHide()

end

function HistoryNameItemView:OnRegisterUIEvent()

end

function HistoryNameItemView:OnRegisterGameEvent()

end

function HistoryNameItemView:OnRegisterBinder()
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

return HistoryNameItemView