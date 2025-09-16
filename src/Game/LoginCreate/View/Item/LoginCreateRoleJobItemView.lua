---
--- Author: chriswang
--- DateTime: 2023-10-20 19:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local LoginRoleProfVM = require("Game/LoginRole/LoginRoleProfVM")

---@class LoginCreateRoleJobItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIconCheck UFImage
---@field ImgIconUncheck UFImage
---@field ImgTabCheck UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateRoleJobItemView = LuaClass(UIView, true)

function LoginCreateRoleJobItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIconCheck = nil
	--self.ImgIconUncheck = nil
	--self.ImgTabCheck = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateRoleJobItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateRoleJobItemView:OnInit()

end

function LoginCreateRoleJobItemView:OnDestroy()

end

function LoginCreateRoleJobItemView:OnShow()
	if self.Params and self.Params.Data then
		local Cfg = self.Params.Data
		UIUtil.ImageSetBrushFromAssetPath(self.ImgIconCheck, Cfg.SimpleIcon)
		UIUtil.ImageSetBrushFromAssetPath(self.ImgIconUncheck, Cfg.SimpleIcon)
	end
end

function LoginCreateRoleJobItemView:OnHide()

end

function LoginCreateRoleJobItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnJob, self.OnJobBtnClick)
end

function LoginCreateRoleJobItemView:OnRegisterGameEvent()

end

function LoginCreateRoleJobItemView:OnRegisterBinder()

end

function LoginCreateRoleJobItemView:OnSelectChanged(IsSelected)
	self:StopAllAnimations()
	if IsSelected then
		self.ToggleBtnJob:SetCheckedState(_G.UE.EToggleButtonState.Checked , false)
		self:PlayAnimation(self.AnimChecked)
	else
		self.ToggleBtnJob:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)
		self:PlayAnimation(self.AnimUnchecked)
	end
end

function LoginCreateRoleJobItemView:UpdateUI(ProfCfg)
	if ProfCfg then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgJob, ProfCfg.SimpleIcon)
		self.ProfCfg = ProfCfg
	end
end

function LoginCreateRoleJobItemView:OnJobBtnClick(ToggleButton, ButtonState)
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end

	Adapter:OnItemClicked(self, Params.Index)

	-- if self.ProfCfg then
	-- 	FLOG_INFO("LoginRoleJobItemView:OnJobBtnClick %s", self.ProfCfg.ProfName)
	-- 	LoginRoleProfVM:ClearSelectProf()
	-- 	LoginRoleProfVM:OnSelectProf(self.ProfCfg)
	-- 	self.ToggleBtnJob:SetCheckedState(_G.UE.EToggleButtonState.Checked , false)
	-- end
end

return LoginCreateRoleJobItemView