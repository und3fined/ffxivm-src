---
--- Author: Administrator
--- DateTime: 2024-02-05 09:31
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class PhotoRoleSetting02ItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnInfo UFButton
---@field TextContent UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PhotoRoleSetting02ItemView = LuaClass(UIView, true)

function PhotoRoleSetting02ItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnInfo = nil
	--self.TextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PhotoRoleSetting02ItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PhotoRoleSetting02ItemView:OnInit()
	self.Binder = 
	{
		{ "IsOpen", 			UIBinderSetIsChecked.New(self, self.ToggleButtonCheck) },
		{ "Name", 				UIBinderSetText.New(self, self.TextContent) },
		{ "IsShowTips", 		UIBinderSetIsVisible.New(self, self.BtnInfo) },
	}
end

function PhotoRoleSetting02ItemView:OnDestroy()

end

function PhotoRoleSetting02ItemView:OnShow()

end

function PhotoRoleSetting02ItemView:OnHide()

end

function PhotoRoleSetting02ItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleButtonCheck, self.OnTogCheck)
end

function PhotoRoleSetting02ItemView:OnRegisterGameEvent()

end

function PhotoRoleSetting02ItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM

	self:RegisterBinders(VM, 				self.Binder)
end

function PhotoRoleSetting02ItemView:OnTogCheck(Tog, Stat)
	-- local IsChecked = UIUtil.IsToggleButtonChecked(Stat)
	local IsChecked = not self.ViewModel.IsOpen
	self.ViewModel:SetIsOpen(IsChecked)
end

return PhotoRoleSetting02ItemView