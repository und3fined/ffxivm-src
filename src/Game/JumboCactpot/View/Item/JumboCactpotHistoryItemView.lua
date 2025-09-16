---
--- Author: Administrator
--- DateTime: 2023-09-18 09:33
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class JumboCactpotHistoryItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextName URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JumboCactpotHistoryItemView = LuaClass(UIView, true)

function JumboCactpotHistoryItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JumboCactpotHistoryItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JumboCactpotHistoryItemView:OnInit()
	self.Binders = {
        { "Nickname", UIBinderSetText.New(self, self.RichTextName)},
	}
end

function JumboCactpotHistoryItemView:OnDestroy()

end

function JumboCactpotHistoryItemView:OnShow()

end

function JumboCactpotHistoryItemView:OnHide()

end

function JumboCactpotHistoryItemView:OnRegisterUIEvent()

end

function JumboCactpotHistoryItemView:OnRegisterGameEvent()

end

function JumboCactpotHistoryItemView:OnRegisterBinder()
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

return JumboCactpotHistoryItemView