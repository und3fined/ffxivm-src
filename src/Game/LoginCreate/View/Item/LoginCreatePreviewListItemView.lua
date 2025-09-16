
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class LoginCreatePreviewListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextCheck UFTextBlock
---@field TextUncheck UFTextBlock
---@field ToggleBtnItem UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreatePreviewListItemView = LuaClass(UIView, true)

function LoginCreatePreviewListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextCheck = nil
	--self.TextUncheck = nil
	--self.ToggleBtnItem = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreatePreviewListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreatePreviewListItemView:OnInit()

end

function LoginCreatePreviewListItemView:OnDestroy()

end

function LoginCreatePreviewListItemView:OnShow()
	if self.Params and self.Params.Data then
		--Cfg可能是职业演示套装、种族演示套装，也可能是
		local Name = self.Params.Data
		self.TextCheck:SetText(Name)
		self.TextUncheck:SetText(Name)
	end
end

function LoginCreatePreviewListItemView:OnHide()

end

function LoginCreatePreviewListItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnItem, self.OnItemToggleBtnClick)
end

function LoginCreatePreviewListItemView:OnRegisterGameEvent()

end

function LoginCreatePreviewListItemView:OnRegisterBinder()

end

function LoginCreatePreviewListItemView:OnSelectChanged(IsSelected)
	if IsSelected then
		self.ToggleBtnItem:SetCheckedState(_G.UE.EToggleButtonState.Checked , false)
		self:PlayAnimation(self.AnimChecked)
	else
		-- self:StopAnimation(self.AnimChecked)
		self:StopAllAnimations()
		self.ToggleBtnItem:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)
		self:PlayAnimation(self.AnimUnchecked)
	end
end

function LoginCreatePreviewListItemView:OnItemToggleBtnClick(ToggleButton, ButtonState)
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end

	Adapter:OnItemClicked(self, Params.Index)
end

return LoginCreatePreviewListItemView