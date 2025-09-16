---
--- Author: enqingchen
--- DateTime: 2022-01-18 14:05
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CommBackBtnView : CommBtnBaseView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Button UFButton
---@field AnimIn UWidgetAnimation
---@field AnimPressed UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommBackBtnView = LuaClass(UIView, true)

function CommBackBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Button = nil
	--self.AnimIn = nil
	--self.AnimPressed = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommBackBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommBackBtnView:OnInit()

end

function CommBackBtnView:OnDestroy()

end

function CommBackBtnView:OnShow()

end

function CommBackBtnView:OnHide()

end

function CommBackBtnView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Button, self.OnBackClick)
end

function CommBackBtnView:OnRegisterGameEvent()

end

function CommBackBtnView:OnRegisterBinder()

end

function CommBackBtnView:AddBackClick(View, Callback)
	self.CallbackView = View
	self.Callback = Callback
end

function CommBackBtnView:OnBackClick()
	if self.CallbackView ~= nil and self.Callback ~= nil then
		self.Callback(self.CallbackView)
	end

	if self.AnimPressed ~= nil then
		self:PlayAnimation(self.AnimPressed)
	end
end

return CommBackBtnView