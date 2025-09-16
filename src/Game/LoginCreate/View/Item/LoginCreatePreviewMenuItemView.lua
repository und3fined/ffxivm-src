
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class LoginCreatePreviewMenuItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIconCheck UFImage
---@field ImgIconUncheck UFImage
---@field ToggleBtnPreview UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreatePreviewMenuItemView = LuaClass(UIView, true)

function LoginCreatePreviewMenuItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIconCheck = nil
	--self.ImgIconUncheck = nil
	--self.ToggleBtnPreview = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreatePreviewMenuItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreatePreviewMenuItemView:OnInit()

end

function LoginCreatePreviewMenuItemView:OnDestroy()

end

function LoginCreatePreviewMenuItemView:OnShow()
	if self.Params and self.Params.Data then
		self.Cfg = self.Params.Data
		if not self.Cfg then
			return
		end

		UIUtil.ImageSetBrushFromAssetPath(self.ImgIconUncheck, self.Cfg.Icon)
		UIUtil.ImageSetBrushFromAssetPath(self.ImgIconCheck, self.Cfg.IconSelect)
	end
end

function LoginCreatePreviewMenuItemView:OnHide()

end

function LoginCreatePreviewMenuItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnPreview, self.OnItemToggleBtnClick)
end

function LoginCreatePreviewMenuItemView:OnRegisterGameEvent()

end

function LoginCreatePreviewMenuItemView:OnRegisterBinder()

end

function LoginCreatePreviewMenuItemView:OnSelectChanged(IsSelected)
	if IsSelected then
		self.ToggleBtnPreview:SetCheckedState(_G.UE.EToggleButtonState.Checked , false)
		self:PlayAnimation(self.AnimChecked)
	else
		-- self:StopAnimation(self.AnimChecked)
		
		self:StopAllAnimations()
		self.ToggleBtnPreview:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)
		self:PlayAnimation(self.AnimUnchecked)
	end
end

function LoginCreatePreviewMenuItemView:OnItemToggleBtnClick(ToggleButton, ButtonState)
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

return LoginCreatePreviewMenuItemView