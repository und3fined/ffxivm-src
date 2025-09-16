local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class MailSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommSlot CommBackpackSlotView
---@field PanelCheck UFCanvasPanel
---@field AnimCheck UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MailSlotItemView = LuaClass(UIView, true)

function MailSlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommSlot = nil
	--self.PanelCheck = nil
	--self.AnimCheck = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MailSlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MailSlotItemView:OnInit()
	self.Binders = {
		{ "IsGetEmailAttach", UIBinderValueChangedCallback.New(self, nil, self.PanelCheckChanged) },
	}
end

function MailSlotItemView:PanelCheckChanged()
	if nil ~= self.ViewModel then 
		local IsShow = self.ViewModel.IsGetEmailAttach
		UIUtil.SetIsVisible(self.PanelCheck, IsShow)
		if IsShow then
			self:PlayAnimation(self.AnimCheck)
		end
	end
end


function MailSlotItemView:OnDestroy()

end

function MailSlotItemView:OnShow()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end
end

function MailSlotItemView:OnHide()

end

function MailSlotItemView:OnRegisterUIEvent()

end

function MailSlotItemView:OnRegisterGameEvent()

end

function MailSlotItemView:OnRegisterBinder()
	if nil == self.Params or  nil == self.Params.Data then
		return
	end
	local ViewModel = self.Params.Data

	self.ViewModel = ViewModel
	self:RegisterBinders(self.ViewModel, self.Binders)
end

return MailSlotItemView